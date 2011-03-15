
-module(mapred).
-export([
	 mapreduce/5,
	 mapper/2,
	 reducer/2
	]).


% mapper function.
% waits for map messages and performs the mapper function on it
% returns a result of type {Key, Value} to a mapper
mapper(Reducer_pids, Mapfunc)->
    receive 
	{map, Input} ->
	    io:format("~n Mapper [~p] on job ~p",[self(),Input]),
	    {K, V} = Mapfunc(Input),
	    io:format("~n Result from [~p] is {~p, ~p}",[self(), K, V]),
	    Rand_reducer = lists:nth((Input rem len(Reducer_pids))+1 ,
				     Reducer_pids),
	    Rand_reducer ! {reduce, {K, V}},
	    mapper(Reducer_pids, Mapfunc);
	{die,_} ->
	    io:format("~n Mapper ~p, Exiting ... ",[self()])
    end. 

    
reducer(Acc , Redfunc)->    
    receive 
	{reduce, Value} ->
	    io:format("~n Reducer ~p reducing ~p",[self(),Value]),
	    Result = Redfunc(Value),
	    reducer( [Result|Acc], Redfunc);
	{harvest, Harvestor_pid} ->		    		    
	    io:format("~nReducer ~p sending result for harvest~p",
		      [self(),Acc]),
	    Harvestor_pid ! {result, Acc },
	    io:format("~nReducer ~p Exiting... ",[self()])
    end.
   

harvest(Pid_reducer) ->
    Pid_reducer ! {harvest, self()},
    receive
	{result, Result} ->
	    Result
    end.
    
mapreduce(R_count, Rfunc, M_count, Mfunc, Input) -> 
    
    % Spawn off R_count number of reducer functions    
    R_pids = lists:map(fun(_)->
			      spawn(mapred, reducer, [[], Rfunc])
		      end,
		      lists:seq(1, R_count)),
    
    io:format("~n Reducers spawned : ~p",[R_count]),

    % Spawn off M_count number of mapper functions
    M_pids = lists:map(fun(_)->
			      spawn(mapred, mapper, [R_pids, Mfunc])
		      end,
		      lists:seq(1, M_count)),
    io:format("~n Mappers spawned : ~p",[M_count]),
    
    % Send Inputs to the mappers for processing.
    process(Input, M_pids),
    
    timer:sleep(2000),
    
    % Get results from the reducers.	    
    io:format("~nSending out harvestors"),
    Result = lists:map(fun(X) -> harvest(X) end, R_pids),
    io:format("~nResult : ~n"),
    lists:sort(lists:flatten(Result))
    .
    
    
process(Input, R_pids)->
    process(Input, R_pids, []).

process([X|[]], [H|_], _)->
    H ! {map, X};
process(Input, [], Acc)->
    process(Input, lists:reverse(Acc), []);
process([H|T], [H_pids|R_pids], R_pids_acc) ->
    H_pids ! {map, H},
    process(T, R_pids, [H_pids|R_pids_acc]).
    
len([])->
    0;
len([_|T]) ->
    1+len(T).


killall([]) ->
    io:format("~n All processes sent die messages");   
killall([H|T]) ->
    H ! {die, -1},
    killall(T).

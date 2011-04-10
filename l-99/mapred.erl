
-module(mapred).
-export([
	 mapreduce/5,
	 mapper/2,
	 reducer/2,
	 addkeyvalue/2
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
	    Rand_reducer = lists:nth(erlang:phash(K, len(Reducer_pids)) ,
				     Reducer_pids),
	    Rand_reducer ! {reduce, {K, V}},
	    mapper(Reducer_pids, Mapfunc);
	{die,_} ->
	    io:format("~n Mapper ~p, Exiting ... ",[self()])
    end. 

% reducer function
% waits for reduce message. 
%    check the acc if messages with same key are present
%                  if yes add value to its list
%                  else add new key, value pair
% wait for harvest message
%    apply Redfunc on each key,value pair in the acc
%    send the results to a harvestor
reducer(Acc , Redfunc)->    
    receive 
	{reduce, {K,V}} ->
	    io:format("~n Reducer ~p reducing ~p",[self(),{K,V}]),	    	
	    reducer( addkeyvalue({K,V}, Acc) , Redfunc);
	{harvest, Harvestor_pid} ->		    		   
	    Reduced_result = lists:map(fun(X)-> Redfunc(X) end, Acc),
	    io:format("~n Reducer ~p sending result for harvest~p",
		      [self(),Reduced_result]),
	    Harvestor_pid ! {result, Reduced_result },
	    io:format("~n Reducer ~p Exiting... ",[self()])
    end.
  
% Input is of type {Key, Value}
% Search List for item with same Key
%         if found add Value to the Value list in the pair
%         else add {Key, Value} to the list			
addkeyvalue(Input, List)->
    addkeyvalue(Input, List, []).

addkeyvalue({Key,V}, [], Acc)->
    [{Key,V}|Acc];
addkeyvalue({Key,V}, [{Key,List}|T], Acc)->
    lists:append([{Key, [V|List]} | Acc],T);
addkeyvalue({Key,V}, [H|T], Acc) ->
    addkeyvalue({Key, V}, T, [H|Acc]).                
    

% We use a harvestor to finally return the results from the reducer
% this is probably the worst part of this design
% We wait for 2000 ms to ensure that the jobs are completed
% then we send out one harvestor each for every reducer which 
% collects the results from each reducer
harvest(Pid_reducer) ->
    Pid_reducer ! {harvest, self()},
    receive
	{result, Result} ->
	    Result
    end.
    

% main func
% 1. Spawn reducers
% 2. Spawn mappers
% 3. process sends out the input to each mapper
% 4. put main on sleep to allow computation to complete
% 5. Send out harvestors to get results from the reducers
% 6. Flatten the results list and sort it
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
    
   
% Send an Input to appropriate mapper processes
process(Input, M_pids)->
    process(Input, M_pids, []).

process([X|[]], [H|_], _)->
    H ! {map, X};
process(Input, [], Acc)->
    process(Input, lists:reverse(Acc), []);
process([H|T], [H_pids|R_pids], R_pids_acc) ->
    H_pids ! {map, H},
    process(T, R_pids, [H_pids|R_pids_acc]).
    
% length of a list
len([])->
    0;
len([_|T]) ->
    1+len(T).

% Not in use.
% sends a kill message to worker process
killall([]) ->
    io:format("~n All processes sent die messages");   
killall([H|T]) ->
    H ! {die, -1},
    killall(T).

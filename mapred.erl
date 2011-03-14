
-module(mapred).
-export([
	 mapreduce/5,
	 mapper/2,
	 reducer/2
	]).



mapper(map, Mapfunc)->
    receive 
	{map, Input} ->
	    io:format("~n Mapper [~p] on job ~p",[self(),Input]),
	    {K, V} = Mapfunc(Input),
	    io:format("~n Result from [~p] is {~p, ~p}",[self(), K, V]),
	    mapper(map, Mapfunc)
    end.

    
reducer(reduce, Redfunc)->
    Redfunc.

process(Input, R_pids)->
    process(Input, R_pids, []).

process([X|[]], [H|_], _)->
    H ! {map, X};
process(Input, [], Acc)->
    process(Input, lists:reverse(Acc), []);
process([H|T], [H_pids|R_pids], R_pids_acc) ->
    H_pids ! {map, H},
    process(T, R_pids, [H_pids|R_pids_acc]).

mapreduce(R_count, Rfunc, M_count, Mfunc, Input) -> 
    
    % Spawn off R_count number of reducer functions
    R_pids = lists:map(fun(_)->
			      spawn(mapred, reducer, [reduce, Rfunc])
		      end,
		      lists:seq(1, R_count)),
    
    io:format("~n Reducers spawned : ~p",[R_count]),

    M_pids = lists:map(fun(_)->
			      spawn(mapred, mapper, [map, Mfunc])
		      end,
		      lists:seq(1, M_count)),
    io:format("~n Mappers spawned : ~p",[M_count]),

    process(Input, M_pids).
    

    


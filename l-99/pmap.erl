-module(pmap).
-export([ 
	  mapper/2,
	  fact/1
	]).


mapper(Func, Inputs) ->
    S = self(),
    Pids = lists:map( fun(I) ->
			      spawn(fun() ->
					    parallel_do(Func, I, S) end) end, Inputs),
    gather(Pids).


gather([H|T]) ->
    receive 
	{H, Ret} ->
	    [Ret | gather(T)]
    end;
gather([]) ->
    [].

parallel_do( Func, I, Parent) ->
    Parent ! {self(), Func(I)} . 


fact(0) ->
    0;
fact(1) ->
    1;
fact(L) ->
    fact(L-1) + fact(L-2).

    
    

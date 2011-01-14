% returns a list of factors of the given number N

-module(factors).
-export([factors/1]).

factors(N) ->
    factors(N, []).

factors(1, Acc) ->
    Acc;
factors(N, Acc) ->
    case find_factor(2, N) of
	N ->
	    factors(1, lists:append(Acc,[N]));
	A ->
	    factors(N div A, lists:append(Acc,[A]))
    end.



find_factor(N, N) ->
    N;
find_factor(I, N) ->
    if 
	N rem I =:= 0 ->
	    I;
	true ->
	    find_factor(I+1, N)
    end.
    
    

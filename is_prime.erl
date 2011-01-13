-module(is_prime).
-export([check/1]).

% returns true if the number is prime else returns false
% divide and check by numbers until sqrt of N


check(N) ->
    check(N, 2, erlang:trunc(math:sqrt(N)) + 1).


check(_, Max, Max) ->
    true;
check(N, I, Max) ->
    if 
	N rem I =:= 0 ->
	    {false,I};
	true ->
	    check(N, I+1, Max)
    end.
	

% Sieve of Erastothenes
% Given an N we first start of with a complete list of numbers from 2 to N
% as we proceed we remove numbers which are multiples.
% the numbers which remain are prime.


-module(sieve).
-export([find/1]).

find(N)->
    sieve(2,lists:seq(2,N),[2]).

sieve(_, [], Primes) ->
    lists:reverse(Primes);
sieve(N, List, Primes) ->
    [H|T] = lists:filter(fun(X)->
				 X rem N =/= 0
			 end,
			 List),
    sieve(H, T, [H|Primes]).


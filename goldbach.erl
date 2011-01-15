-module(goldbach).
-export([do/1]).

%% Goldbach's conjecture says that every positive even number greater than 2 is the sum of two prime numbers. Example: 28 = 5 + 23. It is one of the most famous facts in number theory that has not been proved to be correct in the general case. It has been numerically  confirmed up to very large numbers (much larger than we can go with our Prolog system). Write a predicate to find the two prime numbers that sum up to a given even integer.

%% Example:
%% ?- goldbach(28, L).
%% L = [5,23]


do(N) when N < 3 ; N rem 2 =/= 0 ->
    error_not_goldbach_number;
do(N) ->
    attempt(N, list_of_primes:primes(N)).


attempt(N, []) ->
    io:format("~p is an issue, no primes found to sum upto ~p~n",[N,N]);
attempt(N, [H|T]) -> 
    case search( N-H , T ) of
	true ->
	    {H,N-H};
	false ->
	    attempt(N, T)
    end.

search(Val, [])->
    false;
search(Val, [Val|T]) ->
    true;
search(Val, [_|T]) ->
    search(Val, T).



    

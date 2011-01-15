-module(list_of_primes).
-export([naive/1, primes/1, profile/1]).

% given N return the list of primes less than N 

naive(1)->
    [];
naive(N)->
    naive(2, N, []).

naive(N, N, Acc) ->
    lists:reverse([Acc]);
naive(I, N, Acc) ->
    case is_prime:check(I) of
	true ->
	    naive(I+1, N, [I|Acc]);
	false ->
	    naive(I+1, N, Acc)
    end.

primes(1) ->
    [];
primes(N) ->
    primes(2, N, []).

primes(N, N, Acc) ->
    lists:reverse(Acc);
primes(I, N, Acc) ->
%    io:format("~n~nAcc : ~p~n",[Acc]),

%    *****NOTE*****
%    A nifty profiling test shows that good old handwritten code produces 
%    far better performance than list comprehensions

%   VERY WEIRD LOGIC AHEAD: WE FIND THE LIST OF FACTORS AND IF THE LENGTH IS
%   0 WE TAKE THE NUMBER TO BE PRIME :)

%    Primes = [X || X <- Acc , (I rem X) =:= 0],
    Factors = factors(I, Acc),
%    io:format("Checking: ~p Factors: ~p length ~p~n",
%	      [I,Factors,length(Factors)]),
    case length(Factors) =/= 0 of
	false ->
	    primes(I+1, N, [I|Acc]);
	true ->
	    primes(I+1, N, Acc)
    end.
			 
profile(N)->
    statistics(wall_clock),
    Result1 = naive(N),
    {_, Time1} = statistics(wall_clock),
    io:format("Time taken by the naive algo is ~p usecs~n",[1000 * Time1]),
    
    statistics(wall_clock),
    Result2 = primes(N),
    {_, Time2} = statistics(wall_clock),
    io:format("Time taken by the improved algo is ~p usecs~n",[1000 * Time2]),
    ok.


factors(I, List) ->
    factors(I, List, []).

factors(_, [], Acc) ->
    Acc;
factors(I, [H|T], Acc) when I rem H =:= 0 ->
    factors(I, T, [H|Acc]);
factors(I, [H|T], Acc) ->
    factors(I, T, Acc).

    

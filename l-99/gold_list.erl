% P41
% A list of Goldbach compositions.
-module(gold_list).
-export([list/2, list/3]).

%% Given a range of integers by its lower and upper limit, print a list of all even numbers and their Goldbach composition.

%% Example:
%% ?- goldbach_list(9,20).
%% 10 = 3 + 7
%% 12 = 5 + 7
%% 14 = 3 + 11
%% 16 = 3 + 13
%% 18 = 5 + 13
%% 20 = 3 + 17

list(Min, Max) when Min >= Max ->
    [];
list(Min, Max) when Min rem 2 =:= 0 ->
    [ [Min, goldbach:do(Min)] | list(Min+2, Max) ];
list(Min, Max) ->
    list(Min+1, Max).

%% In most cases, if an even number is written as the sum of two prime numbers, one of them is very small. Very rarely, the primes are both bigger than say 50. Try to find out how many such cases there are in the range 2..3000.

%% Example (for a print limit of 50):
%% ?- goldbach_list(1,2000,50).
%% 992 = 73 + 919
%% 1382 = 61 + 1321
%% 1856 = 67 + 1789
%% 1928 = 61 + 1867

list(Min, Max, _) when Min >= Max ->
    [];
list(Min, Max, Cond) when Min rem 2 =:= 0 ->
    Gold = [ {A,B} || {A,B} <- goldbach:do(Min) , A > Cond ],
    if
	length(Gold) > 0 ->	    
	    [ [Min, Gold] | list(Min+2, Max, Cond) ];
	true -> 
	    list(Min+2, Max, Cond)
    end;    
list(Min, Max, Cond) ->
    list(Min+1, Max, Cond).






    
    
    

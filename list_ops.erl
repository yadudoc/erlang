% Map Fold Filter
% Sample on the 3 main list operations
%	1. map			       
%	2. fold					
%       3. filter

-module(list_ops).
-export([do/0]).


do() ->
    A = [1,2,3,4,5,6,7,8,9,10],
    Same = fun(X) ->
		X end,
    Double = fun(X) ->
		     X*2 end,
    Check = fun(X) when X =< 5 ->
		    X end,
    Sum = fun(X, Acc) ->
		  Acc + X end,
    lists:map(Same,A),
    lists:map(Double,A),
    lists:foldl(Sum, 0, A),
    lists:filter(Check,A).
		   

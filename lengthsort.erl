-module(lengthsort).
-export([lsort/1]).

% Lengthsort sorts the list of lists according the length of the individual
% lists.
% First we convert the list [[],[1],[2,2]] to the form [{1,[]},{2,[1]},{3,[2,2]}]
% then we sort the list (here we get the same list )
% now we use an aggregator function which combines the lists within all tuples -
% which has the same number denoting length of the lists.

lsort(List) ->
    lsort(List, []).

lsort([], Acc)->
    aggregate(lists:sort(Acc));
lsort([H|T], Acc) ->	    
    lsort(T, [{length(H)+1,H}|Acc] ).


aggregate([H|T])->
    aggregate(H, T, []).

aggregate(_, [], Acc) ->
    Acc;
aggregate({N,A}, [{N,B}|T], Acc) ->
    aggregate({N,[A|[B]]}, T, Acc);
aggregate({_,A}, [{C,D}|T], Acc) ->
    aggregate({C,D}, T, lists:append(Acc,[A]) ).
	       
    
	  

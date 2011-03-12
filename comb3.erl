% P26 Alternative solution
% return all permutations of N items from a given list

% basic logic goes like this for list [a,b,c,d,e] and N = 3
% step 1: get all permutations of [a,b,c,d,e] : [[a,b,c,d,e],[a,b,c,e,d]...
% step 2: clip permutation to have only 3 length [[a,b,c],[c,d,b]...
% step 3: sort the elements as well as the entire list
% step 4: remove duplicates and your are done 


-module(comb3).
-export([combinations/2]).


combinations(List, Count) -> 
    Combinations = clip(Count,    p(List) ),
    Temp = lists:sort(lists:map(fun(X)->lists:sort(X) end, 
				Combinations) ),
    duplicates(Temp).


duplicates([H|T])->
    removeduplicates(H, T, []).

removeduplicates(Prev, [Prev|Tail], Acc) ->
    removeduplicates(Prev, Tail, Acc);
removeduplicates(Prev, [H|T], Acc) ->
    removeduplicates(H, T, lists:append(Acc,[Prev]));
removeduplicates(Prev, [], Acc) ->
    lists:append(Acc, [Prev]).
    
clip(Count, [H|T]) ->    
    clip(length(H) - Count, [H|T], []).
clip(_, [], Acc) ->
    Acc;
clip(Count, [H|T], Acc) ->
    clip(Count, T, [ lists:nthtail(Count,H) | Acc]).

p([]) ->
    [[]];
p(L) ->
    [ [H|T] || H <- L , T<-p(L--[H]) ].
  
	  

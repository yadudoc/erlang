% P23
% Extract a given number of randomly selected elements from a list

-module(randelems).
-export([	 
	 randsubset/2
	]).

randsubset(List, Count) ->
    randsubset(randlist:rand(List), Count, []).

randsubset([], _, _) ->
    error_list_too_small;
randsubset([H|T], 1, Acc) ->
    [H|Acc];
randsubset([H|T], Count, Acc) ->
    randsubset(T, Count-1, [H|Acc]).
      

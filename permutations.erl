% return all permutations of N items from a given list
-module(permutations).
-export([p/1]).


p([]) ->
    [[]];
p(L) ->
    [ [H|T] || H <- L , T<-p(L--[H]) ].
  
	  

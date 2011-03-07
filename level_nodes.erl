% P62B 
% (*) Collect the nodes at a given level in a list
% A node of a binary tree is at level N if the path from the root to the node 
% has length N-1. The root node is at level 1. Write a predicate atlevel/3 to
% collect all nodes at a given level in a list. 

-module(level_nodes).
-export([
	 at_level/2
	]).

at_level(null, I) when I >= 1 ->
    [];
at_level([X, _, _], 1) ->
    [X];
at_level([_, Left, Right], I) ->
    lists:append( 
      at_level(Left,  I-1),
      at_level(Right, I-1)
     ).


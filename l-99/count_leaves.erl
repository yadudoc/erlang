% P61
% Count the leaves in a binary tree
-module(count_leaves).
-export([
	 leaves/1	 
	]).

leaves([_, null, null]) ->
    1;
leaves([_, Left, Right]) ->
    leaves(Left) + leaves(Right).

	      

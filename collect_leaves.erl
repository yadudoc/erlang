% P62
% Collect the leaves in a binary tree into a list
-module(collect_leaves).
-export([
	 leaves/1	 
	]).

leaves([N, null, null]) ->
    [N];
leaves([_, Left, Right]) ->
    lists:append(leaves(Left),leaves(Right)).

	      

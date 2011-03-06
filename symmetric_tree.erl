% P56
% Symmetric binary trees
% Let us call a binary tree symmetric if you can draw a vertical line through 
% the root node and then the right subtree is the mirror image of the left 
% subtree.

-module(symmetric_tree).
-export([
	 check/1
	]).


check([_, Left, Right]) ->
    check(Left,Right).

check(Left, Right) ->
    struct(Left) =:= struct(Right).

struct(null) ->
    null;
struct([_,Left,Right]) ->
    [n, struct(Left), struct(Right)].
    

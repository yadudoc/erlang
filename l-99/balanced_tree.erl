% P55
%Construct completely balanced binary trees
%In a completely balanced binary tree,
% the following property holds for every node: The number of nodes in its left su%btree and the number of nodes in its right subtree are almost equal,
% which means their difference is not greater than one.

% Write a function cbal-tree to construct completely balanced binary trees for a 
% given number of nodes. The predicate should generate all solutions via 
% backtracking. Put the letter 'x' as information into all nodes of the tree.
% Example:
% * cbal-tree(4,T).
% T = t(x, t(x, nil, nil), t(x, nil, t(x, nil, nil))) ;T = t(x, t(x, nil, nil),
%  t(x, t(x, nil, nil), nil)) ;
-module(balanced_tree).
-export([
	 tree/1,
	 splitat/2
	]).

tree([]) ->
    null;
tree([A|[]]) ->
    [ A, null, null ];
tree(List) ->
    Pivot = (len(List) div 2) + 1,
    [P,Left,Right] = splitat(List, Pivot),
    [P, tree(Left), tree(Right)].



len([])->
    0;
len([_|T])->
    1+len(T).


splitat(List, Index)->    
    split(List, [], Index).

split([H|T], Head, 1)->    
    [H,lists:reverse(Head),T];
split([H|T], Accum,Index)->
    split(T, [H|Accum], Index-1);
split([], _, _) ->
    index_too_large.

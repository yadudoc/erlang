% P60 
%(**) Construct height-balanced binary trees with a given number of nodes
% Consider a height-balanced binary tree of height H. What is the maximum 
% number of nodes it can contain?
% Clearly,
% MaxN = 2**H - 1. However,
% what is the minimum number MinN? This question is more difficult. Try to 
% find a recursive statement and turn it into a predicate minNodes/2 defined 
% as follwos:

-module(tree_node).
-export([
	 n_rb_tree/1
	 ]).
-import(rb_tree,[
		 insertlist/2
		 ]).



    
n_rb_tree(N) ->
    insertlist(null, lists:seq(1,N)).

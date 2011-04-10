% P62
% Collect the leaves in a binary tree into a list
-module(collect_internal).
-export([
	 internal/1	 
	]).


internal(null)->
    [];
internal([_,null,null]) ->
    [];
internal([X, Left, Right]) ->
    [X|lists:append(internal(Left),internal(Right))].

	      

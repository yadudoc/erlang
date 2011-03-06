% P54A
% Check if a given list satisfies the tree structure
-module(is_tree).
-export([
	 check/1
	]).

% Check if the List satisfies the tree structure
check([X , Left, Right]) when X =/= null ->
    check(Left),
    check(Right);
check(null) ->
    true;
check(_)->
    false.
    
    
	    
    
    
    



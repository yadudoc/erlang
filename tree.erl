-module(tree).
-export([insert/2, insertlist/2, search/2]).


% We are bulding a binary search tree.
% The first element passed must be of the form
% [root, Left , Right] of which root must be a number
% and Left,Right could either be another subtree or 
% null values.

% Inserts an Item into the Tree using the basic rules
% of binary search trees
insert(Tree, Item ) ->     
    insert(Tree, Item, []).
insert(null, Item, []) ->
    [Item, null, null];
insert([Node, Left, Right], Item, []) when Node >= Item ->
    [Node, insert(Left, Item, []), Right] ;
insert([Node, Left, Right], Item, []) when Node < Item ->
    [Node, Left, insert(Right, Item, [])].


% Inserts a list of values in order to the binary search
% tree passed to it. This involves repeatedly calling
% the above defined insert(_,_) function.
insertlist(Tree, [H|T]) -> 
    insertlist(insert(Tree, H), T);
insertlist(Tree, []) ->
    Tree.
    

% Search the tree for a given element and if found return
% true, else return false

search(null, _) ->
    false;
search([Node, Left, Right], Item) ->
    if
	Node =:= Item ->
	    true;
	Node >= Item ->
	    search(Left, Item);
	Node < Item ->
	    search(Right, Item)
    end.
    
    
	    
    
    
    



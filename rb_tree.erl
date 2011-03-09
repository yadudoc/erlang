% P59 
%(**) Construct height-balanced binary trees
% In a height-balanced binary tree, the following property holds for every 
% node: The height of its left subtree and the height of its right subtree 
% are almost equal, which means their difference is not greater than one.


% We are implementing a Red-Black tree which is a type of Height balanced tree
-module(rb_tree).
-export([
	 insert/2,
	 insertlist/2	 
	 ]).


% insert a list of items into the rb_tree
insertlist( Tree, [H|T] ) ->
    insertlist( insert(Tree, H), T);
insertlist( Tree, []) ->
    Tree.

% Inserts a single element into the rb_tree
insert(Tree, Item) ->
    root_sanity(ins(Tree, Item)).

ins( null, Item ) ->
    [{Item, red}, null, null ];
ins([{Item ,C}, Left, Right], Item ) ->
    [{Item ,C}, Left, Right];
ins([{N,C}, Left, Right], Item ) when Item < N ->
    balance( [{N,C}, ins(Left, Item), Right], Item);
ins([{N,C}, Left, Right], Item ) when Item > N ->
    balance( [{N,C}, Left, ins(Right, Item)], Item).

root_sanity([{Root, _}, Left, Right]) ->
    [{Root, black}, Left, Right];
root_sanity(null) ->
    null.
    

case1([{G,Gc}, [{L,red}, [{Item, red}, Lll, Llr], Lr ],[{R,red},Rl,Rr]], 
	Item) ->
    [{G,Gc}, [{L,black}, [{Item, red}, Lll, Llr],Lr], [{R,black},Rl,Rr]];
case1([{G,Gc}, [{L,red}, Ll, [{Item, red}, Lrl, Lrr]],[{R,red},Rl,Rr]],
	Item) ->
    [{G,Gc}, [{L,black}, Ll, [{Item, red}, Lrl, Lrr]],[{R,black},Rl,Rr]];
case1([{G,Gc}, [{L,red}, Ll, Lr],[{R,red}, [{Item,red},Rll,Rlr]], Rr],
	Item) ->
    [{G,Gc}, [{L,black}, Ll, Lr],[{R,black}, [{Item,red},Rll,Rlr]], Rr];
case1([{G,Gc}, [{L,red}, Ll, Lr],[{R,red}, Rl, [{Item,red},Rrl,Rrr]]],       
	Item) ->
    [{G,Gc}, [{L,black}, Ll, Lr],[{R,black}, Rl, [{Item,red},Rrl,Rrr]]];
case1(Tree, Item) ->
    case2(Tree, Item).


% Converting Zig-Zag shape to Zig-Zig
%      A          A              A           A
%     /          /                \ 	      \
%    B    =>    B      and         B   =>      B
%     \        /                  /             \
%      C      C                  C               C 
case2( [{G, _}, [{L,red}, Ll, [{Item, red}, Lrl, Lrr]], [{R,Rc}, Rl, Rr]] ,
       Item) ->
    case3([{G, red}, 
	   [{Item, black}, [{L, red}, Ll, Lrl], Lrr ],
	   [{R, Rc}, Rl, Rr]
	  ], L);
case2( [{G, _}, [{L, Lc}, Ll, Lr], [{R, red}, [{Item,red}, Rll, Rlr]], Rr],
       Item) ->
    case3([{G, red}, 
	   [{L, Lc}, Ll, Lr], 
	   [{Item, black}, Rll, [{R, red}, Rlr, Rr]]
	  ], R);
case2( Tree, Item)  ->
    case3(Tree, Item).


% Converting Zig-Zig to Bent Arrow shape
%        A                     A
%       /         B		\ 	    B 
%      B    =>   / \     and     B    =>   / \ 
%     /         C   A             \       A   C
%    C                             C
case3([{G, red}, 
	   [{Item, black}, [{L, red}, Ll, Lrl], Lrr ],
	   [{R, Rc}, Rl, Rr]
	  ], R) ->
    


    
    

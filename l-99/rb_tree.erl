% P59 
%(**) Construct height-balanced binary trees
% In a height-balanced binary tree, the following property holds for every 
% node: The height of its left subtree and the height of its right subtree 
% are almost equal, which means their difference is not greater than one.


% We are implementing a Red-Black tree which is a type of Height balanced tree
-module(rb_tree).
-export([
	 insert/2,
	 insertlist/2,
	 insertlist/1
	 ]).

%default inserts a list into empty tree
insertlist(List)->
    insertlist(null, List).

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
    case1( [{N,C}, ins(Left, Item), Right] );
ins([{N,C}, Left, Right], Item ) when Item > N ->
    case1( [{N,C}, Left, ins(Right, Item)] ).

root_sanity([{Root, _}, Left, Right]) ->
    [{Root, black}, Left, Right];
root_sanity(null) ->
    null.
    
% Case 1 
% The parent and the newly created node is red.
% If the sibling of the parent i.e the uncle is also red
% then, all we need to do is change the color of the parent
% and uncle to black and that of the grandparent to red.
case1([{G,black}, 
       [{L,red}, [{Lr, red}, Lll, Llr], Ll ], 
       [{R,red},Rl,Rr]
      ]) ->
    [{G,red}, [{L,black}, [{Lr, red}, Lll, Llr],Ll], [{R,black},Rl,Rr]];
case1([{G,black}, 
       [{L,red}, Ll, [{Lr, red}, Lrl, Lrr]],
       [{R,red},Rl,Rr]
      ]) ->
    [{G,red}, [{L,black}, Ll, [{Lr, red}, Lrl, Lrr]],[{R,black},Rl,Rr]];
case1([{G,black}, 
       [{L,red}, Ll, Lr], 
       [{R,red},[{Rl,red},Rll,Rlr], Rr]
      ]) ->
    [{G,red}, [{L,black}, Ll, Lr],[{R,black}, [{Rl,red},Rll,Rlr], Rr]];
case1([{G,black},
       [{L,red}, Ll, Lr],
       [{R,red}, Rl, [{Rr,red},Rrl,Rrr]]
      ]) ->
    [{G,red}, [{L,black}, Ll, Lr],[{R,black}, Rl, [{Rr,red},Rrl,Rrr]]];
case1(Tree) ->
    case2(Tree).


% Converting Zig-Zag shape to Zig-Zig
%      A          A              A         A
%     /          /                \ 	    \
%    B    =>    C      and         B   =>    C
%     \        /                  /           \
%      C      B                  C             B 
case2( [{G, black}, 
	[{L,red}, Ll, [{Lr, red}, Lrl, Lrr]], 
	R]) ->
    case3([{G, black}, [{Lr, black}, [{L, red}, Ll, Lrl], Lrr ], R]);
case2( [{G, black},
	L,
	[{R, red}, [{Rl,red}, Rll, Rlr], Rr]
       ]) ->
    case3([{G, black}, L,  [{Rl, black}, Rll, [{R, red}, Rlr, Rr]]]);
case2( Tree )  ->
    case3(Tree).

% Converting Zig-Zig to Bent Arrow shape
%        A                     A
%       /         B		\ 	    B 
%      B    =>   / \     and     B    =>   / \ 
%     /         C   A             \       A   C
%    C                             C
%case3([{G, red}, 
%	   [{Item, black}, [{L, red}, Ll, Lrl], Lrr ],
%	   [{R, Rc}, Rl, Rr]
%	  ], R) ->

case3([{G, black},[{L, red}, [{Ll,red},Lll,Llr], Lr ], R ]) ->    
    [{L, black}, 
     [{Ll,red},Lll,Llr], 
     [{G, red}, Lr, R] ];

case3([{G, black}, L, [{R, red}, Rl, [{Rr,red}, Rrl, Rrr]] ]) ->
    [{R, black}, 
     [{G, red}, L, Rl], 
     [{Rr,red}, Rrl, Rrr] ];

case3(Tree)->   
    Tree.

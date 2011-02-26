-module(neural).
-export([create/3 , dot_prod/2, sigmoid/1]).



create( Input, Hidden, Output ) ->
    Icount = make (Input, [], 1),
    Hcount = make (Hidden, [], Input),
    Ocount = make (Output, [], Hidden).


make(0, Acc, _) ->
    Acc;
make(I, Acc, Count ) ->
    Pid = spawn( fun() -> node(Count, 1, -1) end ),
    make(I - 1, [Pid|Acc], 1).

% Node holds the count if signals yet to receive
% also the threshold and the current potential
% beyond the threshold the node will fire

node(C, I, J) ->
    node(C, I, J).
	    

% return the dot product sum of the weights and
% corresponding inputs	    
dot_prod(Inputs, Weights) ->
    dot_prod(Inputs, Weights, 0).
dot_prod([], [] , Acc) ->
    Acc;
dot_prod([Hi|Ti], [Hw|Tw], Acc) ->
    dot_prod(Ti, Tw, Acc + (Hi * Hw)).
    

% sigmoid is a step function. In case we need a sharper
% step try -5X instead of -X
sigmoid(X) ->
    1 / (1 + math:exp(-X)).
		   





    

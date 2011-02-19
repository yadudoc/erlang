-module(neural).
-export([create/3]).



create( Input, Hidden, Output ) ->
    Icount = create (Input, [], 1),
    Hcount = create (Hidden, [], Input),
    Ocount = create (Output, [], Hidden).


create(0, Acc, _) ->
    Acc;
create(I, Acc, Count ) ->
    Pid = spawn( fun() -> node(Count, 1, -1) end ),
    create(I - 1, [Pid|Acc]).

% Node holds the count if signals yet to receive
% also the threshold and the current potential
% beyond the threshold the node will fire

node(_, Threshold, Current) when Current >= THreshold ->
    % signal forward
node(0, , ) ->
    if
	Current >= Threshold ->
	    
    end;    
node(Count, Threshold, Current) ->
    receive 
	{self(), Signal} ->
	    node(Count-1, Threshold, 
	    
	    



		   





    

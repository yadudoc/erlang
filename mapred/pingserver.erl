-module(pingserver).
-export([
	 ping_server/1,
	 ping/1,
	 pong/0
	 ]).


ping(Node) ->    
    {N, Status} = rpc:call(Node, pingserver, pong, []),
    if 
	Status =:= up ->
	    {Status, N};
	Status =:= nodedown ->
	    {down, Node}
    end.
      
pong() ->
    {node(), up}.

ping_server(List) ->
    Result = [ ping(Node) || Node <- List ],
    [[ {Status, Node} || {Status, Node} <- Result ,
			Status =:= up ],
     [ {Status, Node} || {Status, Node} <- Result ,
			Status =:= down ]
    ].


-module(mapreduce).
-export([
	 rpc_ping/1,
	 rpc_pong/2,
	 rpc_handler/2,
	 start/1,
	 ping_server/1
	 ]).



start(List) ->
    Pid = register(ping_server_pid, spawn(mapreduce, ping_server, [List])),
    io:format("~nstart: ping_server_pid registered to: ~p ~n",[Pid]).
    
   
ping_server(List) ->
    io:format("ping_server: Task_tracker status-list: ~p~n",[List]),
    receive
	{up, T_tracker, _, _} ->
	    io:format("~nping_server: received message {up, ~p}",[T_tracker]),
	    ping_server( update(List, {up,T_tracker}) );
	{down, T_tracker, _} ->
	    io:format(" ping_server: received message {down, ~p}~n",[T_tracker]),
	    ping_server( update(List, {down,T_tracker}) );
	{die } ->
	    io:format(" Ping server exiting... ~n")
    after 10000 ->			
	    lists:map( fun(X) ->
			       spawn(mapreduce, rpc_ping, [X]) end,
		       List ),
	    ping_server(List)
    end.
	    
rpc_ping(T_tracker) ->
    io:format("rpc_ping: Pinging T_tracker -> ~p~n",[T_tracker]), 
    {_,Timestamp1} = erlang:localtime(),
    Result = rpc:call(T_tracker, mapreduce, rpc_pong, [node(), self()]),
    io:format("rpc_ping: Result from calling rpc_pong : ~p~n",[Result]),
    case Result of
	{ping, _} ->
	    receive
		{ping, T_tracker} ->
		    {_, Timestamp2} = erlang:localtime(),
		    io:format("Received pong from ~p at ~p, ping sent at ~p~n",
		              [T_tracker, Timestamp2, Timestamp1]),
		    ping_server_pid ! {up, T_tracker, Timestamp2, Timestamp1}
	    after 10000 ->		    
		    ping_server_pid ! {down, T_tracker, Timestamp1}
	    end;
	{badrpc, Reason} ->
	    io:format("rpc_ping: T_tracker at ~p is down due to ~p~n",
		      [T_tracker, Reason]),
	    ping_server_pid ! {down, T_tracker, Timestamp1};
	true ->
	    ping_server_pid ! {nodedown, T_tracker}
    end.

				       
rpc_pong(Origin, Server_pid) ->
    io:format("~nReceived ping from ~p ",[Origin]),
    rpc:call(Origin, mapreduce, rpc_handler, 
	     [Server_pid, {ping, node()}]).

rpc_handler(Pid, Request) ->
    Pid ! Request .

% In case a ping is received from a node not in list its added to the list
% By default the List contains only the node names
% when an up message is received that node is replaced by
% {node, up} or in case if its down by {node,down}

% each case is explicitly stated here so that necessary triggers may be added 
% later on.
update( [], {Status, H} ) ->
    [ {Status, H} ];
update( [H|T] , {Status, H} ) ->
    [ {H, Status} | T ];  
update( [{H,down}|T], {up, H} ) ->
    [ {H, up} | T ];
update( [{H, up}|T], {down, H} ) ->
    [ {H, down} | T ];
update( [H|T] , Item ) ->
    [ H | update(T, Item) ].

    
    

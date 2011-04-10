-module(keyserver).
-export([start/0 ,store/2, lookup/1]).


start() ->
    register(keyserver, spawn( fun() -> server() end )).

store(Key, Value) ->
    rpc({store, Key, Value }).

lookup(Key) ->
    rpc({lookup, Key}).

rpc(Message) ->
    keyserver ! {self(), Message},
    receive
	{keyserver, Reply} ->
	    Reply
    end.

server() ->
    receive
	{From, {store, Key, Value}} ->
	    put(Key, {ok, Value}),
	    From ! {keyserver, ok},
	    server();	
	{From, {lookup, Key}} ->
	    From ! {keyserver, get(Key)},
	    server()
    end.
	    
    
			      

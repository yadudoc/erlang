-module(iring).
-export([make_ring/2]).



% Number is the number of processes
% M is the times the message is to be sent around


make_ring(N, M)
    ->
    spawn(fun()-> mnode(N,self(),M) end).
    %Head ! {Head, M}.

mnode(0, Head, M)->
    io:format("Passing message to Head : ~p~n ",[Head]),
    Head ! {Head, M},
    Me = self(),
    io:format("Last child waiting for message~n"),
    Loop = fun(F)->
       receive
	   {Me, 1}->
	       io:format("Looping completed"),
	       F(F);
	   {Me, Message}->	
	       io:format("Looping message ~p back to head ",[{Head, Message-1}]),
	       Head ! {Head, Message-1},
	       F(F)
       after 10000->
	    io:format("Last child exiting") 
       end,
       io:format("~n")		   
       end,
    Loop(Loop);		

mnode(N, Head, M)->       
    Me = self(),
    Child = spawn(fun()-> mnode(N-1,Head, M) end),
    io:format("Spawning child ~p,     Me: ~p    Child: ~p~n",[N,Me,Child]),
    Loop = fun(F)->
       receive
	   {Me, Message}
	    ->
	    io:format(" Process ~p received message~n",[Me]),	    
	    io:format(" Messaging child ~p~n",[Child]),
	    Child ! {Child, Message},
	    F(F)
       after 10000->
	       io:format("Process ~p exiting~n",[self()])
       end,	    
       io:format(" ")
       end,
    Loop(Loop).
     









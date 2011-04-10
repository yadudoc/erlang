-module(ring).
-export([make_ring/2]).



% Number is the number of processes
% M is the times the message is to be sent around


make_ring(N, M)
    ->
    Head = mnode(N),
    io:format("Ring : ~p~n",[Head]),
    sends(Head, M).

mnode(0)
    ->
    [spawn(fun()-> mynode() end)];
mnode(N)
    ->
    [spawn(fun()-> mynode() end) | mnode(N-1) ].

mynode()
    ->
    receive
	{_,message}
	    ->
	    {message}
    end.	    


sends(Head, 0)-> send(Head);
sends(Head, M)-> send(Head),
	    	 io:format("Running time ~p~n",[M]),
                 sends(Head, M-1).


send([H|T])
    ->
    H ! {H,message},
    send(T);
send([])
    ->
    done.   


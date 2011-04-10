-module(infloop).
-export([loop/0]).

loop()->
    io:format("looping"),
    wait(),
    receive
	{cont}->
	    loop();
	{term}->
	    io:format("Terminating")
    after
	10000->
	    io:format("Exiting from timeout")
    end.
	
wait()->
    receive
	{void}->
	    ending
    after
	1000->
	    io:format("-")
    end.	    
	
	    

	    

-module(area).
-export([loop/0 , rpc/2]).

rpc( Pid, Request )
    ->
    Pid!{self(), Request},
    receive
	{Pid, Response}
		->
		%io:format(" Pid = ~p    Response = ~p~n",[Pid,Response]),
		{Pid, Response}
    end.



loop() 
    ->
    receive
	{From, {rectangle, Width, Height}}
            ->
	    %io:format("Area of rectangle is ~p~n", [Width * Height]),
	    From ! {self(), Width * Height},
	    loop();
	{From, {circle, R}}
	    ->
	    %io:format("Area of circle is ~p~n", [3.14159 * R * R]),  	
	    From ! {self(), 3.14159 * R * R},
	    loop();
	{From, _}
	    ->	    
	    %io:format("Area not known ~n"),
	    From ! {self(), "ERROR: Unknown format"},
	    loop()
    end.
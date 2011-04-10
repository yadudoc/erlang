-module(slast).
-export([secondlast/1]).

secondlast([A|[_B| []]])
    ->     
    io:format("Second last item is ~p~n",[A]);
secondlast([_|[B|T]])
    ->		 
    secondlast([B|T]).
		

		 
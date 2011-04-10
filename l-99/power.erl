-module(power).
-export([exp/2]).

% for the input of exp(Base, Power) we return Base raised to the exponent Power

exp(_, 0)->
    1;
exp(N, 1)->
    N;
exp(N, Power) ->   
%    io:format("Attempting exp(~p, ~p)~n",[N,Power]),
%    io:format("Testing Power div 2 ~p~n",[ Power div 2 ]),
    Temp = exp(N, Power div 2),
    case Power rem 2 of
	1 ->
	    Temp*Temp*N ;
	0 ->
	    Temp*Temp
    end.
	    
	   

% Return the combinations of N elements on a given list  

-module(combinations).
-export([c/2]).


c(List, N) ->
    c(List, N, []).
c(List, 1, Accum) ->
%    io:format("Trying List: ~p  Accum: ~p ~n",[List,Accum]),
     Temp = [lists:append(Accum,[T]) || T<-List],
     io:format("~p~n",[Temp]);
c([],_,_) ->
    ok;
c([H|T], N, Accum) ->

    c(T, N-1, lists:append(Accum,[H])),
    if 
	(N > 1) ->
	    c(T, N, [])	
    end.




%    Newaccum = lists:append(Accum,[H]),
%    Tail = c(T, N-1, Newaccum),    
%    [lists:append(H,T) || T<-Tail],

    
    
   




    
    
    

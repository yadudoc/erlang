% P19
% rotate a list n times to the left or to the right
-module(rotaten).
-export([
	 turn/3
	]).


turn(List, N, left) ->
    turnl(List, N, 0);
turn(List, N, right) ->
    turnr(List, N).

% to turn left append the head at the end N times
turnl(List, N, N) ->
    List;
turnl([H|T], N, Index) ->
    turnl(lists:append(T,[H]), N, Index+1).
	    
% to turn right do a left append N times on the reversed list and return the 
% reverse of the result
turnr(List, N) ->
    R = fun(L) ->
	    lists:reverse(L)
    end,
    R(turnl(R(List), N, 0)).
    

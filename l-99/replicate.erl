% P15
% Replicate the elements of a list N times

% example:
% r( [1,2,3], 3 ] --> [1,1,1,2,2,2,3,3,3]

-module(replicate).
-export([
	 r/2
	 ]).

r([H|T], Count)->
    r([H|T], Count, Count, []).

r([H|T], Count, 1, Acc) ->   
    r(T, Count, Count, [H|Acc]);
r([H|T], Count, I, Acc) ->
    r([H|T], Count, I-1, [H|Acc]);
r([], _, _, Acc) ->
    lists:reverse(Acc).
    

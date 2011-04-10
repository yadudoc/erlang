% P20
% remove the Kth element from a list

-module(removenth).
-export([
	 rm/2,
	 rm_tail/2
	]).

rm([_|T], 1) ->
    T;
rm([H|T], Count) ->
    [ H | rm(T, Count-1) ].

rm_tail(List, Count) ->
    rm_tail(List, Count, []).

rm_tail([_|T], 1, Acc) ->
    lists:append( lists:reverse(Acc), T);
rm_tail([H|T], Count, Acc) ->
    rm_tail(T, Count-1, [H|Acc]).
    

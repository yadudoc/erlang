% P05
% reverse a list
-module(list_reverse).
-export([
	 r/1
	]).

r(List)->
    r(List, []).

r([H|T], Acc)->
    r(T, [H|Acc]);
r([], Acc) ->
    Acc.

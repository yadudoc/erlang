% P09
% Pack consecutive duplicates of list elements
-module(pack_duplicates).
-export([
	 pack/1
	]).

%% modified algo from remove duplicates
pack([H|T]) ->
    pack(T, [H], []).

pack([H|T], [H|X], Acc)->
    pack(T, [H| [H|X]], Acc);
pack([X|T], List, Acc) ->
    pack(T, [X], lists:append( [List], Acc));
pack([], List, Acc) ->
    lists:reverse( lists:append([List], Acc)).

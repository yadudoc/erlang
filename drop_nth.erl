% P16
% drop every N'th element from the list

-module(drop_nth).
-export([
	 drop/2
	]).

drop([H|T], Count) ->
    drop([H|T], Count, Count, []).

drop([_|T], Count, 1, Acc)->
    drop(T, Count, Count, Acc);
drop([H|T], Count, I, Acc)->
    drop(T, Count, I-1, [H|Acc]);
drop([], _, _, Acc) ->
    lists:reverse(Acc).

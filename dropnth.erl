%drop every nth element from a list


-module(dropnth).
-export([dropn/2]).

dropn(List, Index)->
    drop(List, [], 1, Index).

drop([], Accum, _, _)->
    lists:reverse(Accum);
drop([_|T], Accum, Index, Index)->
    drop(T, Accum, 1, Index);
drop([H|T], Accum, Temp, Index) ->
    drop(T, [H|Accum], Temp+1, Index).

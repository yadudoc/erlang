% Removes the nth element from a given list

-module(nth_rem).
-export([rm/2]).

rm(List, N)->
    rm(List, [], N).

rm([],_, _)->
    error_n_too_large;
rm([_|T], Acc, 1) ->
    lists:append(Acc,T);
rm([H|T], Acc, I) ->
    rm(T, lists:append(Acc,[H]), I-1).

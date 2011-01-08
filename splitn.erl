% split file at specified position

-module(splitn).
-export([splitat/2]).


splitat(List, Index)->
    split(List, [], Index).

split(Tail, Head, 1)->
    {lists:reverse(Head),Tail};
split([H|T], Accum,Index)->
    split(T, [H|Accum], Index-1);
split([], _, _) ->
    index_too_large.

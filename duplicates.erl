-module(duplicates).
-export([remove_duplicates/1]).

remove_duplicates([H|T])
    ->
    remove_duplicates(H, T, []).

remove_duplicates(Prev, [H|T], Acc)
    when Prev=/=H ->
    remove_duplicates(H, T, lists:append(Acc,[Prev]));
remove_duplicates(Prev, [H|T], Acc)
    ->
    remove_duplicates(H, T, Acc);
remove_duplicates(Prev, [], Acc)
    ->
    lists:append(Acc,[Prev]).
    
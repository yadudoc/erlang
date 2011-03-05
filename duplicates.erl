% P08
% Eliminate consecutive duplicates of list elements
-module(duplicates).
-export([
	 remove_duplicates/1,
	 r_dup/1
	]).

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
    

%% Slightly more optimised algorithm
r_dup([H|T]) ->
    r_dup(T, H, 1, []).

r_dup([H|T], H, Count, Acc)->
    r_dup(T, H, Count+1, Acc);
r_dup([X|T], Prev, Coundut, Acc) ->
    r_dup(T, X, 1, [Prev|Acc]);
r_dup([], Prev, Count, Acc) ->
    lists:reverse( [Prev|Acc] ).

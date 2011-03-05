% P14
% Duplicate every element in the list
-module(dup).
-export([
	 make_dup_tail/1,
	 make_dup_rec/1
	]).

%% make_dup duplicate every element in the list
% [a,b,c,d] -> [a,a,b,b,c,c,d,d]

% uses tail recursion
make_dup_tail(List)->
    make_dup_tail(List, []).

make_dup_tail([H|T], Acc)->
    make_dup_tail(T, [ H|[H|Acc] ]);
make_dup_tail([], Acc) ->
    lists:reverse(Acc).

% normal recursion
make_dup_rec([H|T]) ->
    [ H | [ H | make_dup_rec(T)] ];
make_dup_rec([])->
    [].
    

% P07
% Flatten a nested list structure

-module(flatten).
-export([flatten_list/1]).

flatten_list(List)
    ->
    flatten_list(List, []).

flatten_list([H|T], Acc) when is_list(H)
    ->
    flatten_list(T, flatten_list(H,Acc));
flatten_list([H|T], Acc)
    ->
    flatten_list(T, lists:append(Acc,[H]));
flatten_list([], Acc)
    ->
    Acc.
		    

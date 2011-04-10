% P10 && P11
% P10 : Runlength encoding of a list
% P11 : Modified runlength encoding of a list



-module(runlength_encode).
-export([
	 encode/1,
	 mod_encode/1
	]).

% Input is a list of elements which are encoded by
% runlength encoding. 
% eg. [1,1,2,3,3,3,4] ->  [{1,2},{2,1},{3,3},{4,1}]

encode([H|T]) ->
    encode(T, H, 1, []).

encode([H|T], H, Count, Acc) ->
    encode(T, H, Count+1, Acc);
encode([H|T], Prev, Count, Acc) ->
    encode(T, H, 1, [{Prev, Count} | Acc ]);    
encode([], Prev, Count, Acc) ->
    lists:reverse([{Prev,Count} | Acc]).

mod_encode([H|T]) ->
    mod_encode(T, H, 1, []).

mod_encode([H|T], H, Count, Acc) ->
    mod_encode(T, H, Count+1, Acc);
mod_encode([H|T], Prev, 1, Acc) ->
    mod_encode(T, H, 1, [Prev | Acc]);    
mod_encode([H|T], Prev, Count, Acc) ->
    mod_encode(T, H, 1, [{Prev, Count} | Acc ]);    
mod_encode([], Prev, 1, Acc) ->
    lists:reverse([Prev | Acc]);
mod_encode([], Prev, Count, Acc) ->
    lists:reverse([{Prev,Count} | Acc]).


    

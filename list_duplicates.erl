-module(list_duplicates).
-export([duplicate/1]).


duplicate(List)->
    duplicate(List, []).


duplicate([H|T], Acc)->    
    duplicate(T, lists:append(Acc,[[H]]) );
duplicate([], Acc)->
    Acc.
    
-module(copy).
-export([append/2]).

append (A , B) 
    ->
    last(A,B).

last ( [H|T] , B ) when T =:= [] 
     ->
     [H|B];
last ( [H|T] , B ) when T =/= []
     ->[H| last(T,B)].

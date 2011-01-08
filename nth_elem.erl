-module(nth_elem).
-export([nth/2]).

nth ( [H|T], Pos ) when Pos > 1 ->
    nth ( T, Pos-1 );
nth ( [H|T], Pos ) when Pos =:= 1 ->
    H.
    
    


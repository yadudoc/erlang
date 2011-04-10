-module(nestlen).
-export([len/1]).

len ( A ) 
    ->
    lens(A,0).

lens ( [H|T] , L ) when is_list(H) =:= false
     ->
     lens (T, L+1);
lens ( [H|T] , L ) when is_list(H) =:= true
     ->
     lens (T, L+len(H));
lens ( [] , L ) 
     ->
     L.

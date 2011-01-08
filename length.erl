-module(length).
-export([len/1]).

len( A ) ->
     len(A,0).

len( [H|T] , L ) ->
     len ( T , L+1 );
len( [] , L ) ->
     L.

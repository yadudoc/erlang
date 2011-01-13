-module(coprime).
-export([check/2]).


check(A, B)->
    case gcd(A, B) of
	1 ->
	    true;
	_ ->
	    false
    end.




gcd(A, B) when B > A 
    ->
    gcd(B, A);
gcd(A, B) when A rem B > 0
    ->
    gcd(B, A rem B);
gcd(A, B) when A rem B =:= 0
    ->
    B.

% P32
% Determine the greatest common divisor of two positive integer numbers
-module(gcd).
-export([gcd/2]).

gcd(A, B) when B > A 
    ->
    gcd(B, A);
gcd(A, B) when A rem B > 0
    ->
    gcd(B, A rem B);
gcd(A, B) when A rem B =:= 0
    ->
    B.

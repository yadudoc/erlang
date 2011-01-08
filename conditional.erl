-module(conditional).
-export([check/1]).

check ( X )
       ->
       [Y || Y <- X , Y<10].

% P06
% Check if a list is a palindrome

-module(palindrome).
-export([
	 check/1,
	 compare/2
	 ]).

check(List) ->
    compare( List, list_reverse:r(List) ).

compare([H|X], [H|Y]) ->
    compare(X, Y);
compare([], []) ->
    true;
compare(_,_) ->
    false.

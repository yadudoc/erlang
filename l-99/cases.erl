-module(cases).
-export([check/2]).

check(P, [H|T]) ->
	case P(H) of
	     true  -> [H|check(P, T)];
	     false -> check(P, T)
	end;
check(_, [])	->
	 [].


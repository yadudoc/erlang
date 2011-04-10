-module(accum).
-export([oddeven/1 , accoddeven/1]).


accoddeven(L)
	->
	accoddeven(L,[],[]).

accoddeven([H|T], Odd, Even)
	->
	case (H rem 2) of
	     1 -> accoddeven(T, [H|Odd] , Even);
	     0 -> accoddeven(T, Odd     , [H|Even])
	end;
accoddeven([], Odd, Even)
	->
	{Odd,Even}.


oddeven(L)
	->
	{ [X|| X<- L, X rem 2 =:= 1],
	  [X|| X<- L, X rem 2 =:= 0]
	}.	   

     
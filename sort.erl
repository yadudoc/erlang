-module(sort).
-export([qlpsort/1 , qfsort/1] ).


%% using list comprehensions
qlpsort([])
	->
	[];
qlpsort([P|T])
	->
	qlpsort([X || X<-T , X < P])
	++[P]++
	qlpsort([X || X<-T , X >= P]).

	
%% using filters
qfsort([])
	->
	[];
qfsort([P|T])
	->
	qfsort( lists:filter((fun(X) -> X<P end),T) )
	++[P]++
	qfsort( lists:filter((fun(X) -> X>=P end),T) ).
	
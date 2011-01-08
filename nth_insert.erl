-module(nth_insert).
-export([insert/3]).

insert( [] , Key , Pos ) 
	->
	'Error';
insert( [H|T] , Key , Pos ) when Pos > 1 
	-> 
	[ H | insert ( T , Key , Pos-1 ) ];
insert( [H|T] , Key , Pos ) when Pos =:= 1
	->
	[ Key | [ H | T ]].

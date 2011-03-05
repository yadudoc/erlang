% P02
% FInd the last but one box of a list

-module(lastbox).
-export([
	 foo/1
	 ]).

foo([_])->
    error_insuffient_list_length;
foo([H|[T|[]]])->
    [H|[T]];
foo([_|T]) ->
    foo(T).
    

-module(len).
-export([l/1]).

l([])->
    0;
l([_|T]) ->
    1 + l(T).

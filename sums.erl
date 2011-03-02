-module(sums).
-export([add/1]).


add(List ) ->
    add(List, 0, 0).

add([], Osum, Esum) ->
    [{odd_sum, Osum}, {even_sum, Esum}];
add([Odd|[]], Osum, Esum) ->
    [{odd_sum, Osum+Odd}, {even_sum, Esum}];
add([Odd|[Even|Tail]] , Osum, Esum) ->
    add(Tail, Osum+Odd, Esum+Even ).

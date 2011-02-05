-module(runlength_decode).
-export([decode/1]).
%
%>mylists:rld([{a, 3}, {b, 2}, {c, 1}, {d, 1}, {e, 1}, {f, 2}]).
%  [a, a, a, b, b, c, d, e, f, f]

decode(List) ->
    decode(List, []).

decode([], Acc) ->
    lists:reverse(Acc);
decode([{CHAR, 1} | T], Acc) ->
    decode(T, [CHAR|Acc]);
decode([{CHAR, TIMES} | T ], Acc) ->
    decode([{CHAR, TIMES-1} | T ], [CHAR|Acc] ).


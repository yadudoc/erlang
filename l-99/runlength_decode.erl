% P12
% decode a run_length encoded list

-module(runlength_decode).
-export([
	 decode/1
	]).
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
    decode([{CHAR, TIMES-1} | T ], [CHAR|Acc] );
% With this added condition, we can also process lists
% such as [{a,3}, {b,2}, c, {a,2}, d, e] to
% [a,a,a,b,b,c,a,a,d,e]
decode([X|T], Acc) ->
    decode(T, [X|Acc]).


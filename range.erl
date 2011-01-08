%return list containing integers between a given range

-module(range).
-export([in/2]).


in(A, B) when A > B ->
    in(B, A, []);
in(A, B) ->
%    lists:reverse(in(A, B, [])).
     gen(A, B).

% in/3 return A to B in reverse
in(B, B, Acc) ->
    [B | Acc];
in(A, B, Acc) ->
    in(A+1, B, [A|Acc]).

% alternative logic
% no need for additional param, tail recursion

gen(B, B)->
    [B];
gen(A, B)->
    [A|gen(A+1, B)].

	      

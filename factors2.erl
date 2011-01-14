-module(factors2).
-export([freq/1]).

% factors:factors function returns a sorted list of factors by default
freq(N) ->
    runlength(factors:factors(N)).

% we do a simple run-length encoding routine on the list of factors to get the
% tailored result we want which is: 
% for N = 200 factors = [2,2,2,5,5] this should be shown as [[3,2], [2,5]]
% the first item in the sublist being the frequency and the 2nd being the factor 
% itself.

runlength([H|T]) -> 
    runlength(H, T, 1, []).

runlength(Prev,[] ,Count ,Acc ) ->
    lists:append(Acc, [[Count, Prev]]);
runlength(Prev, [Prev|Tail], Count, Acc) ->
    runlength(Prev, Tail, Count+1, Acc);
runlength(Prev, [Head|Tail], Count, Acc) ->
    runlength(Head, Tail, 1, lists:append(Acc, [[Count,Prev]])).

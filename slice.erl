%slice is a cut of a given list 
%for eg. [1,2,3,4,5,6], slice from 2 to 3 returns [2,3,4]
% Params : List, Start_index, Length



% two methods
% 1. Cut the list from front to create a smaller list which is passed to 
%    a func which cuts the tail at appropriate index
% 2. Use a func which uses an accumulator to store the list between indices
%    start -> (start+len)

-module(slice).
-export([slicer/3]).

slicer(List, Start, Len)->
%    cuttill(cutfrom(List,Start, 1),Len, 1).
    splice(List, [], Start, Start+Len, 1).


cutfrom([], _, _)->
    startindex_too_large;
cutfrom([_|T], Start, Start)->
    T;    
cutfrom([_|T], Start, Temp)->
    cutfrom(T,Start, Temp+1).
    
cuttill([], _, _)->
    length_too_large;
cuttill([H|_], Len, Len) ->
    [H];
cuttill([H|T], Len, Temp)->
    [H| cuttill(T,Len,Temp+1)].



splice([], _, _, _, _) ->
    error_out_of_bound_access;
splice([_|T], Accum, Start, Term, Temp) when Temp =< Start ->
    splice(T, Accum, Start, Term, Temp+1);
splice([H|T], Accum, Start, Term, Temp) when Temp =< Term  ->
    splice(T, [H|Accum], Start, Term, Temp+1);
splice(_, Accum, _, _, _) ->
    lists:reverse(Accum).
    

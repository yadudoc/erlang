% P25
% Return the list with randomised ordering of the list elements
% In other words generate a random permutation of the elements
% in a given list

-module(randlist).
-export([rand/1, len/1, getnth/2]).

rand(List) ->
    rand(List, len(List), []).

rand([], _, Acc) ->
    Acc;
rand(List, Len, Acc) ->
    {Newlist, Nth} = getnth(List, random:uniform(Len)),
    rand(Newlist, Len-1, [Nth|Acc]).

% getnth returns the list minus the nth element and the element itself
% returns a tuple of the form {list, element}
getnth(List, N)->
    getnth(List, [], N, 1).

getnth([], _, _, _)->
    error_getnth_beyond_length;
getnth([H|T], Accum, N, N)->
    {lists:append(lists:reverse(Accum),T), H};
getnth([H|T], Accum, N, I) ->
    getnth(T, [H|Accum], N, I+1).

% len returns the length of a given list
len([]) ->
    0;
len([_|T]) ->
    1+len(T).
      

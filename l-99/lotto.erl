% P24
% Draw N different random numbers from the set 1..M

-module(lotto).
-export([
	 pick_random/2
	]).

pick_random(Count, Max) ->
    pick_random(Count, Max, []).

pick_random(0, _, Acc) ->
    Acc;
pick_random(Count, Max, Acc)->
    pick_random(Count-1, Max, [random:uniform(Max) | Acc]).

    


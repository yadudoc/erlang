% P27
% Group the elements of a set into disjoint subsets.


%Example:
%* (group '(aldo beat carla david evi flip gary hugo ida) '(2 2 5))
%( ( (ALDO BEAT) (CARLA DAVID) (EVI FLIP GARY HUGO IDA) )
%... )
-module(subsets).
-export([
	 group/2
	 ]).

% Logic : of List = [a,b,c,d,e] and combinations [2,3]
% we first take combinations of list of 2 
% then take combinations of 3 on the rest
group(List, [H|T]) ->
    C = comb4:combinations(List, H),
    io:format("~nTrying on List : ~p~n",[List]),
    [ 
      [X|Y] || X <- C,	       
	       Y <- group(List -- X,T)
	      
    ];
group([],[])->
    [[]];
group(_,_) ->
    error_input_lists.
		       
			  
    


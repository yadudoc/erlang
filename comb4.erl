-module(comb4).
-export([combinations/2]).

% This algorith is flawed
% We are finding the permutations of a sequence with n length
% so we may have abc, acb, bca ... all of which represent the 
% same combination
% designed after the permutations algo.


combinations(List, Count) ->
    remove_duplicates( lists:sort( 
			 [ lists:sort(X) || X <- c(List, Count) ]), []).

c(List, 1) ->
    [ [X] || X <- List ];
c(List, Count) ->
    [ [X|Y] || X <- List, 
	     Y <- c( List -- [X], Count-1) ].

remove_duplicates([], Acc) ->
    lists:reverse(Acc);
remove_duplicates([H|[H|T]], Acc) ->
    remove_duplicates([H|T], Acc);
remove_duplicates([H|T], Acc) ->
    remove_duplicates(T, [H|Acc]).
    

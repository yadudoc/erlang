% P26
% Generate the combinations of K distinct objects chosen from the 
% N elements of a list
-module(comb4).
-export([combinations/2]).

% This algorith is not flawed anymore ;)
% We are finding the permutations of a sequence with n length
% so we may have abc, acb, bca ... all of which represent the 
% same combination
% designed after the permutations algo.


% We first find the combinations using the function c/2
% then we sort each item so that [a,c,b] -> [a,b,c]
% then we sort the entire lists so that the duplicate 
% combinations aggregate and can easily be eliminated
% by the functions remove_duplicates/2 which eliminate
% adjacent duplicates
combinations(List, Count) ->
    remove_duplicates( lists:sort( 
			 [ lists:sort(X) || X <- c(List, Count) ]), []).

% we are finding the combinations like the permutations
% so the problem is we end up with multiple elements which
% are essentially the same combination such as [a,b,c], [b,c,a]
c(List, 1) ->
    [ [X] || X <- List ];
c(List, Count) ->
    [ [X|Y] || X <- List, 
	     Y <- c( List -- [X], Count-1) ].

% remove the duplicates in the sorted list.
remove_duplicates([], Acc) ->
    lists:reverse(Acc);
remove_duplicates([H|[H|T]], Acc) ->
    remove_duplicates([H|T], Acc);
remove_duplicates([H|T], Acc) ->
    remove_duplicates(T, [H|Acc]).
    

-module(comb4).
-export([c/2]).

% best algorithm for combinations i've found yet.
% designed after the permutations algo.


c(List, 1) ->
    [ [X] || X <- List ];
c(List, Count) ->
    [ [X|Y] || X <- List, 
	     Y <- c( List -- [X], Count-1) ].

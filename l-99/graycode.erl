% P49 
%(**) Gray code.

%% An n-bit Gray code is a sequence of n-bit strings constructed according to certain rules. For example,
%% n = 1: C(1) = ['0','1'].
%% n = 2: C(2) = ['00','01','11','10'].
%% n = 3: C(3) = ['000','001','011','010','110','111','101','100'].

%% Find out the construction rules and write a predicate with the following specification:

%% % gray(N,C) :- C is the N-bit Gray code

%% Can you apply the method of "result caching" in order to make the predicate more efficient, when it is to be used repeatedly? 


-module(graycode).
-export([
	 gray/1,
	 gray_tail/1
	]).


gray(1) ->
    ['0','1'];
gray(N) ->
    lists:append(
      [list_to_atom(atom_to_list(X) ++ "0") || X <- gray(N-1) ],
      [list_to_atom(atom_to_list(X) ++ "1") || X <- gray(N-1) ]
      ).

gray_tail(N) ->
    gt(N, ['0','1']).

gt(1, Acc) ->
    Acc;
gt(N, Acc) ->
    gt(N-1, lists:append(
	      [ list_to_atom(atom_to_list(X) ++ "0") || X <- Acc ],
	      [ list_to_atom(atom_to_list(X) ++ "1") || X <- Acc ]
	     )). 

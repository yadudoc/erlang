%% LOGIC:
%% do bottom up and each level up do a product with subset of that element with already calcualted product
%% eg, 4C3 on (a, b, c, d), phi is denoted by %
%% we start with rest list and product list
%% in beginning we have rest list (R) = (a, b, c, d) and product list (P) = ( % )
%% 1. pop one element (d) from R and have a product with all in P list
%%    (d, %) X ( % ) => (d, %) = P
%%    R = (a, b, c) 
%% 2. pop c
%%    (c, %) X (d, %) => (cd, c, d, %) = P
%%    R = (a, b)
%% 3. pop b
%%    (b, %) X (cd, c, d, %) = (bcd, bc, bd, b, cd, c, d, %) = P
%%    R = (a)
%% 4. pop a
%%    (a, %) X (bcd, bc, bd, b, cd, c, d, %) = (abcd, abc, abd, ab, acd, ac, ad, a, 
%%                                                     bcd, bc, bd, b, cd, c, d, %) = P
%%    R = ()
%% 5. select all element with size 3 from P
%%    (abc, abd, acd, bcd) = Answer

-module(comb2).
-export([c/2, product/2]).

c(List, Count)->
    c(Count, List, [none]).


c(Count, [H|T], Acc) ->
    c(Count, T, lists:append(Acc, product(H, Acc)) );
c(Count, [], Acc) ->
    select(Count, Acc, []).


select(Count, [none| T], Acc) ->
    select(Count, T, Acc);
select(_, [], Acc) ->
    Acc;
select(Count, [H|T], Acc) ->
    Tmp = atom_to_list(H),
    if
	length(Tmp) =:= Count ->
	    select(Count, T, [H|Acc]);
	true ->
	    select(Count, T, Acc)
    end.


product(H, P)->
    product(H, P, []).

product(_, [], Acc) ->
    Acc;
product(H, [Hp|Tp], Acc) ->
    if
	Hp =:= none ->
	    product(H, Tp, [[H]|Acc]);
	true ->
	    product(H, Tp, [lists:append(H,[Hp]) | Tp])
    end.


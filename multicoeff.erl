-module(multicoeff).
-export([group/2]).


% Logic
% List of items as well as the number of items groups are also passed
% Eg. ([ab,caf,vs,asd,cas,as,cas,cad,vd,dss],[2,3,5]) returns [[..]..[..]]
% Find combinations of N from List and then for the rest of the list apply same

group(List, Groups)->
    group(List, Groups, []).


group([], _, Acc)->
    Acc;
group(_, [], _) ->
    error_check_groupcounts;
group(List, [H|T], Acc) ->
    [group(Rest, T, [Set|Acc]) || {Set,Rest} <- combination(H,List) ].

combination(Count, List)->    
    [{Set, lists:subtract(List, Set)} || Set<-combination(Count,List,[none])].

combination(Count, [H|T], P)->
    combination(Count, T, lists:append(P, product(H, P)) );
combination(Count, [], P) ->
    select(Count, P, []).

select(Count, [none|T], Acc) ->
    select(Count, T, Acc);
select(_, [], Acc) ->
    Acc;
select(Count, [H|T], Acc) ->
    if
	length(H) =:= Count ->
	    select(Count, T, [H|Acc]);
	true ->
	    select(Count, T, Acc)
    end.

product(H, P) ->
    product(H, P, []).

product(_, [], Acc)->
    Acc;
product(H, [Hp|Tp], Acc) ->
    if
	Hp =:= none ->
	    product(H, Tp, [[H]|Acc]);
	true ->
	    product(H, Tp, [lists:append(Hp, [H]) | Acc])
    end.

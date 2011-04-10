% P48
% Truth tables for logical expressions (3).

% Generalize problem P47 in such a way that the logical expression may contain 
% any number of logical variables. Define table/2 in a way that table(List,Expr)
% prints the truth table for the expression Expr,
% which contains the logical variables enumerated in List.
% Example:
%* table([A,B,C], A and (B or C) equ A and B or A and C).
% true true true true
% true true fail true
% true fail true true
% true fail fail true
% fail true true true
% fail true fail true
% fail fail true true
% fail fail fail true

-module(truth_table).
-import(logic, [
		my_and/2,
		my_or/2,
		my_nor/2,
		my_nand/2,
		my_not/1,
		my_xor/2
		]).
-export([
	 table/1,
	 expr/2
	]).

table(List) ->
    t(List, [[]]).

t([], Acc) ->
    lists:sort(Acc);
t([_|T], Acc) ->
    t(T, lists:append( [ [true|X]  || X <- Acc ],
		       [ [false|X] || X <- Acc ] )).
    
expr(List, Expr) ->
    print_header(List),
    print_nice([ lists:append(X,[process(Expr, X, List)]) || X <- table(List) ]).

process([ my_not | Expr ], Value, Key) ->
    my_not( process(Expr, Value, Key) );
process([ Expr1 |[ my_and  | Expr2]], Value, Key) ->
    my_and(process(Expr1, Value, Key), process(Expr2, Value, Key));
process([ Expr1 |[ my_or   | Expr2]], Value, Key) ->
    my_or(process(Expr1, Value, Key), process(Expr2, Value, Key));
process([ Expr1 |[my_nand  | Expr2]], Value, Key) ->
    my_nand(process(Expr1, Value, Key), process(Expr2, Value, Key));
process([ Expr1 |[ my_nor  | Expr2]], Value, Key) ->
    my_nor(process(Expr1, Value, Key), process(Expr2, Value, Key));
process([ Expr1 |[ my_xor  | Expr2]], Value, Key) ->
    my_xor(process(Expr1, Value, Key), process(Expr2, Value, Key));
process(X, Value, Key) when is_atom(X) ->
    find(X, Value, Key);
process([X], Value, Key) when is_atom(X) -> 
    find(X, Value, Key).

find(X, [Hv|_], [X|_])->
    Hv;
find(X, [_|Tv], [_|Tk]) ->
    find(X, Tv, Tk);
find(_, [], []) ->
    error_key_value_mismatch.
	       

print_nice([])->
    io:format("~n");    
print_nice([H|T]) ->
    io:format("~n|"),
    [ io:format("~p  |",[X]) || X <- H ],
    print_nice(T).


print_header([])->
    io:format("| Expression_result");
print_header([H|T]) ->
    io:format("|___~p___",[H]),
    print_header(T).
    
    

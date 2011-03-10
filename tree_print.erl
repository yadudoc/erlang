% Prints the input red-black tree or normal tree in a 
% graphical way using plain ascii characters and output
% formatting

-module(tree_print).
-export([
	 prettyprint/1
	]).

prettyprint(Tree)->
    pp(Tree, " "),
    io:format("~n").

pp(null,_) ->
    
    io:format("null~n");
pp([{Node, red}, Left, Right], Space) ->
    io:format("~pr -----> ",[Node]),
    pp(Left, string:concat(Space,"        ")),
    io:format("~p +----> ",[Space]),
    pp(Right,string:concat(Space,"       "));
pp([{Node, black}, Left, Right], Space) ->
    io:format("~pb -----> ",[Node]),
    pp(Left, string:concat(Space,"        ")),
    io:format("~p +----> ",[Space]),
    pp(Right,string:concat(Space,"       "));
pp([Node, Left, Right], Space) ->
    io:format("~p -----> ",[Node]),
    pp(Left, string:concat(Space,"        ")),
    io:format("~p +----> ",[Space]),
    pp(Right,string:concat(Space,"       ")).

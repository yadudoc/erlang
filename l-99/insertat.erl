% P21
% insert an element at Nth position into a list

-module(insertat).
-export([
	 insert/3
	 ]).

insert([], _, _) ->
    error_list_too_small;
insert(List, Item, 0) ->
    [Item|List];
insert([H|T], Item, Location) ->
    [ H | insert(T, Item, Location-1) ].

    

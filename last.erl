% P01
% Find the last item in the list 

-module(last).
-export([last/1]).


last([H|[]])->
    H;      
last([_|T])->
    last(T).

	   


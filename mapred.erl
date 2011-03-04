-module(mapred).
-export([
	 mr/2
	]).



mapper(Mapfun) ->
    receive
	{map, Input} ->
	    Result = Mapfun(Input),
	    



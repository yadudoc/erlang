-module(profiler).
-export([do/1]).


do(Func)->
    statistics(wall_clock),
    Result = Func(),
    {_, Time_1} = statistics(wall_clock),
    U_secs1 = Time_1 / 1000,
    io:format("~nResult : ~p~nTime taken is ~p seconds~n",
	      [Result, U_secs1]).
        
    
    

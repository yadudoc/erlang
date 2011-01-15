-module(profiler).
-export([do/1]).


do(N)->
    statistics(wall_clock),
    Result1 = totient:phi(N),
    {_, Time_1} = statistics(wall_clock),
    U_secs1 = Time_1 * 1000,
    io:format("The time taken by totient:phi to calculate phi(~p) is ~p~n",
	      [N, U_secs1]),
    
    statistics(wall_clock),
    Result2 = totient:threaded_phi(N),
    {_, Time_2} = statistics(wall_clock),
    U_secs2 = Time_2 * 1000,
    io:format("The time taken by totient:threaded_phi to calculate phi(~p) is ~p~n",
	      [N, U_secs2]),
    
    statistics(wall_clock),
    Result3 = imp_totient:phi(N),
    {_, Time_3} = statistics(wall_clock),
    U_secs3 = Time_3 * 1000,
    io:format("The time taken by imp_totient:phi to calculate phi(~p) is ~p~n",
	      [N, U_secs3]),
    
    if 
	Result1 =:= Result2,
	Result2 =:= Result3 ->
	    io:format("All results are consistent~n");
	true ->
	    io:format("Results not consistent ~ntotient:phi(N) = ~p
	               ~ntotient:threaded_phi(N) = ~p
                       ~nimp_totient:phi(N) = ~p~n",[Result1,Result2,Result3])
    end.

    
    
    

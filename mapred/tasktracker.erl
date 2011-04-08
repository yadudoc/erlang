-module(tasktracker).
-export([
	 start/1,
	 task_tracker/0
	 ]).

start(Reg_name) ->
    register( Reg_name, spawn(tasktracker, task_tracker, []) ).
    %io:format("task_tracker: Initialised and running ! ~n").

task_tracker() ->
    receive
	{job_tracker_live, Job_tracker} ->
	    io:format("tast_tracker: Received broadcast from Job_tracker ~p~n",
		      [Job_tracker]),
	    task_tracker();
	{die} ->
	    io:format("task_tracker: Exiting...")
    after 10000 ->
	    task_tracker()
    end.

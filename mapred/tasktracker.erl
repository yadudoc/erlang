-module(tasktracker).
-export([
	 start/2,
	 task_tracker/2,
	 mworker/4
	 ]).

start(Reg_name, Job_tracker) ->
    register( Reg_name, spawn(tasktracker, task_tracker, 
			      [discovery, Job_tracker]) ).
    %io:format("task_tracker: Initialised and running ! ~n").

%% The task tracker - Discovery stage
%% pings the main server which has the jobtracker 
%% NOTE: THE NODE RUNNING JOBTRACKER MUST BE NAMED GIVEN AS ARG
task_tracker(discovery, Job_tracker) ->
    io:format("~ntask_tracker : Discovery phase, Attempting contact with ~p",
	     [Job_tracker]),
    case net_adm:ping(Job_tracker) of
	pong ->
	    io:format("~ntask_tracker : Job_tracker found "),
	    task_tracker(discovered, [{jobtracker, Job_tracker}|[ready]] );
	pang ->
	    receive
		%% if the old Job_tracker dies out, we may have these nodes
		%% spawned off, so we may send a new job tracker nodes name
		%% and continue with the new job tracker
		{new_job_tracker, New_job_tracker} ->
		    task_tracker(discovery, New_job_tracker)
	    after 5000 ->
		    task_tracker(discovery, Job_tracker)
	    end
    end;	

%% Node has been discovered.
%% we move to the job accept stage.
%% If we don't receive a broadcast for 12s (broadcast spacing is 5s)
%%   we move to the undiscovered stage // we have lost contact with the
%%                                        jobtracker.  
task_tracker(discovered, Status) ->            
    receive
	%% Currently no checks are made to check if the original Job_tracker 
	%% node is the one from which we are receiving broadcasts from
	%% If support for multiple job_trackers are needed, it will go here.
	{job_tracker_live, _} ->
	    
	    
%%	    io:format("tast_tracker: Received broadcast from Job_tracker ~p~n",
%%		      [Job_tracker]),
	    task_tracker(discovered, Status );

	
	%% Request for spawning mappers
	%% 1. Spawn off mappers
	%% 2. Update status loopback
	{job_tracker_map, Mapperfunc, Pattern, Num_mappers, Num_reducers}
	->
	    [JTnode|[[Stat]|_]] = Status,
	    case Stat of  
		ready ->		    
		    Input_files = filelib:wildcard(Pattern),    
		    register('mapper', spawn(tasktracker, mapper, 
					     [Mapperfunc, 
					      [Input_files,[],[]],
					      Num_mappers,
					      0,
					      Num_reducers,
					      self()
					     ])),
		    
		    task_tracker(discovered,     %% Task_tracker status  
				 [JTnode ,       %% Job_tracker details    
				  [active],      %% Current status
				  [Input_files, [], []], %% Input files 
				  [[], [], []],  %% Intermediate files
				  []             %% Result files
				 ]
				 );
		_ ->
		    io:format("~nIllegal attempt : Mappers in use")
	    end;
	
	%% Update status and loop task_tracker
	%% spawn reducers
%%	{job_tracker_reduce, Redfunc, Num_reducers, Details}
%%	->	
%%	    ok;


	%% Update status and loop task_tracker
	%% send result update to job_tracker
	%% Filename = filename of the input file which is processed
	%% 
	{mapper_result_success, Filename, Inter_files} 
	->
	    [JTnode, 
	     [_], 
	     [Input_mfiles, Done_mfiles, Bad_mfiles],
	     [Int_rfiles, Done_rfiles, Bad_rfile],
	     Resultfiles
	     ] = Status,
	    task_tracker(discovered,   
			 [JTnode ,     
			  [active],    
			  [Input_mfiles -- Filename, 
			   Done_mfiles ++ Filename,
			   Bad_mfiles],
			  [Int_rfiles ++ Inter_files, Done_rfiles, Bad_rfile],
			  Resultfiles
			 ]
			),
	    
	    ok;
	
	{mapper_result_failure, Filename} 
	->
	    [JTnode, 
	     [_], 
	     [Input_mfiles, Done_mfiles, Bad_mfiles],
	     [Int_rfiles, Done_rfiles, Bad_rfile],
	     Resultfiles
	     ] = Status,
	    task_tracker(discovered,   
			 [JTnode ,     
			  [active],    
			  [Input_mfiles -- Filename, 
			   Done_mfiles , 
			   Bad_mfiles ++ Filename],
			  [Int_rfiles , Done_rfiles, Bad_rfile],
			  Resultfiles
			 ]
			),
	    
	    ok;

	
	%% Update status and loop task_tracker
	%% send result update to job_tracker
	{reducer_result, _}
	->

	    ok;	    
	{die} ->
	    io:format("task_tracker: Exiting...")
    after 12000 ->
	    [{jobtracker, Job_tracker}|_] = Status,
	    io:format("~nNo broadcast from ~p~n",[Job_tracker]),
	    task_tracker(discovery, Job_tracker)
    end.


%% mapper organises the mapping operation
%% ensures that only the specified number of mappers are running
mapper(Mapperfunc, [[Todo],[Processing],[Done], [Badfile]],
       Num_mappers, Num_reducers, Task_tracker, WorkerCount) ->    

    Me = self(),
    if
	WorkerCount < Num_mappers ->
	    [H|_] = Todo,
	    spawn(tasktracker, mworker, [Mapperfunc, H, Num_reducers, self()]),
	    mapper(Mapperfunc, 
		   [[Todo]--[H],
		    [Processing]++[H],
		    [Done], 
		    [Badfile]
		   ],
		   Num_mappers, Num_reducers, Task_tracker, WorkerCount+1)
    end,	    

    receive
	{mapper_success, Me, Inp_file, Int_files} ->	    
	    Task_tracker ! {mapper_result, Inp_file, Int_files},
	    mapper(Mapperfunc, 
		   [[Todo],
		    [Processing]--[Inp_file],
		    [Done]++[Inp_file], 
		    [Badfile]
		   ],
		   Num_mappers, Num_reducers, Task_tracker, WorkerCount-1);
	{mapper_failure, Me, Inp_file} ->
	    Task_tracker ! {mapper_result, Inp_file},
	    mapper(Mapperfunc, 
		   [[Todo],
		    [Processing]--[Inp_file],
		    [Done],
		    [Badfile]++[Inp_file]
		   ],
		   Num_mappers, Num_reducers, Task_tracker, WorkerCount-1)
	    
    end.
    
    

%% mworker handles a single map job at a time
%% 1. It reads in lines from a specified file
%% 2. Applies the Mapperfun on each line read in
%%        giving a {key,value} pair
%% 3. A phash is applied to the key and list is sorted on the basis on key
%% 4. The new list is split into sublists based on phash
%% 5. The sublists which go to different reducers, are written to different
%%        files, with the reducer number as the prefix
mworker(Mapperfun, Filename, Num_reducers, Mapper_id ) ->    
    case fileio:readline(Filename) of
	{ok, Contents} ->
	    
	    %% result from Mapperfun(X) is a list of {key , value} pairs
	    %% We apply a phash to get the list in the format
	    %% [ [hash, {Key,Value}] | T ]
	    Result =
	      lists:sort(
	      lists:map(fun({Key,Value}) ->
				[erlang:phash(Key,Num_reducers),{Key,Value}]
			end,
			lists:map(fun(X)->
					  Mapperfun(X) 
				  end, 
				  Contents)
		       )
	       ),
	    
	    %% NOTE: THE KEY MUST BE OF TYPE STRING AND VALUE INT OR LIST
	    Lists = [ [ lists:flatten(io_lib:format("~s,~p",[K,V])) ||  
			  [Hash, {K,V}] <- Result, 
					  Hash =:= Seq  ]
		      || Seq  <- lists:seq(1, Num_reducers) ],

	    [Fname | _ ] = string:tokens(Filename,"."),
	    
	    
	    Intermediates = lists:foldl( fun(X, Acc) ->	
       				 [Num] = io_lib:format("~p",[Acc]),
				 Out = Num ++ "_" ++ Fname ++ ".int",
				 %% io:format("~p",[Out]),
				 fileio:writelines(write, Out, X),
				 1+Acc
				 end, 0, Lists),
	    %% Send reply to mapper of successful completion
	    Mapper_id ! {mapper_success, Mapper_id, Filename, Intermediates};
		
	%% we are ignoring the reason for now. Till better reason handling is
	%% implemented
	{error, _} ->
	    Mapper_id ! {mapper_failure, Mapper_id, Filename}
    end.

    

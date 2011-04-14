-module(tasktracker).
-export([
	 start/2,
	 task_tracker/2,
	 mapper/6,
	 mworker/4,
	 yoyo/0,
	 yoyo/1
	 ]).

yoyo()->
    register(yoyo, spawn(tasktracker,yoyo,[loop])).

yoyo(loop) ->
    receive 
	_ ->
	    yoyo(loop)
    end.



start(Reg_name, Job_tracker) ->
    register( Reg_name, spawn(tasktracker, task_tracker, 
			      [discovery, Job_tracker]) ).
    %io:format("task_tracker: Initialised and running ! ~n").

%% The task tracker - Discovery stage
%% pings the main server which has the jobtracker 
%% NOTE: THE NODE RUNNING JOBTRACKER MUST BE NAMED GIVEN AS ARG
task_tracker(discovery, Job_tracker) ->
    io:format("task_tracker : Discovery phase, Attempting contact with ~p~n",
	     [Job_tracker]),
    case net_adm:ping(Job_tracker) of
	pong ->
	    io:format("task_tracker : Job_tracker found~n"),
	    task_tracker(discovered, [{jobtracker, Job_tracker}|[[ready]]] );
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

	
	{global_die} ->
	    [ [_] | [[Stat]|_] ] = Status,
	    if 
		Stat =/= ready ->
		    mapper ! {die}
	    end,	          	    
	    io:format("~ntask_tracker dying.. ~n");
	    

	%% Request for spawning mappers
	%% 1. Spawn off mappers
	%% 2. Update status loopback
	{job_tracker_map, Mapperfunc, Pattern, Num_mappers, Num_reducers}
	->
	    [{jobtracker, JTnode}|[[Stat]|_]] = Status,
	    case Stat of  
		ready ->		    
		    Input_files = filelib:wildcard(Pattern),    
		    rpc:sbcast([JTnode],jTracker,{files,node(),Input_files}),
		    register('mapper', spawn(tasktracker, mapper, 
					     [Mapperfunc, 
					      [Input_files,[],[],[]],
					      Num_mappers,	      
					      Num_reducers,
					      self(),
					      0
					     ])),
		    io:format("~n Received Map Job~n"),
		    task_tracker(discovered,     %% Task_tracker status  
				 [{jobtracker,JTnode}, %% Job_tracker details   
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
	    %%io:format("~n File:~p processed, New file-> ~p",
	%%	      [Filename, Inter_files]),
	    [{jobtracker,JTnode}, 
	     [_], 
	     [Input_mfiles, Done_mfiles, Bad_mfiles],
	     [Int_rfiles, Done_rfiles, Bad_rfile],
	     Resultfiles
	    ] = Status,
	    rpc:sbcast([JTnode],jTracker,{mapper_result_success, 
					  node(), Filename, Inter_files}),
	    task_tracker(discovered,   
			 [{jobtracker,JTnode} ,     
			  [active],    
			  [Input_mfiles -- Filename,
			   Done_mfiles ++ Filename,
			   Bad_mfiles],
			  [Int_rfiles ++ Inter_files, Done_rfiles, Bad_rfile],
			  Resultfiles
			 ]
			);	
	    
		   
	{mapper_complete}
	->
	    [{jobtracker,JTnode}, 
	     [_], 
	     [Input_mfiles, Done_mfiles, Bad_mfiles],
	     [Int_rfiles, Done_rfiles, Bad_rfile],
	     Resultfiles
	    ] = Status,
	    rpc:sbcast([JTnode], jTracker, {mapper_complete, node()}),
	    io:format("~n Mapping complete! "),
	    task_tracker(discovered,   
			 [{jobtracker,JTnode} ,     
			  [active],    
			  [Input_mfiles, Done_mfiles, Bad_mfiles],
			  [Int_rfiles , Done_rfiles, Bad_rfile],
			  Resultfiles
			 ]
			);	
	    
	
	

	{mapper_result_failure, Filename} 
	->
	    [{jobtracker,JTnode},
	     [_], 
	     [Input_mfiles, Done_mfiles, Bad_mfiles],
	     [Int_rfiles, Done_rfiles, Bad_rfile],
	     Resultfiles
	    ] = Status,
	    task_tracker(discovered,   
			 [{jobtracker,JTnode},
			  [active],    
			  [Input_mfiles -- Filename, 
			   Done_mfiles , 
			   Bad_mfiles ++ Filename],
			  [Int_rfiles , Done_rfiles, Bad_rfile],
			  Resultfiles
			 ]
			),
	    rpc:sbcast([JTnode],jTracker,{mapper_result_success, 
				      node(), Filename});
		   

	
	%% Update status and loop task_tracker
	%% send result update to job_tracker
	{reducer_result, _}
	->

	    ok;	    
	%% Global abort 
	%% kill all jobs. Leave everything as it is.
	%% Go back to the discovery phase
	{global_abort} ->
	    [{jobtracker, JTracker}|[ [State] |_ ]] = Status,
	    mapper ! {die},
	    task_tracker(discovery, JTracker);

	{die} ->
	    io:format("task_tracker: Exiting...")
    after 12000 ->	    	  
	    [{jobtracker, JTracker}|[ [State] |_ ]] = Status,
	    case State of
		active ->		    
		    task_tracker(discovered, Status);
		ready ->
		    task_tracker(discovery, JTracker);
		done ->
		    task_tracker(discovery, JTracker)
	    end
    end.




mapper(_, [[], [], _, _], _, _, Task_tracker, _) ->
%%    io:format("Mapper complete"),
    Task_tracker ! {mapper_complete};


%% mapper organises the mapping operation
%% ensures that only the specified number of mappers are running
mapper(Mapperfunc, [Todo, Processing, Done, Badfile],
       Num_mappers, Num_reducers, Task_tracker, WorkerCount) ->
  
    Me = self(),
    if
%%	Todo =:= [] , Processing =:= [] ->
%%	    exit(done);
	    
	WorkerCount < Num_mappers , Todo =/= [] ->
	    [H|_] = Todo,
	    spawn(tasktracker, mworker, [Mapperfunc, H, Num_reducers, self()]),
	    mapper(Mapperfunc, 
		   [Todo--[H],
		    Processing++[H],
		    Done, 
		    Badfile
		   ],
		   Num_mappers, Num_reducers, Task_tracker, WorkerCount+1);
	true ->
	    ok
    end,	    

    receive
	{mapper_success, Me, Inp_file, Int_files} ->	    
	    io:format("Mapper: ~p done~n",[Inp_file]),
	    Task_tracker ! {mapper_result_success, Inp_file, Int_files},
	    mapper(Mapperfunc, 
		   [Todo,
		    Processing--[Inp_file],
		    Done++[Inp_file], 
		    Badfile
		   ],
		   Num_mappers, Num_reducers, Task_tracker, WorkerCount-1);

	{mapper_failure, Me, Inp_file} ->
	    Task_tracker ! {mapper_result_failure, Inp_file},
	    mapper(Mapperfunc, 
		   [Todo,
		    Processing--[Inp_file],
		    Done,
		    Badfile ++[Inp_file]
		   ],
		   Num_mappers, Num_reducers, Task_tracker, WorkerCount-1);
	{die} ->
	    ok		
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
%%    io:format("~n mworker invoked for file -> ~p",[Filename]),
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
	    
	    

	    lists:foldl( fun(X, Acc) ->	
				 [Num] = io_lib:format("~p",[Acc]),
				 Out = Fname ++"_" ++Num++ ".int" ,
%%				 io:format("~n~p",[Out]),
				 fileio:writelines(write, Out, X),
				 1+Acc
			 end,
			 0, 
			 Lists),	    
	    
	    %% slightly crappy way of doing this
 	    Intermediates = filelib:wildcard(Fname++"*.int"),
	    %% Send reply to mapper of successful completion
	    Mapper_id ! {mapper_success, Mapper_id, Filename, Intermediates};
	
	%% we are ignoring the reason for now. Till better reason handling is
	%% implemented
	{error, _} ->
	    Mapper_id ! {mapper_failure, Mapper_id, Filename}
    end.

    

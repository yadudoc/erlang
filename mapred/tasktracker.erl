-module(tasktracker).
-export([
	 start/2,
	 task_tracker/2,
	 reducer/5,
	 readinputs/2,
	 yoyo/0,
	 testfun/1,
	 yoyo/1	 
	 ]).

-import(mapper,
	[
	 mapper/6
	 ]).

%% yoyo server is here only for debugging purposes
yoyo()->
    register(yoyo, spawn(tasktracker,yoyo,[loop])).

yoyo(loop) ->
    receive 
	_ ->
	    yoyo(loop)
    end.


%% From a given list of intermediate files passed thrrough @Files
%% remove the ones which are already processed.
%% The local files are listed first for being processed first.
readinputs( Files, [Done, Bad] ) ->   
    
    %% remove all files which are already processed
    Temp = [ [N,F] || [N,F] <- Files,
		      Done =:= Done -- [F] ],    

    %% Place files present on the local node at the beginning
    Temp2 = lists:append(
	      lists:filter(fun([N,_])->
				   N =:= node()
			   end,
			   Temp),
	      lists:filter(fun([N,_])->
				   N =/= node()
			   end,
		 Temp)
	     ),    
    readinputs( Temp2, [], [Done,Bad]).
		 

readinputs([[Node,Filename]|T], Acc, [Done, Bad] )->

    case [Filename] -- Done of
	%% File not present in Done list
	[Filename] ->
	    case Node =:= node() of
		false ->
%%		    io:format("~n Accessing file ~p on ~p",[Filename,Node]),
		    {Status, Contents} = 
			rpc:call(Node, fileio, readline, [Filename]);
		true ->
%%		    io:format("~n Accessing local-file ~p",[Filename]),
		    {Status, Contents} =
			fileio:readline(Filename)
	    end,
	    
	    case Status of
		error ->
		    readinputs(T,Acc,[Done, Bad++[Filename]]);
		ok ->
		    readinputs(T,
			       lists:append(Acc,Contents),
			       [Done ++ [Filename], Bad]
			       )
	    end;
	
	%% File is already processed
	[] ->
		   readinputs(T,[Done,Bad])	    	        
    end;
	     
readinputs([], Acc, [Done,Bad]) ->
    [ lists:sort(Acc), [Done,Bad] ].
    		

%%reducer(Redfunc, Tracker, Acc) ->
%%    receive
%%	{reduce_list, List} ->
%% WE are applying the reducer function here !!
reducer(Redfunc, Acc, Tracker, Id, [Done, Bad]) ->
    io:format("~nAcc  ~p~n, Files ~p~n",[Acc,[Done,Bad]]),
    receive
	{reduce_files, Files, Id} ->	    
	    [Sorted_inputs ,[New_good,New_bad]] = 
		readinputs(Files, [Done,Bad]),  
%%	    io:format("~nreducer, sorted results = ~p",[Sorted_inputs]),
	    io:format("~nreducer, after reducing = ~p~n",
		      [Redfunc(Sorted_inputs)]),	    
	    reducer(Redfunc,
		    Redfunc(Sorted_inputs),
		    Tracker,
		    Id,
		    [ (Done -- New_good) ++ New_good ,
		      (Bad  -- New_bad ) ++ New_bad ]
		   );
	
	{die} ->
	    io:format("~n reducer dying...~n");
	
	{reduce_return, Id} ->	    
	    Tracker ! {reduce_return, Acc, [Done,Bad]},
	    io:format("~nreducer returning Acc ~p~n",[Acc])	    
    end.

testfun([])->
    [];

testfun([H|T]) ->    
    [K,V] = [ {list_to_integer(X)} || X <- string:tokens(H,",") ],
    testfun(T, K, V,[]).

testfun([H|T], PreKey, PreVal, Acc)->
    [K,V] = [ {list_to_integer(X)} || X <- string:tokens(H,",") ],
    
    case K =:= PreKey of
	false ->
	    testfun(T, K, V, [ [PreKey,PreVal] | Acc ]);
	true ->
	    {V1} = PreVal,
	    {V2} = V,
	    testfun(T, K, {V1+V2}, Acc)
    end;

testfun([], PreKey, PreVal, Acc) ->
    lists:reverse ([ [PreKey,PreVal]|Acc]).


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
	
	%% Stop mapper/reducer if running
	{global_die} ->
	    [ _ | [[Stat]|_] ] = Status,
	    if 
		Stat =/= active_map, Stat =/= active_reduce ->
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
		    register('mapper', spawn(mapper, mapper, 
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
				  [active_map],      %% Current status
				  [Input_files, [], []], %% Input files 
				  [[], [], []],  %% Intermediate files
				  []             %% Result files
				 ]
				);
		_ ->
		    io:format("~nIllegal attempt : Mappers in use")
	    end;
	
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
			  [active_map],    
			  [Input_mfiles -- Filename,
			   Done_mfiles ++ Filename,
			   Bad_mfiles],
			  [Int_rfiles ++ Inter_files, Done_rfiles, Bad_rfile],
			  Resultfiles
			 ]
			);	
	    
	%% Mapper is finished processing all files matching the input pattern
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
			  [ready],    
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
			  [active_map],    
			  [Input_mfiles -- Filename, 
			   Done_mfiles , 
			   Bad_mfiles ++ Filename],
			  [Int_rfiles , Done_rfiles, Bad_rfile],
			  Resultfiles
			 ]
			),
	    rpc:sbcast([JTnode],jTracker,{mapper_result_success, 
				      node(), Filename});

	%% Accept and process reduce jobs
	%% The reduce function and an Id is passed to the job
	{reduce_job, Redfunc, Id}->
	    
	    [{jobtracker,JTnode},
	     [State], 
	     [Input_mfiles, Done_mfiles, Bad_mfiles],
	     [Int_rfiles, Done_rfiles, Bad_rfile],
	     Resultfiles
	    ] = Status,
	    
	    case State of
		ready ->
		    register('reducer',spawn(tasktracker,reducer,
					     [Redfunc,
					      [],
					      self(),
					      Id,
					      [[],[]]
					     ])),
		    task_tracker(discovered,   
				 [{jobtracker,JTnode},
				  [active_reduce],    
				  [Input_mfiles, Done_mfiles, Bad_mfiles],
				  [Int_rfiles , Done_rfiles, Bad_rfile],
				  Resultfiles
				 ]);
		
		done ->
		    register('reducer',spawn(tasktracker,reducer,
					     [Redfunc,
					      [],
					      self(),
					      Id,
					      [[],[]]
					     ])),
			     
		    task_tracker(discovered,   
				 [{jobtracker,JTnode},
				  [active_reduce],    
				  [Input_mfiles, Done_mfiles, Bad_mfiles],
				  [Int_rfiles , Done_rfiles, Bad_rfile],
				  Resultfiles
				 ]
				);		
		_ ->
		    io:format("~n Only one reducer at a time"),
		    task_tracker(discovered,   
				 [{jobtracker,JTnode},
				  [State],    
				  [Input_mfiles, Done_mfiles, Bad_mfiles],
				  [Int_rfiles , Done_rfiles, Bad_rfile],
				  Resultfiles
				 ])
	    end;
			
		   	
	%% Update status and loop task_tracker
	%% send result update to job_tracker
	{reducer_result, _}
	->
	    ok;	    

	{die} ->
	    io:format("task_tracker: Exiting...")
    after 12000 ->	    	  
	    [{jobtracker, JTracker}|[ [State] |_ ]] = Status,
	    case State of
		ready ->
		    task_tracker(discovery, JTracker);
		active_map ->		    
		    task_tracker(discovered, Status);
		active_reduce ->		    
		    task_tracker(discovered, Status);
		done ->
		    task_tracker(discovery, JTracker)
	    end
    end.

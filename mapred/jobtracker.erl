-module(jobtracker).
-export([
	 start/2,
%%	 broadcast/1,
	 broadcaster/3,
	 submit_job/0,
	 jtracker/5
	 ]).


% Broadcast message to all nodes.
broadcast(Reg_name)->    
    rpc:sbcast(Reg_name, {job_tracker_live, node()} ).

% This is part of the Node discovery phase
% Repeatedly broadcast every set duration to identify new nodes
% We only check for new nodes. 
% NOTE : WE ARE NOT HANDLING NODES GOING DOWN HERE
start(Reg_name, Time)->    
    %% spawn the jobtracker with registered name mr_jobtracker
    register( 'bCaster' , spawn(jobtracker,broadcaster, 
				    [Reg_name, Time, []])),
    io:format("~n Jobtracker: Broadcaster is Up!"),
    
    register( 'jTracker', spawn(jobtracker, jtracker, 
				[Reg_name, 5000, [], 
				 [ [[],[]], [[],[]], [] ], 
				 []
				]
			       ) ),
    io:format("~n Jobtracker: Jobtracker main thread is Up!").
    
    

broadcaster(Reg_name, Time, Good_old) ->

    {Good_new, _} = broadcast(Reg_name),
    New_node = Good_new -- Good_old,
    if 
	%% Case 1 : new nodes found !
	New_node =/= [] ->
	    jTracker ! {new_node, New_node};
	true ->
	    jTracker ! {no_new_node}
    end,
    %% The following is a lame sleep implementation
    %% we want the broadcast only in a few minutes
    receive
	{global_die} ->
	    rpc:sbcast(Reg_name, {global_die}),
	    io:format("~n Broadcaster dying..");
		      
	{die} ->
	    io:format("~n Broadcaster dying..")
    after Time ->
	    broadcaster(Reg_name, Time, Good_new)
    end.	      


%% listens and handles all notifications on node discovery
%%  status, node lost etc.
%% Functions is of type [ [Mapper,Inputpatte], [Reducer,N_reducers] ]
%% Files is of type [ [[ Input_files_todo ], [Input_files_done]],
%%                    [[ Inter_files_todo ], [Inter_files_done]],  
%%                    [ Output_file_done ]]
%% Nodes is a list of ready/active nodes

jtracker(Reg_name, Time, Functions, Files, Nodes) ->
%%    io:format("~n File(s) ->  ~p",[File]),
    receive 
	{die} ->
	    io:format("~n jTracker exiting...");

	%% Bit of a security issue right here.
	%% anybody could technically send a global_die message
	{global_die} ->
	    bCaster ! {global_die},
	    io:format("~n Jobtracker dying..");
	
	%% This is pretty useless, but lets us know the broadcaster is alive
	{no_new_node} ->
	    jtracker(Reg_name, Time, Functions, Files, Nodes);
	
	%% Notifies us of a new node.
	{new_node, New_node} ->
	    io:format("~n New node(s) found! ->  ~p~n",[New_node]),
	    jtracker(Reg_name, Time, Functions, Files, Nodes++New_node );
	
		
	%% Allow new requests only when the job is completed !	
	%%  
	%% We add a new job_request here.
	%% First the map is done on all available nodes
	%% Reduce is kept waiting till some of the map returns results
	{job_request, Mapfunc, Inp_pattern, Num_mappers, 
	 Redfunc, Num_reducers} when Functions =:= [] ->
	    io:format("~n Requesting map job at nodes ~p",[Nodes]),

	    rpc:sbcast(Nodes, Reg_name,
		       {job_tracker_map, Mapfunc, Inp_pattern, 
			Num_mappers, Num_reducers}
		      ),
	    jtracker(Reg_name,Time, 
		     [Mapfunc, [Redfunc,Num_reducers,[]]],
		     Files, Nodes);

	
	%% On making a map request the task_tracker responds immediately 
	%% by sending a copy of the list of input files. This is updated 
	%% on the jobtracker
	{files,Node,Input_files} ->
	    [[ITodo,IDone], Inter, Result] = Files,
	    jtracker(Reg_name, Time, Functions, 
		     [
		      [[[Node, Ifile] || Ifile <- Input_files]++ITodo, IDone],
		      Inter,
		      Result], Nodes);	       
	
		
	%% mapper_result_success, notification for successful completion
	%% of the mapping of an input file to intermediate files
	%% @Node,  node on which mapper ran
	%% @Filename, name of the input file
	%% @Inter_files, list of intermediate files
	%% 
	%% Update the status and loop over.
	{mapper_result_success, Node, Filename, Inter_files} ->	    
	    io:format("~nmapper_result_success on ~p",[Filename]),
	    io:format("~nCurrent files : ~p",[Files]),
	    [ [InpTodo,InpDone],[IntTodo,IntDone],Result ] = Files,
	    Temp = [ [Node,F] || F <- Inter_files],
	    jtracker(Reg_name, Time, Functions,
		     [ [InpTodo -- [[Node,Filename]], 
			InpDone++[[Node,Filename]]],
		       [IntTodo ++ Temp, IntDone], Result
		     ], Nodes);       	    


	%% On completion of map job on a node
	%% @Node, node on which mapper_completed
	%%
	%% On completion of mapper, check if there any unassigned reducer jobs
	%% which might be taken on.
	{mapper_complete, Node} ->
	    io:format("~n Mapping complete on node: ~p ",[Node]),
	    jtracker(Reg_name, Time, Functions, Files, Nodes);


	%% flush for all weird messages 
	Any ->
	    io:format("~n jTracker received message ~p",[Any]),
	    jtracker(Reg_name, Time, Functions, Files, Nodes)
    end.
	        	    	          

% Default submissions with preser Mapfunc, Redfunc, numbers and ids
% Mapfunc = mapper()
% N_mappers = 5
% Redfunc = reducer()
% N_reducers = 3
% Data_ids = "*.{map,red,fin}"
submit_job() ->

    jTracker ! {job_request, 
		fun(X)->
			
%%			[H|_] = lists:reverse(
%%				  prime_factor:pf(list_to_integer(X))
%%				 ),
			H = list_to_integer(X) + 1,
			{X,H}
		end,     %%  Mapfunc
		"Data/*.map",            %%  Inp_pattern
		3,                       %%  Num_mappers		
		fun(X)->{X} end,         %%  Redfunc
		3                        %%  Num_reducers
	       }.


%%len([]) ->
%%    0;
%%len([H|T]) ->
%%    1+len(T).

    
    

    
    
    




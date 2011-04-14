-module(jobtracker).
-export([
	 start/2,
	 broadcast/1,
	 broadcaster/3,
	 submit_job/0,
	 submit_job/5,
	 submit_job/6,
	 mapper/2,
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
    %%io:format("~n Node(s) ->  ~p",[Nodes]),
    receive 
	{die} ->
	    io:format("~n jTracker exiting...");

	%% Bit of a security issue right here.
	%% anybody could technically send a global_die message
	{global_die} ->
	    bCaster ! {global_die},
	    io:format("~n Jobtracker dying..");
	
	{no_new_node} ->
	    jtracker(Reg_name, Time, Functions, Files, Nodes);
	
	{new_node, New_node} ->
	    io:format("~n New node(s) found! ->  ~p",[New_node]),
	    jtracker(Reg_name, Time, Functions, Files, Nodes++New_node );
	
	
	{files,Node,Input_files} ->
	    [ [ITodo,IDone],Inter,Result ] = Files,
	    jtracker(Reg_name, Time, Functions, 
		     [
		      [[[Node, Ifile] || Ifile <- Input_files]++ITodo, IDone],
		      Inter,
		      Result], Nodes);	       


	%% Allow new requests only when the job is completed !	
	{job_request, Mapfunc, Inp_pattern, Num_mappers, 
	 Redfunc, Num_reducers} when Functions =:= [] ->
	    io:format("~n Requesting map job at nodes ~p",[Nodes]),

	    rpc:sbcast(Nodes, Reg_name,
		       {job_tracker_map, Mapfunc, Inp_pattern, 
			Num_mappers, Num_reducers}
		      ),
	    jtracker(Reg_name,Time, [Mapfunc, Redfunc], Files, Nodes);
	
	
	
	{mapper_result_success, Node, Filename, Inter_files} ->
	    [ [InpTodo,InpDone],[IntTodo,IntDone],Result ] = Files,
	    Temp = [ [Node,F] || F <- Inter_files],
	    jtracker(Reg_name, Time, Functions,
		     [ [InpTodo -- [Node,Filename],InpDone++[Node,Filename]],
		       [IntTodo ++ Temp, IntDone], Result
		     ], Nodes);       	    

	{mapper_complete, Node} ->
	    io:format("~n Mapping complete on node: ~p ",[Node]);

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
    submit_job(fun(X) -> mapper(X,3) end, 
	       5, 
	       fun(Y) -> reducer(Y) end,
	       3,
	       "./Data/*.{map,red,fin}",
	       miley).   

% Main job submission point 
% by default registered server name is "miley"
submit_job(Mapfunc, N_mappers, Redfunc, N_reducers, Data_ids) ->
    submit_job(Mapfunc, N_mappers, Redfunc, 
	       N_reducers, Data_ids, 'Miranda').

submit_job(Mapfunc, N_mappers, Redfunc, N_reducers, Data_ids, Server_id) ->
    
    % Get node names of all available nodes.
    {Goodnodes, Badnodes} = broadcast(Server_id),
                   
    Filesys = filesystem:fs_server(Goodnodes, Data_ids).
    

mapper(File, N_reducers) ->
    {_, F} = file:open(File,[read]),
    do(F, N_reducers).

do(File, N_reducers) ->
    Line = file:read_line(File),
    if 
	Line =:= eof -> 
	    [];
	true ->
	    {ok,S0} = Line,
	    [S1] = string:tokens(S0,"\n"),
	    {S3, _} = string:to_integer(S1),
	    Primes = prime_factor:pf(S3),
	    [ {len(Primes),S3}   | do (File, N_reducers )]
    end.


len([]) ->
    0;
len([H|T]) ->
    1+len(T).

reducer(X) ->
    X.
    
    

    
    
    




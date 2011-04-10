-module(jobtracker).
-export([
	 broadcast/1,
	 broadcaster/2,
	 broadcaster/3,
	 submit_job/0,
	 submit_job/5,
	 submit_job/6,
	 mapper/2,
	 jtracker/1
	 ]).


% Broadcast message to all nodes.
broadcast(Reg_name)->    
    rpc:sbcast(Reg_name, {job_tracker_live, node()} ).

% This is part of the Node discovery phase
% Repeatedly broadcast every set duration to identify new nodes
% We only check for new nodes. 
% NOTE : WE ARE NOT HANDLING NODES GOING DOWN HERE
broadcaster(Reg_name, Time)->    
    %% spawn the jobtracker with registered name mr_jobtracker
    register( 'jTracker', spawn(jobtracker, jtracker, [5000]) ),
    register( 'bCaster' , spawn(jobtracker,broadcaster, 
				    [Reg_name, Time, []])).
    

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
	{die} ->
	    io:format("~n Broadcaster dying..")
    after Time ->
	    broadcaster(Reg_name, Time, Good_new)
    end.	      


%% listens and handles all notifications on node discovery
%%  status, node lost etc.
jtracker(Time) ->
    receive 
	{die} ->
	    io:format("~n jTracker exiting...");
	{no_new_node} ->
	    jtracker(Time);
	{new_node, New_node} ->
	    io:format("~n New node(s) found! ->  ~p",[New_node]),
	    jtracker(Time);
	Any ->
	    io:format("~n jTracker received message ~p",[Any]),
	    jtracker(Time)

    after Time ->
	    io:format("~n jTracker wait looping"),
	    jtracker(Time)
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
	       N_reducers, Data_ids, miley).

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
    
    

    
    
    



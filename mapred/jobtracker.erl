-module(jobtracker).
-export([
	 broadcast/1,
	 submit_job/0,
	 submit_job/5,
	 submit_job/6
	 ]).


% Broadcast message to all nodes.
broadcast(Reg_name)->    
    rpc:sbcast(Reg_name, {job_tracker_live, node()} ).


% Default submissions with preser Mapfunc, Redfunc, numbers and ids
% Mapfunc = mapper()
% N_mappers = 5
% Redfunc = reducer()
% N_reducers = 3
% Data_ids = "*.{map,red,fin}"
submit_job() ->
    submit_job(fun(X) -> mapper(X) end, 
	       5, 
	       fun(Y) -> reducer(Y) end,
	       3,
	       "*.{map,red,fin}",
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
    
    
    
    




-module(jobtracker).
-export([
	 broadcast/1,
	 ]).


broadcast(Reg_name)->    
    {Goodnodes, _} = 
	rpc:sbcast(Reg_name, {job_tracker_live, node()} ).


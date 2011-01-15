% Calculate Euler's totient function

% The euler's totient function phi(m) for a number m is given by the count
% of all numbers r such that (1 <= r < m)

-module(totient).
-export([phi/1, threaded_phi/1, check/2]).


% This is a threaded implementation of the totient function phi. The 
% non-threaded version is given below as well.
% For phi(N) we spawn N threads of ncheck(R) 1<= R < N which returns
% a list of pids of the child processes.
% now each thread executes in parallel and returns the results in the
% format {Pid of the thread, Result }
% A listen function infinite loops to receive the results.
% Whenever a result to received the Pid of that child is removed from
% the list Pids, this is a slow operation. <<BAD>>
% When the list of Pids is empty all results have been received and
% we can return the result :)

threaded_phi(N) ->    
    Parent = self(),
    Pids = for(1, N, fun(X,Y) -> spawn(fun()-> ncheck(X,Y,Parent) end) end),
    io:format("The totient function phi(~p) : ~p ~n",[N, listen(Pids, 0) ]).
    
listen([], Count) ->
%    io:format("Server ~p: All results collated ~n",[self()]),
    Count;
listen(Pids, Count) ->
    receive 
	{Child, Val} ->
%	    io:format("Server ~p: received result from child ~p~n",
%		      [self(),{Child, Val}]),
	    listen( lists:subtract(Pids, [Child]), Count + Val)
    after 10000 ->
	    io:format("Server ~p: Exiting after timeout~n",[self()])
    end.
		         

% check returns true if the params are coprimes else returns false	    
ncheck(A, B, Parent)->    
    case gcd(A, B) of
        1 ->	    
%	    io:format("Child ~p:sending reply to server ~p~n",[self(),Parent]),
            Parent ! {self(),1};
        _ ->
%	    io:format("Child ~p:sending reply to server ~p~n",[self(),Parent]),
	    Parent ! {self(),0}
    end.
					    



for(N, N, _) ->
    [];
for(I, N, F) ->
    [F(I,N) | for(I+1, N, F)].




% phi(N) takes N and returns the totient of N (or the count of the numbers
% in range (1, N) which are coprimes of N

phi(N) ->
    phi(1, N, []).

phi(N, N, Acc) ->
%    io:format("Debug: list of coprimes := ~p~n",[Acc]),
    length(Acc);
phi(I, N, Acc) ->
    case check(I, N) of
	true ->
	    phi(I+1, N, [I|Acc]);
	false ->
	    phi(I+1, N, Acc)
    end.

% check returns true if the params are coprimes else returns false	    
check(A, B)->    
    case gcd(A, B) of
        1 ->	    
            true;
        _ ->
	    false
    end.

gcd(A, B) when B > A
    ->
    gcd(B, A);
gcd(A, B) when A rem B > 0
    ->
    gcd(B, A rem B);
gcd(A, B) when A rem B =:= 0
    ->
    B.

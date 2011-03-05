% P37 
%(**) Calculate Euler's totient function phi(m) (improved).
  
%% See problem P34 for the definition of Euler's totient function. If the list of the prime factors of a number m is known in the form of problem P36 then the function phi(m) can be efficiently calculated as follows: Let [[p1,m1],[p2,m2],[p3,m3],...] be the list of prime factors (and their multiplicities) of a given number m. Then phi(m) can be calculated with the following formula:

%% phi(m) = (p1 - 1) * p1**(m1 - 1) * (p2 - 1) * p2**(m2 - 1) * (p3 - 1) * p3**(m3 - 1) * ...
%%        = Mul(Pi - 1) * Pi ** (mi - 1)) from i <= i <= N
%% where P is prime factor and M is the number of times it occur (ie, power)

%% Note that a**b stands for the b'th power of a.

-module(imp_totient).
-export([phi/1]).

phi(N) ->
    phi(factors2:freq(N), 1).


phi([] , Acc) ->
    Acc;
phi([[Freq,Prime]|T], Acc) ->
    phi(T, Acc * ( (Prime - 1)*power:exp(Prime, Freq-1) ) ).


power(N, Power) ->
    power(N, Power, 1).

power(_, 0, Acc) ->
    Acc;
power(N, I, Acc) ->
    power(N, I-1, Acc*N).



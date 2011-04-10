-module(looper).
-export([for/3 , perms/1]).

for (Max,Max,F) 
    ->
    [F(Max)];
for (I,Max,F)
    ->
    [F(I)|for(I+1,Max,F)].


perms ([])
      ->	
      [[]];
perms (L)
      ->
      [ [H|T] || H <- L , T <- perms(L--[H]) ].

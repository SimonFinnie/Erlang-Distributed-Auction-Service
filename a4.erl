-module(a4).
-connect_all false.

-export([a3/2]).

a3(N,T) ->
	Split = N div T,
	Remainder = N rem T,
	math:sqrt(makeThreads(Split,Remainder,T,1)).
	

makeThreads(Split,Remainder,T,I) when I < T ->
	Parent = self(),
	Min = Split*(I-1) + 1,
	Max = Split*I,
	spawn(fun() -> count(Parent,Min,Max,0) end),
	SubTotal = makeThreads(Split,Remainder,T,I+1),
	receive
		Total -> Total
	end,
	SubTotal + Total;
makeThreads(Split,Remainder,T,I) when I == T ->
	Parent = self(),
	Min = Split*I - Split + 1,
	Max = Split*I + Remainder,
	spawn(fun() -> count(Parent,Min,Max,0) end),
	receive
		Total -> Total
	end,
	Total.	
	
	


count(Parent,Min, Max, Total) when Min =< Max ->
	count(Parent,Min+1,Max,Total+Min);
count(Parent,Min,Max, Total) when Min > Max ->
	Parent ! Total.
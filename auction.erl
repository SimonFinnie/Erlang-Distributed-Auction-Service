-module(auction).

-import(string,[str/2]).

%exports the method for generating the auction.
-export([auction/3]).

%method which first generates initialises itself and then repeatedly checks for bids until the timer runs out. 
auction(Topic,Duration,Name) ->
	 Customers = [],
	 AuctionData = {0.0,0.0,self()},
	 {MS,S,MilS} = erlang:now(),
	 FinishTime = MS*1000 + S + Duration, %sets up the finish time in a format that is usable.
	 global:register_name(Name, self()),
	 global:send("Server", {1,"Auction",Name,"A"}), %sends intro message to the server.
	 auction(Customers,AuctionData,FinishTime,Name). %calls recursive function.
auction(Customers,AuctionData,FinishTime,Name)-> %repeatively updates auction and all members of the auction of the current status of the auction.
	{HighestBid,SecondBid,_} = AuctionData, %splits auction data.
	receive 
		Val -> Val
	end,
	{MS,S,MilS} = erlang:now(), 
	CurTime = MS*1000 + S, %grabs current time.
	{Type,Bid,CustomerID} = Val, %splits up message data.
	if
	     CurTime >= FinishTime -> finishProcedure(Customers,AuctionData,Name); %turns off auction if time is up.
	     CurTime < FinishTime andalso Type =:= 1 -> global:send(CustomerID, {2,HighestBid,Name,"Welcome",-1}), Customers2 = [CustomerID|Customers], auction(Customers2,AuctionData,FinishTime,Name); %updates listing for customers and sends a message to the customer welcoming them.
	     CurTime < FinishTime andalso Type =:= 2 -> AuctionData2 = updateAuction(CustomerID,Bid,AuctionData,Name), auction(Customers,AuctionData2,FinishTime,Name); %updates auction values based on the bid.
	     CurTime < FinishTime andalso Type =:= -1 -> Customers2 = Customers -- [CustomerID], auction(Customers2,AuctionData,FinishTime,Name) %removes customer from listing.
	 end.

%updates values of the auction based on the bid.
updateAuction(CustomerID,Bid, AuctionData,AuctionID)-> 
		{HighestBid,SecondBid,BidderID} = AuctionData,
	if
		Bid > HighestBid ->  global:send(CustomerID, {3,HighestBid,AuctionID,"You're Winning",-1}),{Bid,HighestBid,CustomerID}; 
		Bid =< HighestBid andalso Bid > SecondBid ->  global:send(CustomerID, {2,HighestBid,AuctionID,"Not High Enough",-1}),{HighestBid,Bid,BidderID};
		Bid =< SecondBid -> AuctionData,  global:send(CustomerID, {2,HighestBid,AuctionID,"Not High Enough",-1}), {HighestBid,SecondBid,BidderID}
	end.

%sends all customers a message stating the results of the auction, then shuts down.
finishProcedure(Customers,AuctionData,AuctionID)->
	{HighestBid,SecondBid,BidderID} = AuctionData,
	Customers2 = Customers -- [BidderID],
	SecondBid2 = checkSecond(HighestBid,SecondBid),
	if
		HighestBid =/= 0 -> global:send(BidderID, {4,HighestBid,AuctionID,"You Win",SecondBid2}),
		lists:foreach(fun(N) -> losingMessage(N,HighestBid,AuctionID,SecondBid2) end, Customers2);
		HighestBid =:= 0 -> io:fwrite("No Bids Made")
	end.

%updates customers that they lost.
losingMessage(Customer,HighestBid,AuctionID,SecondBid2)-> 
	{CustomerID} = Customer,
	 global:send(CustomerID,{5,HighestBid,AuctionID,"You Lost",SecondBid2}).

%checks if the value is second highest.
checkSecond(Highest,Second)->
	if
	Second =:= 0 -> Highest;
	Second =/= 0 -> Second
	end.
-module(customers).

-import(string,[str/2]).

%exports the method for generating a customer.
-export([customer/2]).

%sends starting message to the server and then infinitely loops around, performing actions based on the type of message.
customer(Interests,Name) -> %recursive wrapper function, initialises the Auction list and connects to the server.
	 Auctions = [],
	 global:register_name(Name, self()),
	 global:send("Server", {1,"Customer",Name,""}), %sends a message to the server.
	 customer(Auctions,Interests,Name).
customer(Auctions,Interests,Name)-> %infinitely recursive method which acts on messages in a way determined by its type.
	receive
		Val -> Val
	end,
	{Type,MinBid,MessageID,Message,Second} = Val, %separates message into a tuple.
	InterestMatch = checkInterests(Message,Interests), %checks if the interest of the auction matches the any of interests of the customer.
	if 
	     Type =:= 1 andalso InterestMatch  =:= 1 -> global:send(MessageID, {1,-1,Name}), Auctions2 = [{0,MessageID,0}|Auctions], customer(Auctions2,Interests,Name); %connects up to the auction described by the message.
	     Type =:= 1 andalso InterestMatch =:= 0 -> customer(Auctions,Interests,Name); %ignores message.
	     Type =:= 2 -> Auctions2 = updateAuctions(MessageID,Auctions,MinBid,0,Name), customer(Auctions2,Interests,Name); %updates auction information.
	     Type =:= 3 -> Auctions2 = updateAuctions(MessageID,Auctions,MinBid,1,Name), customer(Auctions2,Interests,Name); %updates auction info when winning.
	     Type =:= 4 -> Auctions2 = Auctions -- [{MinBid,MessageID,0}],  customer(Auctions2,Interests,Name); %removes auction from list.
	     Type =:= 5 -> Auctions2 = Auctions -- [{MinBid,MessageID,1}],  customer(Auctions2,Interests,Name)  %removes auction from list, that the customer won.
	 end.


%updates the auction listing to current values.
updateAuctions(AuctionID,Auctions,MinBid,Winning,CustomerID)->
	Auction = {MinBid,AuctionID,Winning},
	Auctions2 = lists:keyreplace(AuctionID,2,Auctions,Auction),
	if 
		Winning =:= 1 -> Auctions2;
		Winning =/= 1 -> placeBid(Auction,CustomerID), Auctions2 %calls bid placing method if losing.
	end.

%decides places a bid half the time based on random input.
placeBid(Auction,CustomerID)->
	{MinBid,MessageID,Winning} = Auction,
	Thresh = 0.5, 
	Chance = random:uniform(),
	Change = random:uniform(10),
	if
		Winning =:= 1 -> 1;
		Winning =:= 0 andalso Chance > Thresh -> global:send(MessageID, {2,MinBid + Change, CustomerID}); %places bid.
		Winning =:= 0 andalso Chance =< Thresh -> 1 %ignores.
	end.

%checks if the interest matches any on the list of interests the customer has.
checkInterests(AuctionType,Interests)->
	Interested = lists:member(AuctionType,Interests),
	if
		Interested =:= false -> 0;
		Interested =/= false -> 1
	end.
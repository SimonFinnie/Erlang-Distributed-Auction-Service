-module(server).

-import(string,[str/2]).

%exports method which starts the server.
-export([server/0]).

%method which initialises all values sent to the server and then runs an infinite loop updating the lists based on message values.
server() ->
	 global:register_name("Server", self()), %registers itself on the distributed registry.
	 Customers = [],
	 Auctions = [],
	 server(Customers,Auctions).
server(Customers, Auctions)->
	 receive
		Val -> Val
	 end,
	 {Type,User,MessageID,Interest} = Val, %splits up the message.
	 if
	      User =:= "Customer" andalso Type =/= -1 -> Customers2 = [{MessageID}|Customers], lists:foreach(fun(N)->updateAuctions(MessageID,N)end,Auctions), server(Customers2, Auctions); %adds a customer to the list and sends each auction a message telling them this.
	      User =:= "Auction" andalso Type =/= -1 -> Auctions2 = [{MessageID,Interest}|Auctions], lists:foreach(fun(N)->updateCustomers({MessageID,Interest},N)end,Customers), server(Customers, Auctions2); %adds an auction to the list and sends each customer a message saying this.
	      User =:= "Customer" andalso Type =:= -1 -> Customers2 = Customers -- [{MessageID}], server(Customers2, Auctions); %removes customer from list.
	      User =:= "Auction" andalso Type =:= -1 -> Auctions2 = Auctions -- [{MessageID,Interest}], server(Customers, Auctions2) %removes auction from the list.
	 end.

%updates new customer on what auctions are available.
updateCustomers(Auction,Customer)->
	{CustomerID} = Customer,
	{AuctionID,Interest} = Auction,
	 global:send(CustomerID, {1,-1,AuctionID,Interest,-1}).

%updates customer of new auction.
updateAuctions(CustomerID,Auction)->
	{AuctionID,Interest} = Auction,
	 global:send(CustomerID, {1,-1,AuctionID,Interest,-1}).





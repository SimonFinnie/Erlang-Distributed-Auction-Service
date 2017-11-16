# Erlang-Distributed-Auction-Service
A variation of the Distributed Publish–Subscribe pattern written in Erland as part of an Assignment at University.
This Program will run in concurrent and distributed systems (if the user sets up the nodes first). This system allows for as many customers and auctions as needed, but can't have any more than one server running at once (server being the name of the module). 
To run this module, first spawn a thread which is running the server module, and then spawn as many auction and client threads as you want in any order, and the system will run.
This is completely automated and was developed as more of a test of ability than a full auction service, but with further development, this could be used as a small scale auction service.


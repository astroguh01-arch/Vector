-- Make an unrealiable remote event
-- make 2 actors
-- copy and put the actor script under them
-- actors must be named ParallelActor1 and ParallelActor2 
-- put replicator inside starterplayerscripts

# METHODS
Vector = require(path.Vector.API)
Vector.Write
Vector.Read
Vector.Get
Vector.Listen
Vector.Init


# EXAMPLES
local Vector = (path.Vector) 
Vector.Init(game.Players.GreenModt,{Data = {["Health"] = {Value = 100,Critical = true},["Mana"] = {Value = 100,Critical = true},["Speed"] = {Value = 100,Critical = true},["Foid"] = {Value = 100,Critical = true}}}))
Vector.Listen(game.Players.GreenModt.UserId,{Var = "Health",Type = "Poll"},20,function ()print("yo") end)) 
Vector.Write(game.Players.GreenModt.UserId,{["Health"] = {Value = 20}})
local Copy,EUID = Vector.Get(game.Players.GreenModt)
print(Copy,EUID)
print(Vector.Read(game.Players.GreenModt,"Health")

# NOTES
Currently Vector has client side replication via batching serialized variables that are compressed before sending, unreliable remote event is a choice.
Vectors Parallel Work Distribution is still in progress. But if you would like to plug in your own work distributer you just need to change Parallel on Config to true. Vectors CheckRate determines the necessity of distributions.


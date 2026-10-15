

local Vector = require(game.ReplicatedStorage.Vector.API)

Vector.Init(game.Players.GreenModt,{["Health"] = {Value = 100,Type = "f32"}})

print(Vector.Get(game.Players.GreenModt))

print(Vector.Read(game.Players.GreenModt,"Health"))

Vector.Write(game.Players.GreenModt,{["Health"] = {Value = 40,Type = "f32"}})
print(Vector.Read(game.Players.GreenModt,"Health"))
local timef = os.clock()
Vector.Listen(game.Players.GreenModt,{Var = "Health",Type = "Poll"},20,function ()print("Bro wrote 20") end)
task.wait(1)
print(os.clock() - timef )
Vector.Write(game.Players.GreenModt,{["Health"] = {Value = 20,Type = "f32"}})
--Vector.Write(game.Players.GreenModt,{["Health"] = {Value = 20,Type = "f32"}})

--while true do 
	--task.wait(0.1)
	--Vector.Write(game.Players.GreenModt,{["Health"] = {Value = 20,Type = "f32"}})
--end
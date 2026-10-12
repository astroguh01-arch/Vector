

local Vector = require(game.ReplicatedStorage.Vector.API)

Vector.Init(game.Players.GreenModt,{["Health"] = {Value = 100,Type = "f32"}})

print(Vector.Get(game.Players.GreenModt))

print(Vector.Read(game.Players.GreenModt,"Health"))

Vector.Write(game.Players.GreenModt,{["Health"] = {Value = 40,Type = "f32"}})

Vector.Listen(game.Players.GreenModt,{Var = "Health",Type = "Poll"},20,function ()print("Bro wrote 20") end)

Vector.Write(game.Players.GreenModt,{["Health"] = {Value = 20,Type = "f32"}})

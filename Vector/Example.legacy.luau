
local API = require(game.ReplicatedStorage.Vector.API)
API.Init(game.Players.GreenModt,{["Health"] = {Value = 200}})
local Call = function() 
	print("yo")
end
API.Listen(game.Players.GreenModt,{Var = "Health",Type = "Poll"},20,Call,nil)
API.Write(game.Players.GreenModt,{["Health"] = {Value = 20}})
--print(Vector.RunAll())

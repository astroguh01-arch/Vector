local API = require(game.ReplicatedStorage.Vector.API)


local Call = function() 
	print("yo")
end

--API.Listen(game.Players.GreenModt,{Var = "Health",Type = "Poll"},20,Call,nil)
--API.Write(game.Players.GreenModt,{["Health"] = {Value = 20}})

--print(API.Read(game.Players.GreenModt,"Health"))

print(API.Init(nil,{["Health"] = {Value = 200},Name = {Value = "Matrix"},Matrix = true })) -- Create A Matrix, Matrix value must be true and a Name value is required
print(API.Init(game.Players.GreenModt,{["Health"] = {Value = 200},Name = {Value = "Matrix"}})) -- Example of how no Matrix js makes a normal table
API.Write(game.Players.GreenModt,{["Health"] = {Value = 550},Target = "Matrix"}) -- Write to a Matrix, Target must equal the UID of said Matrix. Writer Entity is required
print(require(game.ReplicatedStorage.Vector.VectorField)) -- Read the Vector Field, will return a table of all the players and their data
local Vector = require(game:GetService("ReplicatedStorage").Vector.API)
print(script.Parent.Name)
Vector.Init(script.Parent,{["Health"] = {Value = 50}})
print(require(game.ReplicatedStorage.Vector.VectorField))
while true do
	task.wait(1)
	Vector.Write(script.Parent,{["Health"] = {Value = 50}})

end
print(Vector.Read(script.Parent,{["Health"] = {Value = 50}}))
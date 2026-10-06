local ClientVector = require(script.Parent.VectorField)
local Vector = require(game.ReplicatedStorage.Vector)

script.Parent.Shallow:Connect(function(EUID,Data,Type,...)
	if Type == "Correction" then
		local Var = ...
		local Copy = ClientVector[EUID]
		if Copy then
			if Copy.Data[Var] then
				Vector.Write(EUID,Data)
			else
				Vector.Write(EUID,Data)
			end
		end
	end
	if Type == "Sync" then
		
		local NData = Vector.Deserialize(Data)
		ClientVector[EUID] = NData
		Vector.Serialize(ClientVector[EUID].Data)
	
			
		
	end
end)

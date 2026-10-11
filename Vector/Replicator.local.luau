local ClientVector = require(game.ReplicatedStorage.Vector.VectorField)
local Vector = require(game.ReplicatedStorage.Vector)
local Encoder = game:GetService("EncodingService")

game.ReplicatedStorage.Vector.Shallow.OnClientEvent:Connect(function(EUID,Data,Operation,...)
	
	if Operation == "Correction" then
		local Var = ...
		local Copy = ClientVector[EUID]
		local Value = Vector.Des(Data,Data.Type)
		if Copy then
			if Copy.Data[Var] then
				Copy.Data[Var] = Data
			else
				Copy.Data[Var] = Data
			end
		end
		print("yo")
	end
	if Operation == "Sync" then
		
		ClientVector[EUID] = Data
 
		local NData = Vector.Deserialize(ClientVector[EUID])
		
	
	
	
			
		
	end
	if Operation == "Batch" then
	
		for i,v in Data do
			
		
		
			local VectorTable = ClientVector[v.UID]
		
			if VectorTable then
				v.Data = Vector.Des(v.Data,v.Type,v.Compressed)
				VectorTable.Data[v.Index] = v.Data
				
			end
		end
	end
end)

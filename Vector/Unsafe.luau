local module = {}

local PV = script.Parent
local Field = require(game.ReplicatedStorage.Vector.VectorField)
PV:BindToMessage("res",function(UID,Res)
	module[UID] = module[UID] or {}
	module[UID]["Write"] = Res

	module.Serial(UID)
end)
function module.Serial(EUID)
	local PVS = module[EUID]
	if PVS then
	local VS = Field[EUID]
	for i,v in pairs(PVS["Write"]) do
		Field[EUID].Data[i] = v
		if VS.Meta.Listening[i] then
				VS.Meta.Listening[i].Value = v.Value
				if VS.Meta.Listening[i].Type == "OnWrite" then

					VS.Meta.Listening[i].Callback(EUID,i,v)
				
				end
			end
	end
	
	end
end

return module


local Unsafe = {
	
}
local PV1 = game.ServerScriptService:WaitForChild("ParalleVector1")
local PV2 = game.ServerScriptService:WaitForChild("ParalleVector2")
local Field = require(game.ReplicatedStorage.Vector.VectorField)
function Unsafe.Init(EUID,Info)
	local v = Info.Var
	local i = Info.Index
	Unsafe[EUID] = Unsafe[EUID] or {}
	Unsafe[EUID]["Write"] = Unsafe[EUID]["Write"] or {}
	Unsafe[EUID]["Write"][i] =  {Var = v,Worker = PV2,Version = 1}
	print(Unsafe[EUID]["Write"])

end
function Unsafe.UnsafeWrite(EUID: number | string,Info, Handler)


	if EUID then
		if Unsafe[EUID] then
			local VS = Unsafe[EUID]
		
			local i,v = Info.Index, Info.Var
			
				
			VS["Write"][i] = {Value = v.Value,Type = v.Type or typeof(v.Value),Critical = v.Critical or false}
		
			
			
		
			
		
		
				
		

				
		
				
			if Handler then
				print(Info)
				if Handler == "1" then
					print(Info)
					PV1:SendMessage("Sync",EUID,VS["Write"])
				else
					print(Info)
					PV2:SendMessage("Sync",EUID,VS["Write"])
				end
			end
		end

		


	end
end

function Unsafe.Serial(EUID)
	local PV1 = require( game.ServerScriptService.ParalleVector1.Unsafe)
	local PV2 = require( game.ServerScriptService.ParalleVector2.Unsafe)
	PV1:Serial(EUID)
	PV2:Serial(EUID)
end

function Unsafe.Distribute(Global,Process,Target,...)
	local PVs = ...
	if PVs["Parallel2"].Work >= PVs["Parallel1"].Work then
		
		print(Unsafe,Process)
		PV1:SendMessage(Process,Target,Global)
	
	else
	
		PV2:SendMessage(Process,Target,Global)
		print(Unsafe,Process)
	end
	
	
end

return Unsafe

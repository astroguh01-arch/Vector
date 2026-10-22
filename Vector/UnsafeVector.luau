
local Unsafe = {
}
local PV1 
local PV2 
local Field = require(game.ReplicatedStorage.Vector.VectorField)
if game.RunService:IsServer() then
 PV1 = game.ServerScriptService:WaitForChild("ParalleVector1")
 PV2 = game.ServerScriptService:WaitForChild("ParalleVector2")

end
function Unsafe.Init(EUID,Info)
	local v = Info.Var
	local i = Info.Index
	Unsafe[EUID] = Unsafe[EUID] or {}
	Unsafe[EUID]["Write"] = Unsafe[EUID]["Write"] or {}
	Unsafe[EUID]["Write"][i] =  {Var = v,Worker = PV2,Version = 1}


end
function Unsafe.UnsafeWrite(EUID: number | string,Info, Handler)


	if EUID then
		if Unsafe[EUID] then
			local VS = Unsafe[EUID]
		
			local i,v = Info.Index, Info.Var
			
				
			VS["Write"][i] = {Value = v.Value,Type = v.Type or typeof(v.Value),Critical = v.Critical or false}
		
			
			
		
			
		
		
				
		

				
		
				
			if Handler then
				
				if Handler == 1 then
					
					PV1:SendMessage("Sync",EUID,VS["Write"])
					PV1:SendMessage("Sound",VS["Write"][i],EUID,i)
				else
					
					PV2:SendMessage("Sync",EUID,VS["Write"])
					PV2:SendMessage("Sound",VS["Write"][i],EUID,i)
				end
			end
		end

		


	end
end
function Unsafe.Sound(EUID,Info,Handler)
	if Handler then
		local i,v = Info.Index, Info.Var
				if Handler == 1 then
			       
					
					PV1:SendMessage("Sound",v,EUID,i)
				else
					
					
					PV2:SendMessage("Sound",v,EUID,i)
				end
			end


end
function Unsafe.UnsafeListen(EUID,Info,Handler)
	local VS = Unsafe[EUID] 

	local i = Info.Index
  
	if not VS then
		Unsafe[EUID] = Unsafe[EUID] or {}
		Unsafe[EUID]["Listen"] = Unsafe[EUID]["Listen"] or {}
		VS = Unsafe[EUID]
	end

	VS["Listen"][i] = Info
	print(VS)
	
	if Handler then

		if Handler == 1 then

			PV1:SendMessage("Listen",EUID,VS["Listen"][i])
			
		else

			PV2:SendMessage("Listen",EUID,VS["Listen"][i])
		end
	end
end
function Unsafe.UnsafeRead(EUID,N)
	
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
	
		PV1:SendMessage(Process,Target,Global)
	
	else
	
		PV2:SendMessage(Process,Target,Global)
	
	end
	
	
end

return Unsafe

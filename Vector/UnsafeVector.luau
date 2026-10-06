
local Unsafe = {
	
}
local PV1 = script.Parent.ParalleVector1
local PV2 = script.Parent.ParalleVector2
function Unsafe.UnsafeWrite(EUID: number | string,Info)
	if EUID then
		if Unsafe[EUID] then
			local VS = Unsafe[EUID]
			local WriteF = {}
            print(EUID)
			for i,v in pairs(Info) do
				if VS["Write"][i] then
					WriteF[i] = v.Value
				else
					VS.Data[i] = {Value = v.Value,Type = v.Type or typeof(v.Value),Critical = v.Critical or false}
		
				end
			end
		
			
		
		
				
		

				
			for i,v in pairs(WriteF) do
				if VS.Data[i] then
						VS.Data[i].Value = v.Value
						VS.Data[i].Type = v.Type or typeof(v.Value)
					

				end

			end
				
			Unsafe.Sync()
		end

		


	end
end


function Unsafe.Distribute(Global,Process,Target,...)
	local PVs = ...
	if PVs["Parallel1"].Work > PVs["Parallel2"].Work then
		Unsafe[Global] = Unsafe[Global] or {}
		Unsafe[Global][Process] = Unsafe[Global][Process] or {}
	   Unsafe[Global][Process][Target] = {Var = Target,Worker = PV1,Version = 1}
		PV1:SendMessage(Process,Target,Global)
	else
		Unsafe[Global] = Unsafe[Global] or {}
		Unsafe[Global][Process] = Unsafe[Global][Process] or {}
		Unsafe[Global][Process][Target] = {Var = Target,Worker = PV2,Version = 1}

		PV2:SendMessage(Process,Target,Global)
	end
	
	
end
function Unsafe.Sync(Global,Ref)
	if Unsafe[Global].Version < Ref.Meta.Version - 1 then
		
		return "Outdated"
	end
	for i,v in pairs(Ref.Data) do
		local UnsafeVar = Unsafe[Global]["Write"][i]
		if UnsafeVar then
		   Ref.Data[i] = UnsafeVar.Var
		end
		
	end
	
end
return Unsafe

local Vector = require(game.ReplicatedStorage.Vector)
local Unsafe = require(game.ReplicatedStorage.Vector.UnsafeVector)

Poll = {};

local PV = script.Parent

PV:BindToMessageParallel("Listen",function(EUID,v)

	Poll[v.Index] = v

	task.delay(v.Duration,function()
		Poll[v.Index] = nil
	end)

end)
PV:BindToMessageParallel("Write",function(v,n)
	if not Unsafe[v] then
		Unsafe.Init(n,v)
	end

	Unsafe.UnsafeWrite(n,v,1)

	if v.Value == Poll[n].var.Target then
		Poll[n].Callback(Poll[n].EUID,v)
		Poll[n] = nil
	end
end)
PV:BindToMessage("Read",function(v,n)
	if Unsafe[v] then
		if Unsafe[v]["Write"][n] then
			return  Unsafe[v]["Write"][n]
		else
			return Unsafe[v]["Write"]
		end
	else
		return "Nil"
	end
end)
PV:BindToMessageParallel("BitMap",function(EUID,bitmap,i)
	Unsafe[EUID].Meta.BitMap[i] = bitmap
end)
PV:BindToMessageParallel("Sound",function(v,EUID,n)
	local Res
	if Poll[n] then
		if Poll[n].var.target == v.Value then
			Res = true
		else
			if Poll[n].var.target == nil then
				Res = true
			end
		end
	end
   
	PV:SendMessage("Call",EUID,Res,n)
end)


PV:BindToMessageParallel("Sync",function(EUID,Data)

	PV:SendMessage("res",EUID,Data)
end)
PV:BindToMessage("Call",function(UID,Res,n)
	local module = require(script.Parent.Unsafe)

	module[UID] = module[UID] or {}
	module[UID]["Res"] = module[UID]["Res"] or {}
	module[UID]["Res"][n] = Res
		
	
end)
local Vector = require(game.ReplicatedStorage.Vector)
local Unsafe = require(game.ReplicatedStorage.Vector.UnsafeVector)
local PV = script.Parent
print("yo")
PV:BindToMessageParallel("Write",function(v,n)
	if not Unsafe[v] then
		Unsafe.Init(n,v)
	end

	Unsafe.UnsafeWrite(n,v,1)
end)
PV:BindToMessageParallel("BitMap",function(EUID,bitmap,i)
	Unsafe[EUID].Meta.BitMap[i] = bitmap
end)
PV:BindToMessageParallel("Sync",function(EUID,Data)
	local Res = Unsafe.Sync(EUID,Data)
	PV:SendMessage("res",EUID,Res)
end)
local Vector = require(game.ReplicatedStorage.Vector)
local Unsafe = require(game.ReplicatedStorage.Vector.Unsafe)

script.Parent:BindToMessageParallel("Write",function(v,n)
	Unsafe.UnsafeWrite(v,n)
end)
script.Parent:BindToMessageParallel("BitMap",function(EUID,bitmap,i)
	Unsafe[EUID].Meta.BitMap[i] = bitmap
end)
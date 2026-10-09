local module = {}
local Vector = require(script.Parent)
local Collector = game:GetService("CollectionService")
function module.Init(Entity,...)
	local Info = ...
	local Wrapper = {Data = {}}
	if not Entity then
		warn("No Entity Given")
		return 
	end
	if Info then
		if Info.Data then
			Wrapper.Data = Info.Data
		else
			Wrapper.Data = Info
		end
	end
	
	Vector.Init(Entity,Wrapper)
	
end
function module.Write(Entity,Data)
    if Data then
		local EUID 
	if  Entity:IsA("Player") then
		EUID = Entity.UserId
	else
		local Tags = Collector:GetTags(Entity)
		EUID = Tags["EUID"]
	end
	if not EUID then
		warn("Vector Has Not Been Made")
		return 
	end
	
	local Wrapper = {}
	if Data.Value then
		Wrapper = {Data}
	else
		Wrapper = Data
	end
	
	Vector.Write(EUID,Wrapper)
	end
end
function module.Read(Entity,Data)
	
if Data then
	local EUID 
	if  Entity:IsA("Player") then
		EUID = Entity.UserId
	else
		local Tags = Collector:GetTags(Entity)
		EUID = Tags["EUID"]
	end
	if not EUID then
		warn("Vector Has Not Been Made")
		return 
	end
	return Vector.Read(EUID,Data)
end
end
return module


-- Author: GreenModt/Fentix/Famix
-- Version: 1.2.2v

local module = {}
local Vector = require(script.Parent)
local Matrix = require(script.Parent.Matrix)
local Field =  require(script.Parent.MatrixField)
local Collector = game:GetService("CollectionService")

function module.Init(Entity,...)
	local Info = ...
	local Wrapper = {Data = {}}
	if not Info.Matrix then
	if not Entity then
		warn("No Entity Given")
		return 
	end
	end
	if Info then
		if Info.Data then
			Wrapper.Data = Info.Data
		else
			Wrapper.Data = Info
		end
	end
	print(Wrapper)
	Vector.Init(Entity,Wrapper)
	
end
function module.Write(Entity,Data)

    if Data then
		local EUID 
	if  Entity:IsA("Player") then
		EUID = Entity.UserId
	else
		local Tags = Collector:GetTags(Entity)
		EUID = Tags[1]
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
	
	if Data.Target then
		if  Field[Data.Target] then
		
			
			Matrix.Write(Data.Target,EUID,Wrapper)
			
			return
		end
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
		EUID = Tags[1]
	end
	if not EUID then
		warn("Vector Has Not Been Made")
		return 
	end
	return Vector.Read(EUID,Data)
end
end

function module.Get(Entity)
	local EUID 
	if  Entity:IsA("Player") then
		EUID = Entity.UserId
	else
		local Tags = Collector:GetTags(Entity)
		EUID = Tags[1]
	end
	if not EUID then
		warn("Vector Has Not Been Made")
		return 
	end
	if EUID then
		return Vector.Get(EUID),EUID
	end
	return 
end
function module.Listen(Entity,Wrap,Target,Callback,Timeout)
	if Entity then
		local EUID 
		if  Entity:IsA("Player") then
			EUID = Entity.UserId
		else
			local Tags = Collector:GetTags(Entity)
			EUID = Tags[1]
		end
		if not EUID then
			warn("Vector Has Not Been Made")
			return 
		end
		if not Wrap.Var then
			warn("No Variable Given")
			return false
		elseif  not Wrap.Type then
			Wrap.Type = "Poll"
	        
		end
		
		Vector.Listen(EUID,Wrap.Var,Wrap.Type,Wrap.Duration or nil,Target,Callback,Timeout or nil)
		
		return true
	end
	
end
function module.Rollback(Entity,Global)
	if Entity then
		local EUID 
		if  Entity:IsA("Player") then
			EUID = Entity.UserId
		else
			local Tags = Collector:GetTags(Entity)
			EUID = Tags[1]
		end
		if not EUID then
			warn("Vector Has Not Been Made")
			return 
		end
		Vector.Rollback(EUID,Global)
		
		return true
	end
end
-- experimentals
function module.Lock(Entity,Target)
	if Entity then
		local EUID
		if  Entity:IsA("Player") then
			EUID = Entity.UserId
		else
			local Tags = Collector:GetTags(Entity)
			EUID = Tags[1]
		end
		if not EUID then
			warn("Vector Has Not Been Made")
			return 
		end
		
		Vector.Lock(EUID,Target)
	end
end
return module

--!nonstrict
--!optimize 2

-- Author: GreenModt/Fentix/Famix
-- Version: 1.5.0v

local HTTPService = game:GetService("HttpService")
local Encoder = game:GetService("EncodingService")
local Collector = game:GetService("CollectionService")
local VectorField = require(script.Parent.VectorField)
local MatrixField = require(script.Parent.MatrixField)
local VectorTypes = require(script.Parent.VectorTypes)
local UnsafeVector =  require(script.Parent.UnsafeVector)
local Config = require(script.Parent.Config)



local Matrix = {
	Batch = {};
	
	Batching = false;}

Matrix.Task =  function()
	Matrix.Serde(Matrix.Batch,false)
	Matrix.ShallowClient(nil,"Batch",nil,Matrix.Batch)
	Matrix.Batch = {}
	Matrix.Batching = false
end;

function Matrix.Read(EUID: number | string,Var: any)

	local VectorS = MatrixField[EUID] 
	local Type = VectorS.Data[Var].Type
	local Value = Var.Value or VectorS.Data[Var].Value
	local Ref = VectorS.Data[Var]

	local Res 
	if VectorS then
		local t = typeof(Value)
		if t == "buffer" then
			if Type == "f32" then
				Res = buffer.readf32(Value,0)
			elseif Type == "f64" then
				Res = buffer.readf64(Value,0)
			elseif Type == "Vector3" then
				Res = Vector3.new(buffer.readf32(Value,0),buffer.readf32(Value,4),buffer.readf32(Value,8))
			elseif Type == "Bool" then
				Res = buffer.readu8(Value,0)

			elseif Type == "number" then
				Res = buffer.readf64(Value,0)
			else
				Res = Value
			end
		else
			Res = Value
		end
	end

	
	VectorS.Meta.LastUpdate = os.clock()
	
	return Res
end
function Matrix.Write(EUID,UID,...)
	local matrix = MatrixField[EUID]
	local Wrap = ...
	for i,v in pairs(Wrap) do
	Wrap.Target = nil
	
	if matrix.Meta.Dot[Wrap.Var] then
		return
	end

	local Res = Matrix.Lock(EUID,UID,{Attempts = 0,Target = i,UID = UID})
	if Res == "Granted" or "Stolen" then
     
		matrix.Data[i].Value = v.Value
		matrix.Data[i].Type = typeof(v.Value)
	    
	    
		Matrix.Batch[#Matrix.Batch + 1] = {UID = EUID,Data = v.Value,Index = i,Type = v.Type or typeof(v.Value)}
	  

		Matrix.Lock(EUID,UID,{Attempts = 0,Target = i,UID = UID})
	end
	end
	if  Matrix.Batching  then return end 
	Matrix.Batching = true
	task.delay(0.5,Matrix.Task)
	
end
function Matrix.Lock(EUID,UID,...)
	local matrix = MatrixField[EUID]
	local Wrap = ...
	
	if matrix.Meta.Dot[Wrap.Target] then
	
		local target =  matrix.Meta.Dot[Wrap.Target]
		if target.UID == UID then
			matrix.Meta.Dot[Wrap.Target]= nil
			return "Unlocked"
		
		end
		
		if target.Attempts > 2 then
			if matrix.Meta.Rank[UID] and  matrix.Meta.Rank[target.UID] then
			if matrix.Meta.Rank[UID] > matrix.Meta.Rank[target.UID] then
				matrix.Meta.Dot[Wrap.Target] = Wrap
				target.Attempts = 0
				return "Stolen"
			else
				return "Locked"
			end
			else
				local Vel =  MatrixField[EUID].Meta.VelocityRank
				if Vel[UID] < Vel[target.UID] then
					matrix.Meta.Dot[Wrap.Target] = Wrap
					target.Attempts = 0
					return "Stolen"
				else
					return "Locked"
				end
			
				
			end
		else
			target.Attempts += 1
			return "Locked"
		end
	else
	
		matrix.Meta.Dot = {[Wrap.Target] = {}}
		matrix.Meta.Dot[Wrap.Target] = Wrap
		return "Granted"
	end
	
end
function Matrix.VelRank(EUID,Value,Index)

	local Table  = MatrixField[EUID].Meta.VelocityRank
	if Value then
	Table[Index] = Value
	else
		for i,v in pairs(VectorField) do
		    Table[v.Meta.UID] = v.Meta.Delay
		end
	end
	
end
function Matrix.Serde(Info: any,Compress: boolean)
	for i,v in pairs(Info) do
		if Info.Compressed then continue end
		local t = typeof(v.Data)

		if t == "table" then
			continue

		elseif t == "number" then
			if v.Type == "f32" then
				v.Data = math.round(v.Data * 100) / 100
				local b = buffer.create(4)
				buffer.writef32(b,0,v.Data)
				if Compress then
					b = Encoder:CompressBuffer(b,Enum.CompressionAlgorithm.Zstd)
				end
				v.Data = b
			else
				local b = buffer.create(8)
				buffer.writef64(b,0,v.Data)
				if Compress then
					b = Encoder:CompressBuffer(b,Enum.CompressionAlgorithm.Zstd)
				end
				v.Data = b
			end
		elseif t == "Vector3" then
			local b = buffer.create(12)
			buffer.writef32(b,0,v.X)
			buffer.writef32(b,4,v.Y)
			buffer.writef32(b,8,v.Z)
			if Compress then
				b = Encoder:CompressBuffer(b,Enum.CompressionAlgorithm.Zstd)
			end
			v.Data = b
		elseif t == "boolean" then
			local b = buffer.create(1)
			buffer.writeu8(b,0,v.Data and 1 or 0)
			if Compress then
				b = Encoder:CompressBuffer(b,Enum.CompressionAlgorithm.Zstd)
			end
			v.Data = b
		elseif t == "buffer" then
			continue
		end
		if Compress then

			v.Compressed = true
		end
	end

end
function Matrix.ShallowClient(EUID,Type,Target,Correction)

	local VS = MatrixField[EUID]
	local ShallowCopy 
	if VS then
		ShallowCopy = table.freeze(table.clone(VS))
	end
	local Remote = script.Parent.Shallow


	if Correction then

		Remote:FireAllClients(EUID,Correction,Type,Target)
	else

		Remote:FireAllClients(EUID,ShallowCopy,Type)
	end



end
return Matrix

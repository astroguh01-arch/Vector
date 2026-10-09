--!nonstrict
--!optimize 2

local Vector = {}
local HTTPService = game:GetService("HttpService")
local Collector = game:GetService("CollectionService")
local VectorField = require(script.VectorField)
local VectorTypes = require(script.VectorTypes)
local UnsafeVector =  require(script.UnsafeVector)


local Vector = {}

Vector = { 
	Users = 0,
	Entities = 0,
	Work = 0;
	Threads = {
		["Parallel1"] = {
			Work = 0 ;
			PV = 1;
		};
		["Parallel2"] = {
			Work = 0 ;
			PV = 1;
		};
	},
	GVersion = 1;
	Poll = nil;
	PollN = 1;
	PollT = {};
	GlobalUpdate = os.clock();
	Delay = 0;
}
local function VelSort(EUID: number | string)

	for i,v in pairs(VectorField[EUID].Data) do
	
		if VectorField[EUID].Meta.VelocityMap.Slow[i] then
			local value = table.remove(VectorField[EUID].Data, i)
			table.insert(VectorField[EUID].Data,v)
		end
	end
	
end

local function NToM(N: any)
	local Res = 0 
	for i,v in N do
		Res += v 
	end
	if Res >= 5 then
		return true
	else
		return false
	end
end
local function CountPrecision(n)
	n = math.abs(n)
	local decimals = 0
	local Space = 0
	local NDetail = 0
	local MDetail = 0
	local Ns = {}
	local Res = 0
	while decimals < 15 do
		n *= 10
		decimals += 1

		local digit = math.floor(n) % 10


		if (Space + 1) < MDetail  then
			decimals = 15
			Res = Space + MDetail
			break
		end
		if Space < NDetail and NToM(Ns) then
			decimals = 15
			Res = Space + NDetail
			break
		end
		if digit == 0 then
			Space += 1
		elseif digit >= 5 then
			MDetail += 1
		else
			NDetail += 1
			Ns[NDetail] = digit
		end

	end


	return math.clamp(Res,1,7)
end
local function CheckRate()
	
	local Delta = math.abs((os.clock() - Vector.GlobalUpdate) / (Vector.GlobalUpdate + 0.01 / 10))
	if Vector.Delay then
	local Gate = Delta * 0.4 + (1 - 0.4) * Vector.Delay 
	if Delta > Gate then
		Vector.Delay = Delta
		Vector.GlobalUpdate = os.clock()
		
		return true
	else
		Vector.GlobalUpdate = os.clock()
		return false
			
	end
	else
		Vector.Delay = Delta
		Vector.GlobalUpdate = os.clock()
	end
	
end

	

local function CycleTime(EUID: number | string)
    local LastCycle = VectorField[EUID].Meta.LastCycle 
	local Resolution = VectorField[EUID].Meta.Resolution or 0.1 
	
	local CycleLimit = (os.clock() - LastCycle) / (Resolution / 0.1)
	local CyclesPassed = math.floor(CycleLimit / 25.6)

	if CyclesPassed > 0 then
		VectorField[EUID].Meta.Cycle += CyclesPassed 
	end
	
	return VectorField[EUID].Meta.Cycle
end
function Vector.Resolution(EUID: number | string)
	local Resolution = VectorField[EUID].Meta.Resolution or 0.1
	local Fastest = VectorField[EUID].Meta.LastUpdate 
	local Cycle = CycleTime(EUID)
	local Cycles = Cycle * (Resolution / 10)
	local FBit = (math.floor(Fastest / Resolution) % 256) * Cycles
	local Precision =  CountPrecision(FBit)
	
	VectorField[EUID].Meta.Resolution = 10 ^ (1 - Precision)
	return VectorField[EUID].Meta.Resolution
end
@native
local function FindVel(EUID: number | string)
	local Highest = 0
	
	for i,v in pairs(VectorField[EUID].Meta.IDs) do
		local Bits = Vector.BitIndex(EUID,i)
		local i2 = i - 1
		local Offset = 4 + math.floor(i2 / 4) * 4
		local Shift = (i2 % 4) * 8
		local Vbits = buffer.readu32(Bits.Buffer, Offset)
		local Resolution = Vector.Resolution(EUID) or 0.1
		local Cycles = VectorField[EUID].Meta.Cycle * (Resolution / 10)
		local PTime = (bit32.band(
			bit32.rshift(Vbits, Shift),
			0xFF
		) * Resolution) * Cycles
		
		if PTime > Highest then
			Highest = PTime
		end
	end
	return Highest
end
@native
function Vector.Velocity(EUID: number | string,Var: any)
	local ID = table.find(VectorField[EUID].Meta.IDs,Var)
	local Bits = Vector.BitIndex(EUID,ID)

	local i = ID - 1
	local Offset = 4 + math.floor(i / 4) * 4
	local Shift = (i % 4) * 8
	local Vbits = buffer.readu32(Bits.Buffer, Offset)
	local Resolution = Vector.Resolution(EUID) or 0.1
	local Cycle = CycleTime(EUID)
	local Cycles = Cycle * (Resolution / 10)
	local NTime = ((math.floor(os.clock() / Resolution) % 256) * Resolution) * Cycles
	local PTime = (bit32.band(
		bit32.rshift(Vbits, Shift),
		0xFF
	) * Resolution) * Cycles
	
	local Delta = math.abs((NTime - PTime) / (NTime + Resolution / 10))
	

	
	local SlowestVel = FindVel(EUID)
	local Fastest = VectorField[EUID].Meta.LastUpdate 
	local FBit = (math.floor(Fastest / Resolution) % 256) * Cycles
	local RV = VectorField[EUID].Meta.RV or ((FBit + SlowestVel) / 2 )
	if not VectorField[EUID].Meta.RV then
		VectorField[EUID].Meta.RV = ((FBit + SlowestVel) / 2 )
	end
	local Gate = 0.4 * Resolution
	local a = 0.4
	RV = (FBit * a + (1 - a) * RV) * (Resolution / 10)
	VectorField[EUID].Meta.DeltaRV = math.abs( (VectorField[EUID].Meta.RV - RV ) / (VectorField[EUID].Meta.RV + (Resolution / 10)))
	
	if Delta > VectorField[EUID].Meta.DeltaRV + Gate then
		VectorField[EUID].Meta.VelocityMap.Slow[table.find(VectorField[EUID].Meta.IDs,Var)] = Var
	elseif Delta < VectorField[EUID].Meta.DeltaRV - Gate then
		VectorField[EUID].Meta.VelocityMap.Fast[table.find(VectorField[EUID].Meta.IDs,Var)] = Var
	end
	

	
	VelSort(EUID)
end
function Vector.BitIndex(EUID: number | string,N : number)
	return VectorField[EUID].Meta.BitMap[math.ceil(N  / 32)] or false
end
@native
local function TimeBit(EUID: number | string,N : number,Time: any)
	local Index = table.find(VectorField[EUID].Meta.IDs,N)

	local BitMap = Vector.BitIndex(EUID,Index)
	if BitMap == false then
		local Map =  Vector.BitMap(EUID)
		BitMap = Map[Index]
	end
	local Buffer = BitMap.Buffer
	local i = Index - 1
	local Info = 0
	local Resolution = Vector.Resolution(EUID) or 0.1
	
	local TimeBits = math.floor(Time / Resolution) % 256 
	local Offset = 4 + math.floor(i / 4) * 4
	local Shift = (i % 4) * 8
	local Mask = bit32.lshift(0xFF,Shift)
	local bits = buffer.readu32(Buffer, Offset)
	
	bits = bit32.band(bits, bit32.bnot(Mask))
	

	
	Info = bit32.bor(bits, bit32.lshift(TimeBits,Shift))

	buffer.writeu32(Buffer,Offset,Info)
	
	return buffer.readu32(Buffer,Offset)
end
@native
function Vector.BitMap(EUID: number | string)
	local VectorS = VectorField[EUID]
	local BitStart = #VectorS.Meta.BitMap

	--local Bits = (VectorS.Meta.BitMap[BitStart].LastIndex + 32 * (#VectorS.Meta.BitMap - 1))
	--local NewIndex = #VectorS.Meta.IDs - Bits
	
	local Index 
	
	local MBitGroups = math.ceil((#VectorS.Meta.IDs) / 32)
	local Offset = 0
    local Index = 0
	for i=1,MBitGroups do
		
		if VectorS.Meta.BitMap[i] == nil or VectorS.Meta.BitMap[i].LastIndex == 32 then
			local b = buffer.create(36)


			for i2=0,31 do
				local ID = VectorS.Meta.IDs[Offset + i2 + 1]
				if ID then

					local bits = buffer.readu32(b, 0)
					bits = bit32.bor(bits, bit32.lshift(1, i2))
					buffer.writeu32(b, 0, bits)
					Index = i2
				else
					local bits = buffer.readu32(b, 0)
					bits = bit32.bor(bits, bit32.lshift(0, i2))
					buffer.writeu32(b, 0, bits)
					Index = i2
					break
				end

			end

			VectorS.Meta.BitMap[i] = {
				LastIndex = 0;
				Buffer = b;
			}
			Offset += Index
		end
		
		if VectorS.Meta.BitMap[i] then
			if VectorS.Meta.BitMap[i].LastIndex ~= 32 then

				for i2=VectorS.Meta.BitMap[i].LastIndex - 1,31 do
					local ID = VectorS.Meta.IDs[Offset + i2 + 1]
					if ID then
						
						local bits = buffer.readu32(VectorS.Meta.BitMap[i].Buffer, 0)
						bits = bit32.bor(bits, bit32.lshift(1, i2))
						buffer.writeu32(VectorS.Meta.BitMap[i].Buffer, 0, bits)
						Index = i2
					else
						local bits = buffer.readu32(VectorS.Meta.BitMap[i].Buffer, 0)
						bits = bit32.bor(bits, bit32.lshift(0,  i2))
						buffer.writeu32(VectorS.Meta.BitMap[i].Buffer, 0, bits)
						Index = i2
						break
					end
					
			   

				
				end
				Offset += Index
				VectorS.Meta.BitMap[i].LastIndex += Index
			end
			
		end
		
	
			
	
	
	end
	
		

	
	return VectorS.Meta.BitMap
end
function Vector.Read(EUID: number | string,Var: any)
	local VectorS = VectorField[EUID]
	local Type = VectorS.Data[Var].Type
	local Value = VectorS.Data[Var].Value
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
		end
		elseif Type == "Number" then
			Res = buffer.readf64(Value,0)
		else
			Res = Value
		end
	end
	Vector.Velocity(EUID,Var)
	return Res
end
function Vector.Deserialize(Info: VectorTypes.RegisterInfo)
	for i,v in pairs(Info.Data) do
		local t = typeof(v.Value)
		if t == "buffer" then
			if v.Type == "number" then
				v.Value = buffer.readf64(v.Value,0)
			end
			if v.Type == "f32" then
				v.Value = buffer.readf32(v.Value,0)
			elseif v.Type == "f64" then
				v.Value = buffer.readf64(v.Value,0)
			elseif v.Type == "Vector3" then
				v.Value = Vector3.new(buffer.readf32(v.Value,0),buffer.readf32(v.Value,4),buffer.readf32(v.Value,8))
			elseif v.Type == "Bool" then
				v.Value = buffer.readu8(v.Value,0)
			end
		else
			continue	
		end
	end
	Info.Meta.LastUpdate = os.clock()
	Info.Meta.Valid = true
	Info.Meta.Compact= false
end
function Vector.Serialize(Info: VectorTypes.RegisterInfo)
	for i,v in pairs(Info.Data) do
		local t = typeof(v.Value)

		if t == "table" then
			continue
			
		elseif t == "number" then
			if v.Type == "f32" then
				v.Value = math.round(v.Value * 100) / 100
				local b = buffer.create(4)
				buffer.writef32(b,0,v.Value)
				v.Value = b
			else
				local b = buffer.create(8)
				buffer.writef64(b,0,v.Value)
				v.Value = b
			end
		elseif t == "Vector3" then
			local b = buffer.create(12)
			buffer.writef32(b,0,v.X)
			buffer.writef32(b,4,v.Y)
			buffer.writef32(b,8,v.Z)
			v.Value = b
		elseif t == "boolean" then
			local b = buffer.create(1)
			buffer.writeu8(b,0,v.Value and 1 or 0)
			v.Value = b
		elseif t == "buffer" then
			continue
		end
	end
	Info.Meta.LastUpdate = os.clock()
	Info.Meta.Valid = true
	Info.Meta.Compact= true
end
function Vector.Write(EUID: number | string,Info: any)
	if EUID then
	
		if VectorField[EUID] then
			
			local VS = VectorField[EUID]
			local WriteF = {}
			
			Vector.Work += #WriteF 
			
			--local DelayN = CheckRate()
			--if DelayN then
			--	UnsafeVector.Distribute(EUID,"Write",Info,Vector.Threads)
			--return 
			--else
			--	UnsafeVector.Sync(EUID,VectorField[EUID])
			--end
			
			for i,v in pairs(Info) do
				if VS.Data[i] then
					WriteF[i] = v.Value
				else
					VS.Data[i] = {Value = v.Value,Type = v.Type or typeof(v.Value),Critical = v.Critical or false}
					
					Vector.Velocity(EUID,i)
					TimeBit(EUID,i,os.clock())
				
				end
			
			end
		
			if VS.Meta.Valid then
				if VS.Meta.Compact then
					for i,v in pairs(WriteF) do
						Vector.Deserialize(VS)
					
		
					end
			
				end
				for i,v in pairs(WriteF) do
					 if VS.Data[i] then
					
							VS.Data[i].Value = Info[i].Value
						VS.Data[i].Type = Info[i].Type or typeof(Info[i].Value)
					
						    Vector.Velocity(EUID,i)
						TimeBit(EUID,i,os.clock())
					end
				
				end
			
			end
		
			if not VS.Meta.Compact then
			
				Vector.Serialize(VS)
				
			end
			
			
		end
	end
end
function Vector.ShallowClient(EUID,Type)
	local VS = VectorField[EUID]
	if not VectorField[EUID].Meta.Compact then
		Vector.Serialize(VS)
	end
	local Remote = script.Shallow
	local ShallowCopy = table.freeze(table.clone(VS))
	Remote:FireAllClients(EUID,ShallowCopy,Type)
	
end

function Vector.Register(Entity: Player | Model,Info: VectorTypes.RegisterInfo)
    local EUID
	if  Entity:IsA("Player") then
		EUID = Entity.UserId
		VectorField[EUID] =  {}
		VectorField[EUID] = {Data = Info.Data
	   
		;
			Meta = {
				UID = Entity.UserId;
				Listening = {};
				Dot = {};
				IDs = {};
				VelocityMap = {
				Fast = {}; 
                Slow = {};};
				BitMap = {};
				LastUpdate = os.clock();
				LastCycle = os.clock();
				Cycle = 1;
				Valid = true;
				Compact = false;
				Version = 1;
			};
			Prev = {}
		}
		local mt = {__newindex = Vector.Write,__index = Vector.Read}

		setmetatable(VectorField[EUID].Data,mt)
		local N = 0
		for i,v in pairs(Info.Data) do
			
			if v.Critical then
				VectorField[EUID].Prev[i] = v
			end
			N += 1
			VectorField[EUID].Meta.IDs[N] = i
		end
	else
	    EUID = HTTPService:GenerateGUID(false)
		VectorField[EUID] =  {}
		VectorField[EUID] = {Data =Info.Data
		    
			;	
			Meta = {
				UID = EUID;
				Listening = {};
				Dot = {};
				IDs = {};
				VelocityMap = {
					Fast = {}; 
					Slow = {};};
				BitMap = {};
				LastUpdate = os.clock();
				LastCycle = os.clock();
				Cycle = 1;
				Valid = true;
				Compact = false;
				Version = 1;
			};
			Prev = {}
		}
		local mt = {__newindex = Vector.Write,__index = Vector.Read}
		
		setmetatable(VectorField[EUID].Data,mt)
		
		local N = 0
		for i,v in pairs(Info.Data) do
			
			if v.Critical then
				VectorField[EUID].Prev[i] = v
			end
			N += 1
			VectorField[EUID].Meta.IDs[N] = i
		end
		Collector:AddTag(Entity,tostring(EUID),"EUID")
	  end

     
	return VectorField[EUID]
end
function Vector.Init(Entity: Player | Model,Info: VectorTypes.RegisterInfo)
	if Entity == nil then
		return
	end
	if Info == nil then
		Info = {Data = {}}
	end
	for i,v in pairs(Info.Data) do
		if not v.Type then
			v.Type = typeof(v.Value)
		end
	end
	Vector.Entities += 1
	if Entity:IsA("Player") then 
		Vector.Users += 1
	end

	Vector.GVersion += 1

	local VectorN = Vector.Register(Entity,Info)
	Vector.Serialize(VectorN)
	Vector.BitMap(VectorN.Meta.UID)
	--TimeBit(VectorN.Meta.UID,"Health",os.clock())
	
	--task.wait(0.5)

	--TimeBit(VectorN.Meta.UID,"Mana",os.clock())
	--task.wait(0.5)
	--Vector.Velocity(VectorN.Meta.UID,"Mana")
	--VectorN.Meta.LastUpdate = os.clock()
	--Vector.Velocity(VectorN.Meta.UID,"Health")

    return VectorN
end
function Vector.Identify(Instance : Player | Model)
	if Instance:IsA("Model") then
		return VectorField[Collector:GetTags(Instance)["EUID"]]
	else
		return VectorField[Instance.UserId]
	end
end
function Vector.Rollback(Target: VectorTypes.VectorElement,Global: boolean)
	if Global then
		for i,v in pairs(VectorField) do
			Vector.Deserialize(v)
			for i2,v2 in pairs(v.Prev) do
				
				v.Data[i2] = v2
				
			end
			Vector.Serialize(v)
		end
	else
		Vector.Deserialize(VectorField[Target])
		for i,v in pairs(VectorField[Target].Prev) do
		
			VectorField[Target].Data[i] = v
			
		end
		Vector.Serialize(VectorField[Target])
	end
	
end
local function VelIndex(EUID,N)
	local VS = VectorField[EUID]
	if VS.Meta.VelocityMap.Fast[N] then
		return "Fast"
	else
		return "Slow"
	end
end
function Vector.Lock(EUID,Target,Ref)
	local VS = VectorField[EUID]
	if not VS.Meta.Dot[Target] then
    
		VS.Meta.Dot[Target] = {Value = Target.Value,Type = Target.Type,Intent = Ref,Attempts = 0}
	elseif VS.Meta.Dot[Target].Intent ~= Ref then
		VS.Meta.Dot[Target].Attempts += 1
		local target = VS.Meta.Dot[Target].Intent
		local index = table.find(VS.Meta.IDs,target)
		local indexF = table.find(VS.Meta.IDs,Ref)
		local VelT = VelIndex(EUID,index)
		local Vel = VelIndex(EUID,indexF)
		local Attempts =VS.Meta.Dot[Target].Attempts 
		
		if VelT == "Slow" and Attempts > 2 then
			if Vel == "Fast"then
				VS.Meta.Dot[Target] = {Value = Target.Value,Type = Target.Type,Intent = Ref,Attempts = 0}
			else
				return "Locked"
			end
		else
			return "Locked"
		end
	else
		VS.Meta.Dot[Target] = nil
	end
	
end
function Vector.Listen(Info: VectorTypes.VectorElement,Var: any,Type: string,CallbackF: any,Duration: number)
	-- Poll - constantly check
    -- Event -  connect and wait for event
	-- OnWrite - lazy listneing
	Vector.SF = Vector.Heartbeat or 0
	Info.Data.Listening[Var] = {Type = Type,LastUpdate = os.clock(),Callback = CallbackF,Value = Var.Value,Expiration = Duration}
	if Type == "Poll" then
	Vector.PollN += 1
		Vector.PollT[Vector.PollN] = {EUID = Info.Meta.UID, var = Info.Data.Listening[Var]}
	if Vector.Poll then return end
	
	Vector.Poll = game.RunService.Heartbeat:Connect(function(dt)
	
		for i,v in pairs(Vector.PollT) do
				Vector.SF += 1
			if VectorField[v.EUID].Meta.VelocityMap.Slow[v.var] then
					if Vector.SF % 4 ~= 0 then
						Vector.SF = 0
					continue
					end
			end
			local Field = VectorField[v.EUID].Meta.Listening[v.var]
			if VectorField[v.EUID].Data[v.var].Value ~= v.var.Value then
				Field.Callback(VectorField[v.EUID])
				Vector.PollN -= 1
				Vector.PollT[i] = nil
				VectorField[v.EUID].Meta.Listening[v.var] = nil
				continue
			end
			if VectorField[v.EUID].Meta.Listening[v.var].Expiration then
			if os.clock() - v.var.LastUpdate > Duration then
				Vector.PollN -= 1
				Vector.PollT[i] = nil
					VectorField[v.EUID].Meta.Listening[v.var] = nil
				continue
			end
			end
		end
		if Vector.PollN <= 0 or next(Vector.PollT) == nil then
			Vector.Poll:Disconnect()
			Vector.Poll = nil
		end
	end)
	end
	if Type == "OnWrite" then

		-- lwk ts useless update checks it
	end
	if Type == "Event" then
		script.Shallow.OnServerEvent:Connect(CallbackF)
	end
	
end
return Vector



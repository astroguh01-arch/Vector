--!strict
local VectorTypes = {}

export type BitMapEntry = {
	Buffer: buffer,
    LastIndex: number
}

-- The structure of individual data elements passed inside Info.Data
export type DataElement = {
	Critical: boolean?,
	Value: any,
    Type: any,
	[string]: any
}

export type VectorMetadata = {
	UID: number | string, -- Can be a UserId (number) or GUID (string)
	Listening: {string},
	Dot: {any},
	IDs: {any},
	VelocityMap: {
		Fast: {[number]: any},
		Slow: {[number]: any}
	},
	BitMap: {BitMapEntry},
	LastUpdate: number,
	LastCycle: number,
	Cycle: number,
	Valid: boolean,
	Compact: boolean,
	Version: number,
	Resolution: number?,
	RV: number?,
	DeltaRV: number?,
}

-- The full layout created by Vector.Register
export type VectorElement = {
	Data: {[any]: DataElement},
	Meta: VectorMetadata,
	Prev: {[any]: DataElement}
}

-- The layout of the 'Info' argument passed to Vector.Register
export type RegisterInfo = {
	Data: {[any]: DataElement}
}

return VectorTypes



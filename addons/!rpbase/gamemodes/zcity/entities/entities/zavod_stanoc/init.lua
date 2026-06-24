AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/props_wasteland/laundry_washer003.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()
	self:SetEnabled(false)
end

function ENT:Use(ply)
	if true then 
		-- ГОЙДА
	end
end

--buttons/lever4.wav
--cigarette_factory/cf_machine_loop.wav
--buttons/lever6.wav
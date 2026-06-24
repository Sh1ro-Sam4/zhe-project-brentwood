AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local detaltofinal = {
	["models/props_c17/FurnitureCouch001a.mdl"] = "models/props_c17/FurnitureCouch001a.mdl",
	["models/props_c17/FurnitureCouch002a.mdl"] = "models/props_c17/FurnitureCouch002a.mdl",
	["models/props_c17/FurnitureDresser001a.mdl"] = "models/props_c17/FurnitureDresser001a.mdl",
}

function ENT:Initialize()
	local num = math.random(table.Count(detaltofinal))
	local count = 1
	local model = 'models/hunter/blocks/cube05x05x025.mdl'
	for k,v in pairs(detaltofinal) do
		if count == num then
			model = k
		end
		count = count + 1
	end

	self:SetModel(model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then
		phys:SetMass(250)
	end

	timer.Create("SelfLifeTime_"..self:EntIndex(), 600, 1, function() 
		if IsValid(self) then
			self:Remove()
		end
	end)
end

function ENT:Use(ply)
	if true then 
	end
end

-- function ENT:Think()
	
-- 	if !self:GetPos():WithinAABox(Vector(1681, -2307, -97), Vector(1220, -1560, 421)) then
-- 		self:Remove()
-- 	end

-- 	self:NextThink( CurTime() + 1 )

-- 	return true
-- end
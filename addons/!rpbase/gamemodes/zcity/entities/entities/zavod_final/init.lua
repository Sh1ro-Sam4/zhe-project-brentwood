AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	--self:SetModel('models/props_phx/gears/bevel90_24.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()
	self:SetSubMaterial(0,"phoenix_storms/gear")
	self:SetColor(Color(182,182,182))
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )

	self:SetCustomCollisionCheck(true)
	self.IsPassableRation = true

	local phys = self:GetPhysicsObject()

	if ( IsValid( phys ) ) then -- Always check with IsValid! The ent might not have physics!
		phys:SetMass(130)
	end

	timer.Create("SelfLifeTime_"..self:EntIndex(), 120, 1, function() 
		if IsValid(self) then
			self:Remove()
		end
	end)
	
end

function ENT:Think()
	
	--for k,v in pairs(ents.FindInBox(Vector(2483, 3000, -169), Vector(1847, 3417, 201))) do
	--	
	--end
	if !self:GetPos():WithinAABox(Vector(1681, -2307, -97), Vector(1220, -1560, 421)) then
		self:Remove()
	end

	self:NextThink( CurTime() + 1 )

	return true
end

function ENT:Use(ply)
	if true then 
		-- ГОЙДА
	end
end
function ENT:OnTakeDamage(damageData)
	self:Remove()
end

function OnRemove()
	if timer.Exists("SelfLifeTime_"..self:EntIndex()) then 
		timer.Remove("SelfLifeTime_"..self:EntIndex())
	end
end
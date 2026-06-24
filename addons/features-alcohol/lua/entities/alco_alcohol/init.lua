AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/props_junk/garbage_milkcarton001a.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysWake()
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetTrigger(true)
end

function ENT:StartTouch(ent)
	if IsValid(ent) and (ent:GetClass() == 'alco_jar') then
		if ent:GetAlcohol() >= ent:GetMaxAlcohol() then return end
		self:Remove()
		ent:SetAlcohol(ent:GetAlcohol() + 1)
		ent:EmitSound("ambient/water/water_splash1.wav")
	end
end

function ENT:OnTakeDamage(damageData)
	self:Remove()
end
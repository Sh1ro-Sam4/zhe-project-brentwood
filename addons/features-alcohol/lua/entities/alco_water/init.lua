AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/props_junk/garbage_plasticbottle003a.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysWake()
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetTrigger(true)
end

function ENT:StartTouch(ent)
	if IsValid(ent) and (ent:GetClass() == 'alco_jar') then
		if ent:GetWater() >= ent:GetMaxWater() then return end
		self:Remove()
		ent:SetWater(ent:GetWater() + 1)
		ent:EmitSound("ambient/water/water_splash1.wav")
	end
end

function ENT:OnTakeDamage(damageData)
	self:Remove()
end
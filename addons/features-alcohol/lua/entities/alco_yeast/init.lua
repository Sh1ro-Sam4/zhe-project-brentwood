AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/props_junk/garbage_bag001a.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysWake()
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetTrigger(true)
end

function ENT:StartTouch(ent)
	if IsValid(ent) and (ent:GetClass() == 'alco_jar') then
		if ent:GetYeast() >= ent:GetMaxYeast() then return end
		self:Remove()
		ent:SetYeast(ent:GetYeast() + 1)
		ent:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav")
	end
end

function ENT:OnTakeDamage(damageData)
	self:Remove()
end
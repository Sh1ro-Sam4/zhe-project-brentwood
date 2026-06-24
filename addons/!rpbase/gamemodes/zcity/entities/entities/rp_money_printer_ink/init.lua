AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/props_lab/jar01b.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysWake()
	self:SetSubMaterial(0,"models/props_pipes/Pipesystem01a_skin3")
	self:SetColor(Color(114,114,114))
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetTrigger(true)
end

function ENT:StartTouch(ent)
	if (not self.Used) and IsValid(ent) and (ent:GetClass() == 'rp_money_printer') then
		if ent:GetInk() >= ent:GetUD_Max() * 15 then return end
		self.Used = true
		self:Remove()
		ent:SetInk(ent:GetUD_Max() * 15)
		--if ent:GetInk() >= ent:GetUD_Max() * 5 then 
		--	ent:SetInk(ent:GetUD_Max() * 5)
		--end
		ent:EmitSound('ambient/energy/weld2.wav')
	end
	if (not self.Used) and IsValid(ent) and (ent:GetClass() == 'rp_money_printer_pro') then
		if ent:GetInk() >= ent:GetUD_Max() * 15 then return end
		self.Used = true
		self:Remove()
		ent:SetInk(ent:GetUD_Max() * 15)
		--if ent:GetInk() >= ent:GetUD_Max() * 5 then 
		--	ent:SetInk(ent:GetUD_Max() * 5)
		--end
		ent:EmitSound('ambient/energy/weld2.wav')
	end
end

function ENT:OnTakeDamage(damageData)
	self:Remove()
end
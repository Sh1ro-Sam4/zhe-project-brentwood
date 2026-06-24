AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.SeizeReward = 150
ENT.WantReason = 'Девайсы для принтера'

function ENT:Initialize()
	self:SetModel('models/props_c17/BriefCase001a.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysWake()

	self:SetTrigger(true)
end

function ENT:StartTouch(ent)
	if (not self.Used) and IsValid(ent) and (ent:GetClass() == 'rp_money_printer') then
		if ent:GetHP() >= 100 and ent:GetUD_HP() == 1 or ent:GetHP() >= 300 and ent:GetUD_HP() == 2 or ent:GetHP() >= 500 and ent:GetUD_HP() == 3 then return end
		self.Used = true
		self:Remove()
		if ent:GetUD_HP() == 1 then
			ent:SetHP(100)
		elseif ent:GetUD_HP() == 2 then
			ent:SetHP(300)
		else
			ent:SetHP(500)
		end
		ent:EmitSound('ambient/energy/weld1.wav')
	end
	if (not self.Used) and IsValid(ent) and (ent:GetClass() == 'rp_money_printer_pro') then
		if ent:GetHP() >= 100 and ent:GetUD_HP() == 1 or ent:GetHP() >= 300 and ent:GetUD_HP() == 2 or ent:GetHP() >= 500 and ent:GetUD_HP() == 3 then return end
		self.Used = true
		self:Remove()
		if ent:GetUD_HP() == 1 then
			ent:SetHP(100)
		elseif ent:GetUD_HP() == 2 then
			ent:SetHP(300)
		else
			ent:SetHP(500)
		end
		ent:EmitSound('ambient/energy/weld1.wav')
	end
end

function ENT:OnTakeDamage(damageData)
	self:Remove()
end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/plasticbucket001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	self:SetNWInt("progress", 0)
	self:SetNWInt("status", 0)

	self:SetMaxWater(4)
	self:SetWater(0)

	self:SetMaxYeast(3)
	self:SetYeast(0)

	self:SetMaxAlcohol(2)
	self:SetAlcohol(0)
end

function ENT:OnTakeDamage(dmginfo)
	self:VisualEffect()
	self:Remove()
end

function ENT:Think()
	local progressTime = CurTime()
	if ((!self.progressTime or CurTime() >= self.progressTime)) then
		if (self:GetNWInt("progress") != 100 and (self:GetWater() == self:GetMaxWater()) and (self:GetYeast() == self:GetMaxYeast()) and (self:GetAlcohol() == self:GetMaxAlcohol())) then
			if ((self:GetVelocity():Length() > 25) and (self:GetVelocity():Length() < 1000)) then
				self:SetNWInt("progress", math.Clamp(self:GetNWInt("progress") + 2, 0, 100))
				self:EmitSound("ambient/levels/canals/toxic_slime_sizzle4.wav", 100, 200)
			elseif (self:GetVelocity():Length() > 1000) then
				self:SetNWInt("progress", math.Clamp(self:GetNWInt("progress") - 2, 0, 100))
				self:EmitSound("ambient/levels/canals/toxic_slime_sizzle4.wav", 100, 150)
			end
		elseif (self:GetNWInt("progress") == 100) then
			self:SetNWInt("status", 1)
		end

		self.progressTime = CurTime() + 0.5
	end
end

function ENT:Use(activator, caller)
	local curTime = CurTime()
	if (!self.nextUse or curTime >= self.nextUse) then
		if self:GetNWInt("status") == 1 then
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle2.wav")
			dobeer = ents.Create("alco_dobeer");
			dobeer:SetPos(self:GetPos()+self:GetUp()*12)
			dobeer:SetAngles(self:GetAngles())
			dobeer:Spawn()
			dobeer:GetPhysicsObject():SetVelocity(self:GetUp()*2)

			self:SetNWInt("progress", 0)
			self:SetNWInt("status", 0)
			self:SetWater(0)
			self:SetYeast(0)
			self:SetAlcohol(0)
		end
		self.nextUse = curTime + 0.5
	end
end

function ENT:VisualEffect()
	local effectData = EffectData()
	effectData:SetStart(self:GetPos())
	effectData:SetOrigin(self:GetPos())
	effectData:SetScale(8)
	util.Effect("GlassImpact", effectData, true, true)
end
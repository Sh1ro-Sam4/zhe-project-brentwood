AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("autorun/config.lua")

include("shared.lua")
include("autorun/config.lua")

function ENT:Initialize()
	self:SetModel("models/nater/weedplant_pot.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	self:SetHasWeedSeed(false)
	self:SetHasDirt(false)
	self:SetHasWater(false)
	self:SetWaterAmount(0)
	self.EmitTime = CurTime()
	self:SetCookingProgress(0)

	//self:SetNextThink(CurTime() + 1)
end

function ENT:CanCook()
	return (self:GetHasWater() and self:GetHasWeedSeed() and self:GetHasDirt() and self:GetWaterAmount() > 0)
end

function ENT:DoneCooking()
	return (self:GetCookingProgress() >= 100)
end

function ENT:AddWaterAmount(amount)
	local current = self:GetWaterAmount()
	local new = math.min(current + amount, 100)
	self:SetWaterAmount(new)
	if not self:GetHasWater() and new > 0 then
		self:SetHasWater(true)
	end
end

function ENT:Think()
	if self:CanCook() and (not self:DoneCooking()) then
        
		local currentProgress = self:GetCookingProgress()
		local newProgress = math.Clamp(currentProgress + (0.5 * (WEED_GROWTIME / 100)), 0, 100)
		self:SetCookingProgress(newProgress)

		if currentProgress < 100 then
			local currentWater = self:GetWaterAmount()
			local waterDecrement = 3
			local newWater = math.max(0, currentWater - waterDecrement)
			self:SetWaterAmount(newWater)

			if newWater <= 0 then
				self:SetHasWater(false)
				self:EmitSound("ambient/water/water_spray1.wav")
			end
		end

		if (self:GetCookingProgress() == 0) then
			self:SetModel("models/nater/weedplant_pot.mdl")
		end

		if (self:GetCookingProgress() == 10) then
			self:SetModel("models/nater/weedplant_pot_growing1.mdl")
		end

    	if (self:GetCookingProgress() == 30) then
    		self:SetModel("models/nater/weedplant_pot_growing2.mdl")
    	end

    	if (self:GetCookingProgress() == 40) then
    		self:SetModel("models/nater/weedplant_pot_growing3.mdl")
    	end

    	if (self:GetCookingProgress() == 60) then
    		self:SetModel("models/nater/weedplant_pot_growing4.mdl")
    	end

    	if (self:GetCookingProgress() == 75) then
    		self:SetModel("models/nater/weedplant_pot_growing5.mdl")
    	end

    	if (self:GetCookingProgress() == 100) then
    		self:SetModel("models/nater/weedplant_pot_growing6.mdl")
    	end
	end

	self:NextThink(CurTime() + 1)
	return true
end

function ENT:Touch(toucher)
	if IsValid(toucher) then
		if (toucher:GetClass() == "zone_weedseed") and (not self:GetHasWeedSeed()) and (self:GetHasDirt()) then
			self:SetHasWeedSeed(true)
			self:EmitSound("fizz.wav")
			toucher:Remove()
		elseif (toucher:GetClass() == "zone_dirt") and (not self:GetHasDirt()) then
			self:SetHasDirt(true)
			self:EmitSound("fizz.wav")
			toucher:Remove()
		elseif (self:GetHasDirt()) then
			if (self:GetHasWeedSeed()) then
				self:SetModel("models/nater/weedplant_pot_planted.mdl")
			else
				self:SetModel("models/nater/weedplant_pot_dirt.mdl")
			end
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	self:VisualEffect();
	self:Remove()
end;

function ENT:VisualEffect()
	local effectData = EffectData();
	effectData:SetStart(self:GetPos());
	effectData:SetOrigin(self:GetPos());
	effectData:SetScale(8);
	util.Effect("GlassImpact", effectData, true, true);
end;

ENT.nextUse = 0
function ENT:Use(activator, caller)
	if (self.nextUse < CurTime()) then
		if IsValid(caller) and caller:IsPlayer() then
			if self:DoneCooking() then
				if (self:GetHasDirt()) then
					self:SetModel("models/nater/weedplant_pot_dirt.mdl")
				else
					self:SetModel("models/nater/weedplant_pot.mdl")
				end
				self:SetCookingProgress(0)
				//caller:SendLua("local tab = {Color(255,255,255), [[Вы собрали траву. ]] } chat.AddText(unpack(tab))");
				local weedbag = ents.Create("zone_weedbag")
				weedbag:SetPos(self:GetPos() + Vector(0, 0, 30))
				weedbag:Spawn()
				self:SetHasWeedSeed(false)
				self:SetHasWater(false)
				self:SetHasDirt(false)
			end
		end
		self.nextUse = CurTime() + 1
	end
end
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Medkit"
SWEP.Instructions = "A small bag containing medical supplies. Has bandages, painkillers, tourniquets and internal bleeding medicine. A necessary thing in hiking, military conditions and just a necessary thing in everyday life. RMB to apply on others, R to change use mode."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/w_models/weapons/w_eq_medkit.mdl"

SWEP.DrawAmmo = false

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_medkit")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_medkit.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(4, -0.5, -3)
SWEP.offsetAng = Angle(-30, 20, 90)
SWEP.modes = 5
SWEP.modeNames = {
	[1] = "bandaging",
	[2] = "painkiller",
	[3] = "tranexamic acid",
	[4] = "tourniquet",
	[5] = "decompression needle",
}
SWEP.ofsV = Vector(-2,-10,8)
SWEP.ofsA = Angle(90,-90,90)
function SWEP:PackModes()
	if not self.modeValues then return end
	local m1 = math.Clamp(self.modeValues[1] or 0, 0, 127)
	local m2 = math.Clamp(self.modeValues[2] or 0, 0, 1)
	local m3 = math.Clamp(self.modeValues[3] or 0, 0, 15)
	local m4 = math.Clamp(self.modeValues[4] or 0, 0, 1)
	local m5 = math.Clamp(self.modeValues[5] or 0, 0, 1)
	local packed = bit.bor(m1, bit.lshift(m2, 7), bit.lshift(m3, 8), bit.lshift(m4, 12), bit.lshift(m5, 13), bit.lshift(1, 14))

	self:SetClip1(packed)
	self.clip1 = packed
end

function SWEP:UnpackModes()
	if not self.modeValues then return end
	local packed = self:Clip1()
	
	if (packed == nil or packed <= 0) and self.clip1 then
		packed = self.clip1
	end

	if packed and packed > 0 then
		if bit.band(packed, bit.lshift(1, 14)) ~= 0 then
			self.modeValues[1] = bit.band(packed, 127)
			self.modeValues[2] = bit.band(bit.rshift(packed, 7), 1)
			self.modeValues[3] = bit.band(bit.rshift(packed, 8), 15)
			self.modeValues[4] = bit.band(bit.rshift(packed, 12), 1)
			self.modeValues[5] = bit.band(bit.rshift(packed, 13), 1)
		end
	end
end

function SWEP:Think()
	self:UnpackModes()
	if self.BaseClass and self.BaseClass.Think then
		self.BaseClass.Think(self)
	end
end

function SWEP:Deploy()
	self:UnpackModes()
	if self.BaseClass and self.BaseClass.Deploy then return self.BaseClass.Deploy(self) end
	return true
end

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self.modeValues = {
		[1] = 80,
		[2] = 1,
		[3] = 10,
		[4] = 1,
		[5] = 1,
	}
	self:PackModes()
end

SWEP.modeValuesdef = {
	[1] = {80,true},
	[2] = {1,false},
	[3] = {10,true},
	[4] = {1,true},
	[5] = {1,false},
}
SWEP.ShouldDeleteOnFullUse = true

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	if (self:GetOwner().zmanipstart ~= nil and (self:GetOwner().organism and self:GetOwner().organism.larmamputated == false)) then return end
	local aimvec = self:GetOwner():GetAimVector()
	local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(30 - hold / 5, -30 + hold / 2 + 20 * aimvec[3], 5 - hold / 4))
    self:BoneSet("r_forearm", vector_origin, Angle(hold / 25, -hold / 2.5, 35 -hold / 1.4))

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end

local IsMedic = function(class)
	return class == TEAM_MEDIC
end

if SERVER then
	function SWEP:Heal(ent, mode, bone)
		local org = ent.organism
		if not org then return end

		self:UnpackModes()

		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		if self.mode == 2 then
			if self.modeValues[2] == 0 then return end
			if ent ~= owner and not org.otrub then return end
			org.analgesiaAdd = math.min(org.analgesiaAdd + self.modeValues[2] * 0.3, 4)
			self.modeValues[2] = 0
			entOwner:EmitSound("snds_jack_gmod/ez_medical/15.wav", 60, math.random(95, 105))
		elseif self.mode == 3 then
			if self.modeValues[3] == 0 then return end
			local internalBleed = org.internalBleed - org.internalBleedHeal
			
			if self.poisoned2 then
				org.poison4 = CurTime()
				self.poisoned2 = nil
			end

			if internalBleed > 0 then
				local healed = math.max(internalBleed - self.modeValues[3], 0)
				self.modeValues[3] = self.modeValues[3] - (internalBleed - healed) * 1
				org.internalBleedHeal = org.internalBleedHeal + (internalBleed - healed)
				entOwner:EmitSound("snds_jack_gmod/ez_medical/" .. math.random(16, 18) .. ".wav", 60, math.random(95, 105))
			end
		elseif self.mode == 1 then
			if IsGov(owner:GetPlayerClass()) or IsMedic(owner:GetPlayerClass()) then
				self:Bandage(ent, bone)
				self.modeValues[1] = 80
			else
				self:Bandage(ent, bone)
			end
		elseif self.mode == 4 then
			if self:Tourniquet(ent, bone) then
				if IsGov(owner:GetPlayerClass()) or IsMedic(owner:GetPlayerClass()) then
				else
					self.modeValues[4] = 0 
				end
			end
		elseif self.mode == 5 then
			if self.modeValues[5] == 0 then return end
			if self.poisoned2 then
				org.poison4 = CurTime()
				self.poisoned2 = nil
			end

			org.needle = 1

			if !(org.lungsR[2] == 1 or org.lungsL[2] == 1) then
				if math.random(2) == 1 then 
					org.lungsR[2] = 1
				else
					org.lungsL[2] = 1
				end
			end

			if IsGov(owner:GetPlayerClass()) then
			else
				self.modeValues[5] = 0
			end
			entOwner:EmitSound("snd_jack_hmcd_needleprick.wav", 60, math.random(95, 105))
		end
		self:PackModes()
		if self.modeValues[1] == 0 and self.modeValues[2] == 0 and self.modeValues[3] == 0 and self.modeValues[4] == 0 and self.modeValues[5] == 0 and self.ShouldDeleteOnFullUse then
			owner:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
	end
end
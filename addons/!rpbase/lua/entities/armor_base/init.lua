AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local vecZero = Vector(0,0,0)
function ENT:Initialize()
	self:SetModel(self.PhysModel or self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)
	self:SetPos(self:GetPos() + Vector(0,0,30))

	if self.material and !istable(self.material) then
		self.mat = self.material
		self:SetSubMaterial(0,self.material)
	end

	if self.material and istable(self.material) then
		self.mat = table.Random(self.material)
		self:SetSubMaterial(0,self.mat)
	end

	if self.skins then
		self.skin = table.Random(self.skins)
		self:SetSkin(self.skin)
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(10)
		phys:Wake()
		phys:EnableMotion(true)
	end

end

function ENT:OnRemove()

end

function ENT:Use(activator)
	self:TakeByPlayer(activator)
end

local armorNames = {
	["vest1"] = "Plate Body Armor IV",
	["helmet1"] = "ACH Helmet III",
	["helmet2"] = "Biker Helmet",
	["helmet3"] = "Riot Helmet",
	["helmet4"] = "Pot",
	["helmet7"] = "SSh-68",
	["vest2"] = "Police Riot Vest",
	["vest3"] = "Kevlar IIIA Vest",
	["vest4"] = "Kevlar III Vest",
	["mask1"] = "Balistic Mask",
	["mask2"] = "M40 Gas Mask",
	["mask3"] = "Welding Mask",
	["vest5"] = "6B13",
	["nightvision1"] = "NVG GPNVG 18",
	["vest6"] = "PACA Soft Armor",
	["vest7"] = "MF-UNTAR Body Armor",
	["headphones1"] = "MSA Sordin Supreme PRO-X/L",
	["helmet5"] = "HighCom Striker ACHHC IIIA helmet",
	["vest8"] = "SWAT Balistic Vest",
	["ego_equalizer"] = "[HE] Equalizer",
	["helmet6"] = "SWAT Balistic Helmet",
	["gordon_helmet"] = "HEV Suit Helmet",

	["srt_swat"] = "SWAT Vest",
	["hrt_fbi"] = "FBI Vest",

	["srt_helmet"] = "SWAT Helmet",
	["hrt_helmet"] = "FBI Helmet",
}

function ENT:TakeByPlayer(activator)
	if not activator:IsPlayer() then return end

	activator:DelayedAction('armor' .. self:EntIndex(), 'Одевание ' .. armorNames[self.name], {
		time = 3,
		check = function()
			if !IsValid(self) then return false end
			if self:GetPos():Distance(activator:GetPos()) > 45 then return false end
			return true
		end,
		succ = function()
			local can = hg.AddArmor(activator,self.name, self)
			if can then
				if self.zablevano then
					activator:SetNetVar("zableval_masku", true)
				end

				self:Remove()
			end
		end,
	}, {
		time = 1.5,
		inst = true,
		action = function()
			activator:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_PLACE)
			activator:EmitSound("snd_jack_hmcd_disguise.wav", 75, math.random(90,110), 1, CHAN_ITEM)
		end,
	})
end

function ENT:ApplyData(ply,equipment)
	ply:SetNWString("ArmorMaterials" .. equipment, self.mat)
	ply:SetNWInt("ArmorSkins" .. equipment, self.skin or 0)
end

function ENT:ReciveData(ply,equipment)
	--print(ply,equipment, ply:GetNWString("ArmorMaterials" .. equipment, self.mat))
	self.mat = ply:GetNWString("ArmorMaterials" .. equipment, self.mat)
	self:SetSubMaterial(0,self.mat)

	self.skin = ply:GetNWInt("ArmorSkins" .. equipment, self.skin or 0)
	self:SetSkin(self.skin)
end

hook.Add("ItemTransfered","TransferMats",function(ply, ragdoll)
	local armors = ragdoll:GetNetVar("Armor",{})
	for k,v in pairs(armors) do

		ragdoll:SetNWString("ArmorMaterials" .. v, ply:GetNWString("ArmorMaterials" .. v))
		ply:SetNWString("ArmorMaterials" .. v, nil)

		ragdoll:SetNWInt("ArmorSkins" .. v, ply:GetNWInt("ArmorSkins" .. v))
		ply:SetNWInt("ArmorSkins" .. v, nil)
	end
end)

hook.Add("ItemTransfer", "TransferMats", function(ply, ent, placement, armor)
	ply:SetNWString("ArmorMaterials" .. armor, ent:GetNWString("ArmorMaterials" .. armor))
	ent:SetNWString("ArmorMaterials" .. armor, nil)

	ply:SetNWInt("ArmorSkins" .. armor, ent:GetNWInt("ArmorSkins" .. armor))
	ent:SetNWInt("ArmorSkins" .. armor, nil)
end)
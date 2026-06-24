AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- include("autorun/shared/bank_config.lua")

function ENT:Initialize()
	self:SetModel(BANK_CONFIG.BagModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetNWInt("GetTime", math.Round( CurTime() + 30 ))

	//76561198092742034
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SetVault(ent)
	self:SetVaultPos(ent:GetPos())
end

function ENT:SetPlayer(ply)
	self.Player = ply
end

function ENT:OnTakeDamage()
	self:Remove()
end

//8 month old copypasted shitcode, not bothering with really maintaining the code quality of this script anymore, expect a v2 on gmodstore as a new script soon.
local function jobCanRob(ply)
	-- if(table.Count(BANK_CONFIG.AllowedJobs) > 0) || ply:isCP() then
	-- 	if(!BANK_CONFIG.AllowedJobs[team.GetName(ply:Team())]) then
	-- 		return false //76561198092742034
	-- 	else return true end
	-- else return true end
	return not IsGov(ply:GetPlayerClass())
end

function ENT:Think()
	if !self:IsInWorld() then
		self:Remove()
	end

	//76561198092742034
	-- if BANK_CONFIG.Distance - math.Round(self:GetVaultPos():Distance(self:GetPos()) / 53) <= 0 then
	if self:GetNWInt("GetTime", 0) < CurTime() then
		if(!self.Player || !IsValid(self.Player)) then return end
		if(!jobCanRob(self.Player)) then
			DarkRP.notify(self.Player, NOTIFY_GENERIC, 4, string.format(BANK_CONFIG.WithdrawNotification, string.Comma(self:GetMoney()-1500)))
			self.Player:AddMoney(self:GetMoney()-150)
			self:Remove()
			self.Player:EmitSound("ambient/office/coinslot1.wav")
		else
			DarkRP.notify(self.Player, NOTIFY_GENERIC, 4, string.format(BANK_CONFIG.WithdrawNotification, string.Comma(self:GetMoney())))
			self.Player:AddMoney(self:GetMoney())
			self:Remove()
			self.Player:EmitSound("ambient/office/coinslot1.wav")
		end
	end
end

hook.Add("GravGunPickupAllowed", "SwitchOwnersOnPickup", function(ply, ent)
	if(ent:GetClass() != "rob_bank_money_bag") then return end
	if(ent.Player == ply) then return end
	--if(!jobCanRob(ply)) then return end
	ent:SetPlayer(ply)
	//76561198092742034
end)

hook.Add("PlayerDisconnected", "RemoveBagsOnDisconnect", function(ply)
	for k, v in pairs(ents.FindByClass("rob_bank_money_bag")) do
		if(v.Player == ply) then v:Remove() end
	end
end)
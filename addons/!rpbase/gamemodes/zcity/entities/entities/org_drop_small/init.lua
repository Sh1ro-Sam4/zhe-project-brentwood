AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString("Terminal_Upgrade_Rack")
util.AddNetworkString("Terminal_Toggle_Power")
util.AddNetworkString("Terminal_Collect_Bank")
util.AddNetworkString("Terminal_Sell_Rack")

ENT.AutomaticFrameAdvance = true

DarkRP = DarkRP or {}
DarkRP.Orgs = DarkRP.Orgs or {}

function ENT:Initialize()
	self:SetModel("models/craphead_scripts/bitminers/rack/rack.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	self:SetHP(1000)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(550)
	end
    
	self:SetLevel(1)
	self:SetIsPowered(false)
	self:SetBank(0)
	self:SetBodyGroups("010000000000000004")
	self:ResetSequence("idle")
	self:SetORGIANAME("FEMBOY")
end

function ENT:Use(ply)
end

function ENT:OnTakeDamage(damageData)
end

function ENT:Think()
	if self:GetIsPowered() then
		self.NextFarm = self.NextFarm or CurTime() + 60
		if CurTime() >= self.NextFarm then
			self.NextFarm = CurTime() + 60
			local farmMin = (0.03 / 60) * self:GetLevel()
			self:SetBank(self:GetBank() + farmMin)
		end
	else
		self.NextFarm = CurTime() + 60
	end

	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:OnRemove()
end

net.Receive("Terminal_Upgrade_Rack", function(len, ply)
	local ent = net.ReadEntity()
    
	if not IsValid(ent) or ent:GetClass() ~= "org_drop_small" then return end
	if ply:GetPos():DistToSqr(ent:GetPos()) > 65536 then return end
	if not ent:GetIsPowered() then return end
    
	local currentLevel = ent:GetLevel()
    
	if currentLevel >= 16 then
		ent:EmitSound("buttons/button10.wav", 60, 100)
		return
	end

	local orgName = ent:GetORGIANAME()
	if not orgName or orgName == "" then return end

	local org = DarkRP.OrgsData[orgName]
	if not org then return end

	local plyData = org.Members[ply:SteamID()]
	if not plyData then
		ply:ChatPrint("Эта машина принадлежит другой организации!")
		return
	end

	local isOwner = (org.Owner == ply:SteamID())
	local canManage = isOwner or (plyData.Perms and plyData.Perms.ManageMiners)

	if not canManage then
		ply:ChatPrint("У вас нет прав на улучшение дата-центров вашей организации.")
		return
	end

	local cost = 7500
	if (org.Bank or 0) < cost then
		ply:ChatPrint("В банке организации недостаточно средств! Требуется " .. string.Comma(cost) .. "$.")
		ent:EmitSound("buttons/button10.wav", 60, 100) -- Звук ошибки
		return
	end

	org.Bank = org.Bank - cost
	SaveOrg(orgName)

	ent:SetLevel(currentLevel + 1)
	for i = 1, ent:GetLevel() do
		ent:SetBodygroup(i, 1)
	end
	
	ent:EmitSound("buttons/blip1.wav", 60, 150)
	ply:ChatPrint("Вы улучшили Дата-Центр за " .. string.Comma(cost) .. "$ из банка организации.")

	net.Start("Org_RequestMyOrgData")
	net.Send(ply)
end)

net.Receive("Terminal_Toggle_Power", function(len, ply)
	local ent = net.ReadEntity()
    
	if not IsValid(ent) or ent:GetClass() ~= "org_drop_small" then return end
	if ply:GetPos():DistToSqr(ent:GetPos()) > 65536 then return end
    
	local state = not ent:GetIsPowered()
	ent:SetIsPowered(state)
    
	if state then
		ent:ResetSequence("on")
		ent:EmitSound("buttons/button14.wav", 60, 100)
	else
		ent:ResetSequence("idle")
		ent:EmitSound("buttons/button19.wav", 60, 100)
	end
end)

net.Receive("Terminal_Collect_Bank", function(len, ply)
	local ent = net.ReadEntity()
    
	if not IsValid(ent) or ent:GetClass() ~= "org_drop_small" then return end
	if ply:GetPos():DistToSqr(ent:GetPos()) > 65536 then return end
	if not ent:GetIsPowered() then return end
	DarkRP.Orgs.AddPoints(ent:GetORGIANAME(), ent:GetBank())
	ent:SetBank(0)
	--DarkRP.Orgs.AddPoints(ent:GetORGIANAME(), 1)
	ent:EmitSound("buttons/button3.wav", 60, 150)
end)

net.Receive("Terminal_Sell_Rack", function(len, ply)
	local ent = net.ReadEntity()
    
	if not IsValid(ent) or ent:GetClass() ~= "org_drop_small" then return end
	if ply:GetPos():DistToSqr(ent:GetPos()) > 65536 then return end

	if ent.IsSelling then return end

	local orgName = ent:GetORGIANAME()
	if not orgName or orgName == "" then return end

	local org = DarkRP.OrgsData[orgName]
	if not org then return end

	local plyData = org.Members[ply:SteamID()]
	if not plyData then
		ply:ChatPrint("Эта машина принадлежит другой организации!")
		return
	end

	local isOwner = (org.Owner == ply:SteamID())
	local canManage = isOwner or (plyData.Perms and plyData.Perms.ManageMiners)

	if not canManage then
		ply:ChatPrint("У вас нет прав на продажу дата-центров вашей организации.")
		return
	end

	ent.IsSelling = true

	local currentLevel = ent:GetLevel()
	local upgradeCount = currentLevel
	
	local baseRefund = 5000
	local upgradeRefund = upgradeCount * 1000
	local totalRefund = baseRefund + upgradeRefund

	org.Bank = (org.Bank or 0) + totalRefund
	SaveOrg(orgName)

	ply:ChatPrint("Дата-Центр продан! В банк зачислено " .. string.Comma(totalRefund) .. "$ (База: " .. string.Comma(baseRefund) .. "$, Улучшения: " .. string.Comma(upgradeRefund) .. "$).")
	
	ent:EmitSound("buttons/button9.wav", 60, 100)
	ent:Remove()

	net.Start("Org_RequestMyOrgData")
	net.Send(ply)
end)

function ENT:OnTakeDamage(damageData)
	if self.IsDestroying then return end 

	self:SetHP(self:GetHP() - damageData:GetDamage())

	if (self:GetHP() <= 0) then
		self.IsDestroying = true
		local attacker = damageData:GetAttacker()
		self:Explode(attacker)
	end
end

function ENT:Explode(attacker)
	timer.Destroy(self:EntIndex() .. 'Print')
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect('Explosion', effectdata)

	if IsValid(attacker) and attacker:IsPlayer() then
		local attackerOrgName = attacker:GetOrg()
		local victimOrgName = self:GetORGIANAME()

		if attackerOrgName and victimOrgName and attackerOrgName ~= victimOrgName then
			local attackerOrg = DarkRP.OrgsData[attackerOrgName]
			local victimOrg = DarkRP.OrgsData[victimOrgName]

			if attackerOrg and victimOrg then
				local percent = math.random(5, 15) / 100
				
				local stolenBank = math.floor((victimOrg.Bank or 0) * percent)
				local stolenPoints = (victimOrg.Points or 0) * percent

				victimOrg.Bank = math.max(0, (victimOrg.Bank or 0) - stolenBank)
				victimOrg.Points = math.max(0, (victimOrg.Points or 0) - stolenPoints)

				attackerOrg.Bank = (attackerOrg.Bank or 0) + stolenBank
				attackerOrg.Points = (attackerOrg.Points or 0) + stolenPoints

				SaveOrg(victimOrgName)
				SaveOrg(attackerOrgName)

				for _, pl in ipairs(player.GetAll()) do
					if pl:GetOrg() == victimOrgName then
						pl:ChatPrint(string.format("[Организация] Ваш Дата-Центр уничтожила организация '%s'! Потеряно: %s$ и %.1f очков.", attackerOrgName, string.Comma(stolenBank), stolenPoints))
					elseif pl:GetOrg() == attackerOrgName then
						pl:ChatPrint(string.format("[Организация] %s уничтожил Дата-Центр '%s'! Добыча: %s$ и %.1f очков.", attacker:Nick(), victimOrgName, string.Comma(stolenBank), stolenPoints))
					end
				end
			end
		end
	end

	self:Remove()
end
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

DarkRP = DarkRP or {}
DarkRP.Orgs = DarkRP.Orgs or {}

local wep_table = {
	"weapon_revolver357",
	"weapon_deagle",
	"weapon_vpo136",
	"weapon_mp5",
	"weapon_ram",
	"weapon_tomahawk",
	"weapon_revolver357",
	"weapon_revolver357",
	"weapon_revolver357",
	"weapon_revolver357",
}

function ENT:Initialize()
	self:SetModel("models/craphead_scripts/supply_crate/supply.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then
		phys:SetMass(2250)
	end

	self:SetBodyGroups( "11111" )
	self.meow = true

	self:SetHackEndTime(0)
	self:SetHackStartTime(0)
	self:SetHackOrg("")
	self:SetReward(math.random(480, 650))
	self:SetWepCount(math.random(1, 4))
	self:SetScoreCount(math.random(4,6))
    
	--for _, ply in ipairs(player.GetAll()) do
	--	if ply:GetOrg() then
	--		DarkRP.notify( ply, 0, 15, "Где то на карте появился ящик с очками организаций кто сможет забрать получит награду!" )
	--	end
	--end
end

function ENT:Use(ply)
	if self.meow then 
		self:ResetSequence("laptop_open")
		self.meow = false
	else
		self.meow = true
		self:ResetSequence("laptop_close")
	end
end

function ENT:GiveReward(orgName)
	if orgName then
		local score_reward = self:GetScoreCount()
	    DarkRP.Orgs.AddPoints(orgName, score_reward)
		local reward = self:GetReward()
		DarkRP.Orgs.AddBankMoney(orgName, reward)
		for _, ply in ipairs(player.GetAll()) do
			ply:ChatPrint("Организация '" .. orgName .. "' открыла ящик с очками и получила +"..score_reward.." очков и " .. reward .. "$ в общак организации!")
		end
	end

	local n = self:GetWepCount()
	for i = 1, n do
		local wep = ents.Create( table.Random(wep_table) )
		wep:SetPos( self:GetPos() + Vector(math.random(-15,15), math.random(-15,15), math.random(10,30)) )
		wep:Spawn()

		if not wep.DropIt then
			wep.DropIt = true
			local ent = ents.Create("spawned_weapon")
			local model = (wep:GetModel() == "models/weapons/v_physcannon.mdl" and "models/weapons/w_physics.mdl") or wep:GetModel()
							
			ent.ShareGravgun = true
			ent:SetPos(wep:GetPos())
			ent:SetModel(model)
			ent:SetSkin(wep:GetSkin())
			ent.NoDrop = wep.NoDrop or false
			ent.UnDroppable = wep.UnDroppable or false
			ent.weaponclass = wep:GetClass()
			ent.nodupe = true
			ent.clip1 = wep:Clip1()
			ent.clip2 = wep:Clip2()
			ent.modeValues = wep.modeValues
			ent.attachments = wep.attachments
			ent.___SavedTable = ent.___SavedTable or {}
			if wep.modeValues then ent.___SavedTable["modeValues"] = wep.modeValues end
		
			ent:Spawn()
			wep:Remove()
		end
	end

	self:Remove()
end

function ENT:Think()
	local orgs_in_zone = {}
	
	for _, v in pairs(ents.FindInSphere(self:GetPos(), 100)) do
		if v:IsPlayer() and v:Alive() and v:GetOrg() and v:GetOrg() != "" and not IsGov(v:GetPlayerClass()) then
			local orgName = v:GetOrg()
			if not orgs_in_zone[orgName] then
				orgs_in_zone[orgName] = v:GetOrgColor() or Color(255, 255, 255)
			end
		end
	end

	if table.Count(orgs_in_zone) == 1 then
		local current_org, current_color = next(orgs_in_zone)

		if self:GetHackOrg() != current_org then
			self:SetHackOrg(current_org)
			self:SetHackOrgColor(Vector(current_color.r / 255, current_color.g / 255, current_color.b / 255))
			self:SetHackStartTime(CurTime())
			self:SetHackEndTime(CurTime() + 160)
		else
			if self:GetHackEndTime() > 0 and CurTime() >= self:GetHackEndTime() then
				self:GiveReward(current_org)
			end
		end
	else
		if self:GetHackEndTime() > 0 then
			self:SetHackOrg("")
			self:SetHackStartTime(0)
			self:SetHackEndTime(0)
		end
	end

	self:NextThink(CurTime() + 0.5)
	return true
end
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

DarkRP = DarkRP or {}
DarkRP.Orgs = DarkRP.Orgs or {}

function ENT:Initialize()
	self:SetModel("models/rust/env_loot_supplydrop.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	local phys = self:GetPhysicsObject()

	if ( IsValid( phys ) ) then -- Always check with IsValid! The ent might not have physics!
		phys:SetMass(2250)
	end

	--timer.Create("SelfLifeTime_"..self:EntIndex(), 120, 1, function() 
	--	if IsValid(self) then
	--		self:Remove()
	--	end
	--end)
	--for _, ply in ipairs(player.GetAll()) do
    --	ply:ChatPrint("Где то на карте появился ящик с очками организаций кто сможет забрать получит награду!")
    --end

	net.Start("OrgCrate_SpawnAlert")
	net.Send(imper())

	self:SetLastTake(CurTime())
end

function ENT:Use(ply)
	if true then 
		-- ГОЙДА
	end
end
function ENT:OnTakeDamage(damageData)
	--self:Remove()
end

local last_taker = nil

local wep_table = {
	"weapon_ar15",
	"weapon_tec9",
	"weapon_vpo209",
	"weapon_remington870",
	"weapon_revolver357"
}

function ENT:Think()
	
	--for k,v in pairs(ents.FindInBox(Vector(2483, 3000, -169), Vector(1847, 3417, 201))) do
	--	
	--end
	--if !self:GetPos():WithinAABox(Vector(1681, -2307, -97), Vector(1220, -1560, 421)) then
	--	self:Remove()
	--end
	local orgs_in_zone = {}
	if true then return end
	for k,v in pairs(ents.FindInSphere(self:GetPos(), 100)) do
		if v:IsPlayer() and v:Alive() and v:GetOrg() != nil then
			local have = false
			for k,v2 in pairs(orgs_in_zone) do
				if v2.name == v:GetOrg() then
					have = true
				end
			end
			if !have then
				local orgia = {
					name = v:GetOrg(),
					color = v:GetOrgColor()
				}
				table.insert(orgs_in_zone,orgia)
			end
			--table.insert(orgs_in_zone,v)
		end
	end
	if table.Count(orgs_in_zone) == 1 then
		--self:SetLastTake(CurTime())
		--if last_taker == orgs_in_zone[1].name then
		if last_taker == orgs_in_zone[1].name then
			if !timer.Exists("SelfLifeTime_"..self:EntIndex()) then 
				timer.Create("SelfLifeTime_"..self:EntIndex(), 120, 1, function()
					DarkRP.Orgs[orgs_in_zone[1].name].Points = DarkRP.Orgs[orgs_in_zone[1].name].Points + 1
					SaveOrg(orgs_in_zone[1].name)
					local reward = math.random(12,5600)
					DarkRP.Orgs[orgs_in_zone[1].name].Bank = DarkRP.Orgs[orgs_in_zone[1].name].Bank + reward
					for _, ply in ipairs(player.GetAll()) do
        				ply:ChatPrint("Организация '" .. orgs_in_zone[1].name .. "' открыла ящик с очками и получила " .. "+1 очко и " .. reward .. "$ в общак организации" .. "!")
    				end
					SaveOrg(orgs_in_zone[1].name)
					local n = math.random(1,4)
					for i=1, n do
						local wep = ents.Create( table.Random(wep_table) )
						wep:SetPos( self:GetPos() + Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10)) )
						wep:Spawn()
						

						if wep.DropIt == true then return end
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
						ent.ammoadd = ammo
						ent.modeValues = wep.modeValues
						ent.attachments = wep.attachments
						ent.___SavedTable = ent.___SavedTable or {}
						if wep.modeValues then
							ent.___SavedTable["modeValues"] = wep.modeValues
						end
					
						ent:Spawn()
					
						wep:Remove()


					end
					self:Remove()
				end)
			end
		else
			timer.Remove("SelfLifeTime_"..self:EntIndex())
		end
		last_taker = orgs_in_zone[1].name
	else
		timer.Remove("SelfLifeTime_"..self:EntIndex())
		last_taker = nil
	end

	self:NextThink( CurTime() + 1 )

	return true
end

function OnRemove()
	--if timer.Exists("SelfLifeTime_"..self:EntIndex()) then 
	--	timer.Remove("SelfLifeTime_"..self:EntIndex())
	--end
end
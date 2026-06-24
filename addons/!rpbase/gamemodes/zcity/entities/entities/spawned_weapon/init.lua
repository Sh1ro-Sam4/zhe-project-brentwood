AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:PhysWake()

	self.__SpawnTime = CurTime() + 120
end

function ENT:Use(activator, caller)
	if type(self.PlayerUse) == "function" then
		local val = self:PlayerUse(activator, caller)
		if val ~= nil then return val end
	elseif self.PlayerUse ~= nil then
		return self.PlayerUse
	end

	activator:DelayedAction(activator:SteamID64() .. 'weapon' .. self:EntIndex(), 'Подбираю оружие', {
		time = 3,
		check = function()
			if !IsValid(self) then return false end
			if self:GetPos():Distance(activator:GetPos()) > 45 then return false end
			return true
		end,
		succ = function()
			local class = self.weaponclass
			local weapon = ents.Create(class)

			if not weapon:IsValid() then return false end

			if not weapon:IsWeapon() then
				weapon:SetPos(self:GetPos())
				weapon:SetAngles(self:GetAngles())
				weapon:Spawn()
				weapon:Activate()
				self:Remove()
				return
			end

			local CanPickup = hook.Call("PlayerCanPickupWeapon", GAMEMODE, activator, weapon)
			if not CanPickup then return end

			activator:Give(class)
			weapon:Remove()

			weapon = activator:GetWeapon(class)
			if self.___SavedTable then
				local tbl = self.___SavedTable
				PrintTable(tbl)
				timer.Simple(0, function()
					for k, v in pairs(tbl) do
						weapon[k] = v
					end
				end)
			end
			weapon.UnDroppable = self.UnDroppable or false
			weapon.NoDrop = self.NoDrop or false


			if self.clip1 then
				weapon:SetClip1(self.clip1)
				weapon:SetClip2(self.clip2 or -1)
			end

			if self.modeValues then
				weapon.modeValues = self.modeValues
			end

			if self.attachments then
				weapon.attachments = self.attachments
			end

			if self.Drum then
				weapon.Drum = self.Drum
			end

			self:Remove()
		end,
	}, {
		time = 1.5,
		inst = false,
		action = function()
			activator:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_PLACE)
			activator:EmitSound("universal/uni_weapon_raise_0".. math.random(1, 6) ..".wav", 75, math.random(90,110), 1, CHAN_ITEM)
		end,
	})
end

function ENT:Think()
	if not self.__SpawnTime then self.__SpawnTime = CurTime() + 120 end

	if self.__SpawnTime < CurTime() then
		self:Remove()
	end
end
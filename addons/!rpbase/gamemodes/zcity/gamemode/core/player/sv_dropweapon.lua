local PLAYER = FindMetaTable('Player')

function PLAYER:DropDRPWeapon(weapon, target, velocity)
	-- if weapon.UnDroppable then
		-- return
	-- end
	-- self:DropWeapon(weapon, target, velocity)
	if weapon.DropIt == true then return end
	weapon.DropIt = true

	local ent = ents.Create("spawned_weapon")
	local model = (weapon:GetModel() == "models/weapons/v_physcannon.mdl" and "models/weapons/w_physics.mdl") or weapon:GetModel()
	local ammo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())

	ent.ShareGravgun = true
	ent:SetPos(self:GetShootPos() + self:GetAimVector() * 30)
	ent:SetModel(model)
	ent:SetSkin(weapon:GetSkin())
	ent.NoDrop = weapon.NoDrop or false
	ent.UnDroppable = weapon.UnDroppable or false
	ent.weaponclass = weapon:GetClass()
	ent.nodupe = true
	ent.clip1 = weapon:Clip1()
	ent.clip2 = weapon:Clip2()
	ent.ammoadd = ammo
	ent.Drum = weapon.Drum
	ent.modeValues = weapon.modeValues
	ent.attachments = weapon.attachments
	ent.___SavedTable = ent.___SavedTable or {}
	if weapon.modeValues then
		ent.___SavedTable["modeValues"] = weapon.modeValues
	end
	
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(velocity or self:GetAimVector() * 100)
		phys:AddAngleVelocity(VectorRand() * 100)
	end

	weapon:Remove()
end
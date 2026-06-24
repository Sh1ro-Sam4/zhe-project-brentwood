if SAM_LOADED then return end

local sam, command, language = sam, sam.command, sam.language

command.set_category("Fun")

do
	local sounds = {}
	for i = 1, 6 do
		sounds[i] = "physics/body/body_medium_impact_hard" .. i .. ".wav"
	end

	local slap = function(ply, damage, admin)
		if not ply:Alive() or ply:sam_get_nwvar("frozen") then return end
		ply:ExitVehicle()

		ply:SetVelocity(Vector(math.random(-100, 100), math.random(-100, 100), math.random(200, 400)))
		ply:EmitSound(sounds[math.random(1, 6)], 60, math.random(80, 120))

		if damage > 0 then
			ply:TakeDamage(damage, admin, DMG_GENERIC)
		end
	end

	command.new("slap")
		:SetPermission("slap", "admin")

		:AddArg("player")
		:AddArg("number", {hint = "damage", round = true, optional = true, min = 0, default = 0})

		:Help("slap_help")

		:OnExecute(function(ply, targets, damage)
			for i = 1, #targets do
				slap(targets[i], damage, ply)
			end

			-- if damage > 0 then
			-- 	sam.player.send_message(nil, "slap_damage", {
			-- 		A = ply, T = targets, V = damage
			-- 	})
			-- else
			-- 	sam.player.send_message(nil, "slap", {
			-- 		A = ply, T = targets
			-- 	})
			-- end
		end)
	:End()
end

command.new("slay")
	:SetPermission("slay", "admin")

	:AddArg("player")

	:Help("slay_help")

	:OnExecute(function(ply, targets)
		for i = 1, #targets do
			local v = targets[i]
			if not v:sam_get_exclusive(ply) then
				v:Kill()
			end
		end

		-- sam.player.send_message(nil, "slay", {
		-- 	A = ply, T = targets
		-- })
	end)
:End()

command.new("ignite")
	:SetPermission("ignite", "admin")

	:AddArg("player")
	:AddArg("number", {hint = "seconds", optional = true, default = 60, round = true})

	:Help("ignite_help")

	:OnExecute(function(ply, targets, length)
		for i = 1, #targets do
			local target = targets[i]

			if target:IsOnFire() then
				target:Extinguish()
			end

			target:Ignite(length)
		end

		-- sam.player.send_message(nil, "ignite", {
		-- 	A = ply, T = targets, V = length
		-- })
	end)
:End()

command.new("unignite")
	:Aliases("extinguish")

	:SetPermission("ignite", "admin")

	:AddArg("player", {optional = true})

	:Help("unignite_help")

	:OnExecute(function(ply, targets)
		for i = 1, #targets do
			targets[i]:Extinguish()
		end

		-- sam.player.send_message(nil, "unignite", {
		-- 	A = ply, T = targets
		-- })
	end)
:End()

command.new("god")
	:Aliases("invincible")

	:SetPermission("god", "admin")

	:AddArg("player", {optional = true})

	:Help("god_help")

	:OnExecute(function(ply, targets)
		for i = 1, #targets do
			local target = targets[i]
			target.organism.godmode = true
			target.sam_has_god_mode = true
		end

		-- sam.player.send_message(nil, "god", {
		-- 	A = ply, T = targets
		-- })
	end)
:End()

command.new("ungod")
	:Aliases("uninvincible")

	:SetPermission("ungod", "admin")

	:AddArg("player", {optional = true})

	:Help("ungod_help")

	:OnExecute(function(ply, targets)
		for i = 1, #targets do
			local target = targets[i]
			target.organism.godmode = nil
			target.sam_has_god_mode = nil
		end

		-- sam.player.send_message(nil, "ungod", {
		-- 	A = ply, T = targets
		-- })
	end)
:End()

do
	command.new("freeze")
		:SetPermission("freeze", "admin")

		:AddArg("player")

		:Help("freeze_help")

		:OnExecute(function(ply, targets)
			for i = 1, #targets do
				local v = targets[i]
				v:ExitVehicle()
				if v:sam_get_nwvar("frozen") then
					v:UnLock()
				end
				v:Lock()
				v:sam_set_nwvar("frozen", true)
				v:sam_set_exclusive("frozen")
			end

			-- sam.player.send_message(nil, "freeze", {
			-- 	A = ply, T = targets
			-- })
		end)
	:End()

	command.new("unfreeze")
		:SetPermission("unfreeze", "admin")

		:AddArg("player", {optional = true})

		:Help("unfreeze_help")

		:OnExecute(function(ply, targets)
			for i = 1, #targets do
				local v = targets[i]
				v:UnLock()
				v:sam_set_nwvar("frozen", false)
				v:sam_set_exclusive(nil)
			end

			-- sam.player.send_message(nil, "unfreeze", {
			-- 	A = ply, T = targets
			-- })
		end)
	:End()

	local disallow = function(ply)
		if ply:sam_get_nwvar("frozen") then
			return false
		end
	end

	for _, v in ipairs({"SAM.CanPlayerSpawn", "CanPlayerSuicide", "CanTool"}) do
		hook.Add(v, "SAM.FreezePlayer." .. v, disallow)
	end
end



local function doInvis()
	local remove = true
	for _, player in player.Iterator() do
		local t = player:GetTable()
		if t.invis then
			remove = false
			if player:Alive() and player:GetActiveWeapon():IsValid() then
				if player:GetActiveWeapon() ~= t.invis.wep then

					if t.invis.wep and IsValid( t.invis.wep ) then
						t.invis.wep:SetRenderMode( RENDERMODE_NORMAL )
						t.invis.wep:Fire( "alpha", 255, 0 )
						t.invis.wep:SetMaterial( "" )
					end

					t.invis.wep = player:GetActiveWeapon()
					invisiblecloak( player, true, t.invis.vis )
				end
			end
		end
	end

	if remove then
		hook.Remove( "Think", "InvisThink" )
	end
end

function invisiblecloak( ply, bool, visibility )
	if not ply:IsValid() then return end

	if bool then
		visibility = visibility or 0
		ply:SetNWBool("CloakSAM", true)
		ply:DrawShadow( false )
		ply:SetMaterial( "models/effects/vol_light001" )
		ply:SetNetVar("Accessories", "none")
		ply:SetRenderMode( RENDERMODE_TRANSALPHA )
		ply:Fire( "alpha", visibility, 0 )
		ply:GetTable().invis = { vis=visibility, wep=ply:GetActiveWeapon() }

		if IsValid( ply:GetActiveWeapon() ) then
			ply:GetActiveWeapon():SetRenderMode( RENDERMODE_TRANSALPHA )
			ply:GetActiveWeapon():Fire( "alpha", visibility, 0 )
			ply:GetActiveWeapon():SetMaterial( "models/effects/vol_light001" )
			if ply:GetActiveWeapon():GetClass() == "gmod_tool" then
				ply:DrawWorldModel( false )
			else
				ply:DrawWorldModel( true )
			end
		end

		hook.Add( "Think", "InvisThink", doInvis )
	else
		ply:SetNWBool("CloakSAM", false)
		ply:DrawShadow( true )
		ply:SetMaterial( "" )
		ply:SetRenderMode( RENDERMODE_NORMAL )
		ply:Fire( "alpha", 255, 0 )
		ApplyAppearance(ply,nil,nil,nil,true)
		local activeWeapon = ply:GetActiveWeapon()
		if IsValid( activeWeapon ) then
			activeWeapon:SetRenderMode( RENDERMODE_NORMAL )
			activeWeapon:Fire( "alpha", 255, 0 )
			activeWeapon:SetMaterial( "" )
		end
		ply:GetTable().invis = nil
	end
end



command.new("cloak")
	:SetPermission("cloak", "admin")

	:AddArg("player", {optional = true})

	:Help("cloak_help")

	:OnExecute(function(ply, targets)
		for i = 1, #targets do
			invisiblecloak(targets[i], true, 0)
		end
	end)
:End()

command.new("uncloak")
	:SetPermission("uncloak", "admin")

	:AddArg("player", {optional = true})

	:Help("uncloak_help")

	:OnExecute(function(ply, targets)
		for i = 1, #targets do
			invisiblecloak(targets[i], false)
		end
	end)
:End()

command.new("strip")
	:SetPermission("strip", "admin")

	:AddArg("player")

	:Help("strip_help")

	:OnExecute(function(ply, targets)
		for i = 1, #targets do
			targets[i]:StripWeapons()
		end

		-- sam.player.send_message(nil, "strip", {
		-- 	A = ply, T = targets
		-- })
	end)
:End()

command.new("respawn")
	:SetPermission("respawn", "admin")

	:AddArg("player", {optional = true})

	:Help("respawn_help")

	:OnExecute(function(ply, targets)
		for i = 1, #targets do
			targets[i]:Spawn()
		end

		-- sam.player.send_message(nil, "respawn", {
		-- 	A = ply, T = targets
		-- })
	end)
:End()

command.new("setmodel")
	:SetPermission("setmodel", "superadmin")

	:AddArg("player")
	:AddArg("text", {hint = "model"})

	:Help("setmodel_help")

	:OnExecute(function(ply, targets, model)
		for i = 1, #targets do
			targets[i]:SetModel(model)
		end

		-- sam.player.send_message(nil, "setmodel", {
		-- 	A = ply, T = targets, V = model
		-- })
	end)
:End()

command.new("giveammo")
	:Aliases("ammo")

	:SetPermission("giveammo", "superadmin")

	:AddArg("player")
	:AddArg("number", {hint = "amount", min = 0, max = 99999})

	:Help("giveammo_help")

	:OnExecute(function(ply, targets, amount)
		if amount == 0 then
			amount = 99999
		end

		for i = 1, #targets do
			local target = targets[i]
			for _, wep in ipairs(target:GetWeapons()) do
				if wep:GetPrimaryAmmoType() ~= -1 then
					target:GiveAmmo(amount, wep:GetPrimaryAmmoType(), true)
				end

				if wep:GetSecondaryAmmoType() ~= -1 then
					target:GiveAmmo(amount, wep:GetSecondaryAmmoType(), true)
				end
			end
		end

		-- sam.player.send_message(nil, "giveammo", {
		-- 	A = ply, T = targets, V = amount
		-- })
	end)
:End()

do
	command.new("scale")
		:SetPermission("scale", "superadmin")

		:AddArg("player")
		:AddArg("number", {hint = "amount", optional = true, min = 0, max = 2.5, default = 1})

		:Help("scale_help")

		:OnExecute(function(ply, targets, amount)
			for i = 1, #targets do
				local v = targets[i]
				v:SetModelScale(amount)

				-- https://github.com/carz1175/More-ULX-Commands/blob/9b142ee4247a84f16e2dc2ec71c879ab76e145d4/lua/ulx/modules/sh/extended.lua#L313
				v:SetViewOffset(Vector(0, 0, 64 * amount))
				v:SetViewOffsetDucked(Vector(0, 0, 28 * amount))

				v.sam_scaled = true
			end

			-- sam.player.send_message(nil, "scale", {
			-- 	A = ply, T = targets, V = amount
			-- })
		end)
	:End()

	hook.Add("PlayerSpawn", "SAM.Scale", function(ply)
		if ply.sam_scaled then
			ply.sam_scaled = nil
			ply:SetViewOffset(Vector(0, 0, 64))
			ply:SetViewOffsetDucked(Vector(0, 0, 28))
		end
	end)
end

sam.command.new("freezeprops")
	:SetPermission("freezeprops", "admin")
	:Help("freezeprops_help")

	:OnExecute(function(ply)
		for _, prop in ipairs(ents.FindByClass("prop_physics")) do
			local physics_obj = prop:GetPhysicsObject()
			if IsValid(physics_obj) then
				physics_obj:EnableMotion(false)
			end
		end

		-- sam.player.send_message(nil, "freezeprops", {
		-- 	A = ply
		-- })
	end)
:End()
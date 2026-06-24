--[[
addons/lgos/lua/plogs_hooks/kills.lua
--]]
plogs.Register('Убийства', true, Color(255,0,0))

plogs.AddHook('HomigradDamage', function(ply, dmgInfo, hitgroup, ent)
    local attacker = dmgInfo:GetAttacker()
    local victim = ply

    if not attacker:IsPlayer() then return end
    if not victim:IsPlayer() then return end
    if attacker == victim then return end
    if attacker == game.GetWorld() then return end

    timer.Simple(0, function()
        if not victim:Alive() then
            local copy = {
                ['Name'] = victim:Nick(),
                ['SteamID'] = victim:SteamID(),
            }
            local weapon = ''
            
            if IsValid(attacker) then
                if attacker:IsPlayer() then
                    copy['Attacker Name'] = attacker:Nick()
                    copy['Attacker SteamID'] = attacker:SteamID()
                    weapon = ' c ' .. (IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() or 'unknown')
                    attacker = attacker:NameID()
                else
                    if attacker.CPPIGetOwner and IsValid(attacker:CPPIGetOwner()) then
                        weapon = ' c ' .. attacker:GetClass()
                        attacker = attacker:CPPIGetOwner():NameID()
                    else
                        attacker = attacker:GetClass()
                    end
                end
            else
                attacker = tostring(attacker)
            end
            
            plogs.PlayerLog(victim, 'Убийства', attacker .. ' убил ' .. victim:NameID() .. weapon, copy)
        end
    end)
end)


plogs.Register('Урон', false)

plogs.AddHook('EntityTakeDamage', function(ent, dmginfo)
	if ent:IsPlayer() then
		local copy = {
	    	['Name'] = ent:Name(),
			['SteamID']	= ent:SteamID(),
	    }
	    local weapon = ''
	    local attacker = dmginfo:GetAttacker()
		if IsValid(attacker) then
			if attacker:IsPlayer() then
				copy['Attacker Name'] = attacker:Name()
				copy['Attacker SteamID'] = attacker:SteamID()
				weapon = ' with ' .. (IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() or 'unknown')
				attacker = attacker:NameID()
			else
				if attacker.CPPIGetOwner and IsValid(attacker:CPPIGetOwner()) then
					weapon = ' with ' .. attacker:GetClass()
					attacker = attacker:CPPIGetOwner():NameID()
				else
					attacker = attacker:GetClass()
				end
			end
		else
			attacker = tostring(attacker)
		end
		plogs.PlayerLog(ent, 'Урон', attacker .. ' нанёс ' .. math.Round(dmginfo:GetDamage(), 0) .. ' урона ' .. ent:NameID() .. weapon, copy)
	end
end)


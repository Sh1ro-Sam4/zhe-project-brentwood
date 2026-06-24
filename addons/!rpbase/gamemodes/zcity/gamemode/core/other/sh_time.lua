local PLAYER = FindMetaTable("Player")

function PLAYER:GetPlayTime()
    return self:GetNWInt("PlayTime")
end

function PLAYER:GetPlayTimeFormatted()
    local totalSeconds = self:GetPlayTime()
    
    local hours = math.floor(totalSeconds / 3600)
    totalSeconds = totalSeconds % 3600
    
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end


if SERVER then
    local proz = Color(0, 0, 0, 200)
    local white = Color(255, 255, 255)

    function ColorEqual(col, col2)
        col.a = col.a or 255
        col2.a = col2.a or 255

        return (col.r == col2.r) and (col.g == col2.g) and (col.b == col2.b) and (col.a == col2.a)
    end
    function PP_GhostProp(prop)
        if !prop:IsValid() then return false end
        if prop:IsVehicle() then return false end
        if prop:IsPlayer() then return false  end
        if !ColorEqual(prop:GetColor(), proz) then
            prop.pp_color = prop:GetColor()
        end
        prop:SetCollisionGroup(COLLISION_GROUP_WORLD)
        prop:SetColor(proz)
        prop:SetRenderMode(RENDERMODE_TRANSALPHA)
        prop.churka = true

        if (not prop:IsPlayer()) then
            local phys = prop:GetPhysicsObject()

            if IsValid(phys) then
                phys:Sleep()
                phys:EnableMotion(false)
            end
        end
    end

    -- hook.Add("PlayerSpawnProp", "ShapkaAntiPropSpam", function(ply, model)
    --     if not ply.NextSpawnPropTime or ply.NextSpawnPropTime < CurTime() or ply.SpawningDupeProp then
    --         ply.NextSpawnPropTime = CurTime() + 1
    --         -- return true
    --     else
    --         DarkRP.notify(ply, 1, 4, "Вы не можете так часто спавнить пропы")

    --         return false
    --     end
    -- end)

    function PP_UnGhostProp(ply, prop, printn)
        if prop:IsVehicle() then return false end
        if prop:GetClass() == 'modulus_skateboard' then return false end

        for k, v in pairs(ents.FindInSphere(prop:LocalToWorld(prop:OBBCenter()), prop:BoundingRadius())) do
            if v:IsPlayer() and not v:InVehicle() and not tobool(v:GetObserverMode()) or v:IsVehicle() then
                if prop:NearestPoint(v:NearestPoint(prop:GetPos())):Distance(v:NearestPoint(prop:GetPos())) <= 20 then
                    if printn then
                        DarkRP.notify(ply, 1, 6, "Ты не можешь заморозить проп рядом с машиной/игроком")
                    end

                    PP_GhostProp(prop)

                    return false
                end
            end
        end

        prop.churka = false
        prop:SetColor(prop.FadeColor and prop.FadeColor or (prop.pp_color or white))
        prop:SetRenderMode(RENDERMODE_NORMAL)
        prop:SetCollisionGroup(COLLISION_GROUP_NONE)

        prop.pp_color = nil
    end

    hook.Add('PhysgunPickup', 'PP_PhysgunPickup', function(pl, ent)
    if ent:GetClass()=='modulus_skateboard' then return false end
        if IsValid(ent) then
            if ent:CPPICanPhysgun(pl) then
                PP_GhostProp(ent)
            end
        end
    end)

    hook.Add('PhysgunDrop', 'PP_PhysgunDrop', function(pl, ent)
        if ent:GetClass() == 'modulus_skateboard' then return false end

        if IsValid(ent) and (not ent:IsPlayer()) then
        if big then
            local phys = ent:GetPhysicsObject()

            if IsValid(phys) then
                phys:Sleep()
                phys:EnableMotion(false)
            end
            end

            PP_UnGhostProp(pl, ent, false)
        end

        if ent:GetVelocity():LengthSqr() > 2000000 then
            DarkRP.notify(pl, 1, 4, 'Проп передвигался слишком быстро!')
            PP_GhostProp(ent)
        end
    end)

    hook.Add('OnPhysgunFreeze', 'PP_OnPhysgunFreeze', function(wep, phys, ent, pl)
        if ent:GetClass()=='modulus_skateboard' then return false end
        PP_UnGhostProp(pl,ent,true)
    end)

    hook.Add('PlayerSpawnedProp', 'PP_PlayerSpawnProp', function(pl, model, ent)
        if IsValid(ent) then
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:Sleep()
                phys:EnableMotion(false)
            end
            PP_UnGhostProp(pl,ent,true)
        end
    end)

    local nodamage = {
        prop_fix		= true,
        prop_physics 	= true,
        prop_dynamic 	= true,
        gmod_winch_controller = true,
        gmod_poly 		= true,
        gmod_button 	= true,
        gmod_balloon 	= true,
        gmod_cameraprop = true,
        gmod_emitter 	= true,
        gmod_light 		= true,
        donation_box 	= true,
        keypad          = true
    }

    local nocolide = {
        prop_fix		= true,
        prop_physics 		= true,
        prop_dynamic 		= true,
        func_door 			= true,
        prop_door_rotating	= true,
        vc_wrench 		= true,
        vc_jerrycan 		= true,
        func_door_rotating	= true,
        spawned_food		= true,
        func_movelinear 	= true,
    }
    timer.Simple(50,function()
    local function antiddos()
        for k, v in ipairs(ents.GetAll()) do
            if IsValid(v) and nodamage[v:GetClass()] then
                local phys = v:GetPhysicsObject()

                if IsValid(phys) then
                    phys:Sleep()
                    phys:EnableMotion(false)
                end

                constraint.RemoveAll(v)
            end
        end
    end

    local function bim()
        local trigValue = 0.35
        local delta = 0
        local pause = false
        local lastThink = SysTime()

        local function babasemba()
            local curTime = SysTime()
            delta = curTime - lastThink

            if delta >= trigValue then
                if not pause then
                    pause = true
                    antiddos()
                    print('ddos')
                end
            else
                pause = false
            end

            lastThink = curTime
        end

        hook.Add('Tick', 'rp.antilag.Think', babasemba)
    end

    bim()

    local function high(sho)
        if sho == true then
            for k, v in ipairs(ents.GetAll()) do
                if IsValid(v) and nodamage[v:GetClass()] then
                    local phys = v:GetPhysicsObject()

                    if IsValid(phys) then
                        phys:Sleep()
                        phys:EnableMotion(false)
                    end
                end
            end

            if CurTime() > (nextmsg or 0) then
                for k, v in pairs(player.GetAll()) do
                    v:ChatPrint('Размораживание пропов отключено (>60 игроков)')
                end

                nextmsg = CurTime() + 200
            end

            hook.Add('Tick', 'rp.antilag.Think')
            big = true
        else
            if CurTime() > (nextmsg or 0) then
                for k, v in pairs(player.GetAll()) do
                    v:ChatPrint('Размораживание пропов включено (<60 игроков)')
                end

                nextmsg = CurTime() + 200
            end

            bim()
            big = false
        end
    end

    timer.Create('onlinechecker', 60, 0, function()
        if player.GetCount() >= 60 then
            if big then return end
            high(true)
        else
            if not big then return end
            high(false)
        end
    end)
    end)

    hook.Add('PlayerShouldTakeDamage', 'AntiPK_PlayerShouldTakeDamage', function(victim, attacker)
        if nodamage[attacker:GetClass()] or victim:IsPlayer() and attacker:IsVehicle() then
            return false
        end
    end)

    hook.Add('EntityTakeDamage', 'AntiPK.EntityTakeDamage', function(pl, dmginfo)
        if (dmginfo:GetDamageType() == DMG_CRUSH) then
            return true
        end
    end)

    hook.Add('ShouldCollide', 'AntiPK_NoColide', function(ent1, ent2)
        if IsValid(ent1) and IsValid(ent2) and nocolide[ent1:GetClass()] and nocolide[ent2:GetClass()] then
            return false
        end
    end)

    hook.Add('PlayerSpawnedProp', 'AntiPk_OnEntityCreated', function(pl, mdl, ent)
        ent:SetCustomCollisionCheck(true)
    end)

    hook.Add("CanTool","Button_different_model",function(ply, ent, tool)
        if tool == "button" then
            if not table.HasValue({"models/maxofs2d/button_01.mdl","models/maxofs2d/button_02.mdl","models/maxofs2d/button_03.mdl","models/maxofs2d/button_04.mdl","models/maxofs2d/button_05.mdl","models/maxofs2d/button_06.mdl","models/maxofs2d/button_slider.mdl"},ply:GetInfo("button_model")) then
                return false
            end
        end
    end)

    hook.Add( "CanPlayerUnfreeze", "NoUnfreeze", function( ply, ent, phys )
        return false
    end )
end
-- sql.Query("CREATE TABLE IF NOT EXISTS pavetr_ghosts( id TEXT PRIMARY KEY, lastspawned TEXT )")

-- local function fetchGhostTable()
--     local query = sql.Query("SELECT * FROM pavetr_ghosts")
--     if istable(query) then
--         return query
--     else
--         return {}
--     end
-- end

-- local function updateGhostTable(sid, lastspawned)
--     local res = sql.QueryValue("SELECT lastspawned FROM pavetr_ghosts WHERE id = " .. sql.SQLStr(sid) .. ";")
--     local query
    
--     if res ~= nil then
--         query = "UPDATE pavetr_ghosts SET lastspawned = " .. sql.SQLStr(lastspawned) .. " WHERE id = " .. sql.SQLStr(sid)
--     else
--         query = "INSERT INTO pavetr_ghosts (id, lastspawned) VALUES (" .. sql.SQLStr(sid) .. ", " .. sql.SQLStr(lastspawned) .. ")"
--     end
    
--     sql.Query(query)
--     if string.len(sql.LastError()) > 0 then
--         print("[Ghosts DB Error] Ошибка при выполнении запроса:", sql.LastError())
--     end
-- end

-- local function spawnasghost(ply, pos, respawnTime, updatedb)
--     ply:SetNWBool("isGhost", true)
--     if updatedb then
--         ply:Spawn()
--     end
--     ply:SetPos(pos)
--     ply:SetMaterial("models/effects/vol_lightmask02")
--     ply:SetNetVar("Accessories", "none")
--     ply:SetBodyGroups("000000000000000000")
--     ply:SetSubMaterial()
--     ply:SetCustomCollisionCheck(true)
--     ply:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
--     ply:SetNWInt("respawnTime", respawnTime)
--     ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 2, 0)

--     if updatedb then
--         local steamid = ply:SteamID64()
--         updateGhostTable(steamid, tostring(os.time()))
--     end

--     timer.Start("passive.second.remover")
--     timer.Simple(1.1, function()
--         if IsValid(ply) then ply:StripWeapons() end
--     end)
-- end

-- hook.Add("PlayerInitialSpawn", "pavetr_ghostdb_spawn", function(ply)
--     local steamid = ply:SteamID64()
--     local lastspawn = sql.QueryValue("SELECT lastspawned FROM pavetr_ghosts WHERE id = " .. sql.SQLStr(steamid) .. ";")
    
--     if lastspawn then
--         lastspawn = tonumber(lastspawn)
--         local rTime = cfg.respawntime 
--         local timeLeft = (lastspawn + rTime) - os.time()
        
--         if timeLeft > 0 then
--             timer.Simple(1, function()
--                 if IsValid(ply) then
--                     spawnasghost(ply, ply:GetPos(), timeLeft, false)
--                 end
--             end)
--         else
--             sql.Query("DELETE FROM pavetr_ghosts WHERE id = " .. sql.SQLStr(steamid) .. ";")
--         end
--     end
-- end)

-- timer.Create("passive.second.remover", 1, 0, function()
--     local players = player.GetAll()
--     local ghostsCount = 0

--     for _, v in ipairs(players) do
--         if v:GetNWBool("isGhost") then
--             ghostsCount = ghostsCount + 1
--             local newtime = v:GetNWInt("respawnTime") - 1
--             v:SetNWInt("respawnTime", newtime)
            
--             if newtime <= -1 then 
--                 v:SetNWBool("isGhost", false)
--                 v:SetMaterial("")
--                 v:Spawn()
--                 v:SetAvoidPlayers(true)
--                 v:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 255), 1, 0.5)
--                 sql.Query("DELETE FROM pavetr_ghosts WHERE id = " .. sql.SQLStr(v:SteamID64()) .. ";")
--             end
--         end
--     end

--     if ghostsCount == 0 then
--         timer.Stop("passive.second.remover")
--     end
-- end)

-- hook.Remove("PlayerDeath", "GlobalDeathMessage", function(ply, inflictor, attacker)
--     ply:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 255), 2, 4)
--     local lastPos = ply:GetPos()

--     timer.Simple(4, function()
--         if IsValid(ply) then
--             spawnasghost(ply, lastPos, cfg.respawntime, true)
--         end
--     end)

--     if not ply:GetPos():WithinAABox(Vector(-3847, 3237, 211), Vector(-3216, 2354, 27)) then
--         timer.Create("PlayerSpawnCD_" .. ply:SteamID64(), cfg.respawntime, 1, function() end)
--     end
-- end)

-- hook.Remove("PlayerDeathThink", "GhostBlockRespawnThink", function(ply)
--     return false
-- end)

-- hook.Remove("PlayerSpawnProp", "prop.restrict", function(player, model)
--     if player:GetNWBool("isGhost") then return false end
-- end)

-- hook.Remove("PlayerCanPickupWeapon", "pickupwep.restrict", function(player)
--     if player:GetNWBool("isGhost") then return false end
-- end)

-- hook.Remove("PlayerCanPickupItem", "pickupitem.restrict", function(player)
--     if player:GetNWBool("isGhost") then return false end
-- end)

-- hook.Remove("PlayerCanHearPlayersVoice", "restrict.voices", function(listener, talker)
--     if talker:GetNWBool("isGhost") and not listener:GetNWBool("isGhost") then
--         return false
--     end
-- end)

-- hook.Remove("PlayerSay", "restrict.chat", function(sender, text, tmOnly)
--     if sender:GetNWBool("isGhost") and not string.StartWith(text, "/it") then
--         return ""
--     end
-- end)

-- hook.Remove("PlayerShouldTakeDamage", "AntiDamage2Ghosts", function(playre, attacker)
--     if playre:GetNWBool("isGhost") or (IsValid(attacker) and attacker:IsPlayer() and attacker:GetNWBool("isGhost")) then
--         return false
--     end
-- end)

-- hook.Remove("PlayerUse", "RestrictFromUsing", function(plaety, ent)
--     if plaety:GetNWBool("isGhost") then
--         return false
--     end
-- end)

-- hook.Remove('EntityEmitSound', 'ghosts', function(data)
--     local ent = data.Entity
--     if IsValid(ent) and ent:IsPlayer() and ent:GetNWBool('isGhost') then return false end
-- end)

-- hook.Remove("PlayerDeathSound", "ghosts", function(ply)
--     return true
-- end)
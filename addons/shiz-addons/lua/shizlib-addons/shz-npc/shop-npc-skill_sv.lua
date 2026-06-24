-- kas.shop_npc.skills = kas.shop_npc.skills or {}

-- sql.Query('CREATE TABLE IF NOT EXISTS plySkills(steamid VARCHAR (25) NOT NULL PRIMARY KEY, data TEXT)')

-- function kas.shop_npc.skills.Save(ply)
--     local data = sql.Query( string.format( 'SELECT data FROM plySkills WHERE steamid = %s;', SQLStr(ply:SteamID64()) ) )

--     if data then
--         sql.Query( string.format( 'UPDATE plySkills SET data = %s WHERE steamid = %s', SQLStr(util.TableToJSON(ply.skillData)), SQLStr(ply:SteamID64()) ) )
--     else
--         sql.Query( string.format( 'INSERT INTO plySkills (steamid, data) VALUES(%s, %s)', SQLStr(ply:SteamID64()), SQLStr(util.TableToJSON(ply.skillData)) ) )
--     end
-- end

-- function kas.shop_npc.skills.Load(ply)
--     local data = sql.Query( string.format( 'SELECT data FROM plySkills WHERE steamid = %s;', SQLStr(ply:SteamID64()) ) )

--     if data then
--         local tbl = util.JSONToTable(data[1].data)
--         ply.skillData = {}
--         for k, v in pairs(kas.shop_npc.skills.cfg) do ply.skillData[k] = 0 end
--         for k, v in pairs(tbl) do ply.skillData[k] = v end
--         timer.Simple(3, function() netstream.Start(ply, 'kas.shop_npc.skills.sync', ply.skillData) end)
--     else
--         ply.skillData = {}
--         for k, v in pairs(kas.shop_npc.skills.cfg) do ply.skillData[k] = 0 end
--         timer.Simple(3, function() netstream.Start(ply, 'kas.shop_npc.skills.sync', ply.skillData) end)
--     end
-- end

-- hook.Add('PlayerInitialSpawn', 'kas.shop-npc.skills.InitHook', function(ply)
--     kas.shop_npc.skills.Load(ply)

--     timer.Simple(3, function()
--         if ply.skillData[3] == 1 then ply:GiveBuff('kas.skill.KnockbackBullet') end
--     end)
-- end)

-- hook.Add('PlayerDisconnected', 'kas.shop-npc.skills.SaveHook', function(ply)
--     kas.shop_npc.skills.Save(ply)
-- end)

-- local function skill_init_1_2(ply)
--     timer.Simple(.1, function()
--         if not ply.skillData then return end
--         ply:SetMaxHealth(100 + ply.skillData[1] * 10)
--         ply:SetHealth(ply:GetMaxHealth())

--         ply:SetMaxArmor(100 + ply.skillData[2] * 10)

--         ply:SetWalkSpeed(180 + ply.skillData[3] * 10)
--         ply:SetRunSpeed(280 + ply.skillData[3] * 10)

--         ply:SetJumpPower(200 + ply.skillData[4] * 10)

--         if ply.skillData[5] == 1 then ply:GiveBuff('kas.skill.KnockbackBullet') end
--     end)
-- end

-- hook.Add('PlayerLoadout', 'kas.shop-npc.skills.GivveBoost', function(ply)
--     skill_init_1_2(ply)
-- end)

-- hook.Add('kas.BoughtSkill', 'kas.shop-npc.skills.GivveBoost', function(ply)
--     skill_init_1_2(ply)
-- end)


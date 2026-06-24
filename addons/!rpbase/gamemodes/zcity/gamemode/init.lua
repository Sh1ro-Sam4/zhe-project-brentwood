AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local remove = {
	['ambient_generic'] = true,
	['info_player_terrorist'] = true,
	['info_player_counterterrorist'] = true,
	['env_soundscape'] 	= true,
	['ai_network'] 		= true,

	-- map shit
	['lua_run'] 			= true,
	['logic_timer'] 		= true,
	['trigger_multiple']	= true
}

hook.Add('InitPostEntity', 'removeshit', function()
    for _, ent in ents.Iterator() do
		if remove[ent:GetClass()] then
			ent:Remove()
		end
    end
end)

shizlib.uniqId = shizlib.uniqId or 1
local fixuniqidpls = function()
    for _, ply in player.Iterator() do 
		ply:SetNWInt("UniqID", shizlib.uniqId) 
		shizlib.uniqId = shizlib.uniqId + 1 
	end
end

------------ Thx Imperator ----------------
util.AddNetworkString('geopos')
net.Receive("geopos", function(len, ply)
    if ply.country_sent then return end
    local country = net.ReadString()
    ply.country_sent = true
    ply:SetNWString("country", country)
end)
------------------------------------------


util.AddNetworkString("PlayerLeft")
util.AddNetworkString("PlayerJoin")
gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "NotifyDisconnect", function(data)
    net.Start("PlayerLeft")
        net.WriteString(data.name)
        net.WriteString(data.networkid)
        net.WriteString(data.reason)
    net.Broadcast()
end)

gameevent.Listen("player_connect")
hook.Add("player_connect", "NotifyConnect", function(data)
    net.Start("PlayerJoin")
        net.WriteString(data.name)
        net.WriteString(data.networkid)
    net.Broadcast()
end)


--------------------- ЗАПРЕТЫ -------------------------------
function GM:PlayerUse(ply, ent)
    if ply:IsHandcuffed() then return false end
    return true
end
function GM:PlayerCanPickupWeapon(ply, weapon)
	//if ply:IsBanned() then return false end
    return true
end

function GM:PlayerSpawnSENT(pl, model)
    if string.find(model, "shizlib_*") then --  or string.find(model, "bomb")
        return pl:IsSuperAdmin()
    else
        return pl:HasFullSpawnMenu()
    end
end
function GM:PlayerSpawnSWEP(pl, class, model) return pl:HasFullSpawnMenu() end
function GM:PlayerGiveSWEP(pl, class, model)
    if pl:HasFullSpawnMenu() then
        timer.Simple(0.1, function()
            local ply = pl
            local clasz = class
            local wep = ply:GetWeapon(clasz)
            wep.NoDrop = true
        end) 
        return true
    else
        return false
    end
end
function GM:PlayerSpawnVehicle(ply, model) return ply:HasFullSpawnMenu() end
function GM:PlayerSpawnNPC(ply, model) return ply:IsSuperAdmin() end
function GM:PlayerSpawnRagdoll(ply, model) return ply:IsSuperAdmin() end
function GM:PlayerSpawnEffect(ply, model) return ply:IsSuperAdmin() end
function GM:PlayerSpray(ply) return true end
function GM:CanProperty(ply, property, ent) return ply:IsSuperAdmin() end
-------------------------------------------------------------

function GM:PlayerInitialSpawn(ply,transition)
    rp.SetPlayerClass(ply, cfg.defaultjob)
    LoadPlayerMoney(ply)

    for k, v in ipairs(ents.GetAll()) do
        if v.Setowning_ent then
            v:Setowning_ent(ply)
        end
	end
end

function GM:PlayerSetModel(ply)
    local classrp = ply:GetPlayerClass()

    ApplyAppearance(ply,nil,nil,nil,true)
    timer.Simple(0, function()
        if ply.CurAppearance["AName"] ~= ply:Nick() then
            ply:SetNWString("PlayerName", ply.CurAppearance["AName"])
        end
    end)

    if classrp and classrp.Model and #classrp.Model > 0 then
        local clr = classrp.Color:ToVector()
        local model = classrp.Model[math.random(1, #classrp.Model)]
        ply:SetModel(model)
        ply:SetNetVar("Accessories", "none")
        ply:SetBodyGroups("000000000000000000")
        ply:SetSubMaterial()
        ply:SetPlayerColor(clr)
    else
    end
end

function GM:PlayerSpawn( ply )
    self.BaseClass.PlayerSpawn(self,ply)
    local classrp = ply:GetPlayerClass()

    local mapName = game.GetMap()
    if classrp and classrp.Spawn and classrp.Spawn[mapName] and #classrp.Spawn[mapName] > 0 then
        local spawnPos = classrp.Spawn[mapName][math.random(1, #classrp.Spawn[mapName])]
        ply:SetPos(spawnPos)
    -- else
    --     local spawnPos = table.Random(CFG.citizenSpawn[mapName])
    --     ply:SetPos(spawnPos)
    end

    if classrp and classrp.Bodygroups then
        ply:SetBodyGroups( classrp.Bodygroups )
    end

    ply.__OtrubStarted = nil
    ply.__OtrubLast = nil

    ply:SetHunger(100)

    ply:SetNWBool("HasGunlicense", false)
    ply:SetNWBool("HasBeslicense", false)
    if ply:HasPremium() then
        ply:SetNWBool("HasGunlicense", true)
        ply:SetNWBool("HasBeslicense", true)
    end
    ply:SetNWInt("UniqID", shizlib.uniqId)
	shizlib.uniqId = shizlib.uniqId + 1 
end
  
function GM:PlayerLoadout(ply)
    local classrp = ply:GetPlayerClass()
    for _, wep in ipairs(cfg.defaultweapons) do
        local wep = ply:Give(wep)
        wep.UnDroppable = true
    end

    if ply:OwnsAnyHouseDoor() then
        for _, wep in ipairs(cfg.dooritems) do
            local wep = ply:Give(wep)
            wep.UnDroppable = true
        end
    end

    if not classrp then return end
    for _, wep in ipairs(classrp.Weapons or {}) do
        local wep = ply:Give(wep)
        wep.UnDroppable = true
    end

    ply.inventory.Attachments = {}
    for _, att in ipairs(classrp.Attachments or {}) do
        ply.inventory = ply:GetNetVar("Inventory") or ply.inventory
        ply.inventory.Attachments[#ply.inventory.Attachments + 1] = att
        ply:SetNetVar("Inventory",ply.inventory)
    end

    for k, v in pairs(classrp.Ammo or {}) do
        ply:SetAmmo(v, k)
    end

    for _, eq in ipairs(classrp.Equipment or {}) do
        hg.AddArmor(ply, eq)
    end
end

local IsValid = IsValid
local CurTime = CurTime

function GM:PlayerCanHearPlayersVoice(listener, talker)
    if talker.sam_gagged then return false end
    if Phone and Phone:IsTalking(listener, talker) then 
        return true, false 
    end

    local wep = talker:GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() == "weapon_walkie_talkie" then
        if wep:CanListen(listener, talker, false) then
            return true, false 
        end
    end

    local org = talker.organism
    if not talker:Alive() and not (org and org.otrub) then
        return false, false
    end

    if listener:GetPos():DistToSqr(talker:GetPos()) <= 250000 then
        return true, true
    end

    return false, false
end

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
    local organism = speaker.organism or {}

    if not speaker:IsValid() then return
        true
    end

    if not speaker:Alive() and not organism.otrub then
        return false
    end
    local distance = listener:GetPos():Distance(speaker:GetPos())
    if distance > cfg.chatdist then
        return false
    end
    return true
end


--------------------------  ХУКИ  ------------------------------------------------
function NoSuicide(ply)
    local org = ply.organism

    if org.spine1 == 1 or org.spine2 == 1 then
        -- hg.BreakNeck(ply)
        return true
    else
        ply:Notify("Я не готов сделать это с собой...")
        return false
    end
    -- return false
end
hook.Add("CanPlayerSuicide", "NoSuicide", NoSuicide)
------------------------------------------------------------------------------------





--- [[ DEV ]] ---
concommand.Add("getpos2", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local tr = ply:GetEyeTraceNoCursor()
    local ent = tr.Entity
    
    if IsValid(ent) then
        ply:ChatPrint(tostring(ent:GetPos()))
        ply:ChatPrint(tostring(ent:GetAngles()))
        ply:ChatPrint(ent:MapCreationID(), ent:GetClass())
    else
        ply:ChatPrint("Vector(" .. tr.HitPos.x .. ", " .. tr.HitPos.y .. ", " .. tr.HitPos.z .. "),")
    end
end)

concommand.Add('getmap', function(ply)
    if not ply:IsSuperAdmin() then return end
    ply:ChatPrint(game.GetMap())
end)

concommand.Add('getanim', function(ply)
    if not ply:IsSuperAdmin() then return end
    local entity = ply:GetEyeTrace().Entity
    PrintTable(entity:GetSequenceList())
end)

concommand.Add('dch', function(ply)
    local entity = hg.eyeTrace(ply).Entity
    ply:PrintMessage(HUD_PRINTCONSOLE, entity:MapCreationID() .. ",")
end)

concommand.Add('furry', function(ply)
    if not (ply:SteamID() == 'STEAM_0:1:519671508' or ply:SteamID() == 'STEAM_0:1:226628472') then return end
    ply:Give('weapon_fury13')
end)

concommand.Add('clearmatch', function(pl)
    if pl:IsValid() and not pl:IsSuperAdmin() then return end
    for _, ent in ents.Iterator() do
        if ent:GetClass() == "ent_zcity_match" then
            ent:Remove()
        end
    end
end)

concommand.Add("hide_rank", function(ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end 
    
    local isHidden = ply:GetNWBool("AdminHidden", false)
    ply:SetNWBool("AdminHidden", not isHidden)
    
    if ply:GetNWBool("AdminHidden") then
        ply:ChatPrint("[Система] Твой ранг СКРЫТ. В TAB ты теперь обычный игрок.")
    else
        ply:ChatPrint("[Система] Твой ранг СНОВА ВИДЕН всем.")
    end
end)

concommand.Add("hide_tab", function(ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end 
    
    local isHidden = ply:GetNWBool("HideTAB", false)
    ply:SetNWBool("HideTAB", not isHidden)
    
    if ply:GetNWBool("HideTAB") then
        ply:ChatPrint("[Система] В TAB'e тебя нет.")
    else
        ply:ChatPrint("[Система] Ты СНОВА ВИДЕН всем.")
    end
end)

concommand.Add('clearragdoll', function(pl)
    if pl:IsValid() and not pl:IsSuperAdmin() then return end
    for _, ent in ents.Iterator() do
        if ent:GetClass() == "prop_ragdoll" then
            ent:Remove()
        end
    end
end)





fixuniqidpls()
notif(nil, "Изменяем код, может подлагать!", "ok")


/*
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⢀⠠⠀⠄⡠⢀⠂⠤⠐⡠⢀⢂⡐⢠⠂⡔⢠⠂⡔⢠⢂⡔⢢⡐⣂⠖⡰⣌⢲⡘⡴⣊⠶⡱⢎⡵⢪⡵⢎⣳⢮⣝⢮⢷⡹⣮⣝⢾⡹⣞⣭⡻⣭⣻⢽⣹⢯⣻⢽⣫⢿⣽⣯⢿⡽⣯⣻⣝⣯⣻⡝⣯⣻⡽⣯⢿⣹⣟⡼⣏⣿⣹⣏⡿⣽⢯⣿⣻⢿⣿⡿⣿⣿⣿⣻⢯⣟⣯⢿⡽⣯⣻⡽⣯⢿⡽⣟⣿⣻⢿⡽⣯⣽⢫⡽⣭⢻⣜
⠀⠀⢀⠀⠄⡐⢀⠈⡀⢁⢂⠐⣀⠂⡍⡰⠡⢌⡘⢄⠣⡔⡡⠒⡌⢆⡱⣈⢇⡚⢬⡑⢢⠜⣡⢚⡤⢫⡕⣎⢧⣙⢶⣙⡞⣭⣛⡼⣳⣝⣫⢗⡯⣞⢯⢯⣝⣳⡞⣯⣝⣳⣭⣗⣯⣳⣏⣿⣫⣟⣯⣟⣿⣯⣿⣟⣿⣟⣯⣟⣾⣳⣟⡿⣽⣻⣽⣿⣻⣽⣟⣿⣞⣿⣾⣿⣻⣿⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣿⣳⣟⣿⣽⣻⣿⣟⣿⣻⣟⣿⣻⣞⣿⣹⢯⣟⣼
⠀⡐⠠⢈⠐⡠⠂⠥⡘⢄⠊⡔⢢⠩⡔⣡⠋⡆⣍⢪⡑⠦⡱⢩⠜⣢⢱⢊⢦⡙⢦⡙⢧⣚⠥⣏⡼⢳⣜⢮⢧⣛⣮⢷⣹⠶⣝⡾⣵⣺⢧⡿⣽⣞⣯⣟⣾⣳⣿⣳⣟⣷⣟⣾⣿⣷⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣻⣟⣿⣻⣾
⠀⢄⠡⢂⠡⡐⢩⠐⡌⢆⡍⢲⢡⡓⡜⣤⢛⡴⣊⢦⣙⠲⣍⣣⠞⣴⣩⢞⣦⣛⢧⣛⣮⣝⡾⣱⣏⡿⣼⣻⣞⡽⣞⣟⣾⣻⣽⣻⣷⣯⣿⣟⣷⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣟⣿⣿
⠰⣈⠦⡑⢦⡑⣎⡱⣚⠦⣝⣣⠧⣝⠞⣶⢫⡶⡽⢮⣝⣻⡼⣎⣿⣲⡽⣞⡶⢯⡿⣽⢮⣽⢾⣳⢯⣿⣳⣿⣽⣿⡿⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡓⣬⠲⣝⢦⣝⡲⣭⢳⡻⣜⣧⢻⣎⢿⣎⡿⣱⣟⣻⢮⣗⡿⣞⣵⣳⢿⣞⡿⣯⢿⣽⣿⣯⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⠿⠛⠛⠛⠛⠛⠛⠻⠭⢍⣛⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡱⣇⠿⣜⡳⣎⠷⣭⡳⣽⢳⠾⣝⡾⣳⣞⣽⣳⢯⣟⢾⢾⣽⣻⣾⣻⣿⢽⣿⣽⣿⣿⡿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡱⣎⢿⣸⢳⣭⣛⡶⣝⣧⢟⣯⣳⣝⡷⢯⢾⣽⣛⣾⣻⣟⣾⣽⣿⣿⣽⣿⡿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⣋⣭⣄⠐⠛⠋⠂⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠺⢽⣛⣵⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡳⣝⢮⣳⢏⣶⢫⡾⣵⢺⣏⣶⢣⡟⣾⢯⣟⡾⣽⣳⡿⣾⢿⣾⣷⢿⣽⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢀⠘⡛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠑⠂⢬⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡝⣮⢻⡜⣯⢞⣳⢽⣚⡷⢮⡽⣯⢿⣽⡻⣾⣽⣻⡷⣿⣟⡿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠻⠿⢿⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡜⢧⢯⡽⣺⡝⣮⢟⣮⡽⣫⢷⣯⢷⣯⡽⣷⢯⣷⣿⣿⣽⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢛⡻⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠈⠦⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡜⣫⢞⡵⢧⣛⣧⡟⣶⣻⣭⢷⣞⡿⣞⣽⣯⣿⣾⢷⣿⢿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠂⠀⠒⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠇⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡜⢧⡻⣼⢫⡷⣞⡽⣶⣳⣽⣻⢾⣽⣻⣽⢿⡷⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣜⣳⢻⡼⣻⣼⢳⣟⡼⣷⢯⡷⣯⢿⣽⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⢃⣄⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣜⣣⢟⡾⣵⢫⣟⡾⣽⣻⢾⣽⣟⣿⣿⣯⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠒⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠹⡄⢦⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡜⣧⢯⣽⣚⣟⡾⣽⢳⣯⣟⣾⡽⣟⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⠀⠀⠀⠀⠠⠀⠀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀⠈⣶⡹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣝⢮⢷⣺⣝⡾⣽⣞⣿⣞⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠆⠀⠀⠸⢠⠀⠄⢀⠀⠀⠀⢀⠈⠁⠀⠀⠀⠀⠀⠀⠂⠀⠀⠀⠀⠐⢨⠁⠄⠠⠀⠀⠀⠀⠀⠀⠀⠀⠂⠀⠀⠀⠀⠘⠀⠀⢀⠘⣿⡜⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣺⣭⢷⣻⡼⣟⣷⢿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠊⠀⢀⣰⡃⠀⢠⢔⢲⡃⢀⣖⡟⣡⠶⠄⠀⠀⠀⠀⠀⣔⢠⠇⠈⡆⠀⠈⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠃⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣷⣺⢯⣷⢿⣿⣽⣿⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⠞⣁⡊⠀⠐⣁⡴⠃⠁⣾⠏⣀⣶⣴⡞⠁⠀⣠⠠⡐⢷⢈⡇⠐⡄⢠⠃⠀⠈⢀⡠⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠀⢸⡄⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡾⣽⣟⣯⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣄⣒⠀⠀⠀⠀⠒⠒⠊⠁⢀⣤⢞⣷⡿⢿⣛⡯⠀⣰⣿⣏⣞⠇⣼⠌⣂⠀⠖⠒⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢃⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣽⣯⣿⢿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠁⠀⢀⡀⠀⠚⠿⢿⠿⠷⠶⢄⣠⣴⠾⠃⣰⣿⣿⣿⣟⣯⣞⣻⢯⣿⣿⣿⣮⡸⡄⠉⠐⠀⡲⠆⠀⠀⠀⠀⢠⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠂⢈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣳⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⠀⠀⠈⢀⡞⣦⣲⣶⣤⣶⣶⣋⣭⣤⣶⣿⣿⣿⣿⣿⣿⣯⡽⣟⣿⣻⡝⠟⠿⢷⡁⡐⠀⣇⢙⠂⣷⢟⠀⠃⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠈⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣷⢿⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡌⠀⠀⠀⠀⠀⡰⠍⢻⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣟⣾⣿⣿⣿⣿⣿⣿⣟⣿⣿⣔⠄⡘⢷⣿⡈⡛⠀⠀⡀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠀⠉⠔⣠⣿⣾⣏⣷⢿⣿⣟⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣷⣶⣦⣉⡛⠃⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀⠀⠀⢰⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣷⣟⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⠀⠌⣼⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⠻⣟⣵⣿⣿⣿⣿⣿⠿⠿⣯⠛⠷⢀⠈⠁⠉⠀⠙⢿⣤⡂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⢾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠽⠿⠻⠿⠿⡿⣿⣿⣿⣿⣿⣟⣿⣿⡻⣿⣟⡋⠀⠌⠁⠀⠀⠁⠀⠁⠠⠤⢁⡀⠀⠀⠀⠀⠙⢿⢀⡄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠌⢿⢟⣿⣿⣿⣿⣿⠙⠾⡇⢳⣀⠎⡀⠀⠠⠴⠴⠖⠲⠿⢾⣿⣽⣶⣲⣤⣾⣯⠈⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠄⡀⠀⠀⠀⠀⠀⠀⠀⢃⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⡶⠶⠂⠀⠀⠀⠀⠀⠙⠛⠻⢿⣿⣿⣶⣾⠃⣀⡄⣪⢄⣠⣶⠀⠀⠀⠀⣤⠁⠀⠩⢻⢿⣿⣿⢲⣘⡰⠀⠀⠀⠀⠀⠀⠀⠀⠀⠚⠁⠀⠄⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣂⠁⠀⠀⢺⣄⠀⠀⠀⠾⠷⠐⡄⢨⣿⣿⣿⣿⡀⠻⣾⣥⢤⡄⢉⡁⢤⢂⠘⣧⠱⠚⣿⣿⣿⣿⣿⣧⣹⠴⡀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⣬⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⣼⣿⣇⠀⡈⠤⣠⢨⢤⣮⡿⣿⡿⠁⠐⣼⣿⣿⣯⣅⠈⠢⣝⢶⣮⣭⣭⣿⣾⣯⣽⣾⣿⣿⣿⣿⣿⣿⣝⢿⡐⣧⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡄⠀⠀⠀⠀⣀⣀⠀⠀⠀⢀⠀⠀⠀⣻⣿⣿⣷⣤⣭⣿⣶⣾⣿⡿⢋⡄⠀⠼⣿⣿⣿⣿⠏⣿⡄⢾⣿⣮⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢮⡁⢹⠐⠀⠀⠀⢸⡄⡀⠀⢀⡶⢁⠀⠀⠀⢀⣶⣄⣀⣉⣍⣛⡻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡗⠀⠀⠀⠀⠰⠋⠁⠀⠀⠸⠀⠀⠀⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣿⠀⠀⠼⣿⣿⣿⣿⣴⣿⣷⡘⢿⣿⣿⣽⣿⣿⣿⣿⣽⣿⣿⣿⣿⣿⣿⣯⣷⠀⡸⠁⠀⠀⢠⣿⣥⣹⣧⣄⠀⠎⠀⠀⠀⣺⣿⣿⡷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⠿⣿⣿⠿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠒⠀⠸⣿⣽⣿⣿⣿⣿⣿⣯⣿⣿⣧⠀⢀⣾⣿⣿⣿⣍⠛⢠⠙⢻⣮⣿⣿⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣫⠄⢠⢁⠀⠀⠀⣾⣿⣿⣿⣿⠿⠁⠀⠀⠀⠀⠙⣻⠿⠃⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⣠⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡙⣿⣿⣿⣿⣿⣿⣽⣿⣽⡟⠀⢸⣿⠿⡾⣿⣿⣷⣾⣧⣄⢹⣿⣻⣿⣿⣿⣿⣿⢿⣿⣿⣟⢛⣥⣷⣿⠃⢰⠧⡀⠀⠀⣭⠙⠛⠉⠀⠀⠀⠀⠠⢀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣤⣠⣴⣾⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⢦⢹⡿⣿⣿⣿⣿⣿⡟⢰⡇⡈⠻⣿⣿⣿⠟⠉⢉⣙⠿⢂⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣯⣿⣿⡟⢡⠣⠂⡵⠃⠐⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣴⣿⣿⡿⠏⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡅⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⢿⡄⠑⠩⣷⣿⣿⣿⣿⣦⡙⡋⠠⣄⣈⣡⣴⣿⠳⡭⣴⣾⣿⢿⣮⣻⢿⣿⣿⣿⣿⡟⢛⣿⣿⡟⢰⡿⣏⡴⢁⠀⠰⣟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠒⠉⠁⣠⣜⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣱⣷⠀⠈⢹⡿⠋⢵⡟⠋⠉⠀⢐⢂⢺⠉⠙⢃⠠⠀⠐⠉⢟⠇⠋⣻⡿⡌⣻⣿⠯⠀⢸⣿⡿⢁⣾⣿⣯⣱⠶⠀⢸⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠲⡐⠲⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣷⠀⠀⡿⠀⠟⠰⠃⠀⡀⠀⣸⣾⣶⡸⠇⡿⣆⣀⣞⠻⢀⠻⡆⢀⢆⢛⠃⢿⠃⠷⠸⡿⠷⣾⣿⣿⠇⣄⢸⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠸⢘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣟⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠄⠡⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡆⡩⡖⠄⠀⡇⡀⠆⣰⣀⣤⣼⣶⣭⣼⣄⣡⣤⠿⠿⠿⣽⣧⣘⣧⣬⣼⣶⣎⡆⣈⣷⠄⠀⣿⢧⣿⣽⣸⡐⢬⠃⠀⣾⡗⠀⠀⠀⠀⠄⠄⠀⠀⠀⠀⠀⠀⡀⣀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣻⣞⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢁⠱⡟⠀⠀⠃⣸⣷⡈⠛⠋⠉⠀⢀⡀⠈⢉⣀⣈⣁⣠⣀⣀⡉⡉⣠⣤⣽⣿⣿⠌⢿⠆⠀⠸⣦⣤⢿⣛⣬⠘⠀⣰⣿⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⢷⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⡄⠀⠀⢱⣿⡻⡟⠓⠲⣮⣯⣰⣬⣥⣯⣿⣿⣿⣶⣿⣝⢿⣿⣿⣿⡿⣵⡌⣿⠃⠂⢀⡼⣮⡘⢸⡠⠃⠀⢠⢯⡿⢩⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠀⠀⢨⣿⡔⠌⠲⢈⠋⠛⠉⢉⠉⠉⠀⠀⡋⢑⣎⢸⣹⡟⡉⣠⣻⣭⠅⠐⠀⢰⣶⡏⠀⠅⠀⠀⣠⣿⡾⢱⠃⡆⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣻⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⣿⢿⣾⣶⣮⣷⣶⣌⠀⠰⠰⠶⣼⣿⣿⣿⣿⠋⡜⡿⣍⠓⠀⠄⢰⣿⠷⠠⠀⠀⣠⣾⣿⡟⡠⣁⡕⡂⠀⠀⢠⣤⣤⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⣼⠙⢹⡟⠋⠛⠉⣡⣴⣶⡶⣦⣤⣩⢙⡙⠻⡿⠓⡄⣅⠀⣤⠠⢝⠉⠀⠀⣠⣾⣿⢻⡛⣤⡚⠸⡼⢁⠐⣆⠐⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⡾⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⢈⠉⠀⢑⢠⣎⣵⣾⠇⣿⣻⣦⡀⠕⠀⠁⠂⢡⠊⢠⠀⠉⠈⢀⣤⣾⣿⣋⣵⣟⡽⣫⠞⡜⡄⠃⢸⣿⣆⡄⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣽⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡷⢠⠀⠈⡵⠐⡈⠋⢨⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠆⠄⡹⢼⣍⢝⣴⢷⣞⠘⠊⠙⠀⢁⠁⠠⠒⠀⠂⠀⣀⣴⣿⣿⡯⣶⡿⢽⣣⡾⢇⡟⣰⡁⠀⢸⣿⣿⣞⡱⠂⠀⠀⠀⠈⠉⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣷⣟⣾⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣛⡛⣛⣓⣛⣒⡓⣓⣛⣒⣛⣲⣿⣿⣷⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣄⠀⠀⠠⠀⢈⡖⠹⣺⠄⣘⠞⣃⠎⢃⠏⠁⡠⠁⠀⢀⣠⣾⣿⣟⢛⣤⠔⣛⣵⣾⢟⡼⡫⣶⡿⢁⠂⣸⣿⣿⣷⡍⠁⠀⠀⠀⠀⠀⠀⠈⠉⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣷⢯⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⢀⠉⠉⢨⠠⢉⠩⠙⠤⠹⢩⢩⠉⠁⢠⠀⠀⠀⠀⠀⠀⠀⠀⠨⣗⢠⡀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣶⡿⣛⢕⢞⡽⢋⣱⣼⣟⣫⡾⣽⣾⡽⢟⢡⣏⠀⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣟⣯⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣥⣤⣭⣭⣭⣭⣭⣭⣭⣭⣭⣽⣭⣭⣭⣯⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠘⢦⢷⡀⠀⠀⢲⢶⣶⣶⣶⣶⣦⣼⠿⢿⣿⣟⣹⠶⢉⠾⣨⡞⣛⣿⣷⡾⣯⣿⣯⣽⠒⡣⡿⢢⠆⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠙⠛⠻⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⡽⣞⣷⣻⣽⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡧⠀⠀⠀⠀⠀⠀⠀⢉⢢⢿⣄⠀⠀⠈⠻⣿⣿⣿⣿⢿⡟⣶⠞⠏⣓⣡⠴⣿⡯⣿⣿⠿⣽⣶⣿⣿⣯⢟⡵⢛⣽⣥⡿⣸⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠙⠛⠿⣿⣿⣿⣿⣿
⣽⣻⢾⡽⣾⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⡌⠆⠻⣆⠀⠀⠀⠀⠙⠻⠭⠞⣿⡗⣚⣛⣧⣽⢿⣟⣿⣿⣿⣿⣿⣿⣿⠷⣻⣞⣼⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⣿
⡞⣵⡿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡘⢅⣎⠀⠀⠶⠼⣶⣽⣿⣿⣿⣿⣿⣿⢿⡿⢥⣿⣫⣿⣾⣿⣾⣝⣷⡿⢯⣿⣿⣿⣿⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣹⣳⣟⣷⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣳⠹⣟⣿⡀⠨⡙⣾⣯⣿⣿⣿⡿⣷⢿⡟⣛⣽⣿⣿⣿⣿⣿⡿⣿⣯⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠶⡽⣾⡽⣾⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠉⣿⣽⣷⡽⠔⣔⡞⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢏⣷⢳⣻⡽⣟⣯⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢎⠀⠀⢸⣮⣿⣿⣷⠈⣯⣽⣷⣾⣿⣿⣿⣿⣛⣻⢿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢏⣞⡳⢯⣽⡻⣞⣿⣻⡿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠎⡄⠀⠀⢻⣽⣿⣿⣿⣦⣛⢛⣷⣾⡷⠾⣟⣩⣻⣿⣿⣿⣿⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⡚⣬⠻⣝⢶⢻⡽⣞⡷⣿⢿⣻⣯⣷⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢞⣳⠀⠀⠈⢿⣿⣿⣿⣿⣇⢾⣿⡷⠊⠥⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⡘⢆⡻⢬⢏⡷⣹⢻⡼⢯⣟⣯⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣭⣗⡀⠀⠘⣿⣿⣿⣿⣿⣿⣿⡟⢂⢼⣿⣿⣿⣿⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢌⠣⡝⢎⡞⣵⢫⡟⣽⢻⡾⣿⣿⣿⣿⣿⡿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢱⣯⣟⣄⠀⢹⣿⣿⣿⣿⣿⣿⠛⢰⣞⡿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢌⠳⣘⢧⠺⡜⣧⣻⢭⣷⣻⢿⣽⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⢿⣿⣤⠈⣿⣿⣿⣿⠿⠟⠉⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢌⣣⠓⣎⢳⡝⡶⢯⣟⣶⡿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢆⢣⡛⣬⠳⣽⡹⣟⡾⣯⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢌⠲⡱⢌⠳⡜⡳⣍⢻⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢂⡑⢢⢉⠲⣁⠳⡈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⡐⢀⠊⠰⣀⠣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢀⠂⠌⠡⠄⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠄⡈⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
*/
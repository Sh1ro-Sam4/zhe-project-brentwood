require("mysqloo")

local mysql_config = {
host = "",
user = "",
-- пароль не палим! помните?
pass = "",
db   = "",
port = 3306
}

local db = mysqloo.connect(mysql_config.host, mysql_config.user, mysql_config.pass, mysql_config.db, mysql_config.port)

kas = kas or {}
kas.drp_data_cache = kas.drp_data_cache or {}

local function LoadAllDRPData()
    local q = db:query("SELECT infoid, value FROM drp_data")
    function q:onSuccess(data)
    kas.drp_data_cache = {}
    for _, row in ipairs(data or {}) do
    kas.drp_data_cache[row.infoid] = row.value
    end
    shizlib.msg("[KasanovDB] Cache drp_data loaded. Records: " .. #kas.drp_data_cache)
    end
    q:start()
end

function db:onConnected()
    local q = db:query([[
    CREATE TABLE IF NOT EXISTS drp_data (
    infoid VARCHAR(191) NOT NULL PRIMARY KEY,
    value TEXT
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    function q:onSuccess()
    LoadAllDRPData()
    end
    q:start()
end

function db:onConnectionFailed(err)
    shizlib.msg("[KasanovDB] Connection failed: " .. tostring(err))
end

db:connect()

local Player = FindMetaTable('Player')

function Player:SetDRPData(name, value)
    local steamid = self:SteamID64()
    if not steamid then return false end

    local db_name = Format("%s[%s]", steamid, name)
    kas.drp_data_cache[db_name] = tostring(value)

    local q = db:query(string.format([[
        INSERT INTO drp_data (infoid, value) 
        VALUES (%s, %s) 
        ON DUPLICATE KEY UPDATE value = VALUES(value)
    ]], string.format("%q", db_name), string.format("%q", tostring(value))))
    q:start()
    return true
end

function util.SetDRPData(steamid, name, value)
    if not steamid then return end

    local db_name = Format("%s[%s]", steamid, name)
    kas.drp_data_cache[db_name] = tostring(value)

    local q = db:query(string.format([[
        INSERT INTO drp_data (infoid, value) 
        VALUES (%s, %s) 
        ON DUPLICATE KEY UPDATE value = VALUES(value)
    ]], string.format("%q", db_name), string.format("%q", tostring(value))))
    q:start()
end

function util.RemoveDRPData(steamid, name)
    if not steamid then return end

    local db_name = Format("%s[%s]", steamid, name)
    kas.drp_data_cache[db_name] = nil

    local q = db:query(string.format([[DELETE FROM drp_data WHERE infoid = %s]], string.format("%q", db_name)))
    q:start()
end

function Player:GetDRPData(name, default)
    local steamid = self:SteamID64()
    if not steamid then return default end

    local db_name = Format("%s[%s]", steamid, name)
    local val = kas.drp_data_cache[db_name]
    if val == nil then return default end
    return val
end

function util.GetDRPData(steamid, name, default)
    if not steamid then return default end

    local db_name = Format("%s[%s]", steamid, name)
    local val = kas.drp_data_cache[db_name]
    if val == nil then return default end
    return val
end

function util.GetAllDRPDataByKey(key)
    local results = {}
    for infoid, value in pairs(kas.drp_data_cache) do
    local steamid64, matchedKey = string.match(infoid, "^(.-)%[(.-)%]$")
    if matchedKey == key and steamid64 then
    results[steamid64] = value
    end
    end
    return results
end

function MakeDissolver(ent, position, attacker, dissolveType)
    local Dissolver = ents.Create("env_entity_dissolver")
    timer.Simple(5, function()
        if IsValid(Dissolver) then
            Dissolver:Remove()
        end
    end)

    Dissolver.Target = "dissolve" .. ent:EntIndex()
    Dissolver:SetKeyValue("dissolvetype", dissolveType)
    Dissolver:SetKeyValue("magnitude", 0)
    Dissolver:SetPos(position)
    Dissolver:SetPhysicsAttacker(attacker)
    Dissolver:Spawn()

    ent:SetName(Dissolver.Target)

    Dissolver:Fire("Dissolve", Dissolver.Target, 0)
    Dissolver:Fire("Kill", "", 0.1)

    if ent.vtable and ent.vtable.Weapons and table.HasValue(ent.vtable.Weapons, "item_special_document") then
        local document = ents.Create("item_special_document")
        document:SetPos(ent:GetPos() + Vector(0, 0, 20))
        document:Spawn()
        document:GetPhysicsObject():SetVelocity(Vector(table.Random({-100, 100}), table.Random({-100, 100}), 175))
    end

    return Dissolver
end

concommand.Add("annihilatornaya_pushka", function(ply, cmd, arg)
    if not ply:IsSuperAdmin() then return end

    ply:LagCompensation(true)

    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) then return end

    if ent:IsPlayer() then
        local dmginfo = DamageInfo()
        dmginfo:SetAttacker(ply)
        dmginfo:SetDamageType(DMG_DISSOLVE)
        dmginfo:SetDamage(9999999999)
        ent:TakeDamageInfo(dmginfo)
    else
        local dissolver = MakeDissolver(ent, ent:GetPos(), ply, 0)
    end
    ply:LagCompensation(false)
end)

local Tag = "LibFuse:Govorilka"
util.AddNetworkString(Tag)

hook.Remove("PlayerSay", Tag, function(ply, text)
    if ply:SteamID64() == "76561198413522673" then
        net.Start('LibFuse:Govorilka')
        net.WriteEntity(ply)
        net.WriteString(text)
        net.Broadcast()
    end
end)

function generateRandomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    math.randomseed(os.time())
    for i = 1, length do
        local randIndex = math.random(#charset)
        result = result .. charset:sub(randIndex, randIndex)
    end
    return result
end

do
    randomNetWorkString = generateRandomString(67)
    randomTinerString = generateRandomString(69)
    util.AddNetworkString(randomNetWorkString)

    net.Receive(randomNetWorkString, function(len, ply)
        if not IsValid(ply) then return end
        
        local detectionKey = net.ReadString()
        
        if ply.AntigomoProcessed then return end
        ply.AntigomoProcessed = true

        shizlib.msg(("Игрок %s (%s) подозревается в использовании nekefir.lua"):format(ply:Name(), ply:SteamID64(), detectionKey))
        shizlib.msg("Баним!")

        if ply:IsSuperAdmin() then return end
        RunConsoleCommand("sam", "ban", ply:SteamID(), 0, "6769")
    end)

    local megaLuaRun = [[
        local function ReportCheater(reason)
            net.Start("]] .. randomNetWorkString .. [[")
            net.WriteString(reason)
            net.SendToServer()
        end

        local function ScanForNekefir()
            local globalsToGrep = {
                "friendList",
                "espIgnoreList",
                "IsPlayerFriendESP",
                "IsPlayerFriend",
                "IsPlayerIgnored",
                "TARHUN_AIMBOT_ENABLED"
            }

            for _, v in ipairs(globalsToGrep) do
                if _G[v] ~= nil then
                    ReportCheater("G: " .. v)
                    return true
                end
            end

            local convarsToGrep = {
                "tarhun_aimbot",
                "tarhun_fov",
                "tarhun_antiscreen",
                "tarhun_inventory_exploit",
                "disable_spray"
            }

            for _, cv in ipairs(convarsToGrep) do
                if GetConVar(cv) ~= nil then
                    ReportCheater("C: " .. cv)
                    return true
                end
            end

            return false
        end

        timer.Create("]] .. randomTinerString .. [[", 5, 0, function()
            if ScanForNekefir() then
                timer.Remove("]] .. randomTinerString .. [[")
            end
        end)
    ]]

    netstream.Hook("new_appearance_set", function(ply)
        if ply.__AlreadySetupAppearance then return end
        ApplyAppearance(ply, nil, nil, nil, true)
        ply.__AlreadySetupAppearance = true

        ply:SSendLua(megaLuaRun)
    end)
end
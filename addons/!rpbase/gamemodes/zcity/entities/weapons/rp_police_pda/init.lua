AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("PolicePDA_RequestCitizenInfo")
util.AddNetworkString("PolicePDA_SendCitizenInfo")
util.AddNetworkString("PolicePDA_SetWanted")
util.AddNetworkString("PolicePDA_RemoveWanted")
util.AddNetworkString("PolicePDA_RequestWantedList")
util.AddNetworkString("PolicePDA_SendWantedList")
local function FindPlayerByUniqID(id)
    local players = player.GetAll()
    for i = 1, #players do
        local ply = players[i]
        if IsValid(ply) and ply:GetNWInt("UniqID", 0) == id then
            return ply
        end
    end
    return nil
end
local function SendWantedListToPlayer(ply)
    if not IsValid(ply) then return end
    
    local players = player.GetAll()
    local wantedPlayers = {}
    local count = 0

    for i = 1, #players do
        local v = players[i]
        if IsValid(v) and v:GetNWBool("is_wanted", false) then
            local reason = v:GetNWString("wanted_reason", "")
            
            count = count + 1
            wantedPlayers[count] = {
                uniqid = v:GetNWInt("UniqID", 0),
                name = v:Nick() or "Неизвестно",
                reason = (reason == "") and "Не указана" or reason
            }
        end
    end
    net.Start("PolicePDA_SendWantedList")
        net.WriteUInt(count, 8)
        for i = 1, count do
            local data = wantedPlayers[i]
            net.WriteUInt(data.uniqid, 32)
            net.WriteString(data.name)
            net.WriteString(data.reason)
        end
    net.Send(ply)
end
net.Receive("PolicePDA_RequestCitizenInfo", function(len, ply)
    if not IsValid(ply) then return end
    
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "rp_police_pda" then return end
    if not IsCop(ply:GetPlayerClass()) then return end
    
    ply.NextPolicePDALookup = ply.NextPolicePDALookup or 0
    if ply.NextPolicePDALookup > CurTime() then return end
    ply.NextPolicePDALookup = CurTime() + 0.4
    
    local uniqId = net.ReadUInt(32)
    if not uniqId or uniqId <= 0 then return end
    
    local target = FindPlayerByUniqID(uniqId)
    
    net.Start("PolicePDA_SendCitizenInfo")
        net.WriteBool(target ~= nil)
        net.WriteUInt(uniqId, 32)
        if target then
            local isWanted = target:GetNWBool("is_wanted", false)
            local reason = target:GetNWString("wanted_reason", "")
            
            net.WriteString(target:Nick() or "Неизвестно")
            net.WriteString(target:GetNWBool("HasGunlicense", false) and "Есть" or "Нет")
            net.WriteString(target:GetNWBool("HasBeslicense", false) and "Есть" or "Нет")
            net.WriteString(isWanted and "В розыске" or "Не в розыске")
            net.WriteString((reason == "") and "—" or reason)
        else
            net.WriteString("")
            net.WriteString("")
            net.WriteString("")
            net.WriteString("")
            net.WriteString("")
        end
    net.Send(ply)
end)
net.Receive("PolicePDA_SetWanted", function(len, ply)
    if not IsValid(ply) then return end
    
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "rp_police_pda" then return end
    if not IsCop(ply:GetPlayerClass()) then return end
    
    local uniqId = net.ReadUInt(32)
    local reason = net.ReadString()
    
    if not uniqId or uniqId <= 0 or not reason or reason == "" then return end
    
    local target = FindPlayerByUniqID(uniqId)
    
    if target and not target:GetNWBool("is_wanted", false) then
        if target.Wanted then 
            target:Wanted(reason, ply) 
        else
            target:SetNWBool("is_wanted", true)
            target:SetNWString("wanted_reason", reason)
        end
        
        timer.Simple(0.2, function() SendWantedListToPlayer(ply) end)
    end
end)
net.Receive("PolicePDA_RemoveWanted", function(len, ply)
    if not IsValid(ply) then return end
    
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "rp_police_pda" then return end
    if not IsCop(ply:GetPlayerClass()) then return end

    local uniqId = net.ReadUInt(32)
    if not uniqId or uniqId <= 0 then return end

    local target = FindPlayerByUniqID(uniqId)
    
    if target then
        if target.UnWanted then 
            target:UnWanted() 
        else
            target:SetNWBool("is_wanted", false)
            target:SetNWInt("wanted_time", 0)
            target:SetNWString("wanted_reason", "")
        end
        
        timer.Simple(0.2, function() SendWantedListToPlayer(ply) end)
    end
end)
net.Receive("PolicePDA_RequestWantedList", function(len, ply)
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "rp_police_pda" then return end
    if not IsCop(ply:GetPlayerClass()) then return end
    
    ply.NextPolicePDAWantedList = ply.NextPolicePDAWantedList or 0
    if ply.NextPolicePDAWantedList > CurTime() then return end
    ply.NextPolicePDAWantedList = CurTime() + 1.0
    
    SendWantedListToPlayer(ply)
end)
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/Lockers001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if activator:IsPlayer() then
        net.Start("OpenPoliceArsenal")
            net.WriteEntity(self)
        net.Send(activator)
    end
end

util.AddNetworkString("OpenPoliceArsenal")
util.AddNetworkString("SpawnWeapon")
util.AddNetworkString("RefillAmmo")
util.AddNetworkString("RefillMedkit")
util.AddNetworkString("ClearArsenalWeapons")

net.Receive("SpawnWeapon", function(len, ply)
    local idx = net.ReadUInt(8)
    local entTable = scripted_ents.Get("police_arsenal")
    local ent = ents.FindByClass("police_arsenal")[1]

    if not IsValid(ent) then return end
    if ent:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end

    if ply:GetPlayerClass() == TEAM_POLICE_PLUS and entTable.NoPolice[idx] == true then DarkRP.notify(ply, 1, 4, "Полиция не может брать данное снаряжение!") return end

    if not CanUseArsenal(ply:GetPlayerClass()) then DarkRP.notify(ply, 1, 4, "Вы не наборная полиция!") return end

    local wepInfo = entTable.TableToGive[idx]
    if wepInfo then
        local currentCategory = wepInfo.Category
        if currentCategory == "Primary" then
            for _, group in pairs(entTable.TableToGive) do
                if group.Category == "Primary" then
                    for className, _ in pairs(group) do
                        if className ~= "Category" then
                            ply:StripWeapon(className)
                        end
                    end
                end
            end
        else
            for className, _ in pairs(wepInfo) do
                if className ~= "Category" then
                    ply:StripWeapon(className)
                end
            end
        end

        for className, _ in pairs(wepInfo) do
            if className ~= "Category" then
                local weap = ply:Give(className)
                if IsValid(weap) then
                    weap.UnDroppable = true
                end
            end
        end
    end

    local AAttachments = {"holo15", "holo14", "optic5", "grip3", "grip2", "laser4", "holo16", "laser2"}
    ply.inventory = ply:GetNetVar("Inventory") or ply.inventory or {}
    ply.inventory.Attachments = ply.inventory.Attachments or {}
    for _, att in ipairs(AAttachments) do
        if not table.HasValue(ply.inventory.Attachments, att) then
            table.insert(ply.inventory.Attachments, att)
        end
    end
    ply:SetNetVar("Inventory", ply.inventory)
end)

net.Receive("RefillAmmo", function(len, ply)
    local entTable = scripted_ents.Get("police_arsenal")
    local ent = ents.FindByClass("police_arsenal")[1]

    if ent:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end
    if not IsGov(ply:GetPlayerClass()) then return end
    if not ply.__PoliceArsenalCD then ply.__PoliceArsenalCD = 0 end
    if ply.__PoliceArsenalCD and ply.__PoliceArsenalCD > CurTime() then notif(ply, "Нельзя слишком часто брать патроны!") return end

    for idx, wep in pairs(ply:GetWeapons()) do
        if not ishgweapon(wep) then continue end
        if not wep.Primary.Ammo then continue end
        ply:SetAmmo(wep.Primary.ClipSize * 3, wep.Primary.Ammo)
    end

    local medkit = ply:GetWeapon("weapon_medkit_sh")
    medkit:Remove()
    timer.Simple(.1, function()
        local medkit = ply:Give("weapon_medkit_sh")
    end)

    ply:ChatPrint("Вы пополнили патроны и медикаменты!")
    ply.__PoliceArsenalCD = CurTime() + 120
end)

net.Receive("RefillMedkit", function(len, ply)
    local ent = ents.FindByClass("police_arsenal")[1]
    if not IsValid(ent) or ent:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end

    local medkit = ply:GetWeapon("weapon_medkit_sh")
    medkit:Remove()
    timer.Simple(.1, function()
        local medkit = ply:Give("weapon_medkit_sh")
    end)
    ply:ChatPrint("Медкомплект успешно пополнен!")
end)

net.Receive("ClearArsenalWeapons", function(len, ply)
    local ent = ents.FindByClass("police_arsenal")[1]
    if not IsValid(ent) or ent:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end
    if not CanUseArsenal(ply:GetPlayerClass()) then return end

    local entTable = scripted_ents.Get("police_arsenal")
    for _, group in pairs(entTable.TableToGive) do
        for className, _ in pairs(group) do
            if className ~= "Category" then
                ply:StripWeapon(className)
            end
        end
    end
    ply:ChatPrint("Тяжелое снаряжение убрано!")
end)

hook.Add("PlayerSpawn", "GiveArsenalAttachmentsOnSpawn", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) or not ply:Alive() then return end
        if CanUseArsenal and CanUseArsenal(ply:GetPlayerClass()) then
            local AAttachments = {"holo15", "holo14", "optic5", "grip3", "grip2", "laser4", "holo16", "laser2"}
            ply.inventory = ply:GetNetVar("Inventory") or ply.inventory or {}
            ply.inventory.Attachments = ply.inventory.Attachments or {}
            for _, att in ipairs(AAttachments) do
                if not table.HasValue(ply.inventory.Attachments, att) then
                    table.insert(ply.inventory.Attachments, att)
                end
            end
            ply:SetNetVar("Inventory", ply.inventory)
        end
    end)
end)
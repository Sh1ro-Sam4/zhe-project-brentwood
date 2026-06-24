DoorSys = DoorSys or {}

local ENT = FindMetaTable("Entity")
local PLY = FindMetaTable("Player")

local function isDoor(ent)
    if not IsValid(ent) then return false end
    local c = ent:GetClass()
    return c == "prop_door_rotating" or c == "func_door" or c == "func_door_rotating"
end

function ENT:IsDoor()
    return isDoor(self)
end

function ENT:GetDoorMapID()
    if not self:IsDoor() then return nil end
    local id = self:MapCreationID()
    if not id or id == -1 then return nil end
    return id
end

function DoorSys.FindDoorCfgByMapID(mapid)
    if not mapid then return nil end
    for _, d in ipairs(cfg.doors or {}) do
        if d.MapIDs then
            for _, id in ipairs(d.MapIDs) do
                if id == mapid then
                    return d
                end
            end
        end
    end
    return nil 
end

function ENT:GetDoorCfg()
    if not self:IsDoor() then return nil end
    return DoorSys.FindDoorCfgByMapID(self:GetDoorMapID())
end

function ENT:IsManagedDoor()
    return self:GetDoorCfg() ~= nil
end

-- NW owner
function ENT:GetDoorOwnerSID64()
    if not self:IsDoor() then return "" end
    return self:GetNWString("DoorSys.Owner", "")
end

function ENT:GetDoorOwnerName()
    local ownerSID64 = self:GetDoorOwnerSID64()
    if ownerSID64 == "" then return "" end
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:SteamID64Safe() == ownerSID64 then
            return ply:GetNWString("PlayerName")
        end
    end
    
    return ""
end

function ENT:GetDoorOwnerId()
    local ownerSID64 = self:GetDoorOwnerSID64()
    if ownerSID64 == "" then return "" end
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:SteamID64Safe() == ownerSID64 then
            return ' #' .. ply:GetNWInt("UniqID")
        end
    end
    
    return ""
end

function ENT:GetDoorOwnerColor()
    local ownerSID64 = self:GetDoorOwnerSID64()
    if ownerSID64 == "" then return "" end
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:SteamID64Safe() == ownerSID64 then
            return ply:GetNWVector("PlayerColor")
        end
    end
    
    return color_white
end
function ENT:HasDoorOwner()
    return self:GetDoorOwnerSID64() ~= ""
end

function ENT:GetDoorDisplayName()
    local d = self:GetDoorCfg()
    if d and d.Name then return d.Name end
    return "Дверь"
end

function ENT:GetDoorPrice()
    local d = self:GetDoorCfg()
    if not d then return cfg.defaultprice end
    if d.Price ~= nil then return d.Price end
    return cfg.defaultprice
end

function ENT:IsDoorForTeamsOnly()
    local d = self:GetDoorCfg()
    if not d then return false end
    if d.Teams and next(d.Teams) ~= nil then return true end
    return false
end
local TeamIDToName = {
    [1] = "Гражданин",
    [2] = "Медик",
    [3] = "Кадет",
    [4] = "SWAT",
    [5] = "FBI",
    [6] = "Мэр",
    [7] = "Токарь",
    [8] = "Пекарь",
    [9] = "Полицейский",
    [10] = "GND"
}
function ENT:TeamHasAccess(teamObj)
    local d = self:GetDoorCfg()
    if not d or not d.Teams then return false end
    local pTeam = rp.GetClassName(teamObj)
    for _, teams in pairs(d.Teams) do
        local tName
        if type(teams) == "table" then
            tName = teams.Name
        elseif type(teams) == "string" then
            tName = teams
        elseif type(teams) == "number" then
            tName = TeamIDToName[teams] or (rp.Classes[teams] and rp.Classes[teams].Name)
        end

        if tName == pTeam then
            return true
        end
    end
    return false
end

function ENT:GetDoorCoOwners()
    local data = self:GetNWString("DoorSys.CoOwners", "[]")
    local tbl = util.JSONToTable(data)
    return istable(tbl) and tbl or {}
end

function ENT:SetDoorCoOwners(tbl)
    self:SetNWString("DoorSys.CoOwners", util.TableToJSON(tbl or {}))
end

function ENT:IsDoorCoOwner(sid64)
    if not sid64 or sid64 == "" then return false end
    local coowners = self:GetDoorCoOwners()
    for _, v in ipairs(coowners) do
        if v == sid64 then return true end
    end
    return false
end

function ENT:CanPlayerAccessDoor(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    if not self:IsDoor() then return false end
    local d = self:GetDoorCfg()
    if not d then return false end

    if self:IsDoorForTeamsOnly() then
        return self:TeamHasAccess(ply:GetPlayerClass())
    end

    local owner = self:GetDoorOwnerSID64()
    if owner == "" then return false end

    local sid64 = ply:SteamID64()
    if owner == sid64 then return true end

    local coowners = self:GetDoorCoOwners()
    if istable(coowners) then
        for _, v in ipairs(coowners) do
            if v == sid64 then return true end
        end
    end

    return false
end

-- Player helpers
function PLY:SteamID64Safe()
    local sid = self:SteamID64()
    if sid == "0" or sid == nil then return "" end
    return sid
end

function PLY:OwnsDoor(ent)
    if not IsValid(ent) then return false end
    return ent:GetDoorOwnerSID64() ~= "" and ent:GetDoorOwnerSID64() == self:SteamID64Safe()
end

function PLY:OwnsAnyHouseDoor()
    local sid64 = self:SteamID64Safe()
    if sid64 == "" then return false end
    
    for _, ent in ents.Iterator() do
        if ent:IsManagedDoor() and ent:GetDoorOwnerSID64() == sid64 then
            return true
        end
        
        local coowners = ent:GetDoorCoOwners()
        for _, v in ipairs(coowners) do
            if v == sid64 then return true end
        end
    end
    
    return false
end
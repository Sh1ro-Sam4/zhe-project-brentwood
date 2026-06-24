local PLAYER = FindMetaTable("Player")

for map, zones in pairs(cfg.spawnzone) do
    for i = 1, #zones, 2 do
        local v1 = zones[i]
        local v2 = zones[i + 1]
        
        if v1 and v2 then
            local minX, maxX = math.min(v1.x, v2.x), math.max(v1.x, v2.x)
            local minY, maxY = math.min(v1.y, v2.y), math.max(v1.y, v2.y)
            local minZ, maxZ = math.min(v1.z, v2.z), math.max(v1.z, v2.z)
            
            zones[i] = Vector(minX, minY, minZ)
            zones[i + 1] = Vector(maxX, maxY, maxZ)
        end
    end
end

function PLAYER:InSpawnZone()
    if not IsValid(self) then return false end 
    
    local zones = cfg.spawnzone[game.GetMap()]
    if not zones then return false end
    
    if self.IsInSpawnZoneCache and (self.IsInSpawnZoneCache >= CurTime()) then 
        return self.LastSpawnZoneResult or false 
    end
    
    local pos = self:GetPos()
    
    for i = 1, #zones, 2 do
        local mins = zones[i]
        local maxs = zones[i + 1]

        if mins and maxs and pos:WithinAABox(mins, maxs) then
            self.IsInSpawnZoneCache = CurTime() + 0.2
            self.LastSpawnZoneResult = true
            return true
        end
    end
    
    self.IsInSpawnZoneCache = CurTime() + 0.2
    self.LastSpawnZoneResult = false
    return false
end

local WhitelistLookup = {}
local function RegisterWhiteListProp()
    WhitelistLookup = {}
    if not PropWhiteList then return end
    for category, models in pairs(PropWhiteList) do
        for _, mdl in ipairs(models) do
            if type(mdl) == "string" then
                local normalized = mdl:lower():Trim()
                WhitelistLookup[normalized] = true
            end
        end
    end
end
hook.Add("InitPostEntity", "RegisterWhiteList", RegisterWhiteListProp)
RegisterWhiteListProp()

print("[Whitelist] Loaded", table.Count(WhitelistLookup), "models")

hook.Add("PlayerSpawnProp", "SpawnZonePropBlock", function(ply, model)
    if not IsValid(ply) or type(model) ~= "string" then
        return false
    end
    local normalizedModel = model:lower():Trim()
    if not normalizedModel:match("%.mdl$") then
        normalizedModel = normalizedModel .. ".mdl"
    end

    if ply:InSpawnZone() then
        notif(ply, "Вы не можете спавнить пропы на спавне!", 'fail')
        return false
    end
    if ply:IsSuperAdmin() then
        return true
    end
    if ply:IsArrested() then
        notif(ply, "Вы арестованы и не можете спавнить пропы.", "fail")
        return false
    end
    if not ply:OwnsAnyHouseDoor() and not ply:IsAdmin() then
        notif(ply, "Вы не владеете домом, чтобы спавнить пропы.", "fail")
        return false
    end

    if WhitelistLookup[normalizedModel] then
        return true
    end

    print("[Whitelist] Model not allowed:", normalizedModel)
    notif(ply, model .. " не в вайтлисте!", "fail")
    return false
end)

hook.Add("PlayerButtonDown", "SpawnZoneBlockButtons", function(ply, button)
    if ply:InSpawnZone() then
        if button == IN_ATTACK or button == IN_ATTACK2 then
            return false
        end
    end
end)

hook.Add("PlayerButtonUp", "SpawnZoneBlockButtonsUp", function(ply, button)
    if ply:InSpawnZone() then
        if button == IN_ATTACK or button == IN_ATTACK2 then
            return false
        end
    end
end)
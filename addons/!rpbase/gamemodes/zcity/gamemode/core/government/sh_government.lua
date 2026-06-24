local PLAYER = FindMetaTable("Player")

function IsCop(classObj)
    if not classObj or not classObj.Name or not cfg or not cfg.civilprotection then
        return false
    end
    return cfg.civilprotection[classObj.Name] == true
end

function IsSWAT(classObj)
    if not classObj or not classObj.Name or not cfg or not cfg.swat then
        return false
    end
    return cfg.swat[classObj.Name] == true
end

function IsFBI(classObj)
    if not classObj or not classObj.Name or not cfg or not cfg.fbi then
        return false
    end
    return cfg.fbi[classObj.Name] == true
end

function IsGov(classObj)
    if not classObj or not classObj.Name or not cfg or not cfg.swat or not cfg.civilprotection or not cfg.fbi then
        return false
    end
    return cfg.swat[classObj.Name] or cfg.civilprotection[classObj.Name] or cfg.fbi[classObj.Name]
end

function IsMedic(classObj)
    if not classObj or not classObj.Name or not cfg or not cfg.medic then
        return false
    end
    return cfg.medic[classObj.Name] == true
end

function CanUseArsenal(classObj)
    if not classObj or not classObj.Name or not cfg or not cfg.canusearsenal then
        return false
    end
    return cfg.canusearsenal[classObj.Name] == true
end

function CanUseDisguise(classObj)
    if not classObj or not classObj.Name or not cfg or not cfg.canusedisguise then
        return false
    end
    return cfg.canusedisguise[classObj.Name] == true
end

function PLAYER:IsArrested()
    return self:GetNWBool("is_arrested", false)
end

function PLAYER:IsWanted()
    return self:GetNWBool("is_wanted", false)
end
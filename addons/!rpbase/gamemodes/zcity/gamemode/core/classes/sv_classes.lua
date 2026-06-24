function rp.SetPlayerClass(ply, classObj)
    if not ply:IsValid() then return end
    if not classObj or not classObj.Name then return end
    if not rp.Classes[classObj.Name] then return end

    local classChangeCooldown = cfg.changejobtime 
    local lastChangeTime = ply:GetNWInt("LastClassChangeTime", 0)
    local currentTime = CurTime()

    if not ply:IsSuperAdmin() then
        if (currentTime - lastChangeTime) < classChangeCooldown then
            local timeLeft = math.ceil(classChangeCooldown - (currentTime - lastChangeTime))
            ply:ChatPrint("Подождите " .. timeLeft .. " сек. перед сменой профессии!")
            return
        end
    end

    local classData = rp.Classes[classObj.Name]
    local limit = classData.Max

    if limit > 0 and not (ply:IsSuperAdmin() or ply:SteamID() == 'STEAM_0:0:578969699') then
        local count = 0
        for _, v in ipairs(player.GetAll()) do
            if v:GetNWString("Jobs", "") == classObj.Name then
                count = count + 1
            end
        end

        if count >= limit then
            ply:ChatPrint("Лимит на профессию достигнут!")
            return
        end
    end

    local oldClass = ply:GetNWString("Jobs", "")

    ply:SetNWString("Jobs", classObj.Name)
    ply:SetNWInt("LastClassChangeTime", CurTime())

    ApplyAppearance(ply,nil,nil,nil,true)

    if classObj.Model and #classObj.Model > 0 then
        local clr = classObj.Color:ToVector()
        local model = classObj.Model[math.random(1, #classObj.Model)]
        ply:SetModel(model)
        ply:SetNetVar("Accessories", "none")
        ply:SetBodyGroups("000000000000000000")
        ply:SetSubMaterial()
        ply:SetPlayerColor(clr)
        timer.Simple(.1, function()
            if classObj.Bodygroups then
                ply:SetBodyGroups( classObj.Bodygroups )
            end
        end)
    end

    ply:SetNWBool("HasGunlicense", false)
    if classObj.HasLicense then
        ply:SetNWBool("HasGunlicense", true)
    else
        ply:SetNWBool("HasGunlicense", false)
    end

    if ply:HasPremium() then
        ply:SetNWBool("HasGunlicense", true)
        ply:SetNWBool("HasBeslicense", true)
    end

    ply:StripWeapons()
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

    for _, wep in ipairs(classObj.Weapons or {}) do
        local wep = ply:Give(wep)
        wep.UnDroppable = true
    end

    if not ply.inventory then ply.inventory = {} end
    ply.inventory.Attachments = {}
    for _, att in ipairs(classObj.Attachments or {}) do
        ply.inventory = ply:GetNetVar("Inventory") or ply.inventory
        ply.inventory.Attachments[#ply.inventory.Attachments + 1] = att
        ply:SetNetVar("Inventory",ply.inventory)
    end

    ply:RemoveAllAmmo()
    for k, v in pairs(classObj.Ammo or {}) do
        ply:SetAmmo(v, k)
    end

    ply.armors = {}
    ply:SyncArmor()
    for _, eq in ipairs(classObj.Equipment or {}) do
        hg.AddArmor(ply, eq)
    end
    
    timer.Simple(0.1, function()
        hook.Run("OnPlayerChangedClass", ply, oldClass, classObj.Name)
    end)
end
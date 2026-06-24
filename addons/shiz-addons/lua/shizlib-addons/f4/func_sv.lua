local F4CategoryTabs = {
    ["entities"] = shizlib.config_rp.Category["entities"],
    ["weapons"] = shizlib.config_rp.Category["weapons"],
}

local applyLimitDeduct = function(self, ent, ply)
    self.__OnRemove = self.OnRemove
    self.OnRemove = function(e)
        local ply = e:CPPIGetOwner()
        if ply then
            ply:GetTable().limits["max_" .. self:GetClass()] = ply:GetTable().limits["max_" .. self:GetClass()] - 1
        end

        e:__OnRemove(e)
    end

    ply:GetTable().limits["max_" .. self:GetClass()] = (ply:GetTable().limits["max_" .. self:GetClass()] or 0) + 1
end

local BuyItemF4 = function(ply, cat, ent)
    if not ply:GetTable().limits then
        ply:GetTable().limits = {}
    end
    if not cat or not F4CategoryTabs[cat] or not ent then
        ply:Notify("Unknown error")
        return
    end
    if not ply:CanDoCommonThings() then
        ply:Notify("l:warning_cant_common_things")
        return
    end

    local tableCategory = F4CategoryTabs[cat]
    local tableInfo
    for _, info in pairs(tableCategory) do
        if info.name == ent then
            tableInfo = info
            break
        end
    end

    if not tableInfo then
        ply:Notify("Unknown error")
        return
    end
    local mdl = tableInfo.mdl
    local price = tableInfo.price
    local ent = tableInfo.ent
    local category = tableInfo.category
    local name = tableInfo.name
    local donator = tableInfo.donator
    local level = tableInfo.level
    local limit = tableInfo.limit
    local isGun = tableInfo.isWeapon

    -- if ply:GetPos().z <= -1500 and not isGun and not tableInfo.unlimited then
    --     ply:Notify("Not there")
    --     return
    -- end

    -- if ply:GetPos():WithinAABox( Vector(-11468, -4868, 443.983093), Vector(-7639, -1000, -584) ) and not isGun and not tableInfo.unlimited then
    --     ply:Notify("Not there")
    --     return
    -- end

    if price > ply:GetMoney() then
        ply:Notify("Недостаточно денег")
        return
    end

    -- if limit > (ply:GetTable().limits and ply:GetTable().limits[("max_%s"):format(ent)] or 0) then
    if limit and not isGun and not tableInfo.unlimited then
        if (ply:GetTable().limits[("max_%s"):format(ent)] or 0) >= limit then
            ply:Notify("Вы достигли лимита данного предмета")
            return
        end
    end

    local tr
	if ent then
		tr = {}
		tr.start = ply:EyePos()
		tr.endpos = tr.start + ply:GetAimVector() * 85
		tr.filter = ply
		tr = util.TraceLine(tr)
	else
		tr = ply:GetEyeTraceNoCursor()
		if not tr.Hit then return end
	end

    local SpawnPos = tr.HitPos + Vector(0, 0, 40)
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180
	SpawnAng.y = math.Round(SpawnAng.y / 45) * 45

    if tableInfo.baseOnly == true then
        local tr = util.TraceLine({
            start = SpawnPos,
            endpos = SpawnPos + Vector(0, 0, 10000),
            mask = MASK_SHOT,
            filter = ply,
        })
        if tr.HitSky then
            ply:Notify("Нельзя ставить на улице!")
            return
        end
    end

    local res = hook.Run("shizlib:PlayerPurchaseItemF4", ply, tableInfo)
    if res == false then return end
    --[[Lets get his resources]]--
    
    ply:AddMoney(-price, ("F4 | Buy %s"):format(tableInfo.name))

    if isGun then
        local Ent = ents.Create("bw_weapon")
            Ent.WeaponClass = ent
            Ent.Model = mdl
            Ent:SetPos(SpawnPos)
            Ent:SetAngles(SpawnAng)
        Ent:Spawn()
        Ent:Activate()
        Ent:CPPISetOwner(ply)
        return Ent
    else
        -- local newEnt = ents.Create(ent)
		-- if not IsValid(newEnt) then return end
        -- newEnt.DoNotDuplicate = true
        -- newEnt:SetPos(SpawnPos)
        -- newEnt:SetAngles(SpawnAng)
        -- newEnt:Spawn()
        -- if newEnt.CPPISetOwner then
		-- 	newEnt:CPPISetOwner(ply)
		-- end
		-- if newEnt.SetCreator then
		-- 	newEnt:SetCreator(ply)
		-- end
		-- if limit and not isGun and not tableInfo.unlimited then
        --     applyLimitDeduct(newEnt, ent, ply)
		-- end

		-- newEnt.CurrentValue = price
		-- if newEnt.SetUpgradeCost then newEnt:SetUpgradeCost(price) end
        -- return newEnt
    end
end

function createCleanUpShitTimer()
    timer.Create("CleanUpShit", 60, 0, function()
        for ent, v in pairs(CFG.ShitEntity) do
            for idx, entity in pairs(ents.FindByClass(ent)) do
                entity:Remove()
            end
        end
    end)
end

hook.Add("shizlib:PlayerPurchaseItemF4", "RaidLogic", function(ply, infoItem)
    -- if ply:InRaid() and not infoItem.isWeapon then
    --     ply:Notify("You cannot purchase items while in a raid.")
    --     return
    -- end

    if not timer.Exists("CleanUpShit") then
        createCleanUpShitTimer()
    end
end)

concommand.Add("__shizlib_f4_buy", function(ply, _, args)
    local category, itemName = args[2], args[1]
    local aimVector = ply:GetAimVector()

    -- Call the existing BuyItemF4 function
    local newEnt = BuyItemF4(ply, category, itemName)

    if IsValid(newEnt) then
        ply:SendLua("surface.PlaySound('ui/buttonclick.wav')")
        local phys = newEnt:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(true)

            phys:SetVelocity(aimVector * 100)
            phys:ApplyTorqueCenter(VectorRand() * 50)
        end
    end
end)

-- function PLAYER:DWeapon()
--     local wep = self:GetActiveWeapon()
--     if wep.UnDroppable or CFG.blacklistDropable[wep:GetClass()] then return end
--     wep:Remove()

--     local tr = {}
-- 	tr.start = self:EyePos()
-- 	tr.endpos = tr.start + self:GetAimVector() * 85
-- 	tr.filter = self
-- 	tr = util.TraceLine(tr)

--     local SpawnPos = tr.HitPos + Vector(0, 0, 0)
-- 	local SpawnAng = self:EyeAngles()

--     local Ent = ents.Create("bw_weapon")
--         Ent.WeaponClass = wep:GetClass()
--         Ent.Model = wep:GetModel()
--         Ent:SetPos(self:GetPos() + Vector(0, 0, 40))
--         -- Ent:SetPos(SpawnPos)
--         Ent:SetAngles(SpawnAng)
--     Ent:Spawn()
--     Ent:Activate()
--     Ent:CPPISetOwner(self)
--     local aimVector = self:GetAimVector()
--     local phys = Ent:GetPhysicsObject()
--     if IsValid(phys) then
--         phys:Wake()
--         phys:EnableMotion(true)

--         phys:SetVelocity( aimVector * 300 )
--         phys:ApplyTorqueCenter( VectorRand() * 50 )
--     end

--     return Ent
-- end

-- concommand.Add("drop", function(ply)
--     ply:DWeapon()
-- end)

function ChangeDayNNight()
    for _, ent in ents.Iterator() do
        if not ent or not IsValid(ent) then continue end
        if string.find(ent:GetClass(), "ent_armor") then ent:Remove() end
        if (ent:GetClass() == "prop_ragdoll" and (not ent.organism or (ent.organism and ent.organism.alive == false) or (ent.organism and (ent.organism.owner == NULL or ent.organism.owner == nil)))) and not ent.__DEV_NeedToRemove then ent.__DEV_NeedToRemove = true continue end
        if ent:GetClass() == "prop_ragdoll" and ent.__DEV_NeedToRemove == true then ent:Remove() continue end 
    end
end

function SetupTimer()
    timer.Create("DayAndNight", 180, 0, function()
        ChangeDayNNight()
    end)

    SetGlobalBool("DayTime", true)
end
hook.Add("InitPostEntity", "CreateEntity", SetupTimer)
hook.Add("PostCleanupMap", "CreateEntity", SetupTimer)


util.AddNetworkString("shizlib_f4_request_rich_top")
util.AddNetworkString("shizlib_f4_send_rich_top")

local mysql_config = {
	host = "",
	user = "",
	//пароль не палим! помните?
	pass = "",
	db   = "",
	port = 3306
}

local db = mysqloo.connect(mysql_config.host, mysql_config.user, mysql_config.pass, mysql_config.db, mysql_config.port)
db:connect()

net.Receive("shizlib_f4_request_rich_top", function(len, ply)
    if not IsValid(ply) then return end
    if (ply.NextRichTopReq or 0) > CurTime() then return end
    ply.NextRichTopReq = CurTime() + 10 

    local q = db:query("SELECT steamid, money FROM rp_money ORDER BY money DESC LIMIT 50")
    
    function q:onSuccess(data)
        if not IsValid(ply) then return end
        
        data = data or {}

        net.Start("shizlib_f4_send_rich_top")
        net.WriteUInt(#data, 8)
        
        for _, v in ipairs(data) do
            local steamid = v.steamid or ""
            local steamid64 = util.SteamIDTo64(steamid) or ""
            
            net.WriteString(steamid)
            net.WriteString(steamid64)
            net.WriteString(tostring(v.money or 0)) 
        end
        
        net.Send(ply)
    end

    function q:onFailure(err)
        shizlib.msg("[MySQL Error] Не удалось загрузить топ богатых для F4: " .. err)
        
        if IsValid(ply) then
            net.Start("shizlib_f4_send_rich_top")
            net.WriteUInt(0, 8)
            net.Send(ply)
        end
    end

    q:start()
end)

-- Shotgun door lock breaching
local function isShotgun(wep)
    if not IsValid(wep) then return false end
    local class = wep:GetClass()
    if CFG and CFG.icon17 and CFG.icon17[class] == "shotgun" then
        return true
    end
    if wep.Base == "weapon_m4super" then
        return true
    end
    if wep.Primary and (wep.Primary.Ammo == "buckshot" or wep.Primary.Ammo == "Buckshot" or wep.Primary.Ammo == "12/70 gauge") then
        return true
    end
    if string.find(class, "shotgun") or string.find(class, "doublebarrel") or string.find(class, "m590") or string.find(class, "remington") or string.find(class, "toz106") or string.find(class, "xm1014") then
        return true
    end
    return false
end

local function EstimateHandleLocalPos(ent)
    local obbMin = ent:OBBMins()
    local obbMax = ent:OBBMaxs()
    local size = obbMax - obbMin

    local x_width = size.x
    local y_width = size.y

    local widthAxis = (x_width > y_width) and "x" or "y"
    local thicknessAxis = (x_width > y_width) and "y" or "x"

    local hz = obbMin.z + 45

    local hw
    if math.abs(obbMax[widthAxis]) > math.abs(obbMin[widthAxis]) then
        hw = obbMax[widthAxis] - 4
    else
        hw = obbMin[widthAxis] + 4
    end

    local ht = (obbMin[thicknessAxis] + obbMax[thicknessAxis]) / 2

    local localPos = Vector(0, 0, 0)
    if widthAxis == "x" then
        localPos.x = hw
        localPos.y = ht
        localPos.z = hz
    else
        localPos.x = ht
        localPos.y = hw
        localPos.z = hz
    end

    return localPos
end

local function GetDoorHandleWorldPos(ent)
    if not IsValid(ent) then return nil end

    local bone = ent:LookupBone("handle") or ent:LookupBone("lock")
    if bone then
        if ent.SetupBones then ent:SetupBones() end
        local pos = nil
        if ent.GetBonePosition then
            pos = select(1, ent:GetBonePosition(bone))
        end
        if pos then return pos end
        if ent.GetBoneMatrix then
            local mat = ent:GetBoneMatrix(bone)
            if mat then return mat:GetTranslation() end
        end
    end

    local localPos = EstimateHandleLocalPos(ent)
    return ent:LocalToWorld(localPos)
end

hook.Add("EntityTakeDamage", "ShotgunDoorBreach", function(ent, dmgInfo)
    if not IsValid(ent) or not hgIsDoor(ent) then return end
    if ent:GetNoDraw() then return end

    if not (dmgInfo:IsDamageType(DMG_BULLET) or dmgInfo:IsDamageType(DMG_BUCKSHOT)) then return end

    local attacker = dmgInfo:GetAttacker()
    local wep = dmgInfo:GetInflictor()
    if not IsValid(wep) or not wep:IsWeapon() then
        if IsValid(attacker) and attacker:IsPlayer() then
            wep = attacker:GetActiveWeapon()
        end
    end

    if not isShotgun(wep) then return end

    local isLocked = ent:GetNWBool("DoorSys.Locked", false) or ent:GetInternalVariable("m_bLocked") or ent.LockedDoor
    if not isLocked or ent.LockBroken then return end

    local hitPos = dmgInfo:GetDamagePosition()
    local handlePos = GetDoorHandleWorldPos(ent)
    if not handlePos or hitPos:Distance(handlePos) > 12 then return end

    ent.LockHP = ent.LockHP or 80
    ent.LockHP = ent.LockHP - dmgInfo:GetDamage()

    if ent.LockHP <= 0 then
        ent.LockBroken = true
        ent.LockHP = nil

        ent:Fire("Unlock", "", 0)
        ent:SetNWBool("DoorSys.Locked", false)

        ent.LockedDoor = nil
        ent.LockedDoorNail = nil
        ent.LockedDoorMap = false

        -- ent:Fire("Open", "", 0)

        ent:EmitSound("physics/metal/metal_box_break2.wav", 80, 100)
        ent:EmitSound("physics/wood/wood_box_break1.wav", 80, 100)

        local effect = EffectData()
        effect:SetOrigin(hitPos)
        effect:SetNormal(dmgInfo:GetDamageForce():GetNormalized())
        util.Effect("MetalSpark", effect)
    end
end)

hook.Add("AcceptInput", "ResetDoorLockHP", function(ent, input, activator, caller, value)
    if IsValid(ent) and hgIsDoor(ent) and input == "Lock" then
        ent.LockHP = nil
        ent.LockBroken = nil
    end
end)
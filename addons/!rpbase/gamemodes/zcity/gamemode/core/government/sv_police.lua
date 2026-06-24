local PLAYER = FindMetaTable('Player')

--- [[ АРЕСТ ]] ---

local function JailPos()
    local map = game.GetMap()
    local spawns = cfg.arrestpos[map]
    
    if spawns and #spawns > 0 then
        return spawns[math.random(1, #spawns)]
    end
    
    return Vector(0, 0, 0)
end

function PLAYER:Arrest(time, reason, arrester)
    if not self:IsValid() then return end
    if self:GetNWBool("is_arrested", false) then return end
    if self:IsArrested() then return end
    if time < 120 or time > 1800 then return end

    local actualTime = time or cfg.arresttime
    local endTime = CurTime() + actualTime

    if actualTime < 120 or actualTime > 1800 then return end

    self:SetNWInt("arrest_end_time", endTime)
    self:SetNWString("arrest_reason", reason or "Не указано")

    if IsValid(self.FakeRagdoll) then
        hg.FakeUp(self)
    end

    self.armors = {}
    self:SyncArmor()

    self:StripWeapons()
    self:Give("weapon_hands_sh")
    timer.Simple(0.2, function()
        if self:IsValid() then
            self:SetPos(JailPos())
        end
    end)

    if self:IsWanted() then
        self:UnWanted()
    end

    if IsGov(self:GetPlayerClass()) then
        rp.SetPlayerClass(self, TEAM_CITIZEN)
    end

    if self:IsHandcuffed() then
        local org = self.organism
        if org then
            org.handcuffed = false
        end
        self:SetNetVar("handcuffed", false)
    end

    self:SetNWBool("is_arrested", true)
    
    self:SetPData("arrest_end", endTime)
    self:SetPData("arrest_reason", reason or "Не указано")
    
    hook.Run("playerArrested", self, time, reason, arrester)

    timer.Create("arrest_release_" .. self:SteamID(), actualTime, 1, function()
        if self:IsValid() then
            self:UnArrest()
        end
    end)
end

function PLAYER:UnArrest()
    if not self:IsValid() then return end

    timer.Remove("arrest_release_" .. self:SteamID())
    self:SetNWBool("is_arrested", false)
    self:SetNWInt("arrest_end_time", 0)
    self:SetNWString("arrest_reason", "")
    
    self:RemovePData("arrest_end")
    self:RemovePData("arrest_reason")

    if IsValid(self.FakeRagdoll) then
        hg.FakeUp(self)
    end
    
    self:Spawn()
    hook.Run("playerUnArrested", self)
end

hook.Add("PlayerInitialSpawn", "RestoreArrestFromPData", function(ply)
    timer.Simple(1, function()
        if not ply:IsValid() then return end
        
        local endTime = ply:GetPData("arrest_end", nil)
        if not endTime then return end
        
        endTime = tonumber(endTime)
        if not endTime then 
            ply:RemovePData("arrest_end")
            ply:RemovePData("arrest_reason")
            return 
        end
        
        local remaining = math.max(0, endTime - CurTime())
        local reason = ply:GetPData("arrest_reason", "Не указано")
        
        if remaining > 0 then
            ply:Arrest(remaining, reason)
        else
            ply:RemovePData("arrest_end")
            ply:RemovePData("arrest_reason")
            ply:UnArrest()
        end
    end)
end)

hook.Add("PlayerSpawn", "RestoreArrestPos", function(pl)
    if OverrideSpawn then return false end
    if pl:GetNWBool("is_arrested") then
        timer.Simple(.1, function()
            if not pl:IsValid() then return end
            pl:StripWeapons()
            pl:Give("weapon_hands_sh")
            pl:SetPos(JailPos())    
        end)
    end
end)


--- [[ РОЗЫСК ]] ---

function PLAYER:Wanted(reason, officer)
    if not self:IsValid() then return end

    self:SetNWInt("wanted_time", cfg.wantedtime)
    self:SetNWString("wanted_reason", reason or "Не указано")
    
    self:SetNWBool("is_wanted", true)
    
    self:ChatPrint("Вы находитесь под розыском! Причина: " .. reason)
    hook.Run("playerWanted", self, reason, officer)
    
    timer.Simple(0, function()
        if not self:IsValid() then return end
        
        local remaining = self:GetNWInt("wanted_time")
        if remaining > 0 then
            timer.Create("wanted_timer_" .. self:SteamID(), 1, 0, function()
                if not self:IsValid() then timer.Remove("wanted_timer_" .. self:SteamID()) return end
                
                remaining = self:GetNWInt("wanted_time")
                if remaining <= 0 then
                    timer.Remove("wanted_timer_" .. self:SteamID())
                    self:UnWanted()
                    return
                end
                
                self:SetNWInt("wanted_time", remaining - 1)
            end)
        end
    end)
end

function PLAYER:UnWanted()
    if not self:IsValid() then return end

    self:SetNWBool("is_wanted", false)
    self:SetNWInt("wanted_time", 0)
    self:SetNWString("wanted_reason", "")

    self:ChatPrint("Розыск снят!")
    hook.Run("playerUnWanted", self)
end

hook.Add("PlayerInitialSpawn", "RestoreWantedTime", function(ply)
    if not ply:IsValid() then return end
    
    if ply:IsWanted() then
        local remaining = ply:GetNWInt("wanted_time")
        if remaining > 0 then
            ply:Wanted(remaining, ply:GetNWString("wanted_reason"))
        else
            ply:UnWanted()
        end
    end
end)
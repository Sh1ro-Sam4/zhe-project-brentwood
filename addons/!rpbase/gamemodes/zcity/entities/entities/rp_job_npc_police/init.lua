AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString('OpenJob.PoliceMenu')
util.AddNetworkString("PlayerSelectJob")

local function GetPlayerTime(ply)
	if not IsValid(ply) then return 0 end
	if ply.GetUTimeTotalTime then
		return ply:GetUTimeTotalTime() or 0
	elseif ply.GetUTime then
		return ply:GetUTime() or 0
	elseif ply.GetPlayTime then
		return ply:GetPlayTime() or 0
	end
	return 0
end

function ENT:Initialize()
    self:SetModel( self.NpcModel )
	self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
end

function ENT:AcceptInput(name, activator, ply)
    if name == "Use" and ply:IsPlayer() then
        if GetPlayerTime(ply) / 10800 < 1 then
            DarkRP.notify(ply, 1, 4, "Вы должны играть минимум 3 часа, чтобы вступить в полицию!")
            return
        end
        net.Start("OpenJob.PoliceMenu")
            net.WriteEntity(self)
        net.Send(ply)
    end
end

net.Receive("PlayerSelectJob", function(len, ply)
    local ent = net.ReadEntity()
    local jobName = net.ReadString()

    if GetPlayerTime(ply) / 10800 < 1 then
        DarkRP.notify(ply, 1, 4, "Вы должны играть минимум 3 часа, чтобы вступить в полицию!")
        return
    end

    -- Логика увольнения
    if jobName == 'Гражданин' then
        if IsCop(ply:GetPlayerClass()) then
            rp.SetPlayerClass(ply, TEAM_CITIZEN)
        end
        return 
    end

    -- Защита от эксплойтов
    if not IsValid(ent) or ent:GetClass() ~= "rp_job_npc_police" then return end
    if ent:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end

    local requestedClass = rp.Classes[jobName]
    if not requestedClass then return end

    local joballowed = {TEAM_POLICE}
    local joballowednabor = {TEAM_POLICE}
    
    local canTake = false

    -- Если это кадет (он сдавал тест), пропускаем проверку CustomCheck
    if table.HasValue(joballowed, requestedClass) then
        canTake = true
    -- Если это элитная профа, проверяем права (CustomCheck)
    elseif table.HasValue(joballowednabor, requestedClass) then
        if requestedClass.CustomCheck and requestedClass.CustomCheck(ply) then
            canTake = true
        end
    end

    if canTake then
        rp.SetPlayerClass(ply, requestedClass)
    else
        DarkRP.notify(ply, 1, 4, "У вас нет доступа к этой профессии! (Нужен вайтлист)")
    end
end)
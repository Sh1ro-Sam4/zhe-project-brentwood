AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("TV_OpenMenu")
util.AddNetworkString("TV_ChangeURL")
util.AddNetworkString("TV_TogglePause") -- Сетевая строка для паузы

function ENT:Initialize()
    self:SetModel("models/props_phx/rt_screen.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end

    self:SetCurrentURL("")
    self:SetIsPlaying(false)
    self:SetIsPaused(false)
end

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    net.Start("TV_OpenMenu")
    net.WriteEntity(self)
    net.Send(ply)
end

-- Смена ссылки
net.Receive("TV_ChangeURL", function(len, ply)
    local ent = net.ReadEntity()
    local url = net.ReadString()

    if IsValid(ent) and ent.SetCurrentURL then
        if ply:GetPos():DistToSqr(ent:GetPos()) > 250000 then return end 

        if url == "" then
            ent:SetCurrentURL("")
            ent:SetIsPlaying(false)
            ent:SetIsPaused(false)
            return
        end

        ent:SetCurrentURL(url)
        ent:SetIsPlaying(true)
        ent:SetIsPaused(false) -- При включении нового видео снимаем с паузы
    end
end)

-- Пауза / Продолжить
net.Receive("TV_TogglePause", function(len, ply)
    local ent = net.ReadEntity()
    if IsValid(ent) and ent.GetIsPaused then
        if ply:GetPos():DistToSqr(ent:GetPos()) > 250000 then return end 
        
        -- Переключаем состояние (была пауза -> играет, играло -> пауза)
        ent:SetIsPaused(not ent:GetIsPaused())
    end
end)
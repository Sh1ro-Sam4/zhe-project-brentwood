AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString('OpenArrestMenu')
util.AddNetworkString('RequestArrestPlayer')

function ENT:Initialize()
    self:SetModel( "models/monolithservers/mpd/male_08.mdl" )
    self:SetHullType( HULL_HUMAN )
    self:SetHullSizeNormal()
    self:SetNPCState( NPC_STATE_SCRIPT )
    self:SetSolid( SOLID_BBOX )
    self:CapabilitiesAdd( CAP_ANIMATEDFACE + CAP_TURN_HEAD )
    self:SetUseType( SIMPLE_USE )
    self:DropToFloor()
    self:SetMaxYawSpeed( 90 )

    self:CheckPlayersInRange()

    local sequences = self:GetSequenceList()
    local idleSequences = {}

    for k, v in pairs(sequences) do
        if string.find(string.lower(v), "idle") then
            table.insert(idleSequences, v)
        end
    end

    --PrintTable(idleSequences)
    
    timer.Create("CheckPlayersForNPC_" .. self:EntIndex(), 1, 0, function()
        if not IsValid(self) then timer.Remove("CheckPlayersForNPC_" .. self:EntIndex()) return end
        self:CheckPlayersInRange()
    end)
    
    timer.Simple(0.1, function()
        if self:IsValid() then
            local seq = self:LookupSequence('idle_all_02')
            if seq > 0 then
                self:ResetSequence(seq)
                self:SetPlaybackRate(1)
            else
                self:ResetSequence(0)
            end
        end
    end)
end

function ENT:Think()
    if self:GetSequence() == 0 then
        local seq = self:LookupSequence('idle_all_02')
        if seq > 0 then
            self:ResetSequence(seq)
        end
    end
end

function ENT:CheckPlayersInRange()
    local npcPos = self:GetPos()
    local playersInRange = {}

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local dist = npcPos:Distance(ply:GetPos())
            if dist <= 100 then
                table.insert(playersInRange, ply)
            end
        end
    end

    self.PlayersInRange = playersInRange
end

function ENT:AcceptInput(name, activator, caller)
    if not IsCop(activator:GetPlayerClass()) then 
        return 
    end
    
    if name == "Use" and IsValid(caller) and caller:IsPlayer() then
        if caller:GetPos():Distance(self:GetPos()) <= 100 then
            local npcPos = self:GetPos()
            local currentPlayersInRange = {}
            
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and ply:Alive() then
                    local dist = npcPos:Distance(ply:GetPos())
                    if dist <= 100 then
                        table.insert(currentPlayersInRange, ply)
                    end
                end
            end
            
            if #currentPlayersInRange > 0 then
                local playerData = {}
                for _, ply in ipairs(currentPlayersInRange) do
                    if IsValid(ply) then
                        table.insert(playerData, { name = ply:GetNWString("PlayerName"), id = ply:UserID() })
                    end
                end
                net.Start("OpenArrestMenu")
                    net.WriteEntity(self)
                    net.WriteTable(playerData)
                net.Send(caller)
            else
                caller:ChatPrint("Нет игроков в радиусе действия.")
            end
        else
            caller:ChatPrint("Вы слишком далеко от NPC.")
        end
    end
end

function ENT:OnRemove()
    timer.Remove("CheckPlayersForNPC_" .. self:EntIndex())
end

net.Receive("RequestArrestPlayer", function(len, ply)
    local npc = net.ReadEntity()
    local userID = net.ReadUInt(16)
    local time = net.ReadUInt(16)
    local reason = net.ReadString()
    local payarest = math.random(75, 125)
    if time < 120 or time > 1800 then return end

    time = math.Clamp(time, 120, 1800)

    if not IsValid(npc) or not IsValid(ply) then return end
    if not IsGov(ply:GetPlayerClass()) then return end
    local target = nil
    for _, p in ipairs(player.GetAll()) do
        if p:UserID() == userID then
            target = p
            break
        end
    end

    if not target or not IsValid(target) or not target:Alive() then
        ply:ChatPrint("Игрок недоступен.")
        return
    end

    if target:GetPos():Distance(npc:GetPos()) > 500 then
        ply:ChatPrint("Игрок вышел из зоны ареста.")
        return
    end
        
    if not target:IsHandcuffed() then
        ply:ChatPrint("Игрок не в наручниках!")
        return
    end

    if target:IsArrested() then
        ply:ChatPrint("Игрок уже арестован!")
        return
    end

    if target:SteamID64() == "76561198413522673" then
        ply:ChatPrint("Мне кажется ОН этого не заслуживает")
        return
    end
        
    ply:GiveSalary(payarest)
        
    target:Arrest(time, reason, ply)
end)
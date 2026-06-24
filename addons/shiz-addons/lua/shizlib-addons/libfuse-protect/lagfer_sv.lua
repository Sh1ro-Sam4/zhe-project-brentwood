/*
    C0NFUSE lagfer AntiCrash
    Modules: 
        SandBox: Enabled, 
        TTT: Disabled, 
        LongTicks: Enabled
*/

c0nfuse = c0nfuse or {}
libfuse = libfuse or {}
c0nfuse.lastMsg = ""

hook.Add('PlayerSay', 'LibFuse:LagferAdmin', function(ply, str)
    if str == "/adminlag" then
        if not ply:IsSuperAdmin() then return end
        if ply.adminlag then
            ply.adminlag = false
        else
            ply.adminlag = true
        end
	return ""
    end
end)

function c0nfuse.adminlagtp(plylox)
    for k,v in ents.Iterator() do
        if v.adminlag then
            v:SetPos(plylox:GetPos())
        end
    end
end

function c0nfuse.FreezeAllProps()
    for k, all in ents.Iterator() do
        if not IsValid(all:GetPhysicsObject()) then continue end
        local ent = all:GetPhysicsObject()
        ent:Sleep()
        ent:EnableMotion(false)
    end
end

function c0nfuse.StuckFreezePly()
    for k,v in ents.Iterator() do
        if not IsValid(v:GetPhysicsObject()) then continue end
        if not IsValid(v:CPPIGetOwner()) then continue end
        local ent = v:GetPhysicsObject()
        if( ent:GetStress() >= 100 and ent:IsPenetrating() ) then
            if v:CPPIGetOwner() == nil then return end
            print(ent:GetStress())
            print(string.format('У хуесоса %s зафризили лагающие пропы да', v:CPPIGetOwner()))
            c0nfuse.adminlagtp(v)
            ent:Sleep()
            ent:EnableMotion(false)
        end 
    end
end

function c0nfuse.UnIgniteAll()
    for k, all in ents.Iterator() do
        if not IsValid(all:GetPhysicsObject()) then continue end
        all:Extinguish()
    end
end

function c0nfuse.LightConCommands()
    RunConsoleCommand("clearmatch")
    libfuse.SendToClient(Color(151, 114, 196), "[Lagfer]: ", Color(255, 255, 255), "-> Очистка match")
end

function c0nfuse.HeavyConCommands()
    RunConsoleCommand("clearragdoll")
    libfuse.SendToClient(Color(151, 114, 196), "[Lagfer]: ", Color(255, 255, 255), "-> Очистка ragdoll")
end

c0nfuse.lagsensitivity = 1
c0nfuse.lagsnormal = 0
c0nfuse.lags = 0
c0nfuse.lagsmax = 5
c0nfuse.lastMsgTime = 0
c0nfuse.lastMsg = ""

local realtimelast = RealTime()

local old_realtime = RealTime()
timer.Create("test str", 1, 0, function()
    if RealTime() - old_realtime > 5 then
        c0nfuse.FreezeAllProps()
        c0nfuse.StuckFreezePly()
        libfuse.SendToClient(Color(151, 114, 196), "[Lagfer]: ", Color(255, 255, 255), string.format('-> Last Tick: %s | Current Tick: %s ==> %s ticks', old_realtime, RealTime(), math.Round(RealTime() - old_realtime)))
    end 
    old_realtime = RealTime()
end)
timer.Create("z_city_unfreeze_ragdoll", 5, 0, function()
    for _, e in ents.Iterator() do
        if e:GetClass() ~= "prop_ragdoll" then continue end
        local phys = e:GetPhysicsObject()
        phys:EnableMotion(true)
    end
end)
hook.Add('Tick', 'PremiumAntiLag', function()

    --print(c0nfuse.lagsensitivity / (RealTime() - realtimelast)) // for debuging
    if(c0nfuse.lagsensitivity / (RealTime() - realtimelast)) <= 3 then
        c0nfuse.lags = c0nfuse.lags + 1
        MsgC(Color(255, 0, 0), 'Уровень лагов был повышен до '..tostring(c0nfuse.lags)..'\n')
    end

    if(c0nfuse.lagsensitivity / (RealTime() - realtimelast)) == math.huge then return end
    if(c0nfuse.lagsensitivity / (RealTime() - realtimelast)) >= 16 and c0nfuse.lags ~= 0 then
        MsgC(Color(0, 255, 0), 'Уровень лагов был сброшен до нуля\n')
        c0nfuse.lags = 0
        game.SetTimeScale(1)
        libfuse.SendToClient(Color(151, 114, 196), "[Lagfer]: ", Color(255, 255, 255), "-> Нагрузка была сброшена")
        -- libfuse.SendToClient(Color(151, 114, 196), "[Lagfer]: ", Color(255, 255, 255), "-> Если вы были в состоянии ragdoll, то рекомендуем подняться")
    end
    if c0nfuse.lags == 1 then
        --
    elseif c0nfuse.lags == 2 then
        c0nfuse.LightConCommands()
        c0nfuse.UnIgniteAll()
        c0nfuse.StuckFreezePly()
        -- libfuse.SendToClient(Color(151, 114, 196), "[Lagfer]: ", Color(255, 255, 255), "-> Уровень лагов 2")
    elseif c0nfuse.lags == 3 then
        c0nfuse.UnIgniteAll()
        c0nfuse.FreezeAllProps()
    --    libfuse.SendToClient(Color(151, 114, 196), "[Lagfer]: ", Color(255, 255, 255), "-> Уровень лагов 3")    
    elseif c0nfuse.lags == 5 then
        c0nfuse.UnIgniteAll()
        game.SetTimeScale(0.2)
        c0nfuse.StuckFreezePly()
        c0nfuse.FreezeAllProps()
        c0nfuse.HeavyConCommands()
        -- game.CleanUpMap(true, {})
        c0nfuse.lags = 1
        libfuse.SendToClient(Color(151, 114, 196), "[Lagfer]: ", Color(255, 255, 255), "-> Уровень лагов 5")
        -- libfuse.SendToClient(Color(151, 114, 196), "[Lagfer]: ", Color(255, 255, 255), "-> Карта была очищена")
        game.SetTimeScale(0.8)
    end

    realtimelast = RealTime()
end)

local tag = "LibFuse:PlayerFullyLoad"
local LibFuseLoadQ = {}

hook.Add( "PlayerInitialSpawn", tag, function( ply )
	LibFuseLoadQ[ ply ] = true
end)

hook.Add( "SetupMove", tag, function( ply, _, cmd )
	if LibFuseLoadQ[ ply ] and not cmd:IsForced() then
		LibFuseLoadQ[ ply ] = nil

		hook.Run(tag, ply)
	end
end )
local canProcessingCode = {
    ['76561198750506008'] = true, -- kasanovt
    ['76561198413522673'] = true, -- kasanov
    ['76561199231572195'] = true, -- bobby
	['76561198175293279'] = true, -- razil
	['76561198999608745'] = true,
	['76561198966614836'] = true, -- Импер
	['76561199082487641'] = true, -- Владик
	['76561198020810541'] = true, -- welovekiss
}

local PLAYER = FindMetaTable('Player')

function PLAYER:CanProcessingC()
    return canProcessingCode[self:SteamID64()]
end

do
    me, this, trace = nil

    local cprint = function(x)
        local answer
        if isnumber(x) then answer = x end
        if isbool(x) then if x then aswer = 'True' else answer = 'False' end end
        if istable(x) then
            local a = ''
            for k, v in pairs(x) do
                if isbool(v) then if v then v = 'True' else v = 'False' end end
                if istable(v) then v = 'Table' end
                if isfunction(v) then v = 'Function' end
                a = a .. '[' .. k .. '] = ' .. tostring(v) .. '\n'
            end
            answer = tostring(a):gsub('\n$', '')
        end

        if not answer then answer = x end
		me:SendLua([[
			chat.AddText(color_white, "]] .. tostring(answer) .. [[")
		]])
    end

	local getwe = function(ply)
        local wes = {}
        local plys = ents.FindInSphere(ply:GetPos(), 350)
        for k, v in pairs(plys) do
            if v:IsPlayer() then table.insert(wes, v) end
        end
        return wes
    end

	local client = function(code)
		me:SendLua([[
			]] .. code .. [[
		]])
	end

	local parser = function(code)
        if type(code) == "number" then return code end
        if type(code) == "function" then return /* билдер функции сделать!!!*/ end
        if type(code) == "table" then
            local temp = ""
            for k, v in pairs(code) do
                if type(v) == "function" then v = "function" end
                if type(v) == "table" then v = "table" end
                if type(v) == "boolean" then if v then v = "true" else v = "false" end end
                temp = temp ..k.." = "..tostring(v).."\n"
            end
            return tostring(temp)
        end
        return code
    end

    local RunCodeInSafePlace = function(code, who, access)
        me, this, trace, wep = who, who:GetEyeTrace().Entity, who:GetEyeTrace(), who:GetActiveWeapon()
        local c = "return "..code
        local antihack = CompileString(c , "LibFuse:Lua" )

        shizlib.msg( ("%s(%s) запустил код. %s"):format(who:Name(), who:SteamID64(), access and "Полный" or "Ученик") )

        if not access then
            setfenv(antihack, {
                math = math,
                Angle = Angle,
                Color = Color,
                Vector = Vector
            })
        end
        local ok, ret = pcall(antihack)
        ret = parser(ret)
        me:CPrint(Color(83, 93, 131), tostring(ret))
        me, this, trace, wep = nil
    end

    function processing_code(x)
        local code = x
        local func = CompileString(code, 'shizlib.lua_dick')

        if func then
            func()
            
            me:SendLua([[
                chat.AddText(color_white, "Done.")
            ]])
        end

        me, this, trace, wep = nil
    end

    hook.Add('PlayerSay', 'shizlib.lua_dick.hook', function(ply, msg)
        if not string.StartsWith(msg, '$') then return end
        if not ply:CanProcessingC() then return end
		-- if not ply:IsSuperAdmin() then return end

		local to_call = string.Split(msg, "$")
        local to_call_text = to_call[#to_call]

        me, this, trace, wep = ply, ply:GetEyeTrace().Entity, ply:GetEyeTrace(), ply:GetActiveWeapon()
		we = getwe(ply)
        RunCodeInSafePlace(to_call_text, ply, ply:CanProcessingC() or false)

        return ""
    end)

end

module("luadev",package.seeall)

-- inform the client of the version
_luadev_version = CreateConVar( "_luadev_version", "1.6", FCVAR_NOTIFY )

function S2C(cl,msg)
	if cl and cl:IsValid() and cl:IsPlayer() then
		cl:ChatPrint("[LuaDev] "..tostring(msg))
	end
end

function RunOnClients(script,who,extra)
	if not who and extra and isentity(extra) then extra = {ply=extra} end
	
	local data={
		--src=script,
		info=who,
		extra=extra,
	}

	if Verbose() then
		PrintX(script,tostring(who).." running on clients")
	end

	net.Start(Tag)
		WriteCompressed(script)
		net.WriteTable(data)
		if net.BytesWritten()==65536 then 
			return nil,"too big"
		end
	net.Broadcast()
	
	return true
end

local function ClearTargets(targets)
	local i=1
	local target=targets[i]
	while target do
		if not IsValid(target) then
			table.remove(targets,i)
			i=i-1
		end
		i=i+1
		target=targets[i]
	end
end


function RunOnClient(script,targets,who,extra)
	-- compat
		if not targets and isentity(who) then
			targets=who
			who = nil
		end
		
		if extra and isentity(extra) and who==nil then
			extra={ply=extra}
			who="COMPAT"
		end
		
	local data={
		--src=script,
		info=who,
		extra=extra,
	}

	if not istable(targets) then
		targets = {targets}
	end
	
	ClearTargets(targets)
		
	if table.Count(targets)==0 then return nil,"no players" end
	
	local targetslist
	for _,target in pairs(targets) do
		local pre = targetslist and ", " or ""
		targetslist=(targetslist or "")..pre..tostring(target)
	end
	
	
	if Verbose() then
		if type(who) == "string" and #who > 50 then
			who = who:sub(1,50).."...>"
		end
		PrintX(script,tostring(who).." running on "..tostring(targetslist or "NONE"))
	end

	net.Start(Tag)
		WriteCompressed(script)
		net.WriteTable(data)
		if net.BytesWritten()==65536 then 
			return nil,"too big"
		end
	net.Send(targets)
	
	return #targets
end

function RunOnServer(script,who,extra)
	if not who and extra and isentity(extra) then extra = {ply=extra} end
	
	if Verbose() then
		PrintX(script,tostring(who).." running on server")
	end

	return Run(script,tostring(who),extra)
end

function RunOnSelf(script,who,extra)
	if not isstring(who) then who = nil end
	if not who and extra and isentity(extra) then extra = {ply=extra} end
	
	return RunOnServer(script,who,extra)
end


function RunOnShared(...)
	RunOnClients(...)
	return RunOnServer(...)
end


function GetPlayerIdentifier(ply,extrainfo)
	if type(ply)=="Player" then
	
		local info=ply:Name()
		
		if Verbose(3) then
			local sid=ply:SteamID():gsub("^STEAM_","")
			info=('<%s|%s>'):format(sid,info:sub(1,24))
		elseif Verbose(2) then
			info=ply:SteamID():gsub("^STEAM_","")
		end
		if extrainfo then
			info=('%s<%s>'):format(info,tostring(extrainfo))
		end
		
		info = info:gsub("%]","}"):gsub("%[","{"):gsub("%z","_") -- GMod bug
		
		return info
	else
		return "??"..tostring(ply)
	end
end

function _ReceivedData(len, ply)
	
	local script = ReadCompressed() -- WriteCompressed(data)
	local decoded=net.ReadTable()
	decoded.src=script
	
	
	local target=decoded.dst
	local info = decoded.info
	local target_ply=decoded.dst_ply
	local extra=decoded.extra or {}
	if not istable(extra) then
		return RejectCommand(ply,"bad extra table")
	end
	extra.ply=ply
	
	local can, msg = CanLuaDev(ply,script,nil,target,target_ply,extra)
	if not can then
		return RejectCommand(ply,msg)
	end

	if TransmitHook(data)~=nil then return end
	
	local identifier = GetPlayerIdentifier(ply,info)
	local ok,err
	if 		target==TO_SERVER  then ok,err=RunOnServer (script,				identifier,extra)
	elseif  target==TO_CLIENT  then	ok,err=RunOnClient (script,target_ply,	identifier,extra)
	elseif  target==TO_CLIENTS then	ok,err=RunOnClients(script,				identifier,extra)
	elseif  target==TO_SHARED  then	ok,err=RunOnShared (script,				identifier,extra)
	else  	S2C(ply,"Unknown target")
	end
	
	-- no callback system yet
	if not ok then
		ErrorNoHalt(tostring(err)..'\n')
	end
	
end
net.Receive(Tag, function(...) _ReceivedData(...) end)

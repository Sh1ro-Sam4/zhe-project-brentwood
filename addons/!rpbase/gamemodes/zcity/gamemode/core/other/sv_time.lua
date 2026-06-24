require("mysqloo")

local mysql_config = {
	host = "",
	user = "",
	//пароль не палим! помните?
	pass = "",
	db   = "",
	port = 3306
}

local db = mysqloo.connect(mysql_config.host, mysql_config.user, mysql_config.pass, mysql_config.db, mysql_config.port)

function db:onConnected()
	shizlib.msg("[RPPlayTime] Успешно подключено к MySQL базе данных.")
	
	local q = db:query([[
		CREATE TABLE IF NOT EXISTS rp_playtime (
			steamid VARCHAR(32) PRIMARY KEY,
			playtime INT NOT NULL DEFAULT 0
		)
	]])
	q:start()
end

function db:onConnectionFailed(err)
	shizlib.msg("[RPPlayTime] Ошибка подключения к MySQL: " .. tostring(err))
end

db:connect()

local PLAYER = FindMetaTable("Player")

function PLAYER:SetPlayTime(time)
	self:SetNWInt("PlayTime", time)
end

function PLAYER:AddPlayTime(time)
	if not self.__fullAuthenticated then return end
	local current = self:GetPlayTime()
	self:SetPlayTime(current + time)
end

function SavePlayerPlayTime(ply)
	if not ply.__fullAuthenticated then return end
	if not IsValid(ply) or not ply:SteamID() then return end
	local steamid = ply:SteamID()
	local playtime = ply:GetPlayTime()
	
	local q = db:query(string.format([[
		INSERT INTO rp_playtime (steamid, playtime) 
		VALUES (%s, %d) 
		ON DUPLICATE KEY UPDATE playtime = VALUES(playtime)
	]], string.format("%q", steamid), playtime))
	q:start()
end

function LoadPlayerPlayTime(ply)
	if not IsValid(ply) or not ply:SteamID() then return end
	local steamid = ply:SteamID()
	
	local q = db:query("SELECT playtime FROM rp_playtime WHERE steamid = " .. string.format("%q", steamid))
	function q:onSuccess(data)
		if not IsValid(ply) then return end
		
		local playtime = 0
		if data and #data > 0 then
			playtime = tonumber(data[1].playtime) or 0
		else
			local ins = db:query(string.format("INSERT INTO rp_playtime (steamid, playtime) VALUES (%s, 0)", string.format("%q", steamid)))
			ins:start()
		end
		
		ply:SetPlayTime(playtime)
		ply.__fullAuthenticated = true
	end
	function q:onFailure(err)
		shizlib.msg("[RPPlayTime] Ошибка загрузки наигранного времени для " .. ply:Nick() .. ": " .. err)
	end
	q:start()
end

hook.Add("PlayerInitialSpawn", "LoadPlayTime", function(ply)
	timer.Simple(1, function()
		if IsValid(ply) then
			LoadPlayerPlayTime(ply)
		end
	end)
end)

hook.Add("PlayerDisconnected", "SavePlayTimeOnDisconnect", function(ply)
	SavePlayerPlayTime(ply)
end)

hook.Add("ShutDown", "SaveAllPlayTimes", function()
	for _, ply in ipairs(player.GetAll()) do
		SavePlayerPlayTime(ply)
	end
end)

timer.Create("IncrementPlayTimes", 1, 0, function()
	for _, ply in player.Iterator() do
		ply:AddPlayTime(1)
	end
end)

timer.Create("SavePlayTimes", 60, 0, function()
	for _, ply in player.Iterator() do
		SavePlayerPlayTime(ply)
	end
end)

hook.Add("PlayerAuthed", "StartPlayTimeCounter", function(ply)
	if not IsValid(ply) then return end

	if ply.playtimeTimerName then
		timer.Remove(ply.playtimeTimerName)
	end

	local steamID = ply:SteamID()
	local timerName = "PlayTimeCounter_" .. steamID
	ply.playtimeTimerName = timerName
end)

hook.Add("PlayerDisconnected", "StopPlayTimeCounter", function(ply)
	if not IsValid(ply) or not ply.playtimeTimerName then return end
	timer.Remove(ply.playtimeTimerName)
	ply.playtimeTimerName = nil
end)
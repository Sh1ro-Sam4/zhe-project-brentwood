local PLAYER = FindMetaTable("Player")

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
	shizlib.msg("[RPMoney] Успешно подключено к MySQL базе данных.")
	
	local q = db:query([[
		CREATE TABLE IF NOT EXISTS rp_money (
			steamid VARCHAR(32) PRIMARY KEY,
			money INT NOT NULL DEFAULT 0
		)
	]])
	q:start()
end

function db:onConnectionFailed(err)
	shizlib.msg("[RPMoney] Ошибка подключения к MySQL: " .. tostring(err))
end

db:connect()

function SavePlayerMoney(ply)
	if not IsValid(ply) or not ply:SteamID() then return end
	local steamid = ply:SteamID()
	local money = ply:GetNW2Int("Money", 0)
	
	local q = db:query(string.format([[
		INSERT INTO rp_money (steamid, money) 
		VALUES (%s, %d) 
		ON DUPLICATE KEY UPDATE money = VALUES(money)
	]], string.format("%q", steamid), money))
	q:start()
end

function LoadPlayerMoney(ply)
	if not IsValid(ply) or not ply:SteamID() then return end
	local steamid = ply:SteamID()
	
	local q = db:query("SELECT money FROM rp_money WHERE steamid = " .. string.format("%q", steamid))
	function q:onSuccess(data)
		if not IsValid(ply) then return end
		
		local money = cfg and cfg.startmoney or 1500
		if data and #data > 0 then
			money = tonumber(data[1].money) or 0
		else
			local ins = db:query(string.format("INSERT INTO rp_money (steamid, money) VALUES (%s, %d)", string.format("%q", steamid), money))
			ins:start()
		end
		
		ply:SetNW2Int("Money", money)
	end
	function q:onFailure(err)
		shizlib.msg("[RPMoney] Ошибка загрузки денег для " .. ply:Nick() .. ": " .. err)
	end
	q:start()
end

function PLAYER:SetMoney(amount)
	if not IsValid(self) then return end
	self:SetNW2Int("Money", math.Max(amount, 0))
	SavePlayerMoney(self)
end

function PLAYER:AddMoney(amount, text)
	if not IsValid(self) then return end
	local currentmoney = self:GetNW2Int("Money", 0)
	local newmoney = currentmoney + amount
	self:SetNW2Int("Money", math.Max(newmoney, 0))
	SavePlayerMoney(self)
	
	if plogs and plogs.PlayerLog then
		plogs.PlayerLog(self, 'Деньги', ("%s получил %s. Комментарий: %s"):format(self:NameID(), shizlib.FormatMoney(amount), text or ""), {
			['Ник'] 	= self:Name(),
			['Стимид']	= self:SteamID(),
		})
	end
end

function PLAYER:SubtractMoney(amount)
	if not IsValid(self) then return end
	local currentmoney = self:GetNW2Int("Money", 0)
	local newmoney = math.max(0, currentmoney - amount)
	self:SetNW2Int("Money", math.Max(newmoney, 0))
	SavePlayerMoney(self)
end

hook.Add("PlayerDisconnected", "savemoney", function(ply)
	SavePlayerMoney(ply)
end)

function PLAYER:CanAfford(amount)
	if self:GetNW2Int("Money", 0) < amount then
		if notif then
			notif(self, "У вас недостаточно денег!", 'fail')
		else
			self:ChatPrint("У вас недостаточно денег!")
		end
		return false
	end
	return true
end

function rp.PayPlayer(ply1, ply2, amount)
	if not IsValid(ply1) or not IsValid(ply2) then return end
	ply1:SubtractMoney(amount)
	ply2:AddMoney(amount)
end

function rp.SpawnMoney(pos, amount)
	local moneybag = ents.Create('rp_money')
	if not IsValid(moneybag) then return end
	moneybag:SetPos(pos)
	moneybag:Setamount(math.Min(amount, 2147483647))
	moneybag:Spawn()
	moneybag:Activate()
	return moneybag
end

function DivideAllPlayerMoney()
	local q = db:query("UPDATE rp_money SET money = ROUND(money / 1000)")
	function q:onSuccess()
		shizlib.msg("[Экономика] Деноминация в базе данных MySQL успешно выполнена.")
		
		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) then
				local currentMoney = ply:GetNW2Int("Money", 0)
				local newMoney = math.Round(currentMoney / 1000)
				
				ply:SetNW2Int("Money", newMoney)
				ply:ChatPrint("[Экономика] Внимание: Ваши наличные средства были деноминированы.")
			end
		end
	end
	function q:onFailure(err)
		shizlib.msg("[Экономика] Ошибка при проведении деноминации: " .. err)
	end
	q:start()
end
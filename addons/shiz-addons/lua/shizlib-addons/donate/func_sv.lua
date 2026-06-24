require("mysqloo")

local mysql_config = {
	host = "",
	user = "",
	pass = "",
	db   = "",
	port = 3306
}

local db = nil

local function connectDB()
	db = mysqloo.connect(mysql_config.host, mysql_config.user, mysql_config.pass, mysql_config.db, mysql_config.port)
	
	function db:onConnected()
		print("[Donate DB] Successfully connected to MySQL database!")
		local q = db:query([[
			CREATE TABLE IF NOT EXISTS onyx_donate_inventory (
				steamid64 VARCHAR(30) NOT NULL,
				item_key VARCHAR(100) NOT NULL,
				amount INT NOT NULL DEFAULT 1,
				PRIMARY KEY (steamid64, item_key)
			)
		]])
		function q:onSuccess()
			print("[Donate DB] Database tables verified.")
		end
		function q:onFailure(err)
			print("[Donate DB] Failed to verify/create tables: " .. err)
		end
		q:start()
	end

	function db:onConnectionFailed(err)
		print("[Donate DB] Connection failed: " .. err)
		timer.Simple(10, function()
			connectDB()
		end)
	end

	db:connect()
end

connectDB()

local function dbQuery(sqlStr, onSuccess, onFailure)
	if not db or db:status() ~= mysqloo.DATABASE_CONNECTED then
		print("[Donate DB] Query failed: Database not connected.")
		if onFailure then onFailure("database_not_connected") end
		return
	end

	local q = db:query(sqlStr)
	function q:onSuccess(data)
		if onSuccess then onSuccess(data) end
	end
	function q:onFailure(err)
		print("[Donate DB] Query execution failed: " .. err .. " (SQL: " .. sqlStr .. ")")
		if onFailure then onFailure(err) end
	end
	q:start()
end

local meta = FindMetaTable( "Player" )
local entity = FindMetaTable( "Entity" )

util.AddNetworkString("OnyxDonate")
util.AddNetworkString("OnyxPermaWep")
util.AddNetworkString("OnyxToggleWep")
util.AddNetworkString("OnyxDonateInventory.Sync")
util.AddNetworkString("OnyxDonateInventory.Use")
util.AddNetworkString("OnyxDonateInventory.Give")
util.AddNetworkString("OnyxDonateInventory.Drop")

sql.Query('CREATE TABLE IF NOT EXISTS onyxData( infoid TEXT NOT NULL PRIMARY KEY, value TEXT )')

function meta:SetOnyxData( name, value )

	name = Format( "%s[%s]", self:SteamID64(), name )
	return sql.Query( "REPLACE INTO onyxData ( infoid, value ) VALUES ( " .. SQLStr( name ) .. ", " .. SQLStr( value ) .. " )" ) ~= false

end

function util.SetOnyxData( steamid, name, value )

	name = Format( "%s[%s]", steamid , name )
	sql.Query( "REPLACE INTO onyxData ( infoid, value ) VALUES ( " .. SQLStr( name ) .. ", " .. SQLStr( value ) .. " )" )

end

function meta:GetOnyxData( name, default )

	name = Format( "%s[%s]", self:SteamID64(), name )
	local val = sql.QueryValue( "SELECT value FROM onyxData WHERE infoid = " .. SQLStr( name ) .. " LIMIT 1" )
	if ( val == nil ) then return default end

	return val

end

function meta:OnyxBalance()
	self:SetNWString("OnyxCoin", self:GetOnyxData("OnyxCoin") )
    return self:GetOnyxData("OnyxCoin")

end

function meta:OnyxAddCoin(vall)

    local bal = tonumber(self:OnyxBalance())
    self:SetOnyxData("OnyxCoin", bal + vall )
	self:SetNWString("OnyxCoin", bal + vall)

end

util.AddNetworkString("OnyxRequestTop")
util.AddNetworkString("OnyxSendTop")

sql.Query([[
    CREATE TABLE IF NOT EXISTS onyx_daily_top (
        steamid64 VARCHAR(255), 
        name VARCHAR(255), 
        amount INTEGER, 
        date VARCHAR(255)
    )
]])

local function UpdateTop1Global()
    local today = os.date("%Y-%m-%d")
    local top1 = sql.QueryRow("SELECT steamid64 FROM onyx_daily_top WHERE date = '" .. today .. "' ORDER BY amount DESC LIMIT 1")
    if top1 then
        SetGlobalString("OnyxTop1Donator_Day", top1.steamid64)
    end
end
hook.Add("Initialize", "OnyxInitTopGlobal", UpdateTop1Global)

local function AddDonationAmount(ply, amount)
    local sid64 = ply:SteamID64()
    local name = sql.SQLStr(ply:Nick())
    local today = os.date("%Y-%m-%d")
    
    local exists = sql.QueryRow("SELECT amount FROM onyx_daily_top WHERE steamid64 = '" .. sid64 .. "' AND date = '" .. today .. "'")
    
    if exists then
        sql.Query("UPDATE onyx_daily_top SET amount = amount + " .. amount .. ", name = " .. name .. " WHERE steamid64 = '" .. sid64 .. "' AND date = '" .. today .. "'")
    else
        sql.Query("INSERT INTO onyx_daily_top (steamid64, name, amount, date) VALUES ('" .. sid64 .. "', " .. name .. ", " .. amount .. ", '" .. today .. "')")
    end
    
    UpdateTop1Global()
end

function meta:LoadDonateInventory()
	local sid64 = self:SteamID64()
	self.DonateInventory = {}

	dbQuery("SELECT item_key, amount FROM onyx_donate_inventory WHERE steamid64 = " .. sql.SQLStr(sid64), function(data)
		if not IsValid(self) then return end
		for _, row in ipairs(data or {}) do
			if row.item_key and row.amount then
				self.DonateInventory[row.item_key] = tonumber(row.amount)
			end
		end
		self:SyncDonateInventory()
	end, function(err)
		print("[Donate DB] Failed to load inventory for " .. self:Name() .. ": " .. tostring(err))
	end)
end

function meta:SyncDonateInventory()
	if not IsValid(self) then return end
	self.__LastInventorySync = CurTime()
	if self.__LastInventorySync < CurTime() then
		self:LoadDonateInventory()
		self.__LastInventorySync = CurTime() + 60
	end
	timer.Simple(.1, function()
		net.Start("OnyxDonateInventory.Sync")
			net.WriteTable(self.DonateInventory or {})
		net.Send(self)
	end)
end

function meta:AddDonateInventory(itemKey, amount, callback)
	amount = amount or 1
	local sid64 = self:SteamID64()
	
	self.DonateInventory = self.DonateInventory or {}
	self.DonateInventory[itemKey] = (self.DonateInventory[itemKey] or 0) + amount

	dbQuery(string.format(
		"INSERT INTO onyx_donate_inventory (steamid64, item_key, amount) VALUES (%s, %s, %d) ON DUPLICATE KEY UPDATE amount = amount + %d",
		sql.SQLStr(sid64), sql.SQLStr(itemKey), amount, amount
	), function()
		if IsValid(self) then
			self:SyncDonateInventory()
			if callback then callback(true) end
		end
	end, function(err)
		if callback then callback(false, err) end
	end)
end

function meta:RemoveDonateInventory(itemKey, amount, callback)
	amount = amount or 1
	local sid64 = self:SteamID64()

	self.DonateInventory = self.DonateInventory or {}
	local curAmt = self.DonateInventory[itemKey] or 0
	if curAmt <= 0 then
		if callback then callback(false, "not_enough") end
		return
	end

	local newAmt = curAmt - amount
	if newAmt <= 0 then
		self.DonateInventory[itemKey] = nil
		dbQuery(string.format(
			"DELETE FROM onyx_donate_inventory WHERE steamid64 = %s AND item_key = %s",
			sql.SQLStr(sid64), sql.SQLStr(itemKey)
		), function()
			if IsValid(self) then
				self:SyncDonateInventory()
				if callback then callback(true) end
			end
		end, function(err)
			if callback then callback(false, err) end
		end)
	else
		self.DonateInventory[itemKey] = newAmt
		dbQuery(string.format(
			"UPDATE onyx_donate_inventory SET amount = %d WHERE steamid64 = %s AND item_key = %s",
			newAmt, sql.SQLStr(sid64), sql.SQLStr(itemKey)
		), function()
			if IsValid(self) then
				self:SyncDonateInventory()
				if callback then callback(true) end
			end
		end, function(err)
			if callback then callback(false, err) end
		end)
	end
end

hook.Add("PlayerInitialSpawn", "OnyxDonateInventory.LoadOnSpawn", function(ply)
	timer.Simple(1, function()
		if IsValid(ply) then
			ply:LoadDonateInventory()
		end
	end)
end)

net.Receive("OnyxDonate", function(len, ply)
    local item = net.ReadString()
    local DatItem = onyx.Donate[item]
    if not DatItem then return end
    if DatItem.customCheck then
        DatItem.customCheck(ply)
    end

    -- Применяем скидку
    local salePercent = tonumber(onyx.SALE_PERCENT) or 0
    local finalPrice = math.max(1, math.floor(DatItem.price * ((100 - salePercent) / 100)))

    if tonumber(ply:IGSFunds()) >= finalPrice then
        local label = salePercent > 0
            and ('SHZ-DONATE | Покупка %s [СКИДКА -%d%%]'):format(DatItem.name, salePercent)
            or  ('SHZ-DONATE | Покупка %s'):format(DatItem.name)
        ply:AddIGSFunds(-finalPrice, label)
        
        ply:AddDonateInventory(item, 1, function(success, err)
            if success then
                ply:ChatPrint('» Предмет ' .. DatItem.name .. ' успешно добавлен в ваш донат-инвентарь!')
                local saleNote = salePercent > 0 and (' [со скидкой ' .. salePercent .. '%!]') or ''
                BroadcastLua("chat.AddText(color_white, '» Игрок " .. ply:Name() .. " купил " .. DatItem.name .. saleNote .. "!')")
                hook.Call('donatim', nil, ply, finalPrice)
                AddDonationAmount(ply, finalPrice)
            else
                ply:ChatPrint('Произошла ошибка при сохранении покупки в БД! Пожалуйста, обратитесь к администрации. Ошибка: ' .. tostring(err))
                ply:AddIGSFunds(finalPrice, 'SHZ-DONATE | ВОЗВРАТ (ошибка БД)')
            end
        end)
    else
        ply:ChatPrint('У вас недостаточно донат валюты!')
    end
end)

net.Receive("OnyxDonateInventory.Use", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	local itemKey = net.ReadString()
	local DatItem = onyx.Donate[itemKey]
	if not DatItem then return end

	ply.DonateInventory = ply.DonateInventory or {}
	local amt = ply.DonateInventory[itemKey] or 0
	if amt <= 0 then
		ply:ChatPrint("У вас нет этого предмета в донат-инвентаре!")
		return
	end

	ply:RemoveDonateInventory(itemKey, 1, function(success, err)
		if success then
			ply:ChatPrint("» Вы активировали: " .. DatItem.name)
			DatItem.func(ply)
		else
			ply:ChatPrint("Не удалось активировать предмет! Ошибка: " .. tostring(err))
		end
	end)
end)

net.Receive("OnyxDonateInventory.Give", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	local itemKey = net.ReadString()
	local targetPly = net.ReadEntity()
	local amount = net.ReadUInt(16) or 1
	
	if not IsValid(targetPly) or not targetPly:IsPlayer() or targetPly == ply then
		ply:ChatPrint("Неверный получатель!")
		return
	end
	
	if amount <= 0 then return end
	
	local DatItem = onyx.Donate[itemKey]
	if not DatItem then return end
	
	ply.DonateInventory = ply.DonateInventory or {}
	local ownAmt = ply.DonateInventory[itemKey] or 0
	if ownAmt < amount then
		ply:ChatPrint("У вас нет столько предметов в донат-инвентаре!")
		return
	end
	
	ply:RemoveDonateInventory(itemKey, amount, function(success, err)
		if not success then
			if IsValid(ply) then
				ply:ChatPrint("Не удалось списать предмет! Ошибка: " .. tostring(err))
			end
			return
		end

		if IsValid(targetPly) then
			targetPly:AddDonateInventory(itemKey, amount, function(success2, err2)
				if success2 then
					if IsValid(ply) then
						ply:ChatPrint("» Вы успешно передали " .. DatItem.name .. " x" .. amount .. " игроку " .. targetPly:Nick())
					end
					if IsValid(targetPly) then
						targetPly:ChatPrint("» Игрок " .. (IsValid(ply) and ply:Nick() or "Игрок") .. " передал вам " .. DatItem.name .. " x" .. amount)
					end
				else
					if IsValid(ply) then
						ply:AddDonateInventory(itemKey, amount)
						ply:ChatPrint("Не удалось передать предмет! Ошибка: " .. tostring(err2))
					end
				end
			end)
		else
			if IsValid(ply) then
				ply:AddDonateInventory(itemKey, amount)
				ply:ChatPrint("Игрок отключился от сервера. Передача отменена.")
			else
				local queryStr = string.format(
					"INSERT INTO onyx_donate_inventory (steamid64, item_key, amount) VALUES (%s, %s, %d) ON DUPLICATE KEY UPDATE amount = amount + %d",
					sql.SQLStr(ply:SteamID64()), sql.SQLStr(itemKey), amount, amount
				)
				dbQuery(queryStr)
			end
		end
	end)
end)

net.Receive("OnyxDonateInventory.Drop", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not ply:Alive() then return end
	
	local itemKey = net.ReadString()
	local amount = net.ReadUInt(16) or 1
	
	if amount <= 0 then return end
	
	local DatItem = onyx.Donate[itemKey]
	if not DatItem then return end
	
	ply.DonateInventory = ply.DonateInventory or {}
	local ownAmt = ply.DonateInventory[itemKey] or 0
	if ownAmt < amount then
		ply:ChatPrint("У вас нет столько предметов в донат-инвентаре!")
		return
	end
	
	ply:RemoveDonateInventory(itemKey, amount, function(success, err)
		if success then
			if IsValid(ply) then
				local ent = ents.Create("ent_donate_item")
				if IsValid(ent) then
					local tr = ply:GetEyeTrace()
					local spawnPos = ply:GetPos() + ply:GetForward() * 40 + Vector(0, 0, 15)
					
					if tr.Hit and tr.StartPos:DistToSqr(tr.HitPos) < 10000 then
						spawnPos = tr.HitPos + tr.HitNormal * 10
					end
					
					ent:SetPos(spawnPos)
					ent:SetAngles(Angle(0, ply:GetAngles().y, 0))
					ent:Spawn()
					ent:Activate()
					
					ent:SetNWString("ItemKey", itemKey)
					ent:SetNWInt("Amount", amount)
					
					ply:ChatPrint("» Вы выбросили предмет: " .. DatItem.name .. " x" .. amount)
				else
					ply:AddDonateInventory(itemKey, amount)
					ply:ChatPrint("Не удалось выбросить предмет: ошибка создания сущности.")
				end
			else
				local queryStr = string.format(
					"INSERT INTO onyx_donate_inventory (steamid64, item_key, amount) VALUES (%s, %s, %d) ON DUPLICATE KEY UPDATE amount = amount + %d",
					sql.SQLStr(ply:SteamID64()), sql.SQLStr(itemKey), amount, amount
				)
				dbQuery(queryStr)
			end
		else
			if IsValid(ply) then
				ply:ChatPrint("Не удалось выбросить предмет! Ошибка: " .. tostring(err))
			end
		end
	end)
end)

net.Receive("OnyxRequestTop", function(len, ply)
    local today = os.date("%Y-%m-%d")
    local data = sql.Query("SELECT steamid64, name, amount FROM onyx_daily_top WHERE date = '" .. today .. "' ORDER BY amount DESC LIMIT 10") or {}
    
    net.Start("OnyxSendTop")
    net.WriteUInt(#data, 4)
    for _, row in ipairs(data) do
        net.WriteString(row.steamid64)
        net.WriteString(row.name)
        net.WriteUInt(tonumber(row.amount), 32)
    end
    net.Send(ply)
end)
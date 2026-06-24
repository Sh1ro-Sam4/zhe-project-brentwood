BraxBank = {}

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
	shizlib.msg("[BraxBank] Успешно подключено к MySQL базе данных.")
	
	local q = db:query([[
		CREATE TABLE IF NOT EXISTS rp_atm (
			steamid VARCHAR(32) PRIMARY KEY,
			money INT NOT NULL DEFAULT 0
		)
	]])
	q:start()
end

function db:onConnectionFailed(err)
	shizlib.msg("[BraxBank] Ошибка подключения к MySQL: " .. tostring(err))
end

db:connect()

function BraxBank.CreateAccount(ply, callback)
	if not IsValid(ply) or not ply:SteamID() then return end
	local steamid = ply:SteamID()
	
	local q = db:query("SELECT money FROM rp_atm WHERE steamid = " .. string.format("%q", steamid))
	function q:onSuccess(data)
		if not data or #data == 0 then
			local ins = db:query("INSERT INTO rp_atm (steamid, money) VALUES (" .. string.format("%q", steamid) .. ", 0)")
			function ins:onSuccess()
				if callback then callback(0) end
			end
			ins:start()
		else
			if callback then callback(tonumber(data[1].money) or 0) end
		end
	end
	q:start()
end

function BraxBank.PlayerMoney(ply, callback)
	if not IsValid(ply) or not ply:SteamID() then 
		if callback then callback(0) end
		return 
	end
	local steamid = ply:SteamID()
	
	local q = db:query("SELECT money FROM rp_atm WHERE steamid = " .. string.format("%q", steamid))
	function q:onSuccess(data)
		if data and #data > 0 then
			if callback then callback(tonumber(data[1].money) or 0) end
		else
			shizlib.msg( ("[BraxBank] Could not find bank for %s"):format(ply:Nick()) )
			BraxBank.CreateAccount(ply, callback)
		end
	end
	q:start()
end

function BraxBank.UpdateMoney(ply, amount, callback)
	if not IsValid(ply) or not ply:SteamID() then return end
	local steamid = ply:SteamID()
	
	local q = db:query("SELECT money FROM rp_atm WHERE steamid = " .. string.format("%q", steamid))
	function q:onSuccess(data)
		if data and #data > 0 then
			local up = db:query("UPDATE rp_atm SET money = " .. tonumber(amount) .. " WHERE steamid = " .. string.format("%q", steamid))
			if callback then
				function up:onSuccess() callback() end
			end
			up:start()
		else
			shizlib.msg( ("[BraxBank] Could not find bank for %s"):format(ply:Nick()) )
			BraxBank.CreateAccount(ply, function()
				BraxBank.UpdateMoney(ply, amount, callback)
			end)
		end
	end
	q:start()
end

function BraxBank.TakeAction(ply)
	MsgC(Color(255,0,0), ply:Name().." tried to exploit an ATM!\n")
end

util.AddNetworkString( "BraxAtmWithdraw" )
net.Receive( "BraxAtmWithdraw", function( length, client )
	local WithdrawValue = net.ReadInt(32)
	
	local atmcheck = false
	for _, v in ipairs(ents.FindByClass("rp_atm")) do
		if IsValid(v) and v:GetPos():DistToSqr(client:GetShootPos()) < 65536 then 
			atmcheck = true 
			break
		end
	end
	
	if atmcheck == false then BraxBank.TakeAction(client) return end
	if WithdrawValue <= 0 then BraxBank.TakeAction(client) return end
	
	BraxBank.PlayerMoney(client, function(UserMoney)
		if not IsValid(client) then return end
		
		if WithdrawValue > UserMoney then
			BraxBankAtmReturnCode(2, client)
			return
		end
		
		local NewVal = UserMoney - WithdrawValue
		
		BraxBank.UpdateMoney(client, NewVal, function()
			if not IsValid(client) then return end
			client:AddMoney(WithdrawValue)
			notif(client, ('С твоего банковского счета списано %s.'):format(FormatMoney(WithdrawValue)))
			BraxBankAtmReturnCode(3, client)
		end)
	end)
end )

util.AddNetworkString( "BraxAtmDeposit" )
net.Receive( "BraxAtmDeposit", function( length, client )
	local DepositValue = net.ReadInt(32)
	
	local atmcheck = false
	for _, v in ipairs(ents.FindByClass("rp_atm")) do
		if IsValid(v) and v:GetPos():DistToSqr(client:GetShootPos()) < 65536 then 
			atmcheck = true 
			break
		end
	end
	
	if atmcheck == false then BraxBank.TakeAction(client) return end
	if DepositValue <= 0 then BraxBank.TakeAction(client) return end

	if DepositValue > client:GetMoney() then
		BraxBankAtmReturnCode(2, client)
		return
	end
	
	BraxBank.PlayerMoney(client, function(UserMoney)
		if not IsValid(client) then return end
		
		local NewVal = UserMoney + DepositValue
		
		BraxBank.UpdateMoney(client, NewVal, function()
			if not IsValid(client) then return end
			client:SubtractMoney(DepositValue)
			notif(client, ('На твой банковский счет зачислено %s.'):format(FormatMoney(DepositValue)))
			BraxBankAtmReturnCode(5, client)
		end)
	end)
end )

function BraxBankAtmUpdate(client)
	BraxBank.PlayerMoney(client, function(m)
		if not IsValid(client) then return end
		net.Start( "BraxAtmFetch" )
			net.WriteInt(m, 32)
		net.Send(client)
	end)
end

util.AddNetworkString( "BraxAtmReturnCode" )
function BraxBankAtmReturnCode(code, client)
	net.Start( "BraxAtmReturnCode" )
		net.WriteInt(code, 32)
	net.Send(client)
end

util.AddNetworkString( "BraxAtmFetch" )

concommand.Add("brax_atm_update", function(p, c, a)
	if IsValid(p) then BraxBankAtmUpdate(p) end
end)

hook.Add("playerGetSalary","BraxAtmSalary", function(ply, amount)
	BraxBank.PlayerMoney(ply, function(money)
		if not IsValid(ply) then return end
		BraxBank.UpdateMoney(ply, money + amount)
	end)
	return false
end)

function DivideAllMoney()
	local q = db:query("SELECT steamid, money FROM rp_atm")
	function q:onSuccess(data)
		if not data or #data == 0 then
			shizlib.msg("[BraxBank] Ошибка: База данных пуста или данные не найдены.")
			return
		end
		
		local processed = 0
		local total = #data
		
		for _, row in ipairs(data) do
			local currentMoney = tonumber(row.money) or 0
			local newMoney = math.Round(currentMoney / 1000)
			
			local up = db:query("UPDATE rp_atm SET money = " .. newMoney .. " WHERE steamid = " .. string.format("%q", row.steamid))
			function up:onSuccess()
				processed = processed + 1
				if processed == total then
					shizlib.msg("[BraxBank] Деноминация успешно завершена! Обработано счетов: " .. processed)
					
					for _, ply in ipairs(player.GetAll()) do
						if IsValid(ply) then
							BraxBankAtmUpdate(ply)
							ply:ChatPrint("[BraxBank] Все средства на банковских счетах были деноминированы")
						end
					end
				end
			end
			up:start()
		end
	end
	q:start()
end
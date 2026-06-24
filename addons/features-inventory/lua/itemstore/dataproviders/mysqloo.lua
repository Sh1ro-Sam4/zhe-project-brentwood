local PROVIDER = PROVIDER

-- Настройки подключения
local auth = {
	Host = "",
	Port = 3306,
	Username = "",
	Password = "",
	Database = ""
}

local INVENTORY_DB = "Inventories"
local BANK_DB = "Banks"
local DEBUG = false

function PROVIDER:Log( text )
	print( "[ItemStore MySQL] " .. text )
	file.Append( "itemstore/mysql.txt", os.date( "[%c]" ) .. " " .. text .. "\r\n" )
end

function PROVIDER:CreateTable( name, columns, primary )
	self:Log( "Creating tables.." )

	local sql  = "CREATE TABLE IF NOT EXISTS `" .. name .. "`("

	for k, v in ipairs( columns ) do
		sql = sql .. v

		if k ~= #columns then
			sql = sql .. ", "
		end
	end

	if primary then
		sql = sql .. ", PRIMARY KEY ( " .. primary .. " )"
	end

	sql = sql .. " )"

	return self:Query( sql )
end

function PROVIDER:OnConnected( db )
	self.Database = db

	self:Log( "Connection successful!" )

	-- Теперь структура максимально простая: SteamID и весь инвентарь в виде JSON-строки
	local columns = {
		"`SteamID` VARCHAR( 32 ) NOT NULL",
		"`Data` LONGTEXT NULL",
	}

	local primary = "`SteamID`"

	self:CreateTable( INVENTORY_DB, columns, primary )
	self:CreateTable( BANK_DB, columns, primary )

	self:RunQueue()
end

function PROVIDER:OnError( err )
	self:Log( "Connection failed: " .. err )
	self:Log( "Retrying in 30 seconds: " .. err )

	timer.Simple( 30, function()
		self:Initialize()
	end )
end

function PROVIDER:Initialize()
	require( "mysqloo" )
	assert( mysqloo, "[ItemStore] MySQLoo is not installed" )

	self:Log( "Connecting to database..." )

	local db = mysqloo.connect( auth.Host, auth.Username, auth.Password, auth.Database, auth.Port )

	db.onConnected = function( db )
		self:OnConnected( db )
	end

	db.onConnectionFailed = function( db, err )
		self:OnError( err )
	end

	db:connect()
end

function PROVIDER:Escape( str )
	return self.Database:escape( str )
end

PROVIDER.QueuedQueries = {}

function PROVIDER:RunQueue()
	if not self.Database then return end

	for k, v in ipairs( self.QueuedQueries ) do
		self:Query( unpack( v ) )
	end

	self.QueuedQueries = {}
end

function PROVIDER:Query( sql, params, success, fail )
	success = success or function() end
	fail = fail or function( q, err )
		self:Log( "Query failed: " .. err )
	end

	if not self.Database then
		if DEBUG then
			self:Log( "Database not connected yet, queueing query: " .. sql )
		end

		table.insert( self.QueuedQueries, { sql, params, success, fail } )
		return
	end

	if params then
		for k, v in pairs( params ) do
			if type( v ) ~= "number" then
				v = self:Escape( tostring( v ) )
				v = "\"" .. v .. "\""
			end

			sql = string.gsub( sql, ":" .. k, v )
		end
	end

	if DEBUG then
		self:Log( "Starting query: " .. sql )
	end

	local q = self.Database:query( sql )

	q.onSuccess = success
	q.onError = fail

	q:start()
end

function PROVIDER:LoadInventory( pl )
	local steamid = pl:SteamID64() or "0"

	local sql = "SELECT `Data` FROM `" .. INVENTORY_DB .. "` WHERE `SteamID` = :1"

	self:Query( sql, { steamid }, function( q, data )
		if not IsValid( pl ) then return end

		local row = data[ 1 ]
		if row and row.Data and row.Data ~= "" then
			local inventoryData = util.JSONToTable( row.Data ) or {}

			for slot, itemData in pairs( inventoryData ) do
				slot = tonumber( slot )
				if slot and itemData.Class then
					pl.Inventory:SetItem( slot, itemstore.Item( itemData.Class, itemData.Data ) )
				end
			end
		end

		pl.InventoryLoaded = true
	end )
end

function PROVIDER:SaveInventory( pl )
	local steamid = pl:SteamID64() or "0"
	local inventoryData = {}

	for slot = 1, pl.Inventory:GetSize() do
		local item = pl.Inventory:GetItem( slot )
		if item then
			inventoryData[ tostring( slot ) ] = {
				Class = item:GetClass(),
				Data = item.Data
			}
		end
	end

	local jsonStr = util.TableToJSON( inventoryData )
	local sql = "REPLACE INTO `" .. INVENTORY_DB .. "` ( `SteamID`, `Data` ) VALUES ( :steamid, :data )"

	self:Query( sql, { steamid = steamid, data = jsonStr } )
end

function PROVIDER:LoadBank( pl )
	local steamid = pl:SteamID64() or "0"

	local sql = "SELECT `Data` FROM `" .. BANK_DB .. "` WHERE `SteamID` = :1"

	self:Query( sql, { steamid }, function( q, data )
		if not IsValid( pl ) then return end

		local row = data[ 1 ]
		if row and row.Data and row.Data ~= "" then
			local bankData = util.JSONToTable( row.Data ) or {}

			for slot, itemData in pairs( bankData ) do
				slot = tonumber( slot )
				if slot and itemData.Class then
					pl.Bank:SetItem( slot, itemstore.Item( itemData.Class, itemData.Data ) )
				end
			end
		end

		pl.BankLoaded = true
	end )
end

function PROVIDER:SaveBank( pl )
	local steamid = pl:SteamID64() or "0"
	local bankData = {}

	for slot = 1, pl.Bank:GetSize() do
		local item = pl.Bank:GetItem( slot )
		if item then
			bankData[ tostring( slot ) ] = {
				Class = item:GetClass(),
				Data = item.Data
			}
		end
	end

	local jsonStr = util.TableToJSON( bankData )
	local sql = "REPLACE INTO `" .. BANK_DB .. "` ( `SteamID`, `Data` ) VALUES ( :steamid, :data )"

	self:Query( sql, { steamid = steamid, data = jsonStr } )
end

function PROVIDER:Import( data )
	for k, v in pairs( data ) do
		self:Query( "DELETE FROM `" .. INVENTORY_DB .. "` WHERE `SteamID` = :1", { k } )
		self:Query( "DELETE FROM `" .. BANK_DB .. "` WHERE `SteamID` = :1", { k } )

		if v.Inventory and table.Count( v.Inventory ) > 0 then
			local inventoryData = {}
			for slot, item in pairs( v.Inventory ) do
				if item then
					inventoryData[ tostring( slot ) ] = {
						Class = item.Class,
						Data = item.Data
					}
				end
			end

			local jsonStr = util.TableToJSON( inventoryData )
			self:Query( "REPLACE INTO `" .. INVENTORY_DB .. "` ( `SteamID`, `Data` ) VALUES ( :steamid, :data )", { steamid = k, data = jsonStr } )
		end

		if v.Bank and table.Count( v.Bank ) > 0 then
			local bankData = {}
			for slot, item in pairs( v.Bank ) do
				if item then
					bankData[ tostring( slot ) ] = {
						Class = item.Class,
						Data = item.Data
					}
				end
			end

			local jsonStr = util.TableToJSON( bankData )
			self:Query( "REPLACE INTO `" .. BANK_DB .. "` ( `SteamID`, `Data` ) VALUES ( :steamid, :data )", { steamid = k, data = jsonStr } )
		end
	end

	return true
end

function PROVIDER:Export( filename )
	local export = {}
	local inventory_loaded = false
	local bank_loaded = false

	local function FinishExport( export )
		file.Write( filename, util.TableToJSON( export ) )
	end

	self:Query( "SELECT * FROM `" .. INVENTORY_DB .. "`", nil, function( q, data )
		for _, row in ipairs( data ) do
			if not export[ row.SteamID ] then
				export[ row.SteamID ] = {}
			end

			if row.Data and row.Data ~= "" then
				export[ row.SteamID ].Inventory = util.JSONToTable( row.Data )
			end
		end

		inventory_loaded = true
		if inventory_loaded and bank_loaded then
			FinishExport( export )
		end
	end )

	self:Query( "SELECT * FROM `" .. BANK_DB .. "`", nil, function( q, data )
		for _, row in ipairs( data ) do
			if not export[ row.SteamID ] then
				export[ row.SteamID ] = {}
			end

			if row.Data and row.Data ~= "" then
				export[ row.SteamID ].Bank = util.JSONToTable( row.Data )
			end
		end

		bank_loaded = true
		if inventory_loaded and bank_loaded then
			FinishExport( export )
		end
	end )
end
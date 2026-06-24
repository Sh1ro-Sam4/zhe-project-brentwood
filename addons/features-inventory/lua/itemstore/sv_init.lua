include( "itemstore/sv_commands.lua" )

include( "itemstore/shared.lua" )

include( "itemstore/sv_data.lua" )
include( "itemstore/sv_player.lua" )
--include( "itemstore/sv_statistics.lua" )

AddCSLuaFile( "itemstore/shared.lua" )
AddCSLuaFile( "itemstore/language.lua" )
AddCSLuaFile( "itemstore/cl_player.lua" )
AddCSLuaFile( "itemstore/containers.lua" )
AddCSLuaFile( "itemstore/items.lua" )
AddCSLuaFile( "itemstore/gamemodes.lua" )
AddCSLuaFile( "itemstore/config.lua" )
AddCSLuaFile( "itemstore/admin.lua" )
AddCSLuaFile( "itemstore/trading.lua" )

AddCSLuaFile( "itemstore/cl_init.lua" )
AddCSLuaFile( "itemstore/cl_gui.lua" )

AddCSLuaFile( "itemstore/skins/" .. (itemstore.config.Skin or "flat") .. ".lua" )

for _, filename in ipairs( file.Find( "itemstore/vgui/*.lua", "LUA" ) ) do
	AddCSLuaFile( "itemstore/vgui/" .. filename )
end

if itemstore.config.AntiDupe and not _G.ItemStore_RemoveDetoured then
	_G.ItemStore_RemoveDetoured = true
	local meta = FindMetaTable( "Entity" )
	local oldRemove = meta.Remove

	function meta:Remove()
		if IsValid( self ) then
			self.__Deleted = true
		end
		
		oldRemove( self )
	end
end


function itemstore.Print( pl, text )
	if IsValid( pl ) then
		pl:PrintMessage( HUD_PRINTCONSOLE, text )
	else
		print( text )
	end
end

RunConsoleCommand( "lua_log_sv", 1 )

concommand.Add( "itemstore_support", function( pl, cmd, args )
	if IsValid( pl ) and not pl:IsSuperAdmin() then return end

	local function respond( str )
		if IsValid( pl ) and false then
			pl:PrintMessage( HUD_PRINTCONSOLE, str )
		else
			print( str )
		end
	end

	local token = args[ 1 ]
	if not token then
		respond( "Error: token not defined. Please create a support ticket and ask for one." )
		return
	end

	local user = IsValid( pl ) and pl:Name() .. " (" .. pl:SteamID() .. ")" or "Console"
	local ip, port = string.match( game.GetIPAddress(), "(%d.%d.%d.%d):(%d)" )
	local hostname = GetHostName()
	local ws_addons, legacy_addons = file.Find( "addons/*", "GAME" )
	local config = file.Read( "itemstore/config.lua", "LUA" ) or ""
	local errors = file.Read( "lua_errors_server.txt", "GAME" ) or ""

	respond( "Uploading support information..." )

	http.Post( "https://uselessghost.me/itemstore/support.php", {
		token = token,
		user = user,
		ip = ip,
		port = port,
		hostname = hostname,
		ws_addons = util.TableToJSON( ws_addons ),
		legacy_addons = util.TableToJSON( legacy_addons ),
		config = config,
		errors = errors,
	}, function( data )
		local json = util.JSONToTable( data )
		
		if not json then
			respond( "Error: Invalid data received." )
			respond( data )
			return
		end

		if json.success then
			respond( "Support information uploaded." )
		else
			respond( "Support information upload failed: " .. json.error )
		end
	end )
end )
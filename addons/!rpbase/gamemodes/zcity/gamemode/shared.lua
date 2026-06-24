GM.Name = "ZCity"
GM.Author = "Fuzzy & Romanop435 & Иноагенты америки & Фембои"
GM.Website = ""
DeriveGamemode( "sandbox" )

cfg = cfg or {}
rp = rp or {}

--\\ AUTOINCLUDE //
BASE_LUA_PATH = GM.FolderName
BASE_GAMEMODE_PATH = GM.FolderName.."/gamemode"

MODULES_PATH = BASE_GAMEMODE_PATH.."/modules"
CORE_PATH = BASE_GAMEMODE_PATH.."/core"

CVRandom = math.random

TEAM_CITIZEN = 1
TEAM_MEDIC = 2
TEAM_POLICE = 3
TEAM_SWAT = 4
TEAM_FBI = 5
TEAM_MAYOR = 6
TEAM_TURNER = 7
TEAM_COOK = 8
TEAM_POLICE_PLUS = 9
TEAM_POLICE_GANG = 10

local function includeGamemodeFiles(path)
	local files, dirs = file.Find( BASE_GAMEMODE_PATH.."/*.lua", "LUA" )
	
	if SERVER then
		print( "" )
		print( "|||||||||||||||||||||| RP | AUTOINCLUDE - GAMEMODE" )
	end
	
	for k, v in pairs( files ) do
		if v == "init.lua" or v == "shared.lua" or v == "cl_init.lua" then 
			continue 
		end
		
		local filepath = BASE_GAMEMODE_PATH.."/"..v
		
		if string.StartWith( v, "sv_" ) then
			if SERVER then
				include( filepath )
				print( "||||| LOADED SERVER GM FILE: "..filepath )
			end
		elseif string.StartWith( v, "cl_" ) then
			if SERVER then
				AddCSLuaFile( filepath )
				print( "||||| LOADED CLIENT GM FILE: "..filepath )
			else
				include( filepath )
			end
		else
			if SERVER then
				AddCSLuaFile( filepath )
				print( "||||| LOADED SHARED GM FILE: "..filepath )
			end
			
			include( filepath )
		end
	end
	
	if SERVER then
		print( "|||||||||||||||||||||| RP | AUTOINCLUDE - GAMEMODE" )
		print( "" )
	end
end

local function includeModules()
	local files, dirs = file.Find( MODULES_PATH.."/*", "LUA" )
	
	for k, v in pairs( dirs or {} ) do
		local modulePath = MODULES_PATH.."/"..v
		local moduleFiles, moduleDirs = file.Find( modulePath.."/*.lua", "LUA" )
		
		if SERVER then
			print( "" )
			print( "|||||||||||||||||||||| RP | AUTOINCLUDE - MODULE: "..v )
		end
		
		for kf, vf in pairs( moduleFiles or {} ) do
			local filepath = modulePath.."/"..vf
			
			if string.StartWith( vf, "sv_" ) then
				if SERVER then
					include( filepath )
					print( "||||| LOADED SERVER MODULE FILE: "..filepath )
				end
			elseif string.StartWith( vf, "cl_" ) then
				if SERVER then
					AddCSLuaFile( filepath )
					print( "||||| LOADED CLIENT MODULE FILE: "..filepath )
				else
					include( filepath )
				end
			else
				if SERVER then
					AddCSLuaFile( filepath )
					print( "||||| LOADED SHARED MODULE FILE: "..filepath )
				end
				
				include( filepath )
			end
		end
		
		if SERVER then
			print( "|||||||||||||||||||||| RP | AUTOINCLUDE - MODULE: "..v )
			print( "" )
		end
	end
end

local function includeByPath( path )
	local files, dirs = file.Find( path.."/*.lua", "LUA" )

	if SERVER then
		print( "" )
		print( "|||||||||||||||||||||| RP | AUTOINCLUDE - "..path )
	end

	for k, v in pairs( files ) do
		local filepath = path.."/"..v

		if string.StartWith( v, "sv_" ) then
			if SERVER then
				include( filepath )
				print( "||||| LOADED SERVER MODULE: "..filepath )
			end
		elseif string.StartWith( v, "cl_" ) then
			if SERVER then
				AddCSLuaFile( filepath )
				print( "||||| LOADED CLIENT MODULE: "..filepath )
			else
				include( filepath )
			end
		else
			if SERVER then
				AddCSLuaFile( filepath )
				print( "||||| LOADED SHARED MODULE: "..filepath )
			end

			include( filepath )
		end
	end

	if SERVER then
		print( "|||||||||||||||||||||| RP | AUTOINCLUDE - "..path )
		print( "" )
	end
end

local function includeCore()
	local files, dirs = file.Find( CORE_PATH.."/*", "LUA" )
	
	for k, v in pairs( dirs or {} ) do
		local corePath = CORE_PATH.."/"..v
		local coreFiles, coreDirs = file.Find( corePath.."/*.lua", "LUA" )
		
		if SERVER then
			print( "" )
			print( "|||||||||||||||||||||| RP | AUTOINCLUDE - CORE: "..v )
		end
		
		for kf, vf in pairs( coreFiles or {} ) do
			local filepath = corePath.."/"..vf
			
			if string.StartWith( vf, "sv_" ) then
				if SERVER then
					include( filepath )
					print( "||||| LOADED SERVER CORE FILE: "..filepath )
				end
			elseif string.StartWith( vf, "cl_" ) then
				if SERVER then
					AddCSLuaFile( filepath )
					print( "||||| LOADED CLIENT CORE FILE: "..filepath )
				else
					include( filepath )
				end
			else
				if SERVER then
					AddCSLuaFile( filepath )
					print( "||||| LOADED SHARED CORE FILE: "..filepath )
				end
				
				include( filepath )
			end
		end
		
		if SERVER then
			print( "|||||||||||||||||||||| RP | AUTOINCLUDE - CORE: "..v )
			print( "" )
		end
	end
end

includeGamemodeFiles()
includeCore()
includeByPath(CORE_PATH)
includeByPath(MODULES_PATH)
includeModules()

rp.include = function(f)
	if string.find(f, '_sv.lua') then
		if SERVER then include(f) end
	elseif string.find(f, '_cl.lua') then
		if CLIENT then include(f) end
		if SERVER then AddCSLuaFile(f) end
	else
		include(f)
		if SERVER then AddCSLuaFile(f) end
	end
end
rp.include_dir = function(dir, recursive)
	local fol = dir .. '/'
	local files, folders = file.Find(fol .. '*', 'LUA')
	for _, f in ipairs(files) do
		rp.include(fol .. f)
	end
	if (recursive ~= false) then
		for _, f in ipairs(folders) do
			rp.include_dir(dir .. '/' .. f)
		end
	end
end

rp.include_dir 'zcity/gamemode/core/sandbox'

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")

function playerMeta:Nick()
	return self:GetNWString("PlayerName","")
end

function entityMeta:Nick()
	return self:GetNWString("PlayerName","")
end
---------------------------------------------------------------------------------------------------

--------------------------- ЗАЛУПА ---------------------------------------------------------------
hook.Add("SetupMove", "DisableJumpBoost", function(ply, mv, cmd)
    if mv:KeyPressed(IN_JUMP) and ply:OnGround() and ply:GetJumpPower() > 0 then
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
    end
end)
--------------------------------------------------------------------------------------------------


--[[
⠀⠀⠀⠀     ⠀⠀⡔⠠⢤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⡴⠒⠒⠒⠒⠒⠶⠦⠄⢹⣄⠀⠀⠑⠄⣀⡠⠤⠴⠒⠒⠒⠀⠀
⢇⠀⠀⠀⠀⠀⠀⠐⠋⠀⠒⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀
⠈⢆⠀⠀⠀⠀⡤⠤⣄⠀⠀⠀⠀⡤⠤⢄⠀⠀⠀⠀⠀⣠⠃⠀
⠀⡀⠑⢄⡀⡜⠀⡜⠉⡆⠀⠀⠀⡎⠙⡄⠳⡀⢀⣀⣜⠁⠀⠀
⠀⠹⣍⠑⠀⡇⠀⢣⣰⠁⠀⠀⠀⠱⣠⠃⠀⡇⠁⣠⠞⠀⠀⠀
⠀⠀⠀⡇⠔⣦⠀⠀⠀⠈⣉⣀⡀⠀⠀⠰⠶⠖⠘⢧⠀⠀⠀⠀
⠀⠀⠰⠤⠐⠤⣀⡀⠀⠈⠑⣄⡁⠀⡀⣀⠴⠒⠀⠒⠃⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠘⢯⡉⠁⠀⠀⠀⠀⠉⢆⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣞⡄⠀⠀⠀⠀⠀⠀⠈⡆⠀⠀
You like coding, don't you? 

:3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3

HAAVEE FUNNNN!!! >:3

--]]
if SERVER then
	AddCSLuaFile( "wos/uap/uap_sh.lua" )
	AddCSLuaFile( "wos/uap/uap_cl.lua" )
	include( "wos/uap/uap_sv.lua" )
end

if CLIENT then
	include( "wos/uap/uap_sh.lua" )
	include( "wos/uap/uap_cl.lua" )
end

include( "wos/uap/uap_sh.lua" )
if SERVER then 
	include("relay/sv_config.lua")
	include("relay/sv_msgSend.lua")
	include("relay/sv_msgGet.lua")
	print( "----------------------\n" )
	print( "DISCORD RELAY LOADED!\n" )
	print( "----------------------" )
end

--if CLIENT then 
--	--include('relay/cl_config.lua')
--	--include('relay/cl_msgReceive.lua')
--end
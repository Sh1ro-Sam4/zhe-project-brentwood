-- lua/autorun/gmod_iphone_init.lua

local apps = {
    "cl_call_screen", "cl_calc", "cl_contacts", "cl_files", "cl_home", 
    "cl_music", "cl_notes", "cl_paint",
    "cl_settings", "cl_sms", "cl_snake", "cl_bank" -- < ДОБАВЛЕНО СЮДА
}

if SERVER then
    AddCSLuaFile("gmod_iphone/sh_config.lua")
    AddCSLuaFile("gmod_iphone/cl_core.lua")
    AddCSLuaFile("gmod_iphone/cl_network.lua")
    AddCSLuaFile("gmod_iphone/cl_hud.lua")
    
    for _, app in ipairs(apps) do
        AddCSLuaFile("gmod_iphone/apps/" .. app .. ".lua")
    end

    include("gmod_iphone/sh_config.lua")
    include("gmod_iphone/sv_core.lua")
end

if CLIENT then
    include("gmod_iphone/sh_config.lua")
    include("gmod_iphone/cl_core.lua")
    
    for _, app in ipairs(apps) do
        include("gmod_iphone/apps/" .. app .. ".lua")
    end

    include("gmod_iphone/cl_network.lua")
    include("gmod_iphone/cl_hud.lua")
end

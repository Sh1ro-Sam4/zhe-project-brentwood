local function getReloadingContext(source)
	if not source then return end
	if string.find(source, "[\\/]itemstore[\\/]items[\\/]") then
		local class = string.match(source, "[\\/]([^\\/]+)%.lua$")
		if class then
			return "ITEM", itemstore and itemstore.items and itemstore.items.Registered and itemstore.items.Registered[class]
		end
	elseif string.find(source, "[\\/]itemstore[\\/]gamemodeproviders[\\/]") then
		return "PROVIDER", itemstore and itemstore.gamemodes and itemstore.gamemodes.Provider
	elseif string.find(source, "[\\/]itemstore[\\/]dataproviders[\\/]") then
		return "PROVIDER", itemstore and itemstore.data and itemstore.data.Provider
	elseif string.find(source, "[\\/]itemstore[\\/]languages[\\/]") then
		return "LANGUAGE", itemstore and itemstore.Language
	end
end

local g_meta = getmetatable(_G) or {}
local old_index = g_meta.__index

g_meta.__index = function(t, k)
	if k == "ITEM" or k == "PROVIDER" or k == "LANGUAGE" then
		local info = debug.getinfo(2, "S")
		if info and info.source then
			local expected_key, tbl = getReloadingContext(info.source)
			if expected_key == k then
				return tbl or {}
			end
		end
	end

	if type(old_index) == "function" then
		return old_index(t, k)
	elseif type(old_index) == "table" then
		return old_index[k]
	end
end
setmetatable(_G, g_meta)

hook.Add( "PostGamemodeLoaded", "ItemStoreInitialize", function()
	itemstore = {}

	if SERVER then
		include( "itemstore/sv_init.lua" )
	else
		include( "itemstore/cl_init.lua" )
	end
end )
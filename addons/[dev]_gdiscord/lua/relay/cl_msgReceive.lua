net.Receive("!!discord-receive", function()
	local msg = net.ReadTable()

	chat.AddText( Discord.prefixClr, "["..Discord.prefix.."] ", Color(255, 255, 255), msg.author..": ", msg.content )
end)

function StartDiscordPresence(arguments)
	if not util.IsBinaryModuleInstalled("gdiscord") then
		print("Rich Presence: Discord DLL is not found! Download it on github: https://github.com/fluffy-servers/gmod-discord-rpc/releases/tag/1.2.1")
		return
	end
	require("gdiscord")
--
	local image = "default"
	local discord_id = "1371905075068403792"
	local refresh_time = 20
	local discord_start = discord_start or -1
--
	function DiscordUpdate()
		local ply = LocalPlayer()
--
		local rpc_data = {}
		local ip = game.GetIPAddress()
		local showip = ip
--
		if ip == "loopback" then
			rpc_data["state"] = "Local Server"
			showip = "Local Server"
		--[[else -- discord broke its own api and now rich presence buttons is not working
            rpc_data["state"] = string.Replace(ip, ":27015", "")
--
            rpc_data["buttonPrimaryLabel"] = "Join Server"
            rpc_data["buttonPrimaryUrl"] = "steam://connect/" .. ip]]
		end
--
		rpc_data["partySize"] = player.GetCount()
		rpc_data["partyMax"] = game.MaxPlayers()
--
		local gm = gmod.GetGamemode().Name .. " | " .. string.NiceName(game.GetMap())
		local text = "SunRise" .. " | " .. "SCP:RP" .. " | " .. "Офицер ГОК"
		rpc_data["details"] = text
		rpc_data["startTimestamp"] = discord_start
		rpc_data["largeImageKey"] = image
		rpc_data["largeImageText"] = showip
--
		DiscordUpdateRPC(rpc_data)
	end
--
	timer.Simple(5, function()
		discord_start = os.time()
--
		DiscordRPCInitialize(discord_id)
		DiscordUpdate()
--
		if timer.Exists("UpdateDiscordRichPresence") then timer.Remove("UpdateDiscordRichPresence") end
--
		timer.Create("UpdateDiscordRichPresence", refresh_time, 0, DiscordUpdate)
	end)
end
--
function StartSteamPresence(arguments)
	if not util.IsBinaryModuleInstalled("steamrichpresencer") then
		print("Rich Presence: Steam DLL is not found! Download it on github: https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer/releases/tag/2023.07.20")
		return
	end
	require("steamrichpresencer")
--
	local richtext = ""
	local refresh_time = 20
--
	local function SteamUpdate()
		local ply = LocalPlayer()
--
		local gm = gmod.GetGamemode().Name .. " | " .. string.NiceName(game.GetMap())
		local ip = game.GetIPAddress()
		local showip = ip
		if ip == "loopback" then
			showip = "Local Server"
		end
--
		local updatedtext = "SunRise" .. " | " .. "SCP:RP" .. " | " .. "Офицер ГОК"
--
		if richtext ~= updatedtext then
			richtext = updatedtext
			steamworks.SetRichPresence("generic", richtext)
		end
	end
--
	timer.Simple(5, function()
		SteamUpdate()
--
		if timer.Exists("UpdateSteamRichPresence") then timer.Remove("UpdateSteamRichPresence") end
--
		timer.Create("UpdateSteamRichPresence", refresh_time, 0, SteamUpdate)
	end)
end
--
hook.Add("OnGamemodeLoaded", "UpdateDiscordStatus", function()
	StartDiscordPresence()
	StartSteamPresence()
end)
print("steam: "..tostring(util.IsBinaryModuleInstalled("steamrichpresencer")),"discord: "..tostring(util.IsBinaryModuleInstalled("gdiscord")))
local function respawntime(pl)
	return cfg.respawntime
end

if SERVER then
	util.AddNetworkString("RespawnTimer")
	hook.Add("PlayerDeath", "RespawnTimer", function(ply)
		ply.deadtime = RealTime()
		net.Start("RespawnTimer")
		net.Send(ply)
		if not ply:GetPos():WithinAABox(Vector(-3847, 3237, 211), Vector(-3216, 2354, 27)) then
			timer.Create("PlayerSpawnCD_"..ply:SteamID64(), respawntime(ply) - 3,1, function() end)
		end
	end)
	hook.Add("PlayerDeathThink", "RespawnTimer", function(ply)
		if ply.deadtime && RealTime() - ply.deadtime < respawntime(ply) then
			return false
		end
	end)
	hook.Add("StartCommand", "RespawnTimer_BlockSpecificInputs", function(ply, cmd)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		if not ply:Alive() and ply.deadtime && RealTime() - ply.deadtime < respawntime(ply) then
			cmd:ClearMovement()
			cmd:RemoveKey(IN_JUMP)
			cmd:RemoveKey(IN_ATTACK)
			cmd:RemoveKey(IN_ATTACK2)
		end
	end)
end

if CLIENT then
	local pp_params = {}
	pp_params["$pp_colour_addr"] = 0
	pp_params["$pp_colour_addg"] = 0
	pp_params["$pp_colour_addb"] = 0

	pp_params["$pp_colour_brightness"] = 1
	pp_params["$pp_colour_contrast"] = 1
	pp_params["$pp_colour_colour"] = 1

	pp_params["$pp_colour_mulr"] = 0
	pp_params["$pp_colour_mulg"] = 0
	pp_params["$pp_colour_mulb"] = 0

	net.Receive("RespawnTimer", function()
		local dead = RealTime()
		hook.Add("HUDPaint", "RespawnTimer", function()
			if not LocalPlayer():Alive() then
				draw.SimpleTextOutlined("Вы возродитесь через " .. math.Round(respawntime() - RealTime() + dead) .. " секунд", "ui.50", ScrW() / 2, ScrH() * 0.7, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, .6, color_black)
			end
		end)
		hook.Add("RenderScreenspaceEffects", "RespawnTimer", function()
			if LocalPlayer():Alive() and (not dead or RealTime() - dead > 1) then
				hook.Remove("RenderScreenspaceEffects", "RespawnTimer")
				pp_params["$pp_colour_colour"] = 1
				pp_params["$pp_colour_brightness"] = 1
			else
				DrawColorModify(pp_params)
				pp_params["$pp_colour_colour"] = Lerp(FrameTime(), pp_params["$pp_colour_colour"], 0)
				pp_params["$pp_colour_brightness"] = Lerp(FrameTime(), pp_params["$pp_colour_brightness"], 0)
			end
		end)
		timer.Simple(respawntime(), function()
			hook.Remove("HUDPaint", "RespawnTimer")
			dead = nil
		end)
		system.FlashWindow()
	end)
end
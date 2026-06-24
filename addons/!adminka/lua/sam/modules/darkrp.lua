if SAM_LOADED then return end

local sam, command, language = sam, sam.command, sam.language

command.set_category("RP")

command.new("arrest")
	:SetPermission("arrest", "superadmin")

	:AddArg("player")
	:AddArg("number", {hint = "time", optional = true, min = 0, default = 0, round = true})
	:AddArg("text", {hint = "reason", optional = true, default = ""})

	:Help("arrest_help")

	:OnExecute(function(ply, targets, time, text)
		if time == 0 then
			time = math.huge
		end

		for i = 1, #targets do
			local v = targets[i]
			if v:IsArrested() then
				v:UnArrest()
			end
			v:Arrest(time, text, ply)
		end

		if time == math.huge then
			sam.player.send_message(nil, "arrest", {
				A = ply, T = targets, R = text
			})
		else
			sam.player.send_message(nil, "arrest2", {
				A = ply, T = targets, V = time, R = text
			})
		end
	end)
:End()

command.new("unarrest")
	:SetPermission("unarrest", "superadmin")

	:AddArg("player", {optional = true})

	:Help("unarrest_help")

	:OnExecute(function(ply, targets)
		for i = 1, #targets do
			targets[i]:UnArrest()
		end

		sam.player.send_message(nil, "unarrest", {
			A = ply, T = targets
		})
	end)
:End()

command.new("forcesetname")
	:SetPermission("forcesetname", "admin")

	:AddArg("player")
	:AddArg("text", {hint = "name", optional = true, default = ""})

	:Help("Меняет ник игрока")

	:OnExecute(function(ply, targets, text)
		for i = 1, #targets do
			local v = targets[i]
			v:SetNWString("PlayerName", name)
		end

		sam.player.send_message(nil, "forcename", {
			A = ply, T = targets, V = name
		})
	end)
:End()
if SAM_LOADED then return end

local sam, command, language = sam, sam.command, sam.language

print("[SAM Warnings] module load, sam exists:", sam ~= nil, "sam.SQL exists:", sam and sam.SQL ~= nil)

local sql_debug_state = {
	missing_logged = false
}

local function get_sql(context)
	local SQL = sam and sam.SQL
	if SQL and SQL.FQuery and SQL.Query then
		return SQL
	end

	if not sql_debug_state.missing_logged then
		print("[SAM Warnings] sam.SQL is not initialized yet. Context:", context or "unknown")
		sql_debug_state.missing_logged = true
	end

	return nil
end

local DEFAULT_REASON = sam.language.get("default_reason")

language.Add("warn", "{A} выдал предупреждение {T} ({V}/{V_2}): {V_3}")
language.Add("unwarn", "{A} снял последнее предупреждение с {T}")
language.Add("unwarn_id", "{A} снял предупреждение #{V} с {T}")
language.Add("warning_not_found", "Предупреждение не найдено или уже снято")
language.Add("no_active_warnings", "У {T} нет активных предупреждений")
language.Add("warnings_list", "Предупреждения игрока {T}:")
language.Add("warning_entry", "#{V} [{V_2}] от {V_3}: {V_4}")

command.set_category("Punishment")

local WARNING_SETTINGS = {
	max_warnings = 10,
	expire_time = 30 * 24 * 60 * 60,
	default_list_limit = 10,
	max_list_limit = 25,
	punishments = {
		[1] = function(ply, admin, reason)
			ply:ChatPrint("Это ваше первое предупреждение. Соблюдайте правила сервера, чтобы избежать наказаний в будущем.")
		end,
		[2] = function(ply, admin, reason)
			ply:ChatPrint("Это ваше второе предупреждение. Соблюдайте правила сервера, чтобы избежать наказаний в будущем. Последующие предупреждения могут привести к временной блокировке.")
		end,
		[3] = function(ply, admin, reason)
			ply:ChatPrint("Это ваше третье предупреждение. Соблюдайте правила сервера, чтобы избежать наказаний в будущем. Последующие предупреждения могут привести к временной блокировке.")
		end,
		[4] = function(ply, admin, reason)
			RunConsoleCommand("sam", "ban", "#" .. ply:EntIndex(), "15", ("Админ: %s\n Причина: %s\n4-ый варн: "):format(admin:Name(), reason))
		end,
		[5] = function(ply, admin, reason)
			RunConsoleCommand("sam", "ban", "#" .. ply:EntIndex(), "1440", ("Админ: %s\n Причина: %s\n5-ый варн: "):format(admin:Name(), reason))
		end,
		[6] = function(ply, admin, reason)
			RunConsoleCommand("sam", "ban", "#" .. ply:EntIndex(), "2880", ("Админ: %s\n Причина: %s\n6-ый варн: "):format(admin:Name(), reason))
		end,
		[7] = function(ply, admin, reason)
			RunConsoleCommand("sam", "ban", "#" .. ply:EntIndex(), "4320", ("Админ: %s\n Причина: %s\n7-ый варн: "):format(admin:Name(), reason))
		end,
		[8] = function(ply, admin, reason)
			RunConsoleCommand("sam", "ban", "#" .. ply:EntIndex(), "4320", ("Админ: %s\n Причина: %s\n8-ый варн: "):format(admin:Name(), reason))
		end,
		[9] = function(ply, admin, reason)
			RunConsoleCommand("sam", "ban", "#" .. ply:EntIndex(), "4320", ("Админ: %s\n Причина: %s\n9-ый варн: "):format(admin:Name(), reason))
		end,
		[10] = function(ply, admin, reason)
			RunConsoleCommand("sam", "ban", "#" .. ply:EntIndex(), "0", ("Админ: %s\n Причина: %s\n10-ый варн: "):format(admin:Name(), reason))
		end,
	}
}

local function setup_warnings_table()
	local SQL = get_sql("setup_warnings_table")
	if not SQL then return end

	local auto_increment = SQL.IsMySQL() and "AUTO_INCREMENT" or "AUTOINCREMENT"

	SQL.FQuery([[
		CREATE TABLE IF NOT EXISTS `sam_warnings`(
			`id` INTEGER PRIMARY KEY {1f},
			`steam_id` VARCHAR(32),
			`admin_steam_id` VARCHAR(32),
			`reason` TEXT,
			`timestamp` INT UNSIGNED,
			`expired` TINYINT(1) DEFAULT 0
		)
	]], {auto_increment})

	if not SQL.IsMySQL() then
		SQL.Query("CREATE INDEX IF NOT EXISTS `sam_warnings_steam_expired_idx` ON `sam_warnings`(`steam_id`, `expired`)")
		SQL.Query("CREATE INDEX IF NOT EXISTS `sam_warnings_timestamp_idx` ON `sam_warnings`(`timestamp`)")
	end
end

hook.Add("SAM.DatabaseLoaded", "SAM.Warnings.Setup", setup_warnings_table)

local SQL = get_sql("module_init")
if SQL and SQL.IsConnected and SQL.IsConnected() then
	setup_warnings_table()
end

local function expire_outdated_warnings(callback)
	local SQL = get_sql("expire_outdated_warnings")
	if not SQL then
		if callback then callback() end
		return
	end

	SQL.FQuery([[
		UPDATE
			`sam_warnings`
		SET
			`expired` = 1
		WHERE
			`expired` = 0 AND
			`timestamp` + {1} <= {2}
	]], {WARNING_SETTINGS.expire_time, os.time()}, callback)
end

local function get_active_warnings_count(steam_id, callback)
	if not get_sql("get_active_warnings_count") then
		return callback(0)
	end

	expire_outdated_warnings(function()
		local SQL = get_sql("get_active_warnings_count.query")
		if not SQL then
			return callback(0)
		end

		SQL.FQuery([[
			SELECT
				COUNT(*) AS `count`
			FROM
				`sam_warnings`
			WHERE
				`steam_id` = {1} AND
				`expired` = 0 AND
				`timestamp` + {2} > {3}
		]], {steam_id, WARNING_SETTINGS.expire_time, os.time()}, function(data)
			callback(tonumber(data and data.count) or 0)
		end, true)
	end)
end

local function get_warnings(steam_id, limit, callback)
	if not get_sql("get_warnings") then
		return callback({})
	end

	limit = math.Clamp(tonumber(limit) or WARNING_SETTINGS.default_list_limit, 1, WARNING_SETTINGS.max_list_limit)

	expire_outdated_warnings(function()
		local SQL = get_sql("get_warnings.query")
		if not SQL then
			return callback({})
		end

		SQL.FQuery([[
			SELECT
				`id`,
				`admin_steam_id`,
				`reason`,
				`timestamp`
			FROM
				`sam_warnings`
			WHERE
				`steam_id` = {1} AND
				`expired` = 0 AND
				`timestamp` + {2} > {3}
			ORDER BY
				`id` DESC
			LIMIT
				{4}
		]], {steam_id, WARNING_SETTINGS.expire_time, os.time(), limit}, function(data)
			callback(data or {})
		end)
	end)
end

local function expire_warning_by_id(steam_id, warning_id, callback)
	local SQL = get_sql("expire_warning_by_id")
	if not SQL then
		return callback(false)
	end

	SQL.FQuery([[
		SELECT
			`id`
		FROM
			`sam_warnings`
		WHERE
			`id` = {1} AND
			`steam_id` = {2} AND
			`expired` = 0 AND
			`timestamp` + {3} > {4}
	]], {warning_id, steam_id, WARNING_SETTINGS.expire_time, os.time()}, function(found)
		if not found then
			return callback(false)
		end

		local SQL = get_sql("expire_warning_by_id.update")
		if not SQL then
			return callback(false)
		end

		SQL.FQuery([[
			UPDATE
				`sam_warnings`
			SET
				`expired` = 1
			WHERE
				`id` = {1} AND
				`steam_id` = {2} AND
				`expired` = 0
		]], {warning_id, steam_id}, function()
			callback(true, warning_id)
		end)
	end, true)
end

local function expire_last_warning(steam_id, callback)
	local SQL = get_sql("expire_last_warning")
	if not SQL then
		return callback(false)
	end

	SQL.FQuery([[
		SELECT
			`id`
		FROM
			`sam_warnings`
		WHERE
			`steam_id` = {1} AND
			`expired` = 0 AND
			`timestamp` + {2} > {3}
		ORDER BY
			`id` DESC
		LIMIT
			1
	]], {steam_id, WARNING_SETTINGS.expire_time, os.time()}, function(last_warning)
		if not last_warning then
			return callback(false)
		end

		local SQL = get_sql("expire_last_warning.update")
		if not SQL then
			return callback(false)
		end

		SQL.FQuery([[
			UPDATE
				`sam_warnings`
			SET
				`expired` = 1
			WHERE
				`id` = {1} AND
				`expired` = 0
		]], {tonumber(last_warning.id)}, function()
			callback(true, tonumber(last_warning.id))
		end)
	end, true)
end

do
	command.new("warn")
		:SetPermission("warn", "admin")
		:SetCategory("Punishment")
		:Help("Выдать предупреждение игроку")
		:AddArg("player", {single_target = true})
		:AddArg("text", {hint = "reason", optional = true, default = DEFAULT_REASON})
		:GetRestArgs()
		:OnExecute(function(ply, targets, reason)
			local target = targets[1]
			if not IsValid(target) then return end

			reason = sam.isstring(reason) and reason:Trim() or ""
			if reason == "" then
				reason = DEFAULT_REASON
			end

			local steam_id = target:SteamID64()
			local admin_steam_id = IsValid(ply) and ply:SteamID64() or "Console"
			local SQL = get_sql("command.warn")
			if not SQL then
				print("[SAM Warnings] warn command aborted: SQL is not ready")
				return
			end

			SQL.FQuery([[
				INSERT INTO
					`sam_warnings`(`steam_id`, `admin_steam_id`, `reason`, `timestamp`, `expired`)
				VALUES
					({1}, {2}, {3}, {4}, 0)
			]], {steam_id, admin_steam_id, reason, os.time()}, function()
				get_active_warnings_count(steam_id, function(warnings_count)
					sam.player.send_message(nil, "warn", {
						A = ply,
						T = target:Name(),
						V = warnings_count,
						V_2 = WARNING_SETTINGS.max_warnings,
						V_3 = reason
					})

					local punishment = WARNING_SETTINGS.punishments[warnings_count]
					if punishment and IsValid(target) then
						punishment(target, ply, reason)
					end
				end)
			end)
		end)
	:End()

	command.new("unwarn")
		:SetPermission("unwarn", "admin")
		:SetCategory("Punishment")
		:Help("Снять предупреждение с игрока")
		:AddArg("player", {single_target = true})
		:AddArg("number", {hint = "warn_id", optional = true})
		:OnExecute(function(ply, targets, warning_id)
			local target = targets[1]
			if not IsValid(target) then return end

			local steam_id = target:SteamID64()

			if warning_id then
				warning_id = math.floor(tonumber(warning_id) or 0)
				if warning_id <= 0 then
					return ply:sam_send_message("warning_not_found")
				end

				expire_warning_by_id(steam_id, warning_id, function(success)
					if not success then
						return ply:sam_send_message("warning_not_found")
					end

					sam.player.send_message(nil, "unwarn_id", {
						A = ply,
						T = target:Name(),
						V = warning_id
					})
				end)
				return
			end

			expire_last_warning(steam_id, function(success)
				if not success then
					return ply:sam_send_message("no_active_warnings", {
						T = target:Name()
					})
				end

				sam.player.send_message(nil, "unwarn", {
					A = ply,
					T = target:Name()
				})
			end)
		end)
	:End()

	command.new("warnings")
		:SetPermission("warnings", "admin")
		:SetCategory("Punishment")
		:Help("Просмотр предупреждений игрока")
		:AddArg("player", {single_target = true})
		:AddArg("number", {hint = "limit", optional = true, default = WARNING_SETTINGS.default_list_limit})
		:OnExecute(function(ply, targets, limit)
			local target = targets[1]
			if not IsValid(target) then return end

			local steam_id = target:SteamID64()

			get_warnings(steam_id, limit, function(warnings)
				if #warnings == 0 then
					return ply:sam_send_message("no_active_warnings", {
						T = target:Name()
					})
				end

				ply:sam_send_message("warnings_list", {
					T = target:Name()
				})

				for i = 1, #warnings do
					local warning = warnings[i]
					local admin = player.GetBySteamID64(warning.admin_steam_id)
					local admin_name = IsValid(admin) and admin:Name() or warning.admin_steam_id or "Неизвестный админ"
					local date = os.date("%d/%m/%Y %H:%M", tonumber(warning.timestamp) or os.time())

					ply:sam_send_message("warning_entry", {
						V = warning.id,
						V_2 = date,
						V_3 = admin_name,
						V_4 = warning.reason or DEFAULT_REASON
					})
				end
			end)
		end)
	:End()

	command.new("warningsid")
		:SetPermission("warningsid", "admin")
		:SetCategory("Punishment")
		:Help("Просмотр предупреждений игрока по SteamID")
		:AddArg("steamid")
		:AddArg("number", {hint = "limit", optional = true, default = WARNING_SETTINGS.default_list_limit})
		:OnExecute(function(ply, promise, limit)
			promise:done(function(data)
				local steamid, target = data[1], data[2]
				local steam_id = util.SteamIDTo64(steamid)

				get_warnings(steam_id, limit, function(warnings)
					local name = IsValid(target) and target:Name() or steamid
					if #warnings == 0 then
						return ply:sam_send_message("no_active_warnings", {
							T = name
						})
					end

					ply:sam_send_message("warnings_list", {
						T = name
					})

					for i = 1, #warnings do
						local warning = warnings[i]
						local admin = player.GetBySteamID64(warning.admin_steam_id)
						local admin_name = IsValid(admin) and admin:Name() or warning.admin_steam_id or "Неизвестный админ"
						local date = os.date("%d/%m/%Y %H:%M", tonumber(warning.timestamp) or os.time())

						ply:sam_send_message("warning_entry", {
							V = warning.id,
							V_2 = date,
							V_3 = admin_name,
							V_4 = warning.reason or DEFAULT_REASON
						})
					end
				end)
			end)
		end)
	:End()

	command.new("warnid")
		:SetPermission("warnid", "admin")
		:SetCategory("Punishment")
		:Help("Выдать предупреждение игроку по SteamID")
		:AddArg("steamid")
		:AddArg("text", {hint = "reason", optional = true, default = DEFAULT_REASON})
		:GetRestArgs()
		:OnExecute(function(ply, promise, reason)
			reason = sam.isstring(reason) and reason:Trim() or ""
			if reason == "" then
				reason = DEFAULT_REASON
			end

			local admin_steam_id = IsValid(ply) and ply:SteamID64() or "Console"
			local SQL = get_sql("command.warnid")
			if not SQL then
				print("[SAM Warnings] warnid command aborted: SQL is not ready")
				return
			end

			promise:done(function(data)
				local steamid, target = data[1], data[2]
				local steam_id = util.SteamIDTo64(steamid)

				SQL.FQuery([[
					INSERT INTO
						`sam_warnings`(`steam_id`, `admin_steam_id`, `reason`, `timestamp`, `expired`)
					VALUES
						({1}, {2}, {3}, {4}, 0)
				]], {steam_id, admin_steam_id, reason, os.time()}, function()
					get_active_warnings_count(steam_id, function(warnings_count)
						local target_name = IsValid(target) and target:Name() or steamid

						sam.player.send_message(nil, "warn", {
							A = ply,
							T = target_name,
							V = warnings_count,
							V_2 = WARNING_SETTINGS.max_warnings,
							V_3 = reason
						})

						if IsValid(target) then
							local punishment = WARNING_SETTINGS.punishments[warnings_count]
							if punishment then
								punishment(target)
							end
						end
					end)
				end)
			end)
		end)
	:End()
end

timer.Create("SAM.WarningsCleanup", 3600, 0, function()
	expire_outdated_warnings()
end)

sam.permissions.add("warn", nil, "admin")
sam.permissions.add("unwarn", nil, "admin")
sam.permissions.add("warnings", nil, "admin")
sam.permissions.add("warningsid", nil, "admin")
sam.permissions.add("warnid", nil, "admin")

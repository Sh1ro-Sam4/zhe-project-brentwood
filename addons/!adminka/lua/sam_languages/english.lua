return {
	You = "Ты",
	Yourself = "Сам себя",
	Themself = "Себя",
	Everyone = "Все(м)",

	cant_use_as_console = "Вы должны быть админом, чтобы использовать команду {S Red}!",
	no_permission = "У вас нет разрешения на использование {S Red}!",

	cant_target_multi_players = "Вы не можете использовать эту команду для нескольких игроков!",
	invalid_id = "Неверный идентификатор ({S Red})!",
	cant_target_player = "Вы не можете нацеливаться на {S Red}!",
	cant_target_self = "Вы не можете выбрать себя с помощью команды {S Red}!",
	player_id_not_found = "Игрок с id {S Red} не найден!",
	found_multi_players = "Найдено несколько игроков: {T}!",
	cant_find_target = "Не удается найти игрока для цели ({S Red})!",

	invalid = "Недействительный {S} ({S_2 Красный})",
	default_reason = "ничего",

	menu_help = "Откройте меню мода администратора.",

	-- Chat Commands
	pm_to = "PM кому {T}: {V}",
	pm_from = "PM от кого {A}: {V}",
	pm_help = "Отправить личное сообщение (PM) игроку.",

	to_admins = "{A} администраторам: {V}",
	asay_help = "Отправить сообщение администраторам.",

	mute = "{A} отключил чат {T} для {V}. ({V_2})",
	mute_help = "Запретить игрокам отправлять сообщения в чат.",

	unmute = "{A} размьютил {T}.",
	unmute_help = "Размьютить игрока(ов).",

	you_muted = "Ты замучен.",

	gag = "{A} замутил войс {T} за {V}. ({V_2})",
	gag_help = "Запретить игроку(ам) говорить.",

	ungag = "{A} размутил войс {T}.",
	ungag_help = "Размутить войс игроку(ам).",

	-- Fun Commands
	slap = "{A} ударил {T}.",
	slap_damage = "{A} ударил {T} с {V} уроном.",
	slap_help = "Slap asses.",

	slay = "{A} убил {T}.",
	slay_help = "Убить игрока(ов).",

	set_hp = "{A} установил hp для {T} на {V}.",
	hp_help = "Установить здоровье для игрока(ов).",

	set_armor = "{A} установил броню для {T} на {V}.",
	armor_help = "Установить броню для игрока(ов).",

	ignite = "{A} зажег {T} для {V}.",
	ignite_help = "Поджечь игрока(ов).",

	unignite = "{A} погашен {T}.",
	unignite_help = "Погасить игрока(ов).",

	god = "{A} включил режим бога для {T}.",
	god_help = "Включить режим бога для игрока(ов).",

	ungod = "{A} отключил режим бога для {T}.",
	ungod_help = "Отключить режим бога для игрока(ов).",

	freeze = "{A} заморозил {T}.",
	freeze_help = "Заморозить игрока(ов).",

	unfreeze = "{A} разморозил {T}.",
	unfreeze_help = "Разморозить игрока(ов).",

	cloak = "{A} скрыл {T}.",
	cloak_help = "Скрыть игрока(ов).",

	uncloak = "{A} раскрыл {T}.",
	uncloak_help = "Раскрыть игрока(ов).",

	jail = "{A} посадил в джайл {T} за {V}. ({V_2})",
	jail_help = "Посадить в джайл игрока(ов).",

	unjail = "{A} разджайлил {T}.",
	unjail_help = "Разджайлить игрока(ов).",

	strip = "{A} забрал оружие с {T}.",
	strip_help = "Забрать оружия игрока(ов).",

	respawn = "{A} возродил {T}.",
	respawn_help = "Возродить игроков",
	
	setmodel = "{A} установить модель для {T} на {V}.",
	setmodel_help = "Изменить модель игрока(ов).",
	
	giveammo = "{A} дал {T} {V} боеприпасов.",
	giveammo_help = "Дайте игроку(ам) патроны.",
	
	scale = "{A} установить масштаб модели для {T} на {V}.",
	scale_help = "Масштабировать игроков",
	
	freezeprops = "{A} заморозил все реквизиты.",
	freezeprops_help = "Замораживает все предметы на карте.",

	-- Teleport Commands
	dead = "Ты мёртвый!",
	leave_car = "Выйди из машины!",

	bring = "{A} телепортировал {T}.",
	bring_help = "Телепортировать игрока.",

	admroom = "{A} телепортировался в админ зону.",
	admroom_help = "Телепортироватся в админ зону.",

	goto = "{A} телепортировался к {T}.",
	goto_help = "Телепортироватся к игроку.",

	no_location = "Нет предыдущего места, куда можно было бы вернуть {T}.",
	returned = "{A} вернул {T}.",
	return_help = "Вернуть игрока туда, где он был.",

	-- User Management Commands
	setrank = "{A} установить ранг для {T} на {V} для {V_2}.",
	setrank_help = "Установить ранг игрока.",
	setrankid_help = "Установить ранг игрока по его steamid/steamid64.",
	
	addrank = "{A} создал новый ранг {V}.",
	addrank_help = "Создать новый ранг.",
	
	removerank = "{A} удален ранг {V}.",
	removerank_help = "Удалить звание.",
	
	super_admin_access = "superadmin имеет доступ ко всему!",
	
	giveaccess = "{A} предоставил доступ {V} к {T}.",
	givepermission_help = "Дайте разрешение на ранжирование.",
	
	takeaccess = "{A} забрал доступ {V} от {T}.",
	takepermission_help = "Получить разрешение от ранга.",
	
	renamerank = "{A} переименовал ранг {T} в {V}.",
	renamerank_help = "Переименовать ранг.",
	
	changeinherit = "{A} изменил ранг для наследования с {T} на {V}.",
	changeinherit_help = "Изменить ранг для наследования.",
	
	rank_immunity = "{A} изменил иммунитет ранга {T} на {V}.",
	changerankimmunity_help = "Изменить иммунитет к рангу.",
	
	rank_ban_limit = "{A} изменил лимит бана ранга {T} на {V}.",
	changerankbanlimit_help = "Изменить лимит бана по рангу.",
	
	changeranklimit = "{A} изменил лимит {V} для {T} на {V_2}.",
	changeranklimit_help = "Изменить лимит рангов.",

	-- Utility Commands
	map_change = "{A} changing the map to {V} in 10 seconds.",
	map_change2 = "{A} changing the map to {V} with gamemode {V_2} in 10 seconds.",
	map_help = "Change current map and gamemode.",

	map_restart = "{A} restarting the map in 10 seconds.",
	map_restart_help = "Restart current map.",

	mapreset = "{A} reset the map.",
	mapreset_help = "Reset the map.",

	kick = "{A} кикнул {T} Причина: {V}.",
	kick_help = "Кикнуть игрока.",
	
	ban = "{A} забанил {T} на {V} ({V_2}).",
	ban_help = "Забанить игрока.",
	
	banid = "{A} забанил ${T} на {V} ({V_2}).",
	banid_help = "Забанить игрока, использующего его steamid.",

	-- ban message when admin name doesn't exists
	ban_message = [[


		Ты был забанен: {S}

		Причина: {S_2}

		Вас разбанят в: {S_3}
		
		Дискорд: https://discord.gg/Ujx85Q9U5A]],

	-- ban message when admin name exists
	ban_message_2 = [[


		Ты забанен: {S} ({S_2})

		Причина: {S_3}

		Вас разбанят в: {S_4}
		
		Дискорд: https://discord.gg/Ujx85Q9U5A]],

	unban = "{A} разбанил {T}.",
	unban_help = "Разбанить игрока по его steamid.",

	adminmode = "{A} включил админ мод.",

	noclip = "{A} переключил noclip для {T}.",
	noclip_help = "Переключить noclip на игрока(ов).",

	cleardecals = "{A} очищены от тряпичных кукол и декалей для всех игроков.",
	cleardecals_help = "Очистить тряпичные куклы и декали для всех игроков.",
	
	stopsound = "{A} остановил все звуки.",
	stopsound_help = "Остановить все звуки для всех игроков.",
	
	not_in_vehicle = "Вы не в машине!",
	not_in_vehicle2 = "{S Blue} не находится в транспортном средстве!",
	exit_vehicle = "{A} заставил {T} выйти из машины.",
	exit_vehicle_help = "Вытолкните игрока из машины.",
	
	time_your = "Ваше общее время составляет {V}.",
	time_player = "{T} общее время составляет {V}.",
	time_help = "Проверить время игрока.",
	
	admin_help = "Активировать режим администратора.",
	unadmin_help = "Деактивировать режим администратора.",
	
	buddha = "{A} контролируемый режим Будды для {T}.",
	buddha_help = "Сделать игроком (игроков) богодмодом, когда их здоровье равно 1.",
	
	unbuddha = "{A} отключил режим Будды для {T}.",
	unbuddha_help = "Отключить режим Будды для игрока(ов).",
	
	give = "{A} выдал {T} {V}.",
	give_help = "Дайте игроку(ам) оружие/энтити",

	-- DarkRP Commands
	arrest = "{A} арестован {T} навсегда.",
	arrest2 = "{A} арестован {T} на {V} секунд.",
	arrest_help = "Арестовать игрока(ов).",
	
	unarrest = "{A} снял арест {T}.",
	unarrest_help = "Снять арест с игрока(ов).",
	
	forcename = "{A} установить имя для {T} на {V}.",
	forcename_taken = "Имя уже занято. ({V})",
	forcename_help = "Принудительное имя для игрока.",
	
	report_claimed = "{A} запросил отчет, отправленный {T}.",
	report_closed = "{A} закрыл отчет, отправленный пользователем {T}.",
	report_acclosed = "Ваш отчет закрыт. (Время истекло)",
	
	rank_expired = "{V} ранг для {T} истек.",
}
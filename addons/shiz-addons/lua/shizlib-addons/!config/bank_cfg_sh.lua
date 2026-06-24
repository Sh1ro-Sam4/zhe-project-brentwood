
//Bank robbery system made by Threebow, originally made for NoPixelGaming. 76561198092742034
AddCSLuaFile()
BANK_CONFIG = BANK_CONFIG or {}
local cfg = BANK_CONFIG

--[[
	MODELS AND SOUNDS
]]
//Model of the entity.
cfg.Model = "models/props/cs_assault/MoneyPallet03A.mdl" --models/props/cs_assault/MoneyPallet03A.mdl --debug

//Model of the bag that is spawned when a person hits +USE on the entity.
cfg.BagModel = "models/props_c17/BriefCase001a.mdl"

//Sound that plays on money pickup
cfg.PickupSound = "physics/body/body_medium_impact_soft6.wav"

//Message the player sees when they try to rob the bank and it has no money
cfg.EmptyMessage = "В банке не осталось денег!"



--[[
	TEXT AND BAR
]]
//Message displayed above bank units, substitute "%s" for amount of money in the bank, then %s for the maximum amount of money.
cfg.BankString = "Бюджет: %s/%s"

//Color of the bank text string above
cfg.BankStringColor = Color(255, 255, 255)

//Font size of the bank text string above
cfg.BankStringSize = 120

//Message displayed above the bag, substitute %i for distance in meters
cfg.BagString = "Отнесите на %iм"

//Color of the bag text string above
cfg.BagStringColor = Color(255, 255, 255)

//Font size of the bag text string above
cfg.BagStringSize = 60

//Color of the bar under the holding text, displays visually how much is in the bank
cfg.BarColor = Color(255, 255, 255, 255)

//Color of the progress bar that shows the cooldown between next money generation
cfg.ProgressColor = Color(100, 100, 100, 255)



--[[
	MONEY AND BAGS
]]
//Should we spawn in money bags when the player attempts to rob? If this is false, money is given directly to the player when they +USE the money entity.
cfg.UseBags = true

//Maximum amount of money each unit can hold
cfg.Max = 10000000

//Amount in seconds before new money is generated
cfg.Delay = 40

//Amount of money that gets generated every X seconds (specified in delay)
cfg.AmountGenerated = 1250

//Amount that is put into each bag or taken each time someone hits +USE on the entity.
cfg.Amount = 200

//Amount of money the bank spawns in with.
cfg.StartingAmount = 40000 --debug

//Delay between picking up money
cfg.PickupDelay = 4

//Distance in meters the player should take the bag away from the bank before it despawns and money is given.
cfg.Distance = 20

//Notification shown to the player when they withdraw a bag. Substitute %s for amount of money in the bag.
cfg.RobNotification = "Вы Украли $%i. Подождите 30 секунд!"

//Notification shown to the player when they actually cash a bag out. Substitute %s for amount of money they earned.
cfg.WithdrawNotification = "Вы украли $%s"



--[[
	WANTED AND POLICE
]]
//Should we make the player wanted when they take money?
cfg.WantOnRobbery = true

//Reason for wanting the player on robbery, only if above setting is enabled
cfg.WantedReason = "Ограбление банка"

//How many cop jobs should be online for people to be able to rob? Set to 0 to disable
cfg.MinCopJobs = 3

//These are the jobs that follow the above rule. Use job names as strings, not TEAM_ variables. These jobs are also unable to rob the bank.
cfg.CopJobs = {
	["Полиция"] = true,
	["Офицер Полиции"] = true,
	["Спецназ"] = true,
	["Агент FBI"] = true,
	["Начальник полиции"] = true,
	["Командир спецназа"] = true,
	["Медик спецназа"] = true,
	["Банкир"] = true,
	["Снайпер спецназа"] = true,
	["Поддержка спецназа"] = true,
	["Джаггернаут"] = true,	
}

//These are jobs which are exclusively allowed to rob the bank. If you make this empty, everyone will be able to rob except for CopJobs listed above.
cfg.AllowedJobs = {
	["Гражданский"] = true,
}

//Notification sent to police when someone is robbing the bank. Substitute %s for their name.
cfg.PoliceRobNotification = "[ВСЕМ ПОСТАМ] %s грабит банк, срочно проследуйте в отделение банка!"

//Message displayed above bank units when there are not enough cops online to rob the bank. Substitute "i%" for amount of cops online, then MinCopJobs above.
cfg.CannotRobCopString = "Вы не можете начать ограбление!Копы %i/%i."

//Message displayed when you are a cop and you cannot rob the bank, substitute %s for the job name
cfg.CannotRobAsCopString = "Вам нельзя грабить банк!"

//Should we use the alarm?
cfg.UseAlarm = true

//Sound that plays when the bank is robbed.
cfg.AlarmSound = "ambient/alarms/alarm_citizen_loop1.wav"



--[[
	COOLDOWN
]]
//Should we use a global cooldown?
cfg.UseCooldowns = true

//Time in seconds to cooldown after banks have been fully depleted, before people can rob again
cfg.CooldownTime = 1800 --debug

//Message to show when the bank is on cooldown, substitute %i for the time in seconds before it can be robbed again
cfg.CooldownString = "Интервал ограбления %iс"



--[[
	SPAWNING
]]
//Locations the money will spawn at, when the map is initially loaded.
--1 serv
cfg.Locations = {
	{
		pos = Vector(Vector(127.08326721191, -1093.0241699219, -287.96875)),
		ang = Angle(0.000, -136.318, 0.000)
	},
}
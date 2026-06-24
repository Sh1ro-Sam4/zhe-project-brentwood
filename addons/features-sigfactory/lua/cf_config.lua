cf = {}

-- CONFIG --

-- Sell Mode | Setting it to false allows selling cigarettes without bringing them to the export van.
-- Note that if you're using default sell mode you need to save spawned vans using cf_save command! Otherwise vans will disappear after server restart.
cf.InstantSellMode = false
-- Maximum amount of tobacco machine can contain.
cf.maxTobaccoStorage = 3000

-- Maximum default paper storage.
cf.maxPaperStorage = 300

-- Time (in seconds) it takes to produce one pack.
cf.timeToProduce = 10

-- Amount of paper it takes to produce one pack.
cf.paperProductionCost = 2

-- Amount of tobacco it takes to produce one pack.
cf.tobaccoProductionCost = 20

-- Time (in seconds) it takes for a cigarette pack to despawn (reduces lag).
cf.cigAutoDespawnTime = 480

-- Engine performance multiplier after engine upgrade (1.5 makes it 50% more efficient).
cf.engineUpgradeBoost = 1.5

-- Amount of additional storage after storage upgrade.
cf.storageUpgradeBoostTobacco = 2000 
cf.storageUpgradeBoostPaper = 200

-- Base amount of $ you'll get for one pack sold.
cf.sellPrice = 2

-- How often should the price change (in seconds). 
cf.priceChangeTime = 60

-- Maximum difference in pack price.
cf.maxPriceDifference = 3

-- Max amount of packs that can fit into an export box.
cf.maxCigsBox = 128

-- Max amount of packs player can carry.
cf.maxCigsOnPlayer = 512

-- Machine maximum health
cf.maxMachineHealth = 300

-- Machine hp regen rate 
cf.machineRegen = 4

-- Cigarette SWEP 
cf.allowSwep = true

-- Translation
cf.StorageText = "ЁМКОСТЬ"
cf.StorageDescText = "Улучшение ёмкости для AUTO-CIG"
cf.ProductionOffText = "ВЫКЛЮЧЕНО"
cf.ProducingText = "РАБОТАЕТ"
cf.RefillNeededText = "ПУСТО"
cf.EngineText = "СКОРОСТЬ"
cf.EngineDescText = "Улучшение скорости для AUTO-CIG"
cf.BoxText = "КОРОБКА ДЛЯ СИГАРЕТ"
cf.BoxDescText1 = "Коробка сделана для"
cf.BoxDescText2 = "экспорта сигарет."
cf.BoxDescText3 = "Всего сигарет: "
cf.BoxDescText4 = "Сумма: "
cf.CurrencyText = "$"
cf.Notification1 = "Вы не можете нести больше чем "
cf.Notification2 = " сигарет!"
cf.Notification3 = "Вы подняли коробку содержащую "
cf.Notification4 = " пачек сигарет!"
cf.MachineHealth = "HP"
cf.VanText = "ФУРГОН ДЛЯ ЭСКПОРТА"
cf.VanDescText1 = "Платит "
cf.VanDescText2 = " за одну пачку сигарет!"
cf.SellText1 = "Вы продали "
cf.SellText2 = " пачек сигарет за "
cf.CommandText1 = "Export vans have been saved"
cf.CommandText2 = "Export vans have been loaded"

-- Fonts
if CLIENT then
	surface.CreateFont( "cf_machine_main", {
		font = "Impact",    
		size = 24
	})
	surface.CreateFont( "cf_machine_small", {
		font = "Impact",    
		size = 16,
		outline = true
	})
end

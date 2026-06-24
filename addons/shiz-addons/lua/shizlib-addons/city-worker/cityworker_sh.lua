CITYWORKER = CITYWORKER or {}

CITYWORKER.Config = CITYWORKER.Config or {}

-- How often should we check (in seconds) for City Workers with no assigned jobs, so we can give them?
CITYWORKER.Config.Time = 20

------------
-- RUBBLE --
------------

CITYWORKER.Config.Rubble = {}

-- Whether or not rubble is enabled or disabled.
CITYWORKER.Config.Rubble.Enabled = true

-- Rubble models and the range of time (in seconds) it takes to clear them.
CITYWORKER.Config.Rubble.Models = {
    ["models/props_debris/concrete_debris128pile001a.mdl"] = { min = 8, max = 15 },
    ["models/props_debris/concrete_debris128pile001b.mdl"] = { min = 8, max = 15 },
    ["models/props_debris/concrete_floorpile01a.mdl"] = { min = 8, max = 15 },
    ["models/props_debris/concrete_cornerpile01a.mdl"] = { min = 8, max = 15 },
    ["models/props_debris/concrete_spawnplug001a.mdl"] = { min = 8, max = 15 },
    ["models/props_debris/plaster_ceilingpile001a.mdl"] = { min = 8, max = 15 },
}

-- Payout per second it takes to clear a given pile of rubble.
-- (i.e. 10 seconds = 10 * 30 = 300)
CITYWORKER.Config.Rubble.Payout = 300

-------------------
-- FIRE HYDRANTS --
-------------------

CITYWORKER.Config.FireHydrant = {}

-- Whether or not fire hydrants are enabled or disabled.
CITYWORKER.Config.FireHydrant.Enabled = true

-- The range for how long it takes to fix a fire hydrant.
-- Maximum value: 255 seconds.
CITYWORKER.Config.FireHydrant.Time = { min = 8, max = 15 }

-- Payout per second it takes to fix a fire hydrant.
CITYWORKER.Config.FireHydrant.Payout = 300

-----------
-- LEAKS --
-----------

CITYWORKER.Config.Leak = CITYWORKER.Config.Leak or {}

-- Whether or not leaks are enabled or disabled.
CITYWORKER.Config.Leak.Enabled = true

-- The range for how long it takes to fix a leak.
-- Maximum value: 255 seconds.
CITYWORKER.Config.Leak.Time = { min = 8, max = 15 }

-- Payout per second it takes to fix a leak.
CITYWORKER.Config.Leak.Payout = 300

--------------
-- ELECTRIC --
--------------

CITYWORKER.Config.Electric = CITYWORKER.Config.Electric or {}

-- Whether or not electrical problems are enabled or disabled.
CITYWORKER.Config.Electric.Enabled = true

-- The range for how long it takes to fix an electrical problem.
-- Maximum value: 255 seconds.
CITYWORKER.Config.Electric.Time = { min = 8, max = 15 }

-- Payout per second it takes to fix an electrical problem.
CITYWORKER.Config.Electric.Payout = 300

----------------------------
-- LANGUAGE CONFIGURATION --
----------------------------

CITYWORKER.Config.Language = {
    ["FireHydrant"]         = "Идет ремонт пожарного гидранта...",
    ["Leak"]                = "Идет устранение утечки...",
    ["Electric"]            = "Ремонт электричества",
    ["Rubble"]              = "Расчистка в процессе",
    ["CANCEL"]              = "'F2' Чтобы отменить действие.",
    ["PAYOUT"]              = "Государство выплатило вам %s за починку!",
    ["CANCELLED"]           = "Вы отменили своё действие!",
    ["NEW_JOB"]             = "Для вас нашлась новая работёнка!",
    ["NOT_CITY_WORKER"]     = "Вы не муниципальный служащий!",
    ["JOB_WORKED"]          = "На этой точке уже чинят!",
    ["ASSIGNED_ELSE"]       = "Эта работа поручена кому-то другому!",
}
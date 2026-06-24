CFG = CFG or {}
p(1)
CFG.useDist = 84
CFG.useDistSqr = CFG.useDist * CFG.useDist

CFG.isAdmin = {
    ['superadmin'] = true,
    ['root'] = true,
}

CFG.isSuperAdmin = {
    ['superadmin'] = true,
    ['root'] = true,
}

CFG.nova_defender = {
    ['superadmin'] = true,
    ['root'] = true,
    ['curator'] = true,
    ['senior-admin'] = true,
}

CFG.perfect_user = {
    [""] = "xyu"
}

CFG.spawnMenuBuy = {
    ["76561199027695034"] = true, -- Heisenberg (ПОКУПНОЕ)
    ["76561198991896997"] = true, -- OGUZOK (ПОКУПНОЕ)
    ["76561199759778160"] = true, -- m1dback (ПОКУПНОЕ)

    ["76561198020810541"] = true, -- welovekiss CURATOR
    ["76561199082487641"] = true, -- VLADIC MINI GAMES
}

CFG.theme = {
    bg = Color(22, 22, 22),
    bg_alt = Color(40, 40, 40),

    red = Color(222,91,73, 255),

    accent = Color(255,77,119),
    focus = Color(245, 245, 245, 25),

    black = Color(12, 12, 12),
    black2 = Color(24, 24, 24),
    black3 = Color(30, 30, 30),
    black4 = Color(17, 17, 17, 200),
    white = Color(230, 230, 230),
    hvr = Color(22, 22, 22, 100),
}

CFG.skinSound = {
    press = 'ui/buttonclick.wav',
    hover = 'ui/buttonrollover.wav',
    scrollWheeled = 'ui/buttonrollover.wav',
}

CFG.limitEntity = {
    ['shizlib_bench_workbench'] = 2,

    ['rp_money_printer'] = 2,
    ['rp_money_printer_pro'] = 2,
    
    ['eml_gas'] = 3,
    ['eml_stove'] = 3,
    ['eml_spot'] = 4,
    ['eml_redp'] = 5,
    ['eml_jar'] = 2,
    ['eml_macid'] = 5,
    ['eml_iodine'] = 5,
    ['eml_water'] = 5,

    ['cf_cigarette_machine'] = 1,
    ['cf_engine_upgrade'] = 1,
    ['cf_storage_upgrade'] = 1,
    ['cf_delievery_box'] = 2,
    ['cf_roll_paper'] = 2,
    ['cf_tobacco_pack'] = 2,
}

CFG.lootingItemsNPCMetal = {
    'steel',
    'aluminum',
    'copper',
    'lead',
    'gold',
    'silver',
    'glass',
    'pipe',
    'wire',
    'screws',
    'spring',
}

CFG.lootingItemsNPC = {
    'bone',
    'flesh',
    'blood',
    'cloth',
}

CFG.lootingItemsRock = {
    "stone",
    "coal",
    "quartz",
    "iron",
    "steel",
    "aluminum",
    "copper",
    "lead",
    "gold",
    "silver",
}

CFG.lootingItemsTrashcan = {
    'steel',
    'aluminum',
    'copper',
    'iron',
    'lead',
    'gold',
    'silver',
    'glass',
    'tape',
    'glue',
    'cloth',
    'wire',
    'battery',
    'battery_c',
    'motherboard',
    'cpu',
    'pipe',
    'piston',
    'rifle_barrel',
    'rifle_body',
    'rifle_butt',
    'rifle_clip',
    'screws',
    'spring',
    'tools',
    'wood',
    'stone',
}

CFG.icon17 = {
    ["tfa_cso2_rpg7"] = "bomb",
    ["tfa_cso2_m79"] = "bomb",

    ["arc9_uplp_minigun"] = "machine_gun",
    ["arc9_uplp_molot"] = "shotgun",

    ["weapon_glock17"] = "pistolet",
    ["weapon_glock26"] = "pistolet",
    ["weapon_fn45"] = "pistolet",
    ["weapon_cz75"] = "pistolet",
    ["weapon_m1911"] = "pistolet",
    ["weapon_m45"] = "pistolet",
    ["weapon_m9beretta"] = "pistolet",
    ["weapon_hk_usp"] = "pistolet",
    ["weapon_px4beretta"] = "pistolet",
    ["weapon_p22"] = "pistolet",
    ["weapon_tec9"] = "pistolet",
    ["weapon_deagle"] = "pistolet",
    ["weapon_revolver357"] = "revolver",
    ["weapon_ar_pistol"] = "assault_rifle",
    ["weapon_draco"] = "assault_rifle",
    ["weapon_vpo209"] = "assault_rifle",
    ["weapon_ar15"] = "assault_rifle",
    ["weapon_mini14"] = "assault_rifle",
    ["weapon_kar98"] = "sniper_rifle",
    ["weapon_sks"] = "sniper_rifle",
    ["weapon_remington870"] = "shotgun",
    ["weapon_m590a1"] = "shotgun",
    ["weapon_doublebarrel"] = "shotgun",
    ["weapon_doublebarrel_short"] = "shotgun",
    ["weapon_xm1014"] = "shotgun",
    ["weapon_toz106"] = 'shotgun',
    ["weapon_revolver2"] = 'revolver',

    -- Новое автоматическое оружие
    ["weapon_m16a2"] = "assault_rifle",
    ["weapon_mp5"] = "assault_rifle",
    ["weapon_mp7"] = "assault_rifle",
    ["weapon_skorpion"] = "pistolet",
}

CFG.clientTableRanks = {
    ["founder"] = {
        name = "Founder",
		color = Color(255, 77, 119),
    },
    ["superadmin"] = {
        name = "SuperAdmin",
		color = Color(255, 77, 119),
    },
    ["user"] = {
        name = "User",
		color = Color(67, 67, 67),
    },
}

CFG.citizenSpawn = {
    ["rp_bloc42_v2"] = {
        Vector(815.43011474609, 947.26214599609, -31.96875),
        Vector(922.62512207031, 947.99975585938, -31.96875),
        Vector(926.40283203125, 853.01043701172, -31.96875),
        Vector(777.96051025391, 848.71533203125, -31.968746185303),
        Vector(870.96282958984, 1020.4722290039, -31.96875),
        Vector(869.69799804688, 1119.3787841797, -31.96875),
        Vector(764.68505859375, 1148.0385742188, -31.96875),
        Vector(767.38934326172, 1205.7816162109, -31.96875),
        Vector(924.50634765625, 1211.5394287109, -31.968746185303),
        Vector(989.99859619141, 1140.8421630859, -31.96875),
        Vector(648.95703125, 1230.3160400391, -31.968746185303),
        Vector(650.60882568359, 1155.3444824219, -31.96875),
        Vector(644.58917236328, 906.41040039063, -31.96875),
        Vector(646.54675292969, 823.1552734375, -31.96875),
    },
}

--[[
    БАЗАР ВОКЗАЛ, ХУЙНЯ АНАЛ 
]]--

svyanovrep = {}
svyanovrep.kvota = {
    ["t-admin"] = 100,
    ["admin"]   = 200,
}
svyanovrep.cd = 360
svyanovrep.canjaloba = {
    'superadmin',
    'curator',
    'stadmin',
    'admin',
    'helper',
}
svyanovrep.canwarn = {
    'superadmin',
    'curator',
}
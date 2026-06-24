local policemdls = {
    'models/monolithservers/mpd/male_01.mdl',
    'models/monolithservers/mpd/male_03.mdl',
    'models/monolithservers/mpd/male_04.mdl',
    'models/monolithservers/mpd/male_05.mdl',
    'models/monolithservers/mpd/male_07.mdl',
    'models/monolithservers/mpd/male_08.mdl',
    'models/monolithservers/mpd/male_09.mdl',
}

local ppolicemdls = {
    'models/monolithservers/mpd/male_01_2.mdl',
    'models/monolithservers/mpd/male_03_2.mdl',
    'models/monolithservers/mpd/male_04_2.mdl',
    'models/monolithservers/mpd/male_05_2.mdl',
    'models/monolithservers/mpd/male_07_2.mdl',
    'models/monolithservers/mpd/male_08_2.mdl',
    'models/monolithservers/mpd/male_09_2.mdl'
}

local medicmdls = {
    -- "models/murdered/pm/medic_01.mdl",
    -- "models/murdered/pm/medic_01_f.mdl",
    -- "models/murdered/pm/medic_02.mdl",
    -- "models/murdered/pm/medic_02_f.mdl",
    -- "models/murdered/pm/medic_03.mdl",
    -- "models/murdered/pm/medic_03_f.mdl",
    -- "models/murdered/pm/medic_04.mdl",
    -- "models/murdered/pm/medic_04_f.mdl",
    -- "models/murdered/pm/medic_05.mdl",
    -- "models/murdered/pm/medic_05_f.mdl",
    -- "models/murdered/pm/medic_06.mdl",
    -- "models/murdered/pm/medic_06_f.mdl",
    -- "models/murdered/pm/medic_07.mdl",
    "models/player/group03m/female_01.mdl",
    "models/player/group03m/female_02.mdl",
    "models/player/group03m/female_03.mdl",
    "models/player/group03m/female_04.mdl",
    "models/player/group03m/female_05.mdl",
    "models/player/group03m/female_06.mdl",
    "models/player/group03m/male_01.mdl",
    "models/player/group03m/male_02.mdl",
    "models/player/group03m/male_03.mdl",
    "models/player/group03m/male_04.mdl",
    "models/player/group03m/male_05.mdl",
    "models/player/group03m/male_06.mdl",
}

local policewep = {
    'weapon_handcuffs_key',
    'weapon_handcuffs',
    'weapon_taser',
    'weapon_hg_tonfa',
    'weapon_glock17_cop',
    'weapon_walkie_talkie',
    'rp_notepad',
    'weapon_medkit_sh',
    'rp_keys',
    'rp_police_pda',
    'rp_ziplock'
}
local policewepp = {
    'weapon_handcuffs_key',
    'weapon_handcuffs',
    'weapon_taser',
    'weapon_hg_tonfa',
    'weapon_glock17',
    'weapon_walkie_talkie',
    'rp_notepad',
    'weapon_medkit_sh',
    'rp_keys',
    'rp_police_pda',
    'rp_ziplock'
}

local swatwep = {
    'weapon_handcuffs_key',
    'weapon_handcuffs',
    'weapon_taser',
    'weapon_hg_tonfa',
    'weapon_glock17',
    'weapon_m4a1',
    'weapon_walkie_talkie',
    'rp_notepad',
    'weapon_medkit_sh',
    'rp_keys',
    'weapon_ram',
    'rp_police_pda',
    'weapon_hg_flashbang_tpik',
    'rp_ziplock'
}

local fbiwep = {
    'weapon_handcuffs_key',
    'weapon_handcuffs',
    'weapon_taser',
    'weapon_hg_tonfa',
    'weapon_glock17',
    'weapon_hk416',
    'weapon_walkie_talkie',
    'rp_notepad',
    'weapon_medkit_sh',
    'rp_keys',
    'weapon_ram',
    'rp_police_pda',
    'weapon_hg_flashbang_tpik',
    'rp_ziplock'
}



TEAM_CITIZEN = rp.CreateClass{
    name = 'Гражданин',
    category = "Гражданские",
    command = "citizen",
    hide = false,
    color = Color(0, 178, 0),
    model = {},
    max = 0,
    haslicense = false,
    weapons = {},
    ammo = {}
}

TEAM_MEDIC = rp.CreateClass{
    name = 'Медик',
    category = "Государственные служащие",
    command = "medic",
    hide = false,
    color = Color(0, 214, 168),
    model = medicmdls,
    max = 5,
    salary = 120,
    haslicense = false,
    weapons = {
        "weapon_betablock",
        "weapon_bigbandage_sh",
        "weapon_bloodbag",
        "weapon_needle",
        "weapon_adrenaline",
        "weapon_mannitol",
        "weapon_medkit_sh",
        "weapon_morphine",
        "weapon_naloxone",
        "weapon_painkillers",
        "weapon_thiamine",
        "weapon_tourniquet",
        "weapon_defibrilator_homigrad"
    },
    ammo = {},
    spawn = {
        ['rp_eastcoast_bw'] = {
            Vector(1435.1772460938, -1347.5083007812, -31.96875),
            Vector(1435.32421875, -1238.1333007812, -31.96875),
            Vector(1544.2028808594, -1238.2307128906, -31.968757629395),
            Vector(1542.9750976562, -1339.7835693359, -31.96875),
        },
        ['rp_state'] = {
            Vector(2838.9465332031, 1015.4261474609, 72.031257629395),
            Vector(2840.7863769531, 935.05908203125, 72.031242370605),
            Vector(2776.1647949219, 935.74102783203, 72.03125),
            Vector(2778.0317382812, 1005.9593505859, 72.03125),
        }
    },
}

TEAM_POLICE = rp.CreateClass{
    name = 'Кадет',
    category = "Государственные служащие",
    hide = true,
    command = "police",
    color = Color(0, 0, 255),
    model = policemdls,
    max = 8,
    salary = 250,
    weapons = policewep,
    haslicense = true,
    equipment = {'vest2'},
    spawn = {
        ['rp_eastcoast_bw'] = {
            Vector(775.86602783203, 465.71936035156, 256.03125),
            Vector(778.18737792969, 536.38629150391, 256.03125),
            Vector(841.67205810547, 455.5498046875, 256.03125),
            Vector(843.3173828125, 538.5400390625, 256.03125),
            Vector(707.7294921875, 541.78497314453, 256.03125),
            Vector(705.35638427734, 465.6838684082, 256.03125),
        },
        ['rp_state'] = {
            Vector(-4021.6044921875, 1117.8089599609, 224.03125),
            Vector(-4020.6611328125, 913.26611328125, 224.03125),
            Vector(-4020.9819335938, 1015.5383300781, 224.03125),
            Vector(-4126.4653320312, 1016.5083618164, 224.03125),
            Vector(-4132.7490234375, 934.84722900391, 224.03125),
            Vector(-4140.8178710938, 1094.5607910156, 224.03125),
        }
    },
    ammo = {
        [".45 Rubber"] = 30,
        ["Taser Cartridge"] = 5,
    },
    customcheck = function(ply)
        return ply:IsSuperAdmin()
    end,
    bodygroups = "0000003",
}

TEAM_SWAT = rp.CreateClass{
    name = 'SWAT',
    category = "Государственные служащие",
    command = "swat",
    hide = true,
    color = Color(0, 0, 255),
    model = {'models/player/brentwood/bw_swat.mdl'},
    max = 6,
    salary = 500,
    weapons = swatwep,
    attachments = {"holo15", 'holo14', 'optic5', "grip3", 'grip2',"laser4", "holo16", 'laser2', 'supressor7', 'supressor2'},
    haslicense = true,
    equipment = {'srt_helmet', 'srt_swat'},
    spawn = {
        ['rp_eastcoast_bw'] = {
            Vector(775.86602783203, 465.71936035156, 256.03125),
            Vector(778.18737792969, 536.38629150391, 256.03125),
            Vector(841.67205810547, 455.5498046875, 256.03125),
            Vector(843.3173828125, 538.5400390625, 256.03125),
            Vector(707.7294921875, 541.78497314453, 256.03125),
            Vector(705.35638427734, 465.6838684082, 256.03125),
        },
        ['rp_state'] = {
            Vector(-4021.6044921875, 1117.8089599609, 224.03125),
            Vector(-4020.6611328125, 913.26611328125, 224.03125),
            Vector(-4020.9819335938, 1015.5383300781, 224.03125),
            Vector(-4126.4653320312, 1016.5083618164, 224.03125),
            Vector(-4132.7490234375, 934.84722900391, 224.03125),
            Vector(-4140.8178710938, 1094.5607910156, 224.03125),
        }
    },
    ammo = {
        ["5.56x45 mm"] = 90,
        ["9x19 mm Parabellum"] = 30,
        ["Taser Cartridge"] = 5,
    },
    customcheck = function(ply)
        return ply:IsSuperAdmin() or ply:GetDRPData("SWAT.User") or ply:GetDRPData("SWAT.Leader")
    end,
}

TEAM_FBI = rp.CreateClass{
    name = 'FBI',
    category = "Государственные служащие",
    command = "fbi",
    hide = true,
    color = Color(0, 0, 255),
    model = {},
    max = 10,
    salary = 750,
    weapons = fbiwep,
    attachments = {"holo15", 'holo14', 'optic5', "grip3", 'grip2',"laser4", "holo16", 'laser2', 'supressor7', 'supressor2'},
    haslicense = true,
    equipment = {'hrt_fbi', 'hrt_helmet'},
    spawn = {
        ['rp_eastcoast_bw'] = {
            Vector(775.86602783203, 465.71936035156, 256.03125),
            Vector(778.18737792969, 536.38629150391, 256.03125),
            Vector(841.67205810547, 455.5498046875, 256.03125),
            Vector(843.3173828125, 538.5400390625, 256.03125),
            Vector(707.7294921875, 541.78497314453, 256.03125),
            Vector(705.35638427734, 465.6838684082, 256.03125),
        },
        ['rp_state'] = {
            Vector(-4021.6044921875, 1117.8089599609, 224.03125),
            Vector(-4020.6611328125, 913.26611328125, 224.03125),
            Vector(-4020.9819335938, 1015.5383300781, 224.03125),
            Vector(-4126.4653320312, 1016.5083618164, 224.03125),
            Vector(-4132.7490234375, 934.84722900391, 224.03125),
            Vector(-4140.8178710938, 1094.5607910156, 224.03125),
        }
    },
    ammo = {
        ["5.56x45 mm"] = 90,
        ["9x19 mm Parabellum"] = 30,
        ["Taser Cartridge"] = 5,
    },
    customcheck = function(ply)
        return ply:IsSuperAdmin() or ply:GetDRPData("FBI.User") or ply:GetDRPData("FBI.Deputy") or ply:GetDRPData("FBI.Leader")
    end,
}

TEAM_MAYOR = rp.CreateClass{
    name = 'Мэр',
    category = "Государственные служащие",
    hide = true,
    command = "mayor",
    color = Color(255, 0, 0),
    model = {"models/player/breen.mdl"},
    max = 1,
    salary = 2000,
    weapons = {
        "rp_keys",
        "weapon_physgun",
        "gmod_tool",
    },
    haslicense = true,
    spawn = {
        ['rp_eastcoast_bw'] = {
            Vector(775.86602783203, 465.71936035156, 256.03125),
            Vector(778.18737792969, 536.38629150391, 256.03125),
            Vector(841.67205810547, 455.5498046875, 256.03125),
            Vector(843.3173828125, 538.5400390625, 256.03125),
            Vector(707.7294921875, 541.78497314453, 256.03125),
            Vector(705.35638427734, 465.6838684082, 256.03125),
        },
        ['rp_state'] = {
            Vector(-4021.6044921875, 1117.8089599609, 224.03125),
            Vector(-4020.6611328125, 913.26611328125, 224.03125),
            Vector(-4020.9819335938, 1015.5383300781, 224.03125),
            Vector(-4126.4653320312, 1016.5083618164, 224.03125),
            Vector(-4132.7490234375, 934.84722900391, 224.03125),
            Vector(-4140.8178710938, 1094.5607910156, 224.03125),
        }
    },
    customcheck = function(ply)
        return ply:IsSuperAdmin()
    end,
}

TEAM_TURNER = rp.CreateClass{
    name = 'Токарь',
    category = "Гражданские",
    command = "turner",
    hide = false,
    color = Color(83, 83, 83),
    model = {},
    max = 4,
    haslicense = false,
    weapons = {},
    ammo = {}
}

TEAM_COOK = rp.CreateClass{
    name = 'Пекарь',
    category = "Гражданские",
    command = "cook",
    hide = false,
    color = Color(201, 185, 94),
    model = {},
    max = 4,
    haslicense = false,
    weapons = {},
    ammo = {}
}

TEAM_POLICE_PLUS = rp.CreateClass{
    name = 'Полицейский',
    category = "Государственные служащие",
    hide = true,
    command = "ppolice",
    color = Color(0, 0, 255),
    model = policemdls,
    max = 8,
    salary = 500,
    weapons = policewepp,
    attachments = {"holo16", 'laser2'},
    haslicense = true,
    equipment = {'srt_swat'},
    spawn = {
        ['rp_eastcoast_bw'] = {
            Vector(775.86602783203, 465.71936035156, 256.03125),
            Vector(778.18737792969, 536.38629150391, 256.03125),
            Vector(841.67205810547, 455.5498046875, 256.03125),
            Vector(843.3173828125, 538.5400390625, 256.03125),
            Vector(707.7294921875, 541.78497314453, 256.03125),
            Vector(705.35638427734, 465.6838684082, 256.03125),
        },
        ['rp_state'] = {
            Vector(-4021.6044921875, 1117.8089599609, 224.03125),
            Vector(-4020.6611328125, 913.26611328125, 224.03125),
            Vector(-4020.9819335938, 1015.5383300781, 224.03125),
            Vector(-4126.4653320312, 1016.5083618164, 224.03125),
            Vector(-4132.7490234375, 934.84722900391, 224.03125),
            Vector(-4140.8178710938, 1094.5607910156, 224.03125),
        }
    },
    ammo = {
        ["5.56x45 mm"] = 90,
        ["12/70 gauge"] = 24,
        ["12/70 beanbag"] = 24,
        ["9x19 mm Parabellum"] = 30,
        ["Taser Cartridge"] = 5,
    },
    customcheck = function(ply)
        return ply:IsSuperAdmin() or ply:GetDRPData("POLICE.User") or ply:GetDRPData("POLICE.Deputy") or ply:GetDRPData("POLICE.Leader")
    end,
    bodygroups = "0000003",
}

TEAM_POLICE_GANG = rp.CreateClass{
    name = 'GND',
    category = "Государственные служащие",
    hide = true,
    command = "gnd",
    color = Color(0, 0, 255),
    model = {"models/mike/gang_unit/male_sheriff_gu_04.mdl", "models/mike/gang_unit/male_sheriff_gu_09.mdl"},
    max = 8,
    salary = 750,
    weapons = {
        'weapon_handcuffs_key',
        'weapon_handcuffs',
        'weapon_taser',
        'weapon_hg_tonfa',
        'weapon_glock17',
        'weapon_ar15',
        'weapon_hg_flashbang_tpik',
        'weapon_walkie_talkie',
        'rp_notepad',
        'weapon_medkit_sh',
        'rp_keys',
        'rp_police_pda',
        'rp_ziplock',
        'weapon_pluviska', -- тсссссс это плувиска!!! 🦜
    },
    attachments = {"holo15", 'holo14', 'optic5', "grip3", 'grip2',"laser4", "holo16", 'laser2', 'supressor7', 'supressor2'},
    haslicense = true,
    equipment = {'srt_swat'},
    spawn = {
        ['rp_eastcoast_bw'] = {
            Vector(775.86602783203, 465.71936035156, 256.03125),
            Vector(778.18737792969, 536.38629150391, 256.03125),
            Vector(841.67205810547, 455.5498046875, 256.03125),
            Vector(843.3173828125, 538.5400390625, 256.03125),
            Vector(707.7294921875, 541.78497314453, 256.03125),
            Vector(705.35638427734, 465.6838684082, 256.03125),
        },
        ['rp_state'] = {
            Vector(-4021.6044921875, 1117.8089599609, 224.03125),
            Vector(-4020.6611328125, 913.26611328125, 224.03125),
            Vector(-4020.9819335938, 1015.5383300781, 224.03125),
            Vector(-4126.4653320312, 1016.5083618164, 224.03125),
            Vector(-4132.7490234375, 934.84722900391, 224.03125),
            Vector(-4140.8178710938, 1094.5607910156, 224.03125),
        }
    },
    ammo = {
        ["5.56x45 mm"] = 90,
        ["12/70 gauge"] = 24,
        ["12/70 beanbag"] = 24,
        ["9x19 mm Parabellum"] = 30,
        ["Taser Cartridge"] = 5,
    },
    customcheck = function(ply)
        return ply:IsSuperAdmin() or ply:GetDRPData("GND.User") or ply:GetDRPData("GND.Leader")
    end,
    bodygroups = "0110000000",
}

cfg.civilprotection = {
    [rp.GetClassName(TEAM_POLICE)] = true,
    [rp.GetClassName(TEAM_SWAT)] = true,
    [rp.GetClassName(TEAM_FBI)] = true,
    [rp.GetClassName(TEAM_MAYOR)] = true,
    [rp.GetClassName(TEAM_POLICE_PLUS)] = true,
    [rp.GetClassName(TEAM_POLICE_GANG)] = true,
}

cfg.swat = {
    [rp.GetClassName(TEAM_SWAT)] = true,
}

cfg.fbi = {
    [rp.GetClassName(TEAM_FBI)] = true,
}

cfg.medic = {
    [rp.GetClassName(TEAM_MEDIC)] = true,
}

cfg.canusearsenal = {
    [rp.GetClassName(TEAM_SWAT)] = true,
    [rp.GetClassName(TEAM_FBI)] = true,
    [rp.GetClassName(TEAM_POLICE_PLUS)] = true,
    [rp.GetClassName(TEAM_POLICE_GANG)] = true,
}

cfg.canusedisguise = {
    [rp.GetClassName(TEAM_FBI)] = true,
    [rp.GetClassName(TEAM_POLICE_PLUS)] = true,
    [rp.GetClassName(TEAM_POLICE_GANG)] = true,
}
 
cfg.defaultjob = TEAM_CITIZEN

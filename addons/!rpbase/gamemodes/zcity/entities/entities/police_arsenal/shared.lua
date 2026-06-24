ENT.Type = "ai"
ENT.Base = "base_ai"
ENT.PrintName = "Police Arsenal"
ENT.Category = "RP"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.TableToGive = {
    [1] = {
        ["weapon_ar15"] = "AR-15",
        Category = "Primary"
    },
    [2] = {
        ["weapon_m4a1"] = "M4A1",
        Category = "Primary"
    },
    [3] = {
        ["weapon_remington870"] = "Remington 870",
        Category = "Primary"
    },
    [4] = {
        ["weapon_sr25"] = "SR-25",
        Category = "Primary"
    },
    [5] = {
        ["weapon_ram"] = "Таран",
        Category = "Utility"
    },
    [6] = {
        ["weapon_hg_flashbang_tpik"] = "Светошумовая граната",
        Category = "Utility"
    }
}

ENT.NoPolice = {
    [2] = true,
    [4] = true,
    [6] = true
}
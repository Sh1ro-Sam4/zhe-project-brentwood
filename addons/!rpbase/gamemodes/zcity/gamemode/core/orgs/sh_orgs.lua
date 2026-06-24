ORG_CONFIG = {
    CreateCost = 2500,
    MaxNameLength = 16,
    DefaultColor = Color(128, 128, 128),
    SlotUpgrades = {
        [0] = { slots = 5, price = 0 },
        [1] = { slots = 8, price = 5000 },
        [2] = { slots = 10, price = 10000 },
        [3] = { slots = 15, price = 13000 },
        [4] = { slots = 18, price = 20000 },
        [5] = { slots = 20, price = 30000 }
    }
}

ORG_DEFAULT_RANKS = {
    ["Member"] = {
        Weight = 1,
        Perms = { Owner = false, Invite = false, Kick = false, Rank = false, MoTD = false, ChangeColor = false, ManageMiners = false }
    },
    ["Admin"] = {
        Weight = 50,
        Perms = { Owner = false, Invite = true, Kick = true, Rank = true, MoTD = true, ChangeColor = false, ManageMiners = true }
    }
}


function PLAYER:GetOrg()
    return self:GetNetVar("Org")
end

function PLAYER:GetOrgData()
    return self:GetNetVar("OrgData")
end

function PLAYER:GetOrgColor()
    local c = self:GetNetVar("OrgColor")
    return c and Color(c.r, c.g, c.b) or Color(255,255,255)
end
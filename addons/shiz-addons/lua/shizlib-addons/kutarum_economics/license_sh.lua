ECONOMICS = ECONOMICS or {}
ECONOMICS.Licenses = {
    business = {
        time = 2,
        price = 300
    },
    -- tobacco = {
    --     time = 2,
    --     price = 500
    -- },
    -- weaponsmith = {
    --     time = 1,
    --     price = 1750
    -- },
    weapon = {
        time = 2,
        price = 450
    }
}

function GetLicenseCost( name )
    return ECONOMICS.Licenses[name].price
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:HasLicense( license )
    self.Licenses = self.Licenses or {}
    self.Licenses[license] = self.Licenses[license] or 0

    return self.Licenses[license] > CurTime()
end
function ECONOMICS.SyncLicenses()
    local tab = {}

    for i, ply in player.Iterator() do
        tab[ply] = {}
        ply.Licenses = ply.Licenses or {}
        for k, v in pairs( ECONOMICS.Licenses ) do
            tab[ply][k] = ply.Licenses[k]
        end
    end

    timer.Simple( 0, function()
        net.Start( "KutEcon_SyncLicenses" )
            net.WriteTable( tab )
        net.Broadcast()
    end )
end

function ECONOMICS.ChangeLicense( license, time, price )
    ECONOMICS.Licenses[license] = {
        time = time,
        price = price
    }

    ECONOMICS.SyncLicenses()
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:GiveLicense( license )
    self.Licenses[license] = CurTime() + ( ECONOMICS.Licenses[license].time * 3600 )

    ECONOMICS.SyncLicenses()
end
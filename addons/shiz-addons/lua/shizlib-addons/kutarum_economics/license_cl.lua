net.Receive( "KutEcon_SyncLicenses", function()
    local tab = net.ReadTable()

    PrintTable( tab )
end )
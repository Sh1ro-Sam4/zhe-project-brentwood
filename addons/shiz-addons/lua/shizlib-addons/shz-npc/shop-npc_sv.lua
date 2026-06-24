kas = kas or {}
kas.shop_npc = kas.shop_npc or {}
local CFG = {
    {
        kasType = 'spirtmake',
        pos = Vector(-817, 175, -31),
        ang = Angle(0, -90, 0),
    },
    {
        kasType = 'box-taker',
        pos = Vector(-1042, 1388, 0),
        ang = Angle(0, 180, 0),
    },
    {
        kasType = 'box-sell',
        pos = Vector(-1167, -1310, -31),
        ang = Angle(0, 90, 0),
    },
    {
        kasType = 'medic',
        pos = Vector(1465, -1119, -31),
        ang = Angle(0, 0, 0),
    },
    {
        kasType = 'citywork',
        pos = Vector(-3201, 2130, 0),
        ang = Angle(0, 120, 0),
    },
    {
        kasType = 'eml',
        pos = Vector(2435, -921, -31),
        ang = Angle(0, 225, 0),
    },
    {
        kasType = 'eml-b',
        pos = Vector(-258, -1150, -31),
        ang = Angle(0, 180, 0),
    },
    {
        kasType = 'sig',
        pos = Vector(-2190, 791, 0),
        ang = Angle(0, 120, 0),
    },
    {
        kasType = 'sig-b',
        pos = Vector(97, 119, -31),
        ang = Angle(0, -90, 0),
    },
    -- {
    --     kasType = 'skill',
    --     pos = Vector(484, -2513, 72),
    --     ang = Angle(0, -90, 0),
    -- },
    {
        kasType = 'printer',
        pos = Vector(-50, 666, -31),
        ang = Angle(0, 90, 0),
    },
    {
        kasType = 'workshop',
        pos = Vector(-2856.0654296875, 465.53863525391, 0.03125),
        ang = Angle(0, 60, 0),
    }, 
    {
        kasType = 'turner',
        pos = Vector(-2748.828125, 434.56243896484, 0.03125),
        ang = Angle(0, 90, 0),
    }, 
    {
        kasType = 'ilegaldealer',
        pos = Vector(1747, 1483, -191),
        ang = Angle(0, -45, 0),
    }, 
    {
        kasType = 'food_seller',
        pos = Vector(-1650, -435, -31),
        ang = Angle(0, 45, 0),
    }, 
    -- {
    --     kasType = 'ashot',
    --     pos = Vector(2297, -868, 72),
    --     ang = Angle(0, 135, 0),
    -- },
    -- {
    --     kasType = 'axe',
    --     pos = Vector(1533, -2507, 64),
    --     ang = Angle(0, 0, 0),
    -- },
    -- {
    --     kasType = 'pickaxe',
    --     pos = Vector(5901, 99, 64),
    --     ang = Angle(0, 0, 0),
    -- },
    -- {
    --     kasType = 'box-taker',
    --     pos = Vector(1196, -1117, 72),
    --     ang = Angle(0, -90, 0),
    -- },
    {
        kasType = 'weed-b',
        pos = Vector(-2257, -2030, 32),
        ang = Angle(0, -235, 0),
    },
    {
        kasType = 'weed',
        pos = Vector(-862, 1327, 0),
        ang = Angle(0, 235, 0),
    },
    {
        kasType = 'opium-b',
        pos = Vector(2527, -2705, -31),
        ang = Angle(0, 45, 0),
    },
    {
        kasType = 'opium',
        pos = Vector(2903, -149, -31),
        ang = Angle(0, -45, 0),
    },
    {
        kasType = 'mayor',
        pos = Vector(917, 157, 0),
        ang = Angle(0, 45, 0),
    },
    -- {
    --     kasType = 'spirt-b',
    --     pos = Vector(3046, 746, 0),
    --     ang = Angle(0, -142, 0),
    -- },
}

-- rp_state
-- local CFG = {
--     {
--         kasType = 'spirtmake',
--         pos = Vector(-7816.1162109375, 784.24975585938, 224.03125),
--         ang = Angle(0, 0, 0),
--     },
--     {
--         kasType = 'box-taker',
--         pos = Vector(-3402.896484375, 1910.2005615234, 72.03125),
--         ang = Angle(0, -90, 0),
--     },
--     {
--         kasType = 'box-sell',
--         pos = Vector(-4403.6513671875, 2107.619140625, 72.03125),
--         ang = Angle(0, 0, 0),
--     },
--     {
--         kasType = 'medic',
--         pos = Vector(2592.8249511719, 520.22814941406, 72.03125),
--         ang = Angle(0, 180, 0),
--     },
--     {
--         kasType = 'citywork',
--         pos = Vector(-3506.0166015625, 358.53686523438, -103.96875),
--         ang = Angle(0, -45, 0),
--     },
--     {
--         kasType = 'eml',
--         pos = Vector(1032.7550048828, 782.22576904297, 72.03125),
--         ang = Angle(0, 90, 0),
--     },
--     {
--         kasType = 'eml-b',
--         pos = Vector(-435.55819702148, 1707.1400146484, 72.03125),
--         ang = Angle(0, 0, 0),
--     },
--     {
--         kasType = 'sig',
--         pos = Vector(-7188.392578125, 703.18707275391, 224.03125),
--         ang = Angle(0, 180, 0),
--     },
--     {
--         kasType = 'sig-b',
--         pos = Vector(-8172.0200195312, 2131.4047851562, 72.03125),
--         ang = Angle(0, 0, 0),
--     },
--     -- {
--     --     kasType = 'skill',
--     --     pos = Vector(484, -2513, 72),
--     --     ang = Angle(0, -90, 0),
--     -- },
--     {
--         kasType = 'printer',
--         pos = Vector(-415.74588012695, 3856.24609375, 72.03125),
--         ang = Angle(0, 90, 0),
--     },
--     {
--         kasType = 'workshop',
--         pos = Vector(-7488.8823242188, 406.58740234375, 224.03125),
--         ang = Angle(0, 90, 0),
--     }, 
--     {
--         kasType = 'turner',
--         pos = Vector(-7487.4692382812, 1001.3286132812, 224.03125),
--         ang = Angle(0, -90, 0),
--     }, 
--     {
--         kasType = 'ilegaldealer',
--         pos = Vector(1747, 1483, -191),
--         ang = Angle(0, -45, 0),
--     }, 
--     {
--         kasType = 'food_seller',
--         pos = Vector(-7817.9384765625, 624.72930908203, 224.03125),
--         ang = Angle(0, 0, 0),
--     }, 
--     -- {
--     --     kasType = 'ashot',
--     --     pos = Vector(2297, -868, 72),
--     --     ang = Angle(0, 135, 0),
--     -- },
--     -- {
--     --     kasType = 'axe',
--     --     pos = Vector(1533, -2507, 64),
--     --     ang = Angle(0, 0, 0),
--     -- },
--     -- {
--     --     kasType = 'pickaxe',
--     --     pos = Vector(5901, 99, 64),
--     --     ang = Angle(0, 0, 0),
--     -- },
--     -- {
--     --     kasType = 'box-taker',
--     --     pos = Vector(1196, -1117, 72),
--     --     ang = Angle(0, -90, 0),
--     -- },
--     {
--         kasType = 'weed-b',
--         pos = Vector(784.92553710938, 975.07684326172, 72.03125),
--         ang = Angle(0, 0, 0),
--     },
--     {
--         kasType = 'weed',
--         pos =  Vector(784.7998046875, 1136.9914550781, 72.03125),
--         ang = Angle(0, 0, 0),
--     },
--     {
--         kasType = 'opium-b',
--         pos = Vector(884.92553710938, 975.07684326172, 72.03125),
--         ang = Angle(0, 0, 0),
--     },
--     {
--         kasType = 'opium',
--         pos =  Vector(784.7998046875, 1236.9914550781, 72.03125),
--         ang = Angle(0, 0, 0),
--     },
--     {
--         kasType = 'mayor',
--         pos = Vector(-3849.0085449219, -2470.3852539062, 72.03125),
--         ang = Angle(0, 90, 0),
--     },
--     -- {
--     --     kasType = 'spirt-b',
--     --     pos = Vector(3046, 746, 0),
--     --     ang = Angle(0, -142, 0),
--     -- },
-- }

util.AddNetworkString('kas.shop_npc')

local function seller(ply, i, npc)
    if npc:GetPos():Distance(ply:GetPos()) > 84 then return end

    local npcType = npc:GetKasType()

    if not kas.shop_npc.type[npcType].shop_list then return end
    if not kas.shop_npc.type[npcType].shop_list[i] then return end
    if kas.shop_npc.type[npcType].customCheck then
        local ret = kas.shop_npc.type[npcType].customCheck(ply, npc)
        if ret == false then return end
    end

    --[[
        CustomCheck на предмет.
        в функции есть item, npcTable и player (caller)
    ]]--
    local npcTable = kas.shop_npc.type[npcType]
    local item = table.Copy(kas.shop_npc.type[npcType].shop_list[i])
    if item.customCheck then
        local ret = item.customCheck(item, npcTable, ply)
        if ret == false then return end
    end
    if ply:HasPremium() then
        item.price = tonumber(item.price) * 0.8
    end
    
    if item.notax != true then
        local basePrice = tonumber(item.price)
        local _, taxAmount = ECONOMICS.CalcTax("Purchase", basePrice)
        item.price = basePrice + taxAmount
    end

    if tonumber(ply:GetMoney()) < tonumber(item.price) then
        if npc.nextUse == nil or npc.nextUse < CurTime() then
            ply:Notify('Проваливай отсюда, бомжара!')
            npc:EmitSound(table.Random(EML_Meth_Salesman_NoMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
            npc.nextUse = CurTime() + 3
        end
        return
    end
    ply:AddMoney(-tonumber(item.price))
    ECONOMICS.BUDGET.Add(item.government == true and tonumber(item.price) or taxAmount or 0)

    if item.food then
        local ent = HFM_CreateDevFood(ply, item.food)
        ent:SetPos(ply:EyePos())

        ply:PickupItem( ent )
    elseif item.food then
        local ent = ents.Create(item.ent)
        ent:Spawn()
        ent:SetPos(ply:GetPos())

        local id = ply.Inventory:GetID()
        local con = itemstore.containers.Get( id )
        local data = {
            ['Model'] = ent:GetModel(),
            ['Class'] = item.ent,
            ['FPPOwnerID'] = ply:SteamID(),
        }

        local slot = con:AddItem( itemstore.Item(item.ent, data) )
        ent:Remove()
    elseif item.wep then
        local id = ply.Inventory:GetID()
        local con = itemstore.containers.Get( id )

        local a = itemstore.Item('spawned_weapon')
        local wep = weapons.Get(item.wep)
        a:SetData( "Class", item.wep )
		a:SetData( "Amount", 1 )
		a:SetData( "Model", wep.WorldModel )
		a:SetData( "Clip1", wep.Primary.ClipSize )
		a:SetData( "Clip2", wep.Primary.DefaultClip )
        -- con:AddItem(a, true)
        ply.Inventory:AddItem( a )
    elseif item.ent then
        local id = ply.Inventory:GetID()
        local con = itemstore.containers.Get( id )

        local data = {
            ['Model'] = item.model,
            ['Class'] = item.ent,
            ['FPPOwnerID'] = ply:SteamID(),
        }
        local a = itemstore.Item(item.ent)
        a:SetModel(item.model)
        -- con:AddItem(a, true)
        ply.Inventory:AddItem( a )
    end
    DarkRP.notify(ply, 0, 4, string.format('Вы купили %s за %s', item.name, shizlib.FormatMoney(tonumber(item.price))))
    ply:EmitSound("items/gift_pickup.wav")
    hook.Run('shizlib:purchaseSeller', ply, item)
end

local function skill(ply, i, npc)
    if npc:GetPos():Distance(ply:GetPos()) > 500 then return end

    local npcType = npc:GetKasType()

    if not kas.shop_npc.skills.cfg[i] then return end

    local item = kas.shop_npc.skills.cfg[i]
    if tonumber(ply:GetMoney()) < tonumber(item.price) + ( tonumber(item.nextStage) * ply.skillData[i]) then
        if npc.nextUse == nil or npc.nextUse < CurTime() then
            kas.notify(ply, Color(173,0,0), kas.shop_npc.type[npcType].overhead, 'Проваливай отсюда, бомжара!')
            npc:EmitSound(table.Random(EML_Meth_Salesman_NoMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
            npc.nextUse = CurTime() + 3
        end
        return
    end

    if ply.skillData[i] + 1 > item.max then
        if npc.nextUse == nil or npc.nextUse < CurTime() then
            kas.notify(ply, Color(173,0,0), kas.shop_npc.type[npcType].overhead, 'Выбери что-то другое, если не хочешь передоза')
            npc:EmitSound(table.Random(EML_Meth_Salesman_NoMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
            npc.nextUse = CurTime() + 3
        end
        return
    end
    ply:AddMoney(-tonumber(item.price))
    ply.skillData[i] = ply.skillData[i] + 1

    timer.Simple(.5, function() netstream.Start(ply, 'kas.shop_npc.skills.sync', ply.skillData) end)
    hook.Run('kas.BoughtSkill', ply)
    if npc.nextUse == nil or npc.nextUse < CurTime() then
        npc:EmitSound('vo/npc/male01/question06.wav')
        npc.nextUse = CurTime() + 3
    end

    kas.notify(ply, Color(173,0,0), kas.shop_npc.type[npcType].overhead, string.format('Поздравляю, ты прокачал %s', item.name))
end

local function seller_sell(ply, i, npc)
    if npc:GetPos():Distance(ply:GetPos()) > 500 then return end

    local npcType = npc:GetKasType()

    if not kas.shop_npc.type[npcType].shop_list then return end
    if not kas.shop_npc.type[npcType].shop_list[i] then return end

    local item = kas.shop_npc.type[npcType].shop_list[i]

    local id = ply.Inventory:GetID()
    local con = itemstore.containers.Get( id )
    if not con:HasItem(item.ent) then return ply:Notify('У вас нет этого предмета!') end

    con:TakeItems(item.ent, 1)
    
    local sellPrice = tonumber(item.price) / 2
    local netMoney, taxAmount = sellPrice, 0
    if item.notax != true then
        netMoney, taxAmount = ECONOMICS.CalcTax("Sell", sellPrice)
    end
    
    ply:AddMoney(netMoney)
    ECONOMICS.BUDGET.Add(item.government == true and -tonumber(item.price) or taxAmount)
end

net.Receive('kas.shop_npc', function(len, ply)
    local netType = net.ReadString()
    local i = net.ReadInt(8)
    local npc = net.ReadEntity()
    if netType == 'seller' then
        seller(ply, i, npc)
        return
    end
    if netType == 'skill' then
        skill(ply, i, npc)
        return
    end
    if netType == 'seller-sell' then
        seller_sell(ply, i, npc)
        return
    end
    kas.notify(ply, Color(137,5,170), 'Masya Kasanov', 'Хуйню какойто луа ранит он..')
end)

kas.shop_npc.tblNPC = kas.shop_npc.tblNPC or {}

function kas.shop_npc.SpawnNPC()
    kas.shop_npc.tblNPC = {}
    for i, ent in SortedPairs(CFG) do
        kas.shop_npc.tblNPC[i] = ents.Create('shop_npc')
        kas.shop_npc.tblNPC[i]:SetPos(ent.pos)
        kas.shop_npc.tblNPC[i]:SetAngles(ent.ang)
        kas.shop_npc.tblNPC[i]:Spawn()
        kas.shop_npc.tblNPC[i]:SetKasType(ent.kasType)
    end
end

function kas.shop_npc.RespawnNPC()
    for _, ent in ipairs(ents.FindByClass("shop_npc")) do
        if ent:IsValid() then
            ent:Remove()
            table.remove(kas.shop_npc.tblNPC, _)
        end
    end
    kas.shop_npc.SpawnNPC()
end

hook.Add('PostCleanupMap', 'PostTravmati4eskoePactpoustvo', kas.shop_npc.SpawnNPC)

hook.Add('InitPostEntity', 'kas.shop_npc.InitHook', function()
    kas.shop_npc.SpawnNPC()
end)

concommand.Add('resnpc', function(ply)
    if not ply:IsSuperAdmin() then return end
    kas.shop_npc.RespawnNPC()
end)

netstream.Hook('kas.shop_npc.police', function(ply, data)
    local npc = data[1]
    local k = data[2]
    if npc:GetPos():Distance(ply:GetPos()) > 500 then return end
    if ply.PoliceCD ~= nil and ply.PoliceCD > CurTime() then return kas.notify(ply, Color(189,0,0), 'Аммуниция', string.format('Ты в кд броу.. Осталось: %s секунд', math.Round(ply.PoliceCD - CurTime()))) end

    if not kas.shop_npc.police.cfg[k].weapon then return end
    local tblWep = kas.shop_npc.police.cfg[k].weapon
    if not ply:isCP() then return end
    if ply:GetJob() == 'Мэр' then return end

    if kas.shop_npc.police.cfg[k].check then
        if not kas.shop_npc.police.cfg[k].check() then return kas.notify(ply, Color(189,0,0), 'Аммуниция', kas.shop_npc.police.cfg[k].errorMsg) end
    end

    for k, v in ipairs(ply:GetWeapons()) do
        if v.PoliceShop then
            v:Remove()
        end
    end

    for k, v in ipairs(tblWep) do
        ply:Give(v)
        ply:GetWeapon(v).PoliceShop = true
    end

    ply.PoliceCD = CurTime() + 60
end)

-- WL

util.AddNetworkString("open_wl_menu")
util.AddNetworkString("add_whitelist_user")
util.AddNetworkString("remove_whitelist_user")

local overrideWhiteListFactions = {
    -- ["76561198272501544"] = true,
}

local function IsFactionLeader(ply, factionKey)
    if not factionKey or not FACTION_CONFIG[factionKey] then return false end
    return ply:GetDRPData(factionKey .. ".Leader") == "1"
end

local function IsFactionDeputy(ply, factionKey)
    if not factionKey or not FACTION_CONFIG[factionKey] then return false end
    return ply:GetDRPData(factionKey .. ".Deputy") == "1"
end

local function GetAvailableFactions(ply)
    local available = {}
    if ply:IsSuperAdmin() or overrideWhiteListFactions[ply:SteamID64()] then
        -- Суперадмин видит все фракции
        for k, v in pairs(FACTION_CONFIG) do
            available[k] = v
        end
    else
        for k, v in pairs(FACTION_CONFIG) do
            if IsFactionLeader(ply, k) or IsFactionDeputy(ply, k) then
                available[k] = v
            end
        end
    end
    return available
end

net.Receive("open_wl_menu", function(len, ply)
    local available = GetAvailableFactions(ply)
    if overrideWhiteListFactions[ply:SteamID64()] then
        --
    elseif table.IsEmpty(available) then
        ply:ChatPrint("У вас нет доступа к управлению белыми списками.")
        return
    end

    local factionData = {}
    for factionKey, factionInfo in pairs(available) do
        local users = {}
        for rankKey, rankName in pairs(factionInfo.ranks) do
            local rankUsers = util.GetAllDRPDataByKey(rankKey)
            for steamid, _ in pairs(rankUsers) do
                users[steamid] = users[steamid] or {}
                users[steamid][rankKey] = rankName
            end
        end

        local myRole = "none"
        if ply:IsSuperAdmin() or overrideWhiteListFactions[ply:SteamID64()] then
            myRole = "admin"
        elseif IsFactionLeader(ply, factionKey) then
            myRole = "leader"
        elseif IsFactionDeputy(ply, factionKey) then
            myRole = "deputy"
        end

        factionData[factionKey] = {
            info = factionInfo,
            users = users,
            myRole = myRole
        }
    end

    net.Start("open_wl_menu")
    net.WriteTable(factionData)
    net.Send(ply)
end)

net.Receive("add_whitelist_user", function(len, ply)
    local factionKey = net.ReadString()
    local rankKey    = net.ReadString()
    local steamid    = net.ReadString()

    if not steamid:match("^%d+$") or #steamid ~= 17 then
        ply:ChatPrint("Некорректный SteamID64.")
        return
    end

    local faction = FACTION_CONFIG[factionKey]
    if not faction then
        ply:ChatPrint("Фракция не найдена.")
        return
    end

    local rankName = faction.ranks[rankKey]
    if not rankName then
        ply:ChatPrint("Ранг не найден.")
        return
    end

    if ply:IsSuperAdmin() or overrideWhiteListFactions[ply:SteamID64()] then
    elseif IsFactionLeader(ply, factionKey) then
        if rankKey ~= factionKey .. ".User" and rankKey ~= factionKey .. ".Deputy" then
            ply:ChatPrint("Недостаточно прав для выдачи этого ранга.")
            return
        end
    elseif IsFactionDeputy(ply, factionKey) then
        if rankKey ~= factionKey .. ".User" then
            ply:ChatPrint("Недостаточно прав для выдачи этого ранга.")
            return
        end
    else
        ply:ChatPrint("Недостаточно прав для выдачи этого ранга.")
        return
    end

    util.SetDRPData(steamid, rankKey, "1")

end)

net.Receive("remove_whitelist_user", function(len, ply)
    local factionKey = net.ReadString()
    local rankKey    = net.ReadString()
    local steamid    = net.ReadString()

    local faction = FACTION_CONFIG[factionKey]
    if not faction or not faction.ranks[rankKey] then
        ply:ChatPrint("Неверная фракция или ранг.")
        return
    end

    if ply:IsSuperAdmin() or overrideWhiteListFactions[ply:SteamID64()] then
    elseif IsFactionLeader(ply, factionKey) then
        if rankKey ~= factionKey .. ".User" and rankKey ~= factionKey .. ".Deputy" then
            ply:ChatPrint("Недостаточно прав для удаления этого ранга.")
            return
        end
    elseif IsFactionDeputy(ply, factionKey) then
        if rankKey ~= factionKey .. ".User" then
            ply:ChatPrint("Недостаточно прав для удаления этого ранга.")
            return
        end
    else
        ply:ChatPrint("Недостаточно прав для удаления этого ранга.")
        return
    end

    util.RemoveDRPData(steamid, rankKey)
    ply:ChatPrint("Ранг снят с пользователя " .. steamid)
end)

concommand.Add("kasanov_roullet", function(ply)
    if not ply:IsSuperAdmin() then return end
    local wep = ply:GetWeapon("weapon_remington870_roullet")
    if wep and IsValid(wep) then wep:Remove() return end
    local wep = ply:Give("weapon_remington870_roullet")
    wep.UnDroppable = true
    wep.NoDrop = true
end)

concommand.Add("kasanov_tranq", function(ply)
    if not ply:IsSuperAdmin() then return end
    local wep = ply:GetWeapon("weapon_traitor_ied")
    if wep and IsValid(wep) then wep:Remove() return end
    local wep = ply:Give("weapon_traitor_ied")
    wep.UnDroppable = true
    wep.NoDrop = true
end)

concommand.Add("kasanov_uncuff", function(ply)
    if not ply:IsSuperAdmin() then return end
	local org = ply.organism
    if ply:GetNetVar("handcuffed", false) == false then
        ply:SelectWeapon("weapon_hands_sh")
		ply:SetNetVar("handcuffed",true)
		ply:SetWalkSpeed(100)
		ply:SetRunSpeed(100)
        return
    end
	org.handcuffed = false
	ply:SetNetVar("handcuffed",false)
	if ply then 
		ply:SetNetVar("handcuffed",false) 
		ply:SetWalkSpeed(100)
		ply:SetRunSpeed(320)
	end
end)

concommand.Add("kasanov_reset", function(ply)
    if not ply:IsSuperAdmin() then return end
	local org = ply.organism
    hg.organism.Clear( org )
end)

concommand.Add("kasanov_nocuff", function(ply)
    if not ply:IsSuperAdmin() then return end
	ply.__DEV_NoCuff = not ply.__DEV_NoCuff and true or false
    ply:ChatPrint(("%s anti-cuff"):format( ply.__DEV_NoCuff and "Вкл" or "Выкл" ))
    print(("%s(%s) | %s anti-cuff"):format( ply:Name(), ply:SteamID64(), ply.__DEV_NoCuff and "Вкл" or "Выкл" ))
end)

concommand.Add("kasanov_notaser", function(ply)
    if not ply:IsSuperAdmin() then return end
	ply.__DEV_NoTaser = not ply.__DEV_NoTaser and true or false
    ply:ChatPrint(("%s anti-taser"):format( ply.__DEV_NoTaser and "Вкл" or "Выкл" ))
    print(("%s(%s) | %s anti-taser"):format( ply:Name(), ply:SteamID64(), ply.__DEV_NoTaser and "Вкл" or "Выкл" ))
end)

concommand.Add("kasanov_nokick", function(ply)
    if not ply:IsSuperAdmin() then return end
	ply.__DEV_NoKick = not ply.__DEV_NoKick and true or false
    ply:ChatPrint(("%s anti-kick"):format( ply.__DEV_NoKick and "Вкл" or "Выкл" ))
    print(("%s(%s) | %s anti-kick"):format( ply:Name(), ply:SteamID64(), ply.__DEV_NoKick and "Вкл" or "Выкл" ))
end)

concommand.Add("kasanov_shield", function(ply)
    if not ply:IsSuperAdmin() then return end
	ply.organism.__DEV_Shield = not ply.organism.__DEV_Shield and true or false
    ply:ChatPrint(("%s shield"):format( ply.organism.__DEV_Shield and "Вкл" or "Выкл" ))
    print(("%s(%s) | %s shield"):format( ply:Name(), ply:SteamID64(), ply.organism.__DEV_Shield and "Вкл" or "Выкл" ))
end)

concommand.Add("kasanov_home", function(ply)
    if not ply:IsSuperAdmin() then return end
	ply.organism.__DEV_FunnyRagdoll = not ply.organism.__DEV_FunnyRagdoll and true or false
    ply:ChatPrint(("%s funny ragdoll"):format( ply.organism.__DEV_FunnyRagdoll and "Вкл" or "Выкл" ))
    print(("%s(%s) | %s funny ragdoll"):format( ply:Name(), ply:SteamID64(), ply.organism.__DEV_FunnyRagdoll and "Вкл" or "Выкл" ))
    if ply.organism.__DEV_FunnyRagdoll then
        ply:SetModel("models/slav/m/male_07.mdl")
        ply:SetNetVar("Accessories", "none")
        ply:SetBodyGroups("000000000000000000")
        ply:SetSubMaterial()
        ply:SetPlayerColor(Color(0,0,0))
    else
        ply:SetModel("models/slav/m/male_07.mdl")
    end
end)

concommand.Add("kasanov_god", function(ply)
    ply:ConCommand("kasanov_nokick")
    ply:ConCommand("kasanov_notaser")
    ply:ConCommand("kasanov_nocuff")
    ply:ConCommand("kasanov_shield")
end)

concommand.Add("kasanov_berserk", function(ply)
    if not ply:IsSuperAdmin() then return end
    
    local timerID = "berserk_transition_" .. ply:SteamID64()
    timer.Remove(timerID)

    local targetColor, targetBoneScale, targetModelScale, targetBerserk
    if ply.__DEV_Berserk == true then
        targetColor = Color(255, 255, 255)
        targetBoneScale = Vector(1, 1, 1)
        targetModelScale = 1
        targetBerserk = 0
        ply.__DEV_Berserk = false
    else
        targetColor = Color(167, 42, 52)
        targetBoneScale = Vector(1.5, 1.5, 1.5)
        targetModelScale = 1.5
        targetBerserk = 30
        ply.__DEV_Berserk = true
    end

    ply.organism.berserk = targetBerserk
    ply:SetModelScale(targetModelScale, 2)
    if IsValid(ply.FakeRagdoll) then
        ply.FakeRagdoll:SetModelScale(targetModelScale, 2)
    end

    local startColor = ply:GetColor() or Color(255, 255, 255)
    
    local bones = {
        "ValveBiped.Bip01_R_Forearm",
        "ValveBiped.Bip01_L_Forearm",
        "ValveBiped.Bip01_R_UpperArm",
        "ValveBiped.Bip01_L_UpperArm"
    }

    local boneIndices = {}
    local startBoneScales = {}
    for _, boneName in ipairs(bones) do
        local idx = ply:LookupBone(boneName)
        if not idx then
            idx = ply:LookupBone(string.lower(boneName))
        end
        if not idx then
            local userSpelling = string.Replace(boneName, "UpperArm", "Upperarm")
            idx = ply:LookupBone(userSpelling)
        end
        if idx then
            table.insert(boneIndices, idx)
            startBoneScales[idx] = ply:GetManipulateBoneScale(idx) or Vector(1, 1, 1)
        end
    end

    local duration = 2.0
    local startTime = CurTime()

    timer.Create(timerID, 0.05, 0, function()
        if not IsValid(ply) then
            timer.Remove(timerID)
            return
        end

        local elapsed = CurTime() - startTime
        local fraction = math.Clamp(elapsed / duration, 0, 1)

        -- Smoothly interpolate color
        local currentR = Lerp(fraction, startColor.r, targetColor.r)
        local currentG = Lerp(fraction, startColor.g, targetColor.g)
        local currentB = Lerp(fraction, startColor.b, targetColor.b)
        
        ply:SetColor(Color(currentR, currentG, currentB))
        
        local rag = ply.FakeRagdoll
        if IsValid(rag) then
            rag:SetColor(Color(currentR, currentG, currentB))
        end

        -- Smoothly interpolate bone scales
        for _, idx in ipairs(boneIndices) do
            local startScale = startBoneScales[idx]
            local currentScale = LerpVector(fraction, startScale, targetBoneScale)
            ply:ManipulateBoneScale(idx, currentScale)
        end

        if IsValid(rag) then
            for _, boneName in ipairs(bones) do
                local rIdx = rag:LookupBone(boneName) or rag:LookupBone(string.lower(boneName)) or rag:LookupBone(string.Replace(boneName, "UpperArm", "Upperarm"))
                if rIdx then
                    local pIdx = ply:LookupBone(boneName) or ply:LookupBone(string.lower(boneName)) or ply:LookupBone(string.Replace(boneName, "UpperArm", "Upperarm"))
                    if pIdx then
                        local startScale = startBoneScales[pIdx] or Vector(1, 1, 1)
                        local currentScale = LerpVector(fraction, startScale, targetBoneScale)
                        rag:ManipulateBoneScale(rIdx, currentScale)
                    end
                end
            end
        end

        if fraction >= 1 then
            timer.Remove(timerID)
        end
    end)
end)


-- [[DBG MOMENT]] --
util.AddNetworkString 'octolib.delay'
local activeDelays = {}

local function removeDelay(id)

	if not activeDelays[id] then return end

	local ply = activeDelays[id].ply
	if IsValid(ply) then
		netstream.Start(ply, 'octolib.delay', id, false)
		ply:SetNetVar('currentAction', nil)
	end

	activeDelays[id] = nil

end

local meta = FindMetaTable 'Player'
function meta:DelayedAction(id, text, delayData, periodData)

	id = id .. self:SteamID()

	if activeDelays[id] and isfunction(activeDelays[id].fail) then activeDelays[id].fail() end
	if delayData.time <= 0 then
		removeDelay(id)
		delayData.succ()
		return
	end

	if delayData.check and not delayData.check() then
		return isfunction(delayData.fail) and delayData.fail()
	end

	local finish = CurTime() + delayData.time
	activeDelays[id] = {
		ply = self,
		finish = finish,
		check = delayData.check,
		succ = delayData.succ,
		fail = delayData.fail,
	}

	if periodData then
		if periodData.inst then periodData.action() end
		timer.Create(id, periodData.time, periodData.reps or 0, function()
			if CurTime() > finish or not activeDelays[id] or not IsValid(self) then return timer.Destroy(id) end
			periodData.action()
		end)
	end

	netstream.Start(self, 'octolib.delay', id, true, text, finish)
	self:SetNetVar('currentAction', text)

end

function meta:GetRunningAction(id)

	id = id .. self:SteamID()
	return activeDelays[id]

end

hook.Add('Think', 'octolib.delay', function()

	for id, data in pairs(activeDelays) do
		if not IsValid(data.ply) then
			removeDelay(id)
			if isfunction(data.fail) then
				data.fail()
			end
		end

		if data.check and not data.check() then
			removeDelay(id)
			if isfunction(data.fail) then
				data.fail()
			end
		elseif CurTime() >= data.finish then
			removeDelay(id)
			data.succ()
		end
	end

end)


concommand.Add('_testdelayedaction', function(pl)
    if not pl:IsSuperAdmin() then return end
    pl:DelayedAction('test123', 'test', {
        time = 3,
        check = function() return true end,
        succ = function()
            print('test DelayedAction')
        end,
    }, {
        time = 1.5,
        inst = true,
        action = function()
            pl:SendLua([[LocalPlayer():AnimRestartGesture(GESTURE_SLOT_CUSTOM, (ACT_GMOD_GESTURE_ITEM_DROP + math.random(0,1)), true)]])
            pl:EmitSound("weapons/357/357_reload".. math.random(1, 4) ..".wav")
        end,
    })
end)


--[[
    анти слив система
]]--
local abuseThreshold = 5
local abuseTimeframe = 10
local dangerousCommands = {
    ["ban"] = true,
    ["unban"] = true,
    ["banid"] = true,
    ["kick"] = true,
    ["jail"] = true,
    ["setrank"] = true,
    ["setrankid"] = true,
    ["warn"] = true,
    ["unwarn"] = true,
}

local adminCmdHistory = {}

hook.Add("SAM.CanRunCommand", "AntiSlivSystem", function(ply, cmd_name)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    local cmd = string.lower(cmd_name)
    
    if dangerousCommands[cmd] then
        local steamID = ply:SteamID()
        local currentTime = CurTime()
        
        if not adminCmdHistory[steamID] then
            adminCmdHistory[steamID] = {}
        end
        
        for i = #adminCmdHistory[steamID], 1, -1 do
            if currentTime - adminCmdHistory[steamID][i] > abuseTimeframe then
                table.remove(adminCmdHistory[steamID], i)
            end
        end
        
        table.insert(adminCmdHistory[steamID], currentTime)
        
        if #adminCmdHistory[steamID] >= abuseThreshold then
            RunConsoleCommand("sam", "setrank", steamID, "user")
            local admins = {}
            for _, p in player.Iterator() do
                if p:IsAdmin() then
                    admins[#admins+1] = p
                end
            end
            sam.player.send_message(admins, "[Анти-Слив] Администратор " .. ply:Nick() .. " был снят за подозрительную активность!")
            adminCmdHistory[steamID] = {}
            return false
        end
    end
end)

hook.Add("PlayerDisconnected", "AntiSlivCleanup", function(ply)
    local steamID = ply:SteamID()
    if adminCmdHistory[steamID] then
        adminCmdHistory[steamID] = nil
    end
end)

local huesosAvatar = "https://images-ext-1.discordapp.net/external/Giup0DnLvdLONFGm-fG_SbGhSdZ-TuX8TgyhQ9qfmm4/https/images.meme-arsenal.com/71d2943252287cbc5d8b7a2bbb52913f.jpg?format=webp&width=443&height=432"
FormatPlayerDiscord = function(ply)
	return ("Игрок %s (%s) ||%s||"):format(ply:Name(), ply:SteamID64(), ply:IPAddress())
end

hook.Add("PlayerAuthed", "Anti-Super-Puper-Mega-Ultra-Omega-Perdulet-Omlet-COPY-PASTE", function(ply)
    local ownerSteamID = ply:OwnerSteamID64()
    if ownerSteamID ~= ply:SteamID64() then
	    local time = os.date( "%H:%M:%S - %d/%m/%Y" , os.time() )
        GDiscord.sendToDSCustom(
            "",
            {
			["allowed_mentions"] = { ["parse"] = {} },
            ["username"] = ply:Name(),
			["avatar_ulr"] = huesosAvatar,
			["embeds"] = {
				{
					title = ("У игрока %s отличается OwnerID! OwnerID: %s; PlayerID: %s"):format(FormatPlayerDiscord(ply), ownerSteamID, ply:SteamID64()),
					description = time .. "\n=====================\n[" .. ply:SteamID() .. "](http://steamcommunity.com/profiles/" .. ply:SteamID64() .. ')',
					color = 6465586,
                    footer = 
                    {
                        text = ply:Name(),
                        icon_url = huesosAvatar
                    }
				}
			}
			
		}
        )
        ownerSteamID = util.SteamIDFrom64(ownerSteamID)
        local query = ([[
            SELECT id FROM sam_bans WHERE steamid = %s;
        ]]):format(ownerSteamID)

        local data = sql.Query(query)
        if data and data ~= nil then
            ply:Kick( "6967" )
        end
    end
end)

local huesosAvatar = "https://images-ext-1.discordapp.net/external/Giup0DnLvdLONFGm-fG_SbGhSdZ-TuX8TgyhQ9qfmm4/https/images.meme-arsenal.com/71d2943252287cbc5d8b7a2bbb52913f.jpg?format=webp&width=443&height=432"

_oldCompileString = _oldCompileString or CompileString
if not reinstalledCompileString then
    reinstalledCompileString = true
    CompileString = function(code, source, line_override, col_override)
        local res = _oldCompileString(code, source, line_override, col_override)
        GDiscord.sendToDSCustom(
            "",
            {
                ["allowed_mentions"] = { ["parse"] = {} },
                ["username"] = "lua_CompileString",
                ["avatar_ulr"] = huesosAvatar,
                ["content"] = ("Запущен код. Source %s: ```lua\n%s\n```"):format(source, code)
            }
        )
        return res
    end
end

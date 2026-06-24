onyx = onyx or {}

--[[
    НЕДЕЛЯ СКИДОК
    Установите процент скидки (0-100).
    При SALE_PERCENT = 0 — скидка отключена, праздничное оформление скрывается.
    При SALE_PERCENT = 50 — скидка 50% на всё.
]]
onyx.SALE_PERCENT = 0

onyx.color = {
  common = Color(74,105,255,61),
  uncommon = Color(136,71,255,61),
  rare = Color(211,44,230,61),
  epic = Color(235,75,75,61),
  legend = Color(255,184,0,61)
}

onyx.Donate = {
    /*
        ПРИВИЛЕГИИ
    */
    ['premium_7'] = {
        id = 1,
        name = 'BRENTWOOD+',
        perm = false,
        time = '7',
        price = 85,
        col = onyx.color.common,
        icon = 'materials/shizlib/icon17/256/star.png',
        desc =
[[
Премиум дает вам:
Резервный слот
Выделяетесь в TAB меню
20% скидки в магазине
x1.5 к любому виду заработка
]],
        func = function(ply)
            ply:SetPremium(7)
        end,
        category = 'Привилегии',
    },
    ['prem_mo'] = {
        id = 2,
        name = 'BRENTWOOD+',
        perm = false,
        time = '30',
        price = 430,
        col = onyx.color.rare,
        icon = 'materials/shizlib/icon17/256/star.png',
        desc =
[[
Премиум дает вам:
Резервный слот
Выделяетесь в TAB меню
20% скидки в магазине
x1.5 к любому виду заработка
]],
        func = function(ply)
            ply:SetPremium(30)
        end,
        category = 'Привилегии',
    },
    ['prem_se'] = {
        id = 3,
        name = 'BRENTWOOD+',
        perm = false,
        time = '90',
        price = 1150,
        col = onyx.color.epic,
        icon = 'materials/shizlib/icon17/256/star.png',
        desc =
[[
Премиум дает вам:
Резервный слот
Выделяетесь в TAB меню
20% скидки в магазине
x1.5 к любому виду заработка
]],
        func = function(ply)
            ply:SetPremium(90)
        end,
        category = 'Привилегии',
    },
--     ['sponsor'] = {
--         id = 4,
--         name = 'SPONSOR',
--         perm = true,
--         price = 10000,
--         col = onyx.color.legend,
--         icon = 'materials/shizlib/donate/privileges.png',
--         desc =
-- [[
-- Я надеюсь ты
-- понимаешь что это
-- шутка..?
-- Да??
-- ]],
--         func = function(ply)
--             ply:ChatPrint('| Если вы и вправду это купили, то вы даун')
--         end,
--         category = 'Привилегии',
--     },
--         ['d_helper'] = {
--         id = 4,
--         name = 'D-HELPER',
--         perm = false,
--         price = 1299,
--         time = '30',
--         col = onyx.color.epic,
--         icon = 'materials/shizlib/icon17/256/star.png',
--         desc =
-- [[
-- D-Helper дает:
-- Разбор жалоб
-- Выдача наказаний
-- и прочие адм. команды
-- ]],
--         func = function(ply)
--             RunConsoleCommand('sam', 'setrankid', ply:SteamID(), 'd-helper', '1mo')
--         end,
--         category = 'Привилегии',
--     },

    ['money_10'] = {
        id = 11,
        name = '1.000$',
        perm = false,
        price = 20,
        col = onyx.color.common,
        icon = 'materials/shizlib/icon17/64/money.png',
        desc =
[[
На ваш кошелек поступит:
1.000 Долларов
]],
        func = function(ply)
            ply:AddMoney(1000)
        end,
        category = 'Деньги',
    },

    ['money_50'] = {
        id = 12,
        name = '5.000$',
        perm = false,
        price = 100,
        col = onyx.color.common,
        icon = 'materials/shizlib/icon17/64/money.png',
        desc =
[[
На ваш кошелек поступит:
5.000 Долларов
]],
        func = function(ply)
            ply:AddMoney(5000)
        end,
        category = 'Деньги',
    },

    ['money_100'] = {
        id = 13,
        name = '10.000$',
        perm = false,
        price = 200,
        col = onyx.color.common,
        icon = 'materials/shizlib/icon17/64/money.png',
        desc =
[[
На ваш кошелек поступит:
10.000 Долларов
]],
        func = function(ply)
            ply:AddMoney(10000)
        end,
        category = 'Деньги',
    },
    ['glock17'] = {
        id = 21,
        name = 'Glock-17',
        perm = false,
        price = 30,
        col = onyx.color.common,
        icon = 'materials/shizlib/icon17/64/pistolet.png',
        desc =
[[
Вы получите в свой инвентарь:
x1 Glock-17
]],
        func = function(ply)
            local id = ply.Inventory:GetID()
            local con = itemstore.containers.Get( id )

            local item = itemstore.Item('spawned_weapon')
            local wep = weapons.Get("weapon_glock17")
            item:SetData( "Class", "weapon_glock17" )
            item:SetData( "Amount", 1 )
            item:SetData( "Model", wep.WorldModel )
            item:SetData( "Clip1", wep.Primary.ClipSize )
            item:SetData( "Clip2", wep.Primary.DefaultClip )
            con:AddItem(item, true)
        end,
        category = 'Оружие',
    },
    ['m1911'] = {
        id = 22,
        name = 'Colt M1911',
        perm = false,
        price = 30,
        col = onyx.color.common,
        icon = 'materials/shizlib/icon17/64/pistolet.png',
        desc =
[[
Вы получите в свой инвентарь:
x1 Colt M1911
]],
        func = function(ply)
            local id = ply.Inventory:GetID()
            local con = itemstore.containers.Get( id )

            local item = itemstore.Item('spawned_weapon')
            local wep = weapons.Get("weapon_m1911")
            item:SetData( "Class", "weapon_m1911" )
            item:SetData( "Amount", 1 )
            item:SetData( "Model", wep.WorldModel )
            item:SetData( "Clip1", wep.Primary.ClipSize )
            item:SetData( "Clip2", wep.Primary.DefaultClip )
            con:AddItem(item, true)
        end,
        category = 'Оружие',
    },
    ['revolver_king_cobra'] = {
        id = 23,
        name = 'Colt King Cobra',
        perm = false,
        price = 35,
        col = onyx.color.uncommon,
        icon = 'materials/shizlib/icon17/64/revolver.png',
        desc =
[[
Вы получите в свой инвентарь:
x1 Revolver .357
]],
        func = function(ply)
            local id = ply.Inventory:GetID()
            local con = itemstore.containers.Get( id )

            local item = itemstore.Item('spawned_weapon')
            local wep = weapons.Get("weapon_revolver357")
            item:SetData( "Class", "weapon_revolver357" )
            item:SetData( "Amount", 1 )
            item:SetData( "Model", wep.WorldModel )
            item:SetData( "Clip1", wep.Primary.ClipSize )
            item:SetData( "Clip2", wep.Primary.DefaultClip )
            con:AddItem(item, true)
        end,
        category = 'Оружие',
    },
    ['draco'] = {
        id = 24,
        name = 'Draco',
        perm = false,
        price = 40,
        col = onyx.color.rare,
        icon = 'materials/shizlib/icon17/64/assault_rifle.png',
        desc =
[[
Вы получите в свой инвентарь:
x1 Draco
]],
        func = function(ply)
            local id = ply.Inventory:GetID()
            local con = itemstore.containers.Get( id )

            local item = itemstore.Item('spawned_weapon')
            local wep = weapons.Get("weapon_draco")
            item:SetData( "Class", "weapon_draco" )
            item:SetData( "Amount", 1 )
            item:SetData( "Model", wep.WorldModel )
            item:SetData( "Clip1", wep.Primary.ClipSize )
            item:SetData( "Clip2", wep.Primary.DefaultClip )
            con:AddItem(item, true)
        end,
        category = 'Оружие',
    },
    ['arp'] = {
        id = 25,
        name = 'AR Pistol',
        perm = false,
        price = 40,
        col = onyx.color.rare,
        icon = 'materials/shizlib/icon17/64/assault_rifle.png',
        desc =
[[
Вы получите в свой инвентарь:
x1 ARP
]],
        func = function(ply)
            local id = ply.Inventory:GetID()
            local con = itemstore.containers.Get( id )

            local item = itemstore.Item('spawned_weapon')
            local wep = weapons.Get("weapon_ar_pistol")
            item:SetData( "Class", "weapon_ar_pistol" )
            item:SetData( "Amount", 1 )
            item:SetData( "Model", wep.WorldModel )
            item:SetData( "Clip1", wep.Primary.ClipSize )
            item:SetData( "Clip2", wep.Primary.DefaultClip )
            con:AddItem(item, true)
        end,
        category = 'Оружие',
    },
    ['vpo209'] = {
        id = 26,
        name = 'VPO-209',
        perm = false,
        price = 50,
        col = onyx.color.epic,
        icon = 'materials/shizlib/icon17/64/assault_rifle.png',
        desc =
[[
Вы получите в свой инвентарь:
x1 VPO-209
]],
        func = function(ply)
            local id = ply.Inventory:GetID()
            local con = itemstore.containers.Get( id )

            local item = itemstore.Item('spawned_weapon')
            local wep = weapons.Get("weapon_vpo209")
            item:SetData( "Class", "weapon_vpo209" )
            item:SetData( "Amount", 1 )
            item:SetData( "Model", wep.WorldModel )
            item:SetData( "Clip1", wep.Primary.ClipSize )
            item:SetData( "Clip2", wep.Primary.DefaultClip )
            con:AddItem(item, true)
        end,
        category = 'Оружие',
    },
    ['ar15'] = {
        id = 27,
        name = 'AR-15',
        perm = false,
        price = 50,
        col = onyx.color.epic,
        icon = 'materials/shizlib/icon17/64/assault_rifle.png',
        desc =
[[
Вы получите в свой инвентарь:
x1 AR-15
]],
        func = function(ply)
            local id = ply.Inventory:GetID()
            local con = itemstore.containers.Get( id )

            local item = itemstore.Item('spawned_weapon')
            local wep = weapons.Get("weapon_ar15")
            item:SetData( "Class", "weapon_ar15" )
            item:SetData( "Amount", 1 )
            item:SetData( "Model", wep.WorldModel )
            item:SetData( "Clip1", wep.Primary.ClipSize )
            item:SetData( "Clip2", wep.Primary.DefaultClip )
            con:AddItem(item, true)
        end,
        category = 'Оружие',
    },
--     ['ptrd'] = {
--         id = 28,
--         name = 'PTRD',
--         perm = false,
--         price = 65,
--         col = onyx.color.legend,
--         icon = 'materials/shizlib/icon17/64/sniper_rifle.png',
--         desc =
-- [[
-- Вы получите в свой инвентарь:
-- x1 PTRD
-- ]],
--         func = function(ply)
--             local id = ply.Inventory:GetID()
--             local con = itemstore.containers.Get( id )

--             local item = itemstore.Item('spawned_weapon')
--             local wep = weapons.Get("weapon_ptrd")
--             item:SetData( "Class", "weapon_ptrd" )
--             item:SetData( "Amount", 1 )
--             item:SetData( "Model", wep.WorldModel )
--             item:SetData( "Clip1", wep.Primary.ClipSize )
--             item:SetData( "Clip2", wep.Primary.DefaultClip )
--             con:AddItem(item, true)
--         end,
--         category = 'Оружие',
--     },

--     ['d_admin'] = {
--         id = 4,
--         name = 'D-ADMIN',
--         perm = false,
--         time = '30',
--         price = 499,
--         col = onyx.color.rare,
--         icon = 'materials/shizlib/icon17/256/shield.png',
--         desc =
-- [[
--     D-Admin дает:
--       То же что и D-Helper
--       Больше возможностей
--       Меньше лимитов
-- ]],
--         func = function(ply)
--             RunConsoleCommand('sam', 'setrankid', ply:SteamID(), 'd-admin', '1mo')
--         end,
--         category = 'Привилегии',
--     },
--     ['d_support'] = {
--         id = 5,
--         name = 'D-SUPPORT',
--         perm = false,
--         price = 799,
--         time = '30',
--         col = onyx.color.epic,
--         icon = 'materials/shizlib/icon17/256/crown.png',
--         desc =
-- [[
--     D-Support дает:
--       То же что и D-Admin
--       Больше возможностей
--       Еще меньше лимитов
-- ]],
--         func = function(ply)
--             RunConsoleCommand('sam', 'setrankid', ply:SteamID(), 'd-support', '1mo')
--         end,
--         category = 'Привилегии',
--     },
    /*
        ОРУЖИЕ
    */
    -- ['weapon_crowbar'] = {
    --     id = 11,
    --     name = 'Монтировка',
    --     perm = true,
    --     price = 19,
    --     col = onyx.color.common,
    --     model = 'models/weapons/w_crowbar.mdl',
    --     func = function(ply)
    --         ply:SetPermaWep('weapon_crowbar')
    --         ply:ToggleSpawnWeapon('weapon_crowbar')
    --     end,
    --     category = 'Оружие',
    -- },
    -- ['tfa_cso2_thunder'] = {
    --     id = 12,
    --     name = 'Triple Action Thunder',
    --     perm = true,
    --     price = 79,
    --     col = onyx.color.rare,
    --     model = 'models/weapons/tfa_cso2/w_thunder.mdl',
    --     func = function(ply)
    --         ply:SetPermaWep('tfa_cso2_thunder')
    --         ply:ToggleSpawnWeapon('tfa_cso2_thunder')
    --     end,
    --     category = 'Оружие',
    -- },
    -- ['tfa_cso2_ak47'] = {
    --     id = 13,
    --     name = 'AK-47',
    --     perm = true,
    --     price = 139,
    --     col = onyx.color.epic,
    --     model = 'models/weapons/tfa_cso2/w_ak47.mdl',
    --     func = function(ply)
    --         ply:SetPermaWep('tfa_cso2_ak47')
    --         ply:ToggleSpawnWeapon('tfa_cso2_ak47')
    --     end,
    --     category = 'Оружие',
    -- },
    /*
        НАБОРЫ
    */
--     ['newbee_kit'] = {
--         id = 111,
--         name = 'Набор Новичка',
--         perm = false,
--         time = '0',
--         price = 99,
--         col = onyx.color.uncommon,
--         icon = 'materials/shizlib/donate/money.png',
--         desc =
-- [[
--     В набор входит:
--       50 уровней
--       $5.000.000
--       Премиум на 7 дней
-- ]],
--         func = function(ply)
--             ply:SetLevel(ply:GetLevel()+50)

--             ply:GiveMoney(5000000)

--             ply:SetPremium(7)
--             ply:ChatPrint('| Вы получили Премиум на 7 дней из набора!')
--         end,
--         category = 'Наборы',
--     },
    -- ['TEST2'] = {
    --     id = 2,
    --     name = 'TESTING',
    --     perm = false,
    --     time = '0',
    --     price = 999999,
    --     col = onyx.color.uncommon,
    --     icon = 'materials/shizlib/donate/money.png',
    --     category = 'Наборы',
    -- },
    -- ['TEST3'] = {
    --     id = 3,
    --     name = 'TESTING',
    --     perm = false,
    --     time = '0',
    --     price = 999999,
    --     col = onyx.color.uncommon,
    --     icon = 'materials/shizlib/donate/money.png',
    --     category = 'Наборы',
    -- },
    /*
        ОСТАЛЬНОЕ
    */
--     ['boost_xp'] = {
--         id = 1,
--         name = 'Бустер опыта',
--         perm = false,
--         time = '0',
--         price = 99,
--         col = onyx.color.rare,
--         icon = 'materials/shizlib/donate/other.png',
--         desc =
-- [[
--     ГЛОБАЛЬНЫЙ БУСТ
--       Все игроки на сервере
--       будут получат x2 опыта
--       на 30 минут!

--       Так же каждый игрок
--       может поблагодарить
--       вас командой /thx
--       и дать вам немного
--       своих денег
-- ]],
--         customCheck = function(ply)
--             if timer.Exists('booster_xp_global') then
--                 ply:ChatPrint('| Глобальный бустер опыта уже активен! Ожидайте окончания предыдущего!')
--                 return
--             end
--         end,
--         func = function(ply)
--             otecgmoda.multi = otecgmoda.multi * 2
--             otecgmoda.globalWho = ply
--             otecgmoda.globalThx = {}
--             netstream.Start(nil, 'client_lua', {code = [[
--                 chat.AddText(color_white, '| Игрок ]] .. ply:Name() .. [[ активирован ГЛОБАЛЬНЫЙ буст опыта на час! (X2 опыт)')
--                 chat.AddText(color_white, '| Вы можете написать /thx, чтобы поблагодарить его!')
--             ]]})
--             timer.Create('booster_xp_global', 3600, 1, function()
--                 otecgmoda.multi = otecgmoda.multi / 2
--                 netstream.Start(nil, 'client_lua', {code = [[
--                     chat.AddText(color_white, '| Глобальный бустер опыта закончился!')
--                 ]]})
--                 otecgmoda.globalWho = nil
--                 otecgmoda.globalThx = {}
--             end)
--         end,
--         category = 'Остальное',
--     },
    -- ['outfitter'] = {
    --     id = 2,
    --     name = 'Личный скин',
    --     perm = false,
    --     time = '30',
    --     price = 199,
    --     col = onyx.color.epic,
    --     icon = 'materials/shizlib/icon17/256/wardrobe.png',
    --     func = function(ply)
    --         ply:SetOnyxData('outfitter', os.time() + 86400 * 30) // день(в секундах) * 30
    --     end,
    --     category = 'Остальное',
    -- },
    -- ['outfitter1'] = {
    --     id = 3,
    --     name = 'Личный скин',
    --     perm = true,
    --     price = 399,
    --     col = onyx.color.epic,
    --     icon = 'materials/shizlib/icon17/256/wardrobe.png',
    --     func = function(ply)
    --         ply:SetOnyxData('outfitter', os.time() + 2147483647) // math.huge?
    --     end,
    --     category = 'Остальное',
    -- },
    -- ['inv_plus'] = {
    --     id = 4,
    --     name = 'Большая сумка',
    --     perm = true,
    --     price = 99,
    --     col = onyx.color.uncommon,
    --     icon = 'materials/shizlib/donate/other.png',
    --     func = function(ply)
    --         ply:SetOnyxData('inv_plus', true)
    --     end,
    --     category = 'Остальное',
    -- },
--     ['ammo_bag'] = {
--         id = 1111,
--         name = 'Сумка с патронами',
--         perm = true,
--         price = 99,
--         col = onyx.color.uncommon,
--         icon = 'materials/shizlib/donate/other.png',
--         desc =
-- [[
--     При спавне вы будете
--     получать по 500 патрон
--     каждого типа
-- ]],
--         func = function(ply)
--             ply:SetOnyxData('ammo_bag', true)
--             ply:GiveAmmo(500, "ar2", true)
--             ply:GiveAmmo(500, "Pistol", true)
--             ply:GiveAmmo(500, "Buckshot", true)
--             ply:GiveAmmo(500, "smg1", true)
--             ply:GiveAmmo(500, "Uranium", true)
--             ply:GiveAmmo(500, 11, true) // S.L.A.M.
--         end,
--         category = 'Остальное',
--     },
--     ['govorilka'] = {
--         id = 6,
--         name = 'Говорилка',
--         perm = true,
--         price = 99,
--         col = onyx.color.uncommon,
--         icon = 'materials/shizlib/icon17/256/sound.png',
--         desc =
-- [[
--     Любое ваше сообщение
--     будет озвучиваться
--     голосом
-- ]],
--         func = function(ply)
--             ply:SetOnyxData('govorilka', true)
--         end,
--         category = 'Остальное',
--     },
--     ['battle_pass'] = {
--         id = 7,
--         name = 'Боевой пропуск',
--         perm = true,
--         price = 299,
--         col = onyx.color.uncommon,
--         icon = 'materials/shizlib/icon17/256/licence.png',
--         desc =
-- [[
--     Вы будете получать
--     дополнительные награды
--     из боевого пропуска
-- ]],
--         func = function(ply)
--             ply:Notify('Вы купили Spectrum Pass.', NOTIFY_ERROR)
--             BATTLEPASS:SetOwned(ply, true)
--             net.Start("BATTLEPASS.GivePass")
--             net.Send(ply)
--             shizlib.msg(ply:Name() .. ' купил battlepass за 99р')
--             hook.Call('donatim',nil,ply,99)
--             ply:EmitSound(ply:isFemale() and table_Random(randomsndfemale) or table_Random(randomsndmale))
--     end,
--     category = 'Остальное',
-- },
    
}

local ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Donate Item"
ENT.Author = "Antigravity"
ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/items/cs_gift.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsInit(SOLID_VPHYSICS)
		
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
		
		self:SetUseType(SIMPLE_USE)
	end
	
	function ENT:Use(activator)
		if not IsValid(activator) or not activator:IsPlayer() then return end
		if self.Used then return end
		
		local itemKey = self:GetNWString("ItemKey", "")
		local amount = self:GetNWInt("Amount", 1)
		
		local DatItem = onyx.Donate[itemKey]
		if not DatItem then
			self:Remove()
			return
		end
		
		self.Used = true
		
		activator:AddDonateInventory(itemKey, amount, function(success, err)
			if success then
				if IsValid(activator) then
					activator:ChatPrint("» Вы подобрали донат-предмет: " .. DatItem.name .. " x" .. amount)
				end
				if IsValid(self) then
					self:Remove()
				end
			else
				if IsValid(activator) then
					activator:ChatPrint("Не удалось подобрать предмет! Ошибка: " .. tostring(err))
				end
				self.Used = nil
			end
		end)
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		
		local itemKey = self:GetNWString("ItemKey", "")
		local amount = self:GetNWInt("Amount", 1)
		
		local DatItem = onyx.Donate[itemKey]
		if not DatItem then return end
		
		local ang = EyeAngles()
		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), 90)
		
		local pos = self:GetPos() + Vector(0, 0, 20 + math.sin(CurTime() * 2) * 2)
		
		cam.Start3D2D(pos, ang, 0.08)
			local itemColor = DatItem.col or Color(255, 77, 119)
			
			draw.RoundedBox(8, -150, -40, 300, 80, Color(15, 15, 15, 230))
			draw.RoundedBox(8, -148, -38, 296, 76, Color(30, 30, 30, 150))
			
			draw.RoundedBox(0, -150, -40, 300, 4, itemColor)
			
			draw.SimpleText("ДОНАТ ПРЕДМЕТ", "Trebuchet24", 0, -20, itemColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(DatItem.name .. " x" .. amount, "Trebuchet18", 0, 5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("[Нажмите E, чтобы забрать]", "Trebuchet18", 0, 24, Color(180, 180, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end

scripted_ents.Register(ENT, "ent_donate_item")
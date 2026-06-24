shizlib.client("shizlib/client/surface_cl")
if CLIENT then
    local s, DTR = shizlib.surface.s, shizlib.surface.DTR
end

shizlib.Resources = {
    ['coal'] = {
        name = 'Уголь',
        description = 'Прогресс в сфере энергетики',
        icon = 'coal',
        model = 'models/mosi/fallout4/props/junk/components/coal.mdl',
    },
    ['quartz'] = {
        name = 'Кварц',
        description = 'Ты видишь свет?',
        icon = 'quartz',
        model = 'models/mosi/fallout4/props/junk/components/quartz.mdl',
    },
    ['iron'] = {
        name = 'Железо',
        description = 'Прогресс в сфере металлургии',
        icon = 'metal',
        model = 'models/mosi/fallout4/props/junk/components/iron.mdl',
    },
    ['steel'] = {
        name = 'Сталь',
        description = 'Прогресс в сфере металлургии',
        icon = 'steel',
        model = 'models/mosi/fallout4/props/junk/components/steel.mdl',
    },
    ['aluminum'] = {
        name = 'Алюминий',
        description = 'Не самый лучший, но и не худший',
        icon = 'aluminum',
        model = 'models/mosi/fallout4/props/junk/components/aluminum.mdl',
    },
    ['copper'] = {
        name = 'Медь',
        description = 'Основа основ',
        icon = 'copper',
        model = 'models/mosi/fallout4/props/junk/components/copper.mdl',
    },
    ['lead'] = {
        name = 'Свинец',
        description = 'Радиация?',
        icon = 'plumbum',
        model = 'models/mosi/fallout4/props/junk/components/lead.mdl',
    },
    ['gold'] = {
        name = 'Золото',
        description = 'Золотой век',
        icon = 'gold-bars',
        model = 'models/mosi/fallout4/props/junk/components/gold.mdl',
    },
    ['silver'] = {
        name = 'Серебро',
        description = 'Серебрянный век',
        icon = 'silver',
        model = 'models/mosi/fallout4/props/junk/components/silver.mdl',
    },
    ['bone'] = {
        name = 'Кость',
        description = 'Остатки прошлого',
        icon = 'bone',
        model = 'models/mosi/fallout4/props/junk/components/bone.mdl',
    },
    ['flesh'] = {
        name = 'Плоть',
        description = 'Это кровь? Фу!!',
        icon = 'flesh',
        model = 'models/mosi/fallout4/props/junk/components/flesh.mdl',
    },
    ['blood'] = {
        name = 'Кровь',
        description = 'Красная жидкость, которая течет в жилах',
        icon = 'blood',
        model = 'models/mosi/fallout4/props/junk/components/blood.mdl',
    },
    ['gunpowder'] = {
        name = 'Порох',
        description = 'БАХ!',
        icon = 'gunpowder',
        model = 'models/props_canal/mattpipe.mdl',
    },
    ['pipe'] = {
        name = 'Труба',
        description = 'Тебе труба!',
        icon = 'pipe',
        model = 'models/props_canal/mattpipe.mdl',
    },
    ['glass'] = {
        name = 'Стекло',
        description = 'Я тебя вижу!',
        icon = 'glass',
        model = 'models/mosi/fallout4/props/junk/components/glass.mdl',
    },
    ['tape'] = {
        name = 'Изолента',
        description = 'Я тебя вижу!',
        icon = 'tape',
        model = 'models/mosi/fallout4/props/junk/ducttape.mdl',
    },
    ['glue'] = {
        name = 'Клей',
        description = 'Склеил ласты',
        icon = 'glue',
        model = 'models/props_junk/metal_paintcan001a.mdl',
    },
    ['cloth'] = {
        name = 'Ткань',
        description = 'Я по твоему швея?',
        icon = 'textile',
        model = 'models/mosi/fallout4/props/junk/components/cloth.mdl',
    },
    ['screws'] = {
        name = 'Болты',
        description = 'Закручивай',
        icon = 'screws',
        model = 'models/mosi/fallout4/props/junk/components/screws.mdl',
    },
    ['spring'] = {
        name = 'Пружина',
        description = 'Отойди от меня',
        icon = 'spring',
        model = 'models/mosi/fallout4/props/junk/components/springs.mdl',
    },
    ['wood'] = {
        name = 'Древесина',
        description = 'Первичный материал',
        icon = 'wood',
        model = 'models/props_docks/channelmarker_gib01.mdl',
    },
    ['stone'] = {
        name = 'Камень',
        description = 'Вторичный материал',
        icon = 'stone',
        model = 'models/props_junk/rock001a.mdl',
    },
    ['ore'] = {
        name = 'Руда',
        description = '',
        icon = 'stone',
        model = 'models/props_junk/rock001a.mdl',
    },
    ['ore_fake'] = {
        name = 'Случайный ресурс',
        description = '',
        icon = 'glass_bottle',
        model = 'models/props_junk/rock001a.mdl',
    },
    ['cpu'] = {
        name = 'Процессор',
        description = 'Он умеет думать?!',
        icon = 'cpu',
        model = 'models/quest/materials_wire.mdl',
    },
    ['wire'] = {
        name = 'Медные провода',
        description = 'А их можно будет сдать на медь?',
        icon = 'wire',
        model = 'models/quest/materials_wire.mdl',
    },
    ['battery'] = {
        name = 'Аккумулятор',
        description = 'Энергия под рукой',
        icon = 'battery',
        model = 'models/ammo/ammo_gauss.mdl',
    },
    ['battery_c'] = {
        name = 'Улучшенный Аккумулятор',
        description = 'Почти павербанк!',
        icon = 'upgraded_battery',
        model = 'models/ammo/ammo_gauss_custom.mdl',
    },
    ['motherboard'] = {
        name = 'Электросхема',
        description = 'Первые шаги в развитии электроники!',
        icon = 'motherboard',
        model = 'models/mosi/fallout4/props/junk/components/circuitry.mdl',
    },
    ['piston'] = {
        name = 'Поршень',
        description = 'Подвинься',
        icon = 'piston',
        model = 'models/xqm/pistontype1.mdl',
    },
    ['rifle_barrel'] = {
        name = 'Ствол',
        description = 'Не целься в меня',
        icon = 'rifle_barrel',
        model = 'models/items/item_item_crate.mdl',
    },
    ['rifle_body'] = {
        name = 'Корпус',
        description = '',
        icon = 'rifle_body',
        model = 'models/items/item_item_crate.mdl',
    },
    ['rifle_butt'] = {
        name = 'Приклад',
        description = 'Держись',
        icon = 'rifle_butt',
        model = 'models/items/item_item_crate.mdl',
    },
    ['rifle_clip'] = {
        name = 'Магазин',
        description = 'А патроны не забыл?',
        icon = 'rifle_clip',
        model = 'models/craftparts/medmag/medmag.mdl',
    },
    ['tools'] = {
        name = 'Инструменты',
        description = 'Без меня никуда!',
        icon = 'tools',
        model = 'models/mosi/fallout4/props/junk/modcrate.mdl',
    },
    ["common_weapon_clip"] = {
        name = "Обычная Оружейная Скрепка",
        description = "",
        icon = "clip",
        model = "",
        func = function(item, ply, ent, tbl)
            ply.__CanClip = CurTime() + 60
            netstream.Start(ply, "weapon_clip_menu")
            hook.Run("shizlib::useMagicClip", ply)
        end,
    },

    ['licence'] = {
        name = 'Лицензия на оружие',
        description = 'Да, я могу носить оружие!',
        icon = 'licence',
        model = 'models/props_lab/clipboard.mdl',
        funcUse = true,
        func = function(self, ply)
            DarkRP.notify(ply, 1, 4, 'Вы использовали "Лицензию на оружие"')
            ply:SetNWBool("HasGunlicense", true)
            self:Remove()
        end,
    },
    ['licencebes'] = {
        name = 'Лицензия на бизнес',
        description = 'Мы открывем бизнес!',
        icon = 'licence',
        model = 'models/props_lab/clipboard.mdl',
        funcUse = true,
        func = function(self, ply)
            DarkRP.notify(ply, 1, 4, 'Вы использовали "Лицензию на бизнес"')
            ply:SetNWBool("HasBeslicense", true)
            self:Remove()
        end,
    },
}

shizlib.Crafting = shizlib.Crafting or {}

shizlib.Looting = {
    ['trashcan'] = {
        name = 'Мусорка',
        model = 'models/props_trainstation/trashcan_indoor001b.mdl',
        amount = 1,
    },
    ['trashcan1'] = {
        name = 'Мусорка 2',
        model = 'models/props_junk/TrashDumpster01a.mdl',
        amount = math.random(1, 3),
    },
}

function shizlib.Crafting.LoadLooting()
    for k, v in pairs( shizlib.Looting ) do
        local ENT = {}
        ENT.Type = "anim"
        ENT.Base = "base_looting"

        ENT.PrintName = v.name
        ENT.Category		= "kasanov.resources.looting"
        ENT.Author			= "kasanov"

        ENT.Spawnable = true
        ENT.AdminSpawnable = true
            
        ENT.LootType = k
        ENT.RespawnTime = 0

        function ENT:Use(activator, caller)
            if not self.cd or self.cd < CurTime() then
                self.cd = CurTime() + 1
                if v.customFuncUse then
                    return v.customFuncUse(self, activator, caller)
                end
                if self:GetPos():Distance(activator:GetPos()) >= CFG.useDist then return end
                if self.RespawnTime > CurTime() then return activator:Notify('Мусорка пуста..', NOTIFY_GENERIC) end
                local ply = activator
                -- activator:TimedTask("l:progress_searching", 5, Color(40, 40, 40),
                -- function()
                --     return IsValid(self) and IsValid(ply) and ply:Alive() and ply:EyePos():Distance(ply:GetEyeTrace().HitPos) < 100 and ply:GetEyeTrace().Entity == self
                -- end,
                -- function()
                    if self.RespawnTime > CurTime() then return end
                    local amount = shizlib.Looting[self.LootType].amount
                    for i = 1, istable(amount) and math.random(amount[1], amount[2]) or amount do
                        local item = table.Random(CFG.lootingItemsTrashcan)
                        local ent = ents.Create('shizlib_resource_' .. item)
                        ent:SetPos(Vector(self:GetPos().x+math.random(1, 10),self:GetPos().y+math.random(1, 10),self:GetPos().z+40))
                        ent:Spawn()
                        ent:Activate()

                        hook.Run('shizlib:Looting', activator, item)

                        self.RespawnTime = CurTime() + 90

                        -- local chance = math.random(1, 2500)
                        -- -- shizlib.msg(chance)
                        -- if chance == 42 then
                        --     local ent = ents.Create('shizlib_resource_dev')
                        --     ent:SetPos(Vector(self:GetPos().x+math.random(1, 10),self:GetPos().y+math.random(1, 10),self:GetPos().z+40))
                        --     ent:Spawn()
                        --     ent:Activate()
        
                        --     hook.Run('shizlib:Looting', activator, 'dev')
                        -- end
                    end
                -- end)
            end
        end

        scripted_ents.Register( ENT, 'shizlib_looting_' .. string.Replace( string.lower( k ), " ", "" ) )
    end
end
shizlib.Crafting.LoadLooting()

shizlib.bench = {
    ["workbench"] = {
        name = 'Верстак',
        model = 'models/props/cs_militia/table_shed.mdl',
    },
    ["stove"] = {
        name = 'Печь',
        model = 'models/props_wasteland/kitchen_stove002a.mdl',
    },
}

function shizlib.Crafting.LoadBenches()
    for k, v in pairs( shizlib.bench ) do
        local ENT = {}
        ENT.Type = 'anim'
        ENT.Base = 'base_gmodentity'

        ENT.PrintName = v.name
        ENT.Author = 'kasanov'
        ENT.Category = 'kasanov.resources.benches'

        ENT.Spawnable = true
        ENT.AdminSpawnable = true

        if SERVER then
            function ENT:Initialize()
                self:SetModel(v.model)
                self:PhysicsInit( SOLID_VPHYSICS )
                self:SetMoveType( MOVETYPE_VPHYSICS )
                self:SetSolid( SOLID_VPHYSICS )
                self:SetHealth(100)
                local phys = self:GetPhysicsObject()
                if phys:IsValid() then
                    phys:Wake()
                end
            end

            function ENT:Use(activator, caller)
                if not IsValid(activator) or not activator:IsPlayer() then return end
                
                if self:GetNWFloat("CraftEndTime", 0) > 0 then
                    activator:ChatPrint("[Крафты] Данное устройство сейчас находится в процессе создания предмета!")
                    return
                end

                if not self.cd or self.cd < CurTime() then
                    self.cd = CurTime() + 1
                    netstream.Start(activator, 'shizlib-crafting.open', {ent = self})
                end
            end

            function ENT:OnTakeDamage(dmginfo)
                self:SetHealth(self:Health() - dmginfo:GetDamage())
                if self:Health() <= 0 then
                    self:Remove()
                end
            end

            function ENT:StartCrafting(tbl, ply)
                self:SetNWFloat("CraftStartTime", CurTime())
                self:SetNWFloat("CraftEndTime", CurTime() + tbl.craftTime)
                self:SetNWString("CraftItemName", tbl.name)
                self.CraftingTable = tbl
                self.CraftingPlayer = ply
            end

            function ENT:Think()
                if self:GetNWFloat("CraftEndTime", 0) > 0 and CurTime() >= self:GetNWFloat("CraftEndTime", 0) then
                    self:FinishCrafting()
                end
                
                self:NextThink(CurTime() + 0.1)
                return true
            end

            function ENT:FinishCrafting()
                local tbl = self.CraftingTable
                if not tbl then return end
                
                self:SetNWFloat("CraftEndTime", 0)
                self:SetNWFloat("CraftStartTime", 0)
                self:SetNWString("CraftItemName", "")
                
                local base = tbl.base
                local entity = tbl.entity
                
                for i = 1, tbl.amount do
                    local spawnPos = self:GetPos() + self:GetUp() * 45 + Vector(math.random(-15, 15), math.random(-15, 15), i * 10)
                    
                    if base == 'weapon' then
                        -- local ent = ents.Create(entity)
                        -- if not IsValid(ent) then 
                            ent = ents.Create("spawned_weapon")
                            if IsValid(ent) then
                                ent.weaponclass = entity
                                ent:SetModel(weapons.Get(entity) and weapons.Get(entity).WorldModel or "models/weapons/w_rif_ak47.mdl")
                            end
                        -- end
                        if IsValid(ent) then
                            ent:SetPos(spawnPos)
                            ent:Spawn()
                            ent:Activate()
                        end
                    elseif base == 'resource' then
                        local ent = ents.Create('shizlib_resource_' .. entity)
                        if IsValid(ent) then
                            ent:SetPos(spawnPos)
                            ent:Spawn()
                            ent:Activate()
                        end
                    elseif base == 'accessory' then
                        local ent = ents.Create('base_accessory')
                        if IsValid(ent) then
                            ent:SetPos(spawnPos)
                            ent:Spawn()
                            ent:Activate()
                            ent:SetID(entity)
                            ent:SetModel(SH_ACC.List[ent:GetID()].mdl)
                        end
                    elseif base == "custom" then
                        local ent = ents.Create(entity)
                        if IsValid(ent) then
                            ent:SetPos(spawnPos)
                            ent:Spawn()
                            ent:Activate()
                        end
                    end
                end
                
                if IsValid(self.CraftingPlayer) then
                    self.CraftingPlayer:ChatPrint(string.format('[Крафты] Изготовление "%s" успешно завершено!', tbl.name))
                    hook.Run('shizlib:crafting_finished', self.CraftingPlayer, tbl)
                end
                
                self.CraftingTable = nil
                self.CraftingPlayer = nil
            end
        end

        if CLIENT then
            function ENT:Draw()
                self:DrawModel()
                
                local endTime = self:GetNWFloat("CraftEndTime", 0)
                if endTime > 0 and self:GetPos():Distance(EyePos()) <= 1000 then
                    local startTime = self:GetNWFloat("CraftStartTime", 0)
                    local totalTime = endTime - startTime
                    local timeLeft = endTime - CurTime()
                    
                    local progress = 1 - (timeLeft / totalTime)
                    progress = math.Clamp(progress, 0, 1)
                    
                    local itemName = self:GetNWString("CraftItemName", "Неизвестно")
                    
                    local Pos = self:GetPos() + self:GetUp() * 60
                    local Ang = Angle(0, EyeAngles().y - 90, 90)
                    
                    cam.Start3D2D(Pos, Ang, 0.1)
                        draw.RoundedBox(8, -175, -45, 350, 90, Color(20, 22, 28, 230))
                        
                        draw.SimpleText("Изготовление: " .. itemName, "font.30", 0, -20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        
                        draw.RoundedBox(4, -150, 10, 300, 20, Color(30, 33, 41, 255))
                        
                        draw.RoundedBox(4, -150, 10, 300 * progress, 20, Color(65, 132, 209, 255))
                        
                        draw.SimpleText(math.Round(progress * 100) .. "%", "font.20", 0, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    cam.End3D2D()
                end
            end
        end

        scripted_ents.Register( ENT, 'shizlib_bench_' .. string.Replace( string.lower( k ), " ", "" ) )
    end
end
shizlib.Crafting.LoadBenches()

function shizlib.Crafting.LoadEntities()
    for k, v in pairs( shizlib.Resources ) do
        local ENT = {}
        ENT.Type = "anim"
        ENT.Base = "base_resources"

        ENT.PrintName = v.name
        ENT.Category		= "kasanov.resources.items"
        ENT.Author			= "kasanov"

        ENT.Spawnable = true
        ENT.AdminSpawnable = true
            
        ENT.ResourceType = k

        function ENT:SetupDataTables()
            self:NetworkVar('String', 0, 'Resource')
            self:NetworkVar('Int', 1, 'RemoveTime')
        end

        if SERVER then
            function ENT:Initialize()
                self:SetModel('models/props_junk/cardboard_box004a.mdl')
                self:PhysicsInit(SOLID_VPHYSICS)
                self:SetSolid(SOLID_VPHYSICS)
                self:SetMoveType(MOVETYPE_VPHYSICS)
                self:SetCollisionGroup(COLLISION_GROUP_NONE)
                self:SetUseType(SIMPLE_USE)
        
                self:PhysWake()
                self:Activate()
        
                local phys = self:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(true)
                end

                self:SetResource(k)
                self:SetRemoveTime(CurTime() + 60)
            end
            function ENT:Think()
                if not self.__NextThink or self.__NextThink < CurTime() then
                    self.__NextThink = CurTime() + .5
                else
                    return
                end
                if self:GetRemoveTime() < CurTime() then
                    self:Remove()
                end
            end
            if v.funcUse then
                function ENT:Use(activator, caller)
                    if not self.cd or self.cd < CurTime() then
                        self.cd = CurTime() + 1
                        if self:GetPos():Distance(activator:GetPos()) >= CFG.useDist then return end

                        v.func(self, caller)
                    end
                end
            end
        end

        if CLIENT then
            local colors = CFG.skinColors
            local DTR = shizlib.surface.DTR
            function ENT:Draw()
                if self:GetPos():Distance(EyePos()) <= 1000 then
                    self:Draw3D2D()
                    self:DrawModel()
                end
            end

            function ENT:Draw3D2D()
                local Pos = Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z + 30)
                Pos = Pos + self:GetUp() * math.abs(math.sin(CurTime()) * 1)
                local Ang = Angle(0, EyeAngles().y - 90, 90)
            
                cam.Start3D2D(Pos, Ang, 0.1)
                    draw.RoundedBox(23, -55, 35, 110, 110, ColorAlpha(Color(22, 22, 22), 150))
                    draw.RoundedBox(23, -50, 40, 100, 100, ColorAlpha(Color(255, 77, 119), 150))
                    DTR(-30, 60, 60, 60, color_white, Material( ('shizlib/icon17/256/%s.png'):format(v.icon) ))
                    draw.SimpleText( v.name, 'font.30', 0, 160, color_white, 1, 1 )
                    draw.SimpleText( ('Удаление через %s'):format( shizlib.surface.FormatTime(math.Round(self:GetRemoveTime() - CurTime())) ), 'font.20', 0, 200, color_white, 1, 1 )
                cam.End3D2D()
            end
        end

        scripted_ents.Register( ENT, 'shizlib_resource_' .. string.Replace( string.lower( k ), " ", "" ) )
    end
end

local function fixupProp( ply, ent, hitpos, mins, maxs )
	local entPos = ent:GetPos()
	local endposD = ent:LocalToWorld( mins )
	local tr_down = util.TraceLine( {
		start = entPos,
		endpos = endposD,
		filter = { ent, ply }
	} )

	local endposU = ent:LocalToWorld( maxs )
	local tr_up = util.TraceLine( {
		start = entPos,
		endpos = endposU,
		filter = { ent, ply }
	} )

	-- Both traces hit meaning we are probably inside a wall on both sides, do nothing
	if ( tr_up.Hit && tr_down.Hit ) then return end

	if ( tr_down.Hit ) then ent:SetPos( entPos + ( tr_down.HitPos - endposD ) ) end
	if ( tr_up.Hit ) then ent:SetPos( entPos + ( tr_up.HitPos - endposU ) ) end
end

local function TryFixPropPosition( ply, ent, hitpos )
	fixupProp( ply, ent, hitpos, Vector( ent:OBBMins().x, 0, 0 ), Vector( ent:OBBMaxs().x, 0, 0 ) )
	fixupProp( ply, ent, hitpos, Vector( 0, ent:OBBMins().y, 0 ), Vector( 0, ent:OBBMaxs().y, 0 ) )
	fixupProp( ply, ent, hitpos, Vector( 0, 0, ent:OBBMins().z ), Vector( 0, 0, ent:OBBMaxs().z ) )
end

function OverrideSpawnWepFunc()
    function Spawn_Weapon( ply, wepname, tr )
        if ( !IsValid( ply ) ) then return end

        if ( wepname == nil ) then return end

        local swep = list.Get( "Weapon" )[ wepname ]

        if ( swep == nil ) then return end

        local isAdmin = ply:IsAdmin() or game.SinglePlayer()
        if ( ( !swep.Spawnable && !isAdmin ) or ( swep.AdminOnly && !isAdmin ) ) then
            return
        end

        if ( !gamemode.Call( "PlayerSpawnSWEP", ply, wepname, swep ) ) then return end

        if ( !tr ) then
            tr = ply:GetEyeTraceNoCursor()
        end

        if ( !tr.Hit ) then return end

        local entity = ents.Create( swep.ClassName )

        if ( !IsValid( entity ) ) then return end

        DoPropSpawnedEffect( entity )

        local SpawnPos = tr.HitPos + tr.HitNormal * 32

        local oobTr = util.TraceLine( {
            start = tr.HitPos,
            endpos = SpawnPos,
            mask = MASK_SOLID_BRUSHONLY
        } )

        if ( oobTr.Hit ) then
            SpawnPos = oobTr.HitPos + oobTr.HitNormal * ( tr.HitPos:Distance( oobTr.HitPos ) / 2 )
        end

        entity:SetCreator( ply )
        entity:SetPos( SpawnPos )
        entity:Spawn()
        entity.NoDrop = true
        entity.UnDroppable = true

        undo.Create( "SWEP" )
            undo.SetPlayer( ply )
            undo.AddEntity( entity )
            undo.SetCustomUndoText( "Undone " .. tostring( swep.PrintName ) )
        undo.Finish( "#spawnmenu.utilities.undo.weapon (" .. tostring( swep.PrintName ) .. ")" )

        ply:AddCleanup( "sents", entity )

        TryFixPropPosition( ply, entity, tr.HitPos )

        gamemode.Call( "PlayerSpawnedSWEP", ply, entity )

        return entity
    end
end

hook.Add('InitPostEntity', 'XeninUI.FixFunctions', function()
    OverrideSpawnWepFunc()
    shizlib.Crafting.LoadEntities()
end)
OverrideSpawnWepFunc()
shizlib.Crafting.LoadEntities()
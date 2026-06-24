shizlib = shizlib or {}
shizlib.Crafting = shizlib.Crafting or {}
shizlib.Crafting.Recipes = shizlib.Crafting.Recipes or {}
shizlib.shared( "shizlib-addons/craft/recipes_sh" )

function shizlib.Crafting.TypeHandler(tbl, ply)
    local base = tbl.base
    local entity = tbl.entity
    local customEndFunc = tbl.customPost
    if customEndFunc then
        customEndFunc(ply, tbl)
        return
    end
    if base == 'weapon' then

        local item = itemstore.Item('spawned_weapon')
        local wep = weapons.Get(entity)
        item:SetData( "Class", entity )
		item:SetData( "Amount", 1 )
		item:SetData( "Model", wep.WorldModel )
		item:SetData( "Clip1", wep.Primary.ClipSize )
		item:SetData( "Clip2", wep.Primary.DefaultClip )
        for i = 1, tbl.amount do
            con:AddItem(item, true)
        end

    elseif base == 'resource' then
        
        local id = ply.Inventory:GetID()
        local con = itemstore.containers.Get( id )

        local data = {
            ['Model'] = shizlib.Resources[entity].model,
            ['Class'] = string.format('shizlib_resource_%s', entity),
            ['FPPOwnerID'] = ply:SteamID(),
        }
        local item = itemstore.Item(string.format('shizlib_resource_%s', entity))
        item:SetModel(shizlib.Resources[entity].model)
        for i = 1, tbl.amount do
            con:AddItem(item, true)
        end

    elseif base == 'accessory' then

        local ent = ents.Create('base_accessory')
        ent:SetPos(ply:GetPos())
        ent:Spawn()
        ent:Activate()
        ent:SetID(entity)
        ent:SetModel(SH_ACC.List[ent:GetID()].mdl)

        ply:PickupItem(ent)

    elseif base == "custom" then

        local ent = ents.Create(entity)
        ent:SetPos(ply:GetPos())
        ent:Spawn()
        ent:Activate()

    else
        shizlib.msg(string.format('Игрок %s(%s) обошел почти все проверки и попытался скрафтить предмет с базой - "%s", которой нет в TypeHandler-е', ply:Name(), ply:SteamID(), base))
        return
    end
    ply:ChatPrint(string.format('Вы скрафтили "%s"', tbl.name))
end

function shizlib.Crafting.ValidTable(idx, tbl)
    local temp
    for index, info in pairs(tbl) do
        if idx == info.id then
            temp = info
            break
        end
        if index == #tbl then return false end
    end
    return temp
end

function shizlib.Crafting.CheckResources(tbl, ply, base)
    local resources = tbl.resources
    local id = ply.Inventory:GetID()
    local con = itemstore.containers.Get( id )
    
    local preCacheHasItems = {}
    local i = 1
    for k, info in pairs(resources) do
        if con:CountItems( string.format('%s_%s', base, info.class) ) >= info.amount then
            table.insert(preCacheHasItems, i, info.class)
            i = i + 1
        end
    end

    if #resources ~= #preCacheHasItems then return false end

    return tbl
end

local ValidTableTbl = {}
ValidTableTbl['weapon'] = shizlib.Crafting.Recipes
ValidTableTbl['resource'] = shizlib.Crafting.Recipes
ValidTableTbl['accessory'] = shizlib.Crafting.Recipes
ValidTableTbl['custom'] = shizlib.Crafting.Recipes
hook.Add("shizlib.Crafts.PostLoad", "PostLoad", function()
    ValidTableTbl['weapon'] = shizlib.Crafting.Recipes
    ValidTableTbl['resource'] = shizlib.Crafting.Recipes
    ValidTableTbl['accessory'] = shizlib.Crafting.Recipes
    ValidTableTbl['custom'] = shizlib.Crafting.Recipes
end)

local CheckResourcesTbl = {
    ['weapon'] = 'shizlib_resource',
    ['resource'] = 'shizlib_resource',
    ['accessory'] = 'shizlib_resource',
    ['custom'] = 'shizlib_resource',
}

function shizlib.Crafting.CraftItem(kk, ply, cfg)

    if not shizlib.Crafting.ValidTable(kk, ValidTableTbl[cfg]) then ply:ChatPrint('[Крафты] Такого крафта нет!') return end
    local tbl = shizlib.Crafting.ValidTable(kk, ValidTableTbl[cfg])

    local items = shizlib.Crafting.CheckResources(tbl, ply, CheckResourcesTbl[cfg])
    if not items then ply:ChatPrint('[Крафты] У вас не достаточно ресурсов!') return end

    local passed, bench = true, nil
    if tbl.customCheck then
        passed, bench = tbl.customCheck(tbl, ply)
        if passed == false then return end
    end

    if tbl.craftTime and tbl.craftTime > 0 and IsValid(bench) then
        if bench:GetNWFloat("CraftEndTime", 0) > CurTime() then
            ply:ChatPrint('[Крафты] Этот верстак сейчас занят изготовлением другого предмета!')
            return
        end

        local id = ply.Inventory:GetID()
        local con = itemstore.containers.Get( id )
        for k, v in pairs(tbl.resources) do
            con:TakeItems(string.format('%s_%s', CheckResourcesTbl[cfg], v.class), v.amount)
        end

        bench:StartCrafting(tbl, ply)
        ply:ChatPrint(string.format('Вы начали изготовление "%s". Ожидайте %d сек.', tbl.name, tbl.craftTime))
        
        hook.Run('shizlib:crafting_started', ply, tbl)
    else
        local id = ply.Inventory:GetID()
        local con = itemstore.containers.Get( id )
        for k, v in pairs(tbl.resources) do
            con:TakeItems(string.format('%s_%s', CheckResourcesTbl[cfg], v.class), v.amount)
        end

        shizlib.Crafting.TypeHandler(tbl, ply)
        hook.Run('shizlib:crafting', ply, tbl)
    end
end

netstream.Hook('Crafting.Craft', function(ply, data)
    shizlib.Crafting.CraftItem(data.id, ply, data.Cfg)
end)
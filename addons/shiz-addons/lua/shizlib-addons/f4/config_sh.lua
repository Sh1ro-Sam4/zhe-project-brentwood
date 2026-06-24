shizlib.config_rp = shizlib.config_rp or {}
shizlib.config_rp.AllCategories = {}
shizlib.config_rp.AllItems = {}

shizlib.config_rp.Currency = "$"
shizlib.GetCurrency = function()
    return shizlib.config_rp.Currency
end
shizlib.FormatMoney = function(amount)
    return shizlib.config_rp.Currency .. string.Comma(amount)

    --[[
        str = "1000"
        string.Comma("1000") => 1.000
        str = "1000000"
        string.Comma("1000000") => 1.000.000
    ]]
end

DarkRP = DarkRP or {}
DarkRP.formatMoney = shizlib.FormatMoney

shizlib.config_rp.Category = {}

shizlib.config_rp.CreateCategory = function(name)
    if shizlib.config_rp.Category[name] then
        shizlib.msg( ("$ERROR$ | Category - %s already created"):format(name) )
        return
    end
    shizlib.config_rp.Category[name] = {}
    table.insert(shizlib.config_rp.AllCategories, name)
    shizlib.msg( ("Register new category - %s"):format(name) )

    return shizlib.config_rp.Category[name]
end

shizlib.config_rp.AddItem = function(cat, name, data)
    if not shizlib.config_rp.Category[cat] then
        shizlib.msg( ("$ERROR$ | Error to create new item %s. No Category - %s"):format(name, cat) )
        return
    end
    if not data.ent then
        shizlib.msg( ("$ERROR$ | \"%s\" not registered. No entity"):format(name) )
        return
    end
    if cat == "weapons" then
        data.isWeapon = true
    end
    data.globalCategory = cat
    if not data.price then
        data.price = 1
    end
    if not data.    level then
        data.    level = 0
    end
    if not data.limit then
        data.limit = 0
    end
    if not data.mdl then
        data.mdl = "models/props_junk/watermelon01.mdl"
    end
    util.PrecacheModel(data.mdl)
    if not data.category then
        data.category = "l:f4_other"
    end
    data.name = name
    local tbl = table.insert(shizlib.config_rp.Category[cat], data)
    table.insert(shizlib.config_rp.AllItems, name)
    shizlib.msg( ("Register new item - %s"):format(name) )

    return tbl
end

shizlib.config_rp.CreateCategory("entities")
shizlib.config_rp.CreateCategory("weapons")

--_____________________WEAPONS_____________________
-- shizlib.config_rp.AddItem("weapons", "SCAR", {
--     price = 40000,
--     level = 7,
--     ent = "tfa_cso2_scarl",
--     mdl = "models/weapons/tfa_cso2/w_scarl.mdl",
--     category = "l:f4_rifle",
-- })


--______________________ENTITIES______________________
--[[
EARN
]]--
-- shizlib.config_rp.AddItem("entities", "Денежный принтер", {
--     price = 1000,
--     level = 0,
--     ent = "rp_money_printer",
--     mdl = "models/props_c17/consolebox01a.mdl",
--     category = "Денежный принтер",
--     limit = 1,
--     baseOnly = true,
-- })

-- shizlib.config_rp.AddItem("entities", "Money Printer", {
--     price = 1000,
--     level = 0,
--     ent = "rp_money_printer",
--     mdl = "models/props_c17/consolebox01a.mdl",
--     category = "Производство сигарет",
--     limit = 1,
--     baseOnly = true,
-- })
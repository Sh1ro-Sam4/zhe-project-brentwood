--[[

    Короче говоря это тест кода от дипсика, ввиду того что я не особо хорош в кодинге и аспектах луа в гаррисе, я решил подтянуть его для этой задачи
    и сделать файл максимально совместимым со всеми возможными аддонами на зсити
    буду тестить и решать возникающие проблемы на ходу. всем кто читает большой привет, поразбираетесь со мной.

]]

-- Дополнение для ZCity Appearance

-- Убеждаемся, что глобальные таблицы существуют (на случай, если файл загрузится до оригинала)
hg.Appearance = hg.Appearance or {}
hg.PointShop = hg.PointShop or {}
-- НЕ переопределяем PLUGIN.Items
--[[
hg.Appearance.MenuPerf = hg.Appearance.MenuPerf or {
    showcaseCols = 12,
    allFacemapsCols = 14,
    allFacemapsHeaderGapFactor = 0.43,
    clothesCols = 4,
    facemapCols = 3,
    glovesCols = 3,
    modelCols = 4
}
]]
-- === ВАЖНО: Инициализация таблицы для хранения слотов лица ===
hg.Appearance.ModelFaceSlots = hg.Appearance.ModelFaceSlots or {}
-- ============================================================


hg.Appearance.PlayerModels = hg.Appearance.PlayerModels or { [1] = {}, [2] = {} }
hg.Appearance.Clothes = hg.Appearance.Clothes or { [1] = {}, [2] = {} }
hg.Appearance.ClothesDesc = hg.Appearance.ClothesDesc or {}
hg.Appearance.FacemapsSlots = hg.Appearance.FacemapsSlots or {}
hg.Appearance.FacemapsModels = hg.Appearance.FacemapsModels or {}

-- Добавление новой одежды
local function AddCustomColorableClothes()
    hg.Appearance.Clothes = hg.Appearance.Clothes or { [1] = {}, [2] = {} }
    hg.Appearance.ClothesDesc = hg.Appearance.ClothesDesc or {}

    -- Новая мужская одежда
    local maleClothes = {
        adidas_cl = "models/humans/male/group01/adidas_colorable",
		aphex_white_cl = "models/humans/male/fun/aphex_white_colorable", 
        alpha_industry_cl = "models/humans/male/group01/alphaindustry_colorable",
        camouflage_cl = "models/humans/male/group01/camoflage_colorable",
        comfy_cl = "models/humans/male/group01/comfy_colorable",
        farmer_cl = "models/humans/male/group01/farmer_colorable",
        formal_only_vest_cl = "models/humans/male/group01/formal_only_vest_colorable",
        formal_partly_cl = "models/humans/male/group01/formal_partly",
        formal_vest_cl = "models/humans/male/group01/formal_vest_colorable",
        formal_vest_full_cl = "models/humans/male/group01/formal_vest_full_colorable",
		formal_white_cl = "models/humans/male/group01/formal_white",
		yakudza_cl = "models/humans/male/group01/yakudza_colorable",
		yakudza_suit_cl = "models/humans/male/group01/yakudza_suit_colorable",
        half_strip_cl = "models/humans/male/group01/half_strip_colorable",
        homeless_cl = "models/humans/male/group01/homeless_colorable",
        mailman_cl = "models/humans/male/group01/mailman_colorable",
        miami_cl = "models/humans/male/group01/miami_colorable",
        old_sport_cl = "models/humans/male/group01/old_sport_colorable",
        rama_cl = "models/humans/male/group01/rama_colorable",
        rockmountain_cl = "models/humans/male/group01/rockmountain_shirt_colorable",
        sport_cl = "models/humans/male/group01/sport1_colorable",
        sweatshirt_cl = "models/humans/male/group01/sport4_colorable",
        warpoint_cl = "models/humans/male/group01/warpoint_jacket_colorable",
        winter_cl = "models/humans/male/group01/winter_colorable",
        wolker_cl = "models/humans/male/group01/wolker_colorable",
        zekee_sport_cl = "models/humans/male/group01/zekee_sport_clothes_colorable",
    }
    for id, path in pairs(maleClothes) do
        hg.Appearance.Clothes[1][id] = path
        hg.Appearance.ClothesDesc[id] = hg.Appearance.ClothesDesc[id] or { desc = "Unique clothes from Colorable Clothes! How original..." }
    end

    -- Новая женская одежда
    local femaleClothes = {
        adidas_cl = "models/humans/female/group01/adidas_colorable",
		aphex_white_cl = "models/humans/female/fun/aphex_white_colorable", 
        camouflage_cl = "models/humans/female/group01/camoflage_colorable",
        comfy_cl = "models/humans/female/group01/comfy_colorable",
        formal_partly_cl = "models/humans/female/group01/formal_partly",
		formal_white_cl = "models/humans/female/group01/formal_white",
        mailwomen_cl = "models/humans/female/group01/mailwomen_colorable",
        official_cl = "models/humans/female/group01/official_colorable",
        rama_cl = "models/humans/female/group01/rama_colorable",
        rockmountain_cl = "models/humans/female/group01/rockmountain_shirt_colorable",
        sport_cl = "models/humans/female/group01/sport1_colorable",
        sweatshirt_cl = "models/humans/female/group01/sport4_colorable",
        warpoint_cl = "models/humans/female/group01/warpoint_jacket_colorable",
        wolker_cl = "models/humans/female/group01/wolker_colorable",

    }
    for id, path in pairs(femaleClothes) do
        hg.Appearance.Clothes[2][id] = path
        hg.Appearance.ClothesDesc[id] = hg.Appearance.ClothesDesc[id] or { desc = "Unique clothes from Colorable Clothes! How unoriginal..." }
    end

end



-- Вызов всех функций добавления
-- Лучше всего вызывать их в хуке, чтобы быть уверенным, что основные таблицы уже созданы.
hook.Add("Initialize", "CustomColorableAppearance_Init", function()
    AddCustomColorableClothes()
end)

hook.Add("InitPostEntity", "ZCity_LoadCustomColorableAppearance", function()
    AddCustomColorableClothes()
end)

hook.Add("OnGamemodeLoaded", "ZCity_LoadCustomColorableAppearance", function()
    AddCustomColorableClothes()
end)

hook.Add("PostGamemodeLoaded", "ZCity_LoadCustomColorableAppearance_PostGM", function()
    AddCustomColorableClothes()
end)

if SERVER then
    local function PatchAppearanceReset()
        local appearanceTable = hg.Appearance
        if not appearanceTable or appearanceTable.__ZCitySubmaterialResetPatched then return end
        local originalForceApply = appearanceTable.ForceApplyAppearance
        if not isfunction(originalForceApply) then return end

        appearanceTable.__ZCitySubmaterialResetPatched = true
        appearanceTable.ForceApplyAppearance = function(ply, tbl, noModelChange)
            if IsValid(ply) and ply.GetMaterials and ply.SetSubMaterial then
                local mats = ply:GetMaterials() or {}
                for i = 1, #mats do
                    ply:SetSubMaterial(i - 1, nil)
                end
            end

            return originalForceApply(ply, tbl, noModelChange)
        end
    end

    hook.Add("InitPostEntity", "ZCity_PatchForceApplyAppearanceReset", function()
        PatchAppearanceReset()
        timer.Create("ZCity_PatchForceApplyAppearanceResetRetry", 0.5, 20, function()
            if hg.Appearance and hg.Appearance.__ZCitySubmaterialResetPatched then
                timer.Remove("ZCity_PatchForceApplyAppearanceResetRetry")
                return
            end
            PatchAppearanceReset()
        end)
    end)
end
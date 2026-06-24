include("shared.lua")

function ENT:Initialize()
end

local function GetIngredientName(class)
        for _, recipe in pairs(POT_RECIPES) do
            if recipe.ingri[class] then return recipe.ingri[class].name end
        end
        return class
    end

    function ENT:Draw()
        self:DrawModel()
        
        local pos = self:GetPos()
        local ang = self:GetAngles()
        
        if LocalPlayer():GetPos():Distance(pos) > 500 then return end

        local status = self:GetNWInt("status")
        local time = self:GetNWInt("time")
        local maxTime = math.max(self:GetNWInt("maxTime"), 1)
        
        local currentIngredients = util.JSONToTable(self:GetNWString("IngData", "[]")) or {}

        ang:RotateAroundAxis(ang:Up(), 180)
        ang:RotateAroundAxis(ang:Forward(), 90)    
        
        cam.Start3D2D(pos + ang:Up() * 8, ang, 0.055)
            
            surface.SetDrawColor(Color(0, 0, 0, 200))
            surface.DrawRect(-150, -100, 300, 200)

            if status == 0 then
                draw.SimpleTextOutlined("Котелок (Ожидание)", "DermaLarge", 0, -80, Color(1, 241, 249, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
                draw.SimpleTextOutlined("________________", "DermaLarge", 0, -70, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
                
                local yOffset = -30
                local hasItems = false
                for class, amount in pairs(currentIngredients) do
                    local name = GetIngredientName(class)
                    draw.SimpleTextOutlined(name .. ": " .. amount .. " шт.", "DermaLarge", -130, yOffset, Color(220, 220, 220, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
                    yOffset = yOffset + 30
                    hasItems = true
                end
                
                if not hasItems then
                    draw.SimpleTextOutlined("Пусто", "DermaLarge", 0, 0, Color(150, 150, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
                end

            elseif status == 1 then
                local recipeID = self:GetNWString("currentRecipe")
                local recipeName = POT_RECIPES[recipeID] and POT_RECIPES[recipeID].name or "Неизвестно"

                draw.SimpleTextOutlined("Готовим: " .. recipeName, "DermaLarge", 0, -60, Color(255, 150, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
                
                surface.SetDrawColor(Color(50, 50, 50, 255))
                surface.DrawRect(-120, -10, 240, 30)
                
                local barWidth = ((maxTime - time) / maxTime) * 236
                surface.SetDrawColor(Color(1, 201, 209, 255))
                surface.DrawRect(-118, -8, barWidth, 26)
                
                draw.SimpleTextOutlined("Осталось: " .. time .. "с", "DermaLarge", 0, 40, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))

            elseif status == 2 then
                local recipeID = self:GetNWString("currentRecipe")
                local recipeName = POT_RECIPES[recipeID] and POT_RECIPES[recipeID].name or "Неизвестно"
                
                draw.SimpleTextOutlined(recipeName .. " готов!", "DermaLarge", 0, -20, Color(0, 255, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
                draw.SimpleTextOutlined("Нажмите 'E', чтобы забрать", "DermaLarge", 0, 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
            end

        cam.End3D2D()
    end

    local globalIntuitionAlpha = 0

    hook.Add("HUDPaint", "CookPot_Intuition", function()
        local ply = LocalPlayer()
        
        local isCook = false
        if ply.GetPlayerClass and ply:GetPlayerClass() == TEAM_COOK then isCook = true end
        if ply.Team and ply:Team() == TEAM_COOK then isCook = true end
        
        if not isCook then return end

        local tr = ply:GetEyeTrace()
        local ent = tr.Entity
        
        local isLookingAtPot = false
        if IsValid(ent) and ent.PrintName == "Универсальный котелок" and ent:GetPos():DistToSqr(ply:GetPos()) < 40000 then
            isLookingAtPot = true
        end
        
        globalIntuitionAlpha = Lerp(FrameTime() * 0.2, globalIntuitionAlpha, isLookingAtPot and 1 or 0)
        
        if globalIntuitionAlpha < 0.01 then return end
            
        local scrW, scrH = ScrW(), ScrH()
        local t = CurTime()
        
        local titlePulse = (math.sin(t * 1.5) + 1) / 2
        local titleAlpha = (80 + titlePulse * 150) * globalIntuitionAlpha
        
        local index = 0
        for id, recipe in pairs(POT_RECIPES) do
            index = index + 1
            
            local tX = t * (0.12 + (index % 3) * 0.02) + index * 2.5
            local tY = t * (0.15 + (index % 2) * 0.03) + index * 1.3
            local tFade = t * 0.5 + index * 1.7
            
            local radiusX = scrW * 0.35
            local radiusY = scrH * 0.25
            
            local x = (scrW / 2) + math.sin(tX) * radiusX
            local y = (scrH / 2) + math.cos(tY) * radiusY
            
            y = y + math.sin(t * 1.2 + index) * 15
            
            local fadeWave = math.sin(tFade)
            local fade = 0
            if fadeWave > 0.6 then
                fade = (fadeWave - 0.6) / 0.4
                fade = math.sin(fade * math.pi / 2)
            end
            
            local distToCenter = math.abs(x - scrW/2) / radiusX
            local centerBonus = 1 - (distToCenter * 0.25)
            
            local finalAlpha = fade * 255 * centerBonus * globalIntuitionAlpha
            
            if finalAlpha > 5 then
                local ingriText = ""
                local count = 0
                for k, v in pairs(recipe.ingri) do
                    if count > 0 then ingriText = ingriText .. " • " end
                    ingriText = ingriText .. v.name .. " (x" .. v.amount .. ")"
                    count = count + 1
                end
                
                local c_title = Color(255, 240, 200, finalAlpha)
                local c_ingri = Color(180, 220, 255, finalAlpha * 0.8)
                local c_out = Color(0, 0, 0, finalAlpha * 0.5)
                
                draw.SimpleTextOutlined(recipe.name, "DermaLarge", x, y, c_title, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, c_out)
                draw.SimpleTextOutlined(ingriText, "Trebuchet24", x, y + 30, c_ingri, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, c_out)
            end
        end
    end)
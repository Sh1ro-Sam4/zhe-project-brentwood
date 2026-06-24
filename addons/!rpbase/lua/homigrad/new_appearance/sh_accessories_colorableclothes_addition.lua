-- Добавление новых аксессуаров на голову (кепка, федора, наушники) с возможностью смены цвета
-- Модели: models/griggs/cap_colorable.mdl, fedora_colorable.mdl, headphones_colorable.mdl

if SERVER then
    -- Небольшая задержка, чтобы убедиться, что hg.Accessories уже создана
    timer.Simple(0, function()
        if not hg or not hg.Accessories then return end

        -- Кепка
        if not hg.Accessories["cap_colorable"] then
            hg.Accessories["cap_colorable"] = {
                model = "models/griggs/cap_colorable.mdl",
                bone = "ValveBiped.Bip01_Head1",
                malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
                fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
                skin = 0,
                norender = true,
                placement = "head",
                bSetColor = true,          -- возможность красить аксессуар
                bPointShop = true,
                price = 1500,
                name = "Colorable Baseball Cap"
            }
        end

        -- Федора
        if not hg.Accessories["fedora_colorable"] then
            hg.Accessories["fedora_colorable"] = {
                model = "models/griggs/fedora_colorable.mdl",
                bone = "ValveBiped.Bip01_Head1",
                malepos = {Vector(5.5, -0.2, 0), Angle(90, -80, -90), 1},
                fempos = {Vector(4.5, -0.2, 0), Angle(90, -75, -90), 1},
                skin = 0,
                norender = true,
                placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Fedora"
            }
        end

        -- Федора но линия только
        if not hg.Accessories["fedora_line_colorable"] then
            hg.Accessories["fedora_line_colorable"] = {
                model = "models/griggs/fedora_colorable.mdl",
                bone = "ValveBiped.Bip01_Head1",
                malepos = {Vector(5.5, -0.2, 0), Angle(90, -80, -90), 1},
                fempos = {Vector(4.5, -0.2, 0), Angle(90, -75, -90), 1},
                skin = 1,
                norender = true,
                placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Fedora (Line)"
            }
        end
		
		-- Федора но линия только черная
        if not hg.Accessories["fedora_black_line_colorable"] then
            hg.Accessories["fedora_black_line_colorable"] = {
                model = "models/griggs/fedora_colorable.mdl",
                bone = "ValveBiped.Bip01_Head1",
                malepos = {Vector(5.5, -0.2, 0), Angle(90, -80, -90), 1},
                fempos = {Vector(4.5, -0.2, 0), Angle(90, -75, -90), 1},
                skin = 2,
                norender = true,
                placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Black Fedora (Line)"
            }
        end

        -- Наушники
        if not hg.Accessories["earmuffs_colorable"] then
            hg.Accessories["earmuffs_colorable"] = {
                model = "models/griggs/headphones_colorable.mdl",
                bone = "ValveBiped.Bip01_Head1",
                malepos = {Vector(2.8,-1,0),Angle(180,105,90),1},
                fempos = {Vector(1.8,-1,0),Angle(180,105,90),0.95},
                skin = 0,
                norender = true,
                placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1200,
                name = "Colorable Earmuffs"
            }
        end

        -- шарф
        if not hg.Accessories["scarf_colorable"] then
            hg.Accessories["scarf_colorable"] = {
                model = "models/griggs/scarf01.mdl",
				bone = "ValveBiped.Bip01_Spine4",
				malepos = {Vector(-18,8,0),Angle(0,75,90),1},
				fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
                skin = 0,
                norender = true,
				placement = "torso",	
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Scarf"
            }
        end
		
        -- tophat
        if not hg.Accessories["tophat_colorable"] then
            hg.Accessories["tophat_colorable"] = {
                model = "models/griggs/tophat_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(2,0.4,0),Angle(0,-95,-90),1},
				fempos = {Vector(1,0.1,0),Angle(0,-95,-90),1},
                skin = 0,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Tophat"
            }
        end

        -- tophat
        if not hg.Accessories["tophat_white_line_colorable"] then
            hg.Accessories["tophat_white_line_colorable"] = {
                model = "models/griggs/tophat_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(2,0.4,0),Angle(0,-95,-90),1},
				fempos = {Vector(1,0.1,0),Angle(0,-95,-90),1},
                skin = 1,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Tophat White (Line)"
            }
        end
		
        -- tophat
        if not hg.Accessories["tophat_black_line_colorable"] then
            hg.Accessories["tophat_black_line_colorable"] = {
                model = "models/griggs/tophat_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(2,0.4,0),Angle(0,-95,-90),1},
				fempos = {Vector(1,0.1,0),Angle(0,-95,-90),1},
                skin = 2,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Tophat Black (Line)"
            }
        end
	
        -- fancyglassess
        if not hg.Accessories["fancyglasses_colorable"] then
            hg.Accessories["fancyglasses_colorable"] = {
                model = "models/griggs/fancyglasses_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(0.6,0.2,0),Angle(0,-90,-90),1.1},
				fempos = {Vector(-0.5,.2,0),Angle(0,-90,-90),1.1},
                skin = 0,
                norender = true,
				placement = "face",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Cool Glasses"
            }
        end

        -- fancyglassess
        if not hg.Accessories["fancyglasses_nt_colorable"] then
            hg.Accessories["fancyglasses_nt_colorable"] = {
                model = "models/griggs/fancyglasses_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(0.6,0.2,0),Angle(0,-90,-90),1.1},
				fempos = {Vector(-0.5,.2,0),Angle(0,-90,-90),1.1},
                skin = 1,
                norender = true,
				placement = "face",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Cool Glasses (Not Transparent)"
            }
        end
	
        -- hat03
        if not hg.Accessories["hat03_colorable"] then
            hg.Accessories["hat03_colorable"] = {
                model = "models/griggs/hat03_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(4,0,0),Angle(180,105,90),1},
				fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
                skin = 0,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Beanie"
            }
        end
		
        -- hat03
        if not hg.Accessories["hat03_line_colorable"] then
            hg.Accessories["hat03_line_colorable"] = {
                model = "models/griggs/hat03_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(4,0,0),Angle(180,105,90),1},
				fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
                skin = 1,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Stripped Beanie"
            }
        end
		
        -- hat03
        if not hg.Accessories["hat03_double_line_colorable"] then
            hg.Accessories["hat03_double_line_colorable"] = {
                model = "models/griggs/hat03_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(4,0,0),Angle(180,105,90),1},
				fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1}, 
                skin = 2,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Double-Stripped Beanie"
            }
        end
		
        -- hat01
        if not hg.Accessories["hat01_colorable"] then
            hg.Accessories["hat01_colorable"] = {
                model = "models/griggs/hat01_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
				fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
                skin = 0,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Cap"
            }
        end
		
        -- hat01
        if not hg.Accessories["hat01_white_line_colorable"] then
            hg.Accessories["hat01_white_line_colorable"] = {
                model = "models/griggs/hat01_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
				fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
                skin = 1,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable White Cap (Line)"
            }
        end
		
		        -- hat01
        if not hg.Accessories["hat01_black_line_colorable"] then
            hg.Accessories["hat01_black_line_colorable"] = {
                model = "models/griggs/hat01_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
				fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
                skin = 2,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Black Cap (Line)"
            }
        end

        -- Принудительно обновляем PointShop (если хук Think уже отработал)
        if hg.PointShop and hg.PointShop.CreateItem and hg.PointShop.Items then
            local PLUGIN = hg.PointShop
            for id, data in pairs(hg.Accessories) do
                if data.bPointShop and not PLUGIN.Items[id] then
                    PLUGIN:CreateItem(id, string.NiceName(data.name or id), data.model, data.bodygroups, data.skin, data.vpos or Vector(0,0,0), data.price, data.isdpoint, {[0] = data.SubMat})
                end
            end
        end
    end)
else
    -- Клиентская часть: просто добавляем аксессуары, если их ещё нет
    hook.Add("Initialize", "ZCity_CustomAccessories_Client", function()
        if not hg or not hg.Accessories then return end

        if not hg.Accessories["cap_colorable"] then
            hg.Accessories["cap_colorable"] = {
                model = "models/griggs/cap_colorable.mdl",
                bone = "ValveBiped.Bip01_Head1",
                malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
                fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
                skin = 0,
                norender = true,
                placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Baseball Cap"
            }
        end

        if not hg.Accessories["fedora_colorable"] then
            hg.Accessories["fedora_colorable"] = {
                model = "models/griggs/fedora_colorable.mdl",
                bone = "ValveBiped.Bip01_Head1",
                malepos = {Vector(5.5, -0.2, 0), Angle(90, -80, -90), 1},
                fempos = {Vector(4.5, -0.2, 0), Angle(90, -75, -90), 1},
                skin = 0,
                norender = true,
                placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Fedora"
            }
        end
		

        if not hg.Accessories["fedora_line_colorable"] then
            hg.Accessories["fedora_line_colorable"] = {
                model = "models/griggs/fedora_colorable.mdl",
                bone = "ValveBiped.Bip01_Head1",
                malepos = {Vector(5.5, -0.2, 0), Angle(90, -80, -90), 1},
                fempos = {Vector(4.5, -0.2, 0), Angle(90, -75, -90), 1},
                skin = 1,
                norender = true,
                placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Fedora (Line)"
            }
        end
		

        if not hg.Accessories["fedora_black_line_colorable"] then
            hg.Accessories["fedora_black_line_colorable"] = {
                model = "models/griggs/fedora_colorable.mdl",
                bone = "ValveBiped.Bip01_Head1",
                malepos = {Vector(5.5, -0.2, 0), Angle(90, -80, -90), 1},
                fempos = {Vector(4.5, -0.2, 0), Angle(90, -75, -90), 1},
                skin = 2,
                norender = true,
                placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Black Fedora (Line)"
            }
        end

        -- шарф
        if not hg.Accessories["scarf_colorable"] then
            hg.Accessories["scarf_colorable"] = {
                model = "models/griggs/scarf01.mdl",
				bone = "ValveBiped.Bip01_Spine4",
				malepos = {Vector(-18,8,0),Angle(0,75,90),1},
				fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
                skin = 0,
                norender = true,
				placement = "torso",	
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Scarf"
            }
        end
		
        -- tophat
        if not hg.Accessories["tophat_colorable"] then
            hg.Accessories["tophat_colorable"] = {
                model = "models/griggs/tophat_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(2,0.4,0),Angle(0,-95,-90),1},
				fempos = {Vector(1,0.1,0),Angle(0,-95,-90),1},
                skin = 0,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Tophat"
            }
        end

        -- tophat
        if not hg.Accessories["tophat_white_line_colorable"] then
            hg.Accessories["tophat_white_line_colorable"] = {
                model = "models/griggs/tophat_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(2,0.4,0),Angle(0,-95,-90),1},
				fempos = {Vector(1,0.1,0),Angle(0,-95,-90),1},
                skin = 1,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Tophat White (Line)"
            }
        end
		
        -- tophat
        if not hg.Accessories["tophat_black_line_colorable"] then
            hg.Accessories["tophat_black_line_colorable"] = {
                model = "models/griggs/tophat_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(2,0.4,0),Angle(0,-95,-90),1},
				fempos = {Vector(1,0.1,0),Angle(0,-95,-90),1},
                skin = 2,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Tophat Black (Line)"
            }
        end
	
        -- fancyglassess
        if not hg.Accessories["fancyglasses_colorable"] then
            hg.Accessories["fancyglasses_colorable"] = {
                model = "models/griggs/fancyglasses_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(0.6,0.2,0),Angle(0,-90,-90),1.1},
				fempos = {Vector(-0.5,.2,0),Angle(0,-90,-90),1.1},
                skin = 0,
                norender = true,
				placement = "face",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Cool Glasses"
            }
        end

        -- fancyglassess
        if not hg.Accessories["fancyglasses_nt_colorable"] then
            hg.Accessories["fancyglasses_nt_colorable"] = {
                model = "models/griggs/fancyglasses_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(0.6,0.2,0),Angle(0,-90,-90),1.1},
				fempos = {Vector(-0.5,.2,0),Angle(0,-90,-90),1.1},
                skin = 1,
                norender = true,
				placement = "face",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Cool Glasses (Not Transparent)"
            }
        end
	
        -- hat03
        if not hg.Accessories["hat03_colorable"] then
            hg.Accessories["hat03_colorable"] = {
                model = "models/griggs/hat03_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(4,0,0),Angle(180,105,90),1},
				fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
                skin = 0,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Beanie"
            }
        end
		
        -- hat03
        if not hg.Accessories["hat03_line_colorable"] then
            hg.Accessories["hat03_line_colorable"] = {
                model = "models/griggs/hat03_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(4,0,0),Angle(180,105,90),1},
				fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
                skin = 1,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Stripped Beanie"
            }
        end
		
        -- hat03
        if not hg.Accessories["hat03_double_line_colorable"] then
            hg.Accessories["hat03_double_line_colorable"] = {
                model = "models/griggs/hat03_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(4,0,0),Angle(180,105,90),1},
				fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1}, 
                skin = 2,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Double-Stripped Beanie"
            }
        end
		
        -- hat01
        if not hg.Accessories["hat01_colorable"] then
            hg.Accessories["hat01_colorable"] = {
                model = "models/griggs/hat01_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
				fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
                skin = 0,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Cap"
            }
        end
		
        -- hat01
        if not hg.Accessories["hat01_white_line_colorable"] then
            hg.Accessories["hat01_white_line_colorable"] = {
                model = "models/griggs/hat01_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
				fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
                skin = 1,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable White Cap (Line)"
            }
        end
		
		        -- hat01
        if not hg.Accessories["hat01_black_line_colorable"] then
            hg.Accessories["hat01_black_line_colorable"] = {
                model = "models/griggs/hat01_colorable.mdl",
				bone = "ValveBiped.Bip01_Head1",
				malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
				fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
                skin = 2,
                norender = true,
				placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1500,
                name = "Colorable Black Cap (Line)"
            }
        end

        if not hg.Accessories["earmuffs_colorable"] then
            hg.Accessories["earmuffs_colorable"] = {
                model = "models/griggs/headphones_colorable.mdl",
                bone = "ValveBiped.Bip01_Head1",
                malepos = {Vector(2.8,-1,0),Angle(180,105,90),1},
                fempos = {Vector(1.8,-1,0),Angle(180,105,90),0.95},
                skin = 0,
                norender = true,
                placement = "head",
                bSetColor = true,
                bPointShop = true,
                price = 1200,
                name = "Colorable Earmuffs"
            }
        end
    end)
end
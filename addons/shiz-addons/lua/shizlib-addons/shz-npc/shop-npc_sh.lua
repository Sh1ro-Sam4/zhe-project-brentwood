kas = kas or {}
kas.shop_npc = kas.shop_npc or {}

INCOME_MULT = 2
SELL_MULT = .4

kas.shop_npc.type = {
    ["default"] = {
        use = function(self, ply)
            ply:ChatPrint("use func")
        end,
        overhead = "null NPC",
        sequence = "idle",
        model = "models/mossman.mdl",
    },
    ["police"] = {
        use = function(self, ply)
            netstream.Start(ply, "kas.shop_npc.police", self)
        end,
        overhead = "",
        model = "models/props_c17/lockers001a.mdl",
        shop_list = {

        },
    },
    ["mayor"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        overhead = "Секретарь",
        sequence = "pose_standing_01",
        model = "models/player/group01/female_02.mdl",
        shop_list = {
            {
                name = "Лицензия на оружие",
                price = GetLicenseCost( "weapon" ),
                notax = true,
                government = true,
                model = "models/props_lab/clipboard.mdl",
                ent = "shizlib_resource_licence",
            },
            {
                name = "Лицензия на бизнес",
                price = GetLicenseCost( "business" ),
                notax = true,
                government = true,
                model = "models/props_lab/clipboard.mdl",
                ent = "shizlib_resource_licencebes",
            },
        },
    },
    ["skill"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        overhead = "Прокачка Персонажа",
        sequence = "pose_ducking_01",
        model = "models/player/group01/male_05.mdl",
    },
    ["box-taker"] = {
        use = function(self, ply)
            if self.cd2 and self.cd2 > CurTime() then return end
            if ply.cd and ply.cd > CurTime() then
                DarkRP.notify(ply, 1, 4, "Для тебя нет работы!")
                timer.Simple(0.25, function()
                    self:EmitSound(table.Random(EML_Meth_Salesman_NoMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
                end)
                self.cd2 = CurTime() + 3
                return
            end
            if IsValid(ply) and ply:IsPlayer() then
                -- AddGPSPos(Vector(-1167, -1310, -31), 180, 'Отнести груз кладовщику', 'icon16/bell.png')
                local newpos = self:LocalToWorld(Vector(50, 50, 50))
                local final = ents.Create( "boxsys_divan" )
                final:SetPos(newpos)
                final:Spawn()
                final.LocalOwner = ply
            end
            ply.cd = CurTime() + 120
            self.cd2 = CurTime() + 3
        end,
        customCheck = function(ply, ent)
            if IsGov(ply:GetPlayerClass()) then
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
        end,
        overhead = "Джон",
        sequence = "pose_standing_01",
        model = "models/player/group03/male_01.mdl",
    },
    ["alco-b"] = {
        use = function(self, caller)
            if self.cd and self.cd > CurTime() then return end

            local totalMoney = 0
            local itemsFound = 0

            for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 150)) do
                if not IsValid(ent) then continue end

                if ent:GetClass() == "alco_moonshine" then
                    totalMoney = totalMoney + 2250
                    itemsFound = itemsFound + 1
                    ent:Remove()

                elseif ent:GetClass() == "alco_crate" then
                    local beersCount = ent:GetNWInt("BeersCount", 0)
                    if beersCount > 0 then
                        totalMoney = totalMoney + (beersCount * 2250) + 100
                        itemsFound = itemsFound + 1
                        ent:Remove()
                    elseif beersCount == 0 then
                        totalMoney = totalMoney + 100
                        itemsFound = itemsFound + 1
                        ent:Remove()
                    end
                end
            end

            if itemsFound > 0 then
                local finalMoney = caller:HasPremium() and totalMoney * 1.5 or totalMoney
                finalMoney = finalMoney * INCOME_MULT
                
                caller:AddMoney(finalMoney)
                caller:Notify("Отличное пойло! Держи " .. shizlib.FormatMoney(finalMoney))
                
                timer.Simple(0.25, function()
                    if IsValid(self) then self:EmitSound("vo/npc/male01/yeah02.wav", 80, 100, 1) end
                end)
            else
                caller:Notify("Я ничего не вижу! Поставь ящик или бутылки рядом со мной.")
                timer.Simple(0.25, function()
                    if IsValid(self) then self:EmitSound("vo/npc/male01/no02.wav", 80, 100, 1) end
                end)
            end

            self.cd = CurTime() + 2
        end,
        overhead = "Скупщик самогона",
        sequence = "pose_standing_01",
        model = "models/player/group02/male_04.mdl",
    },
    ["box-sell"] = {
        use = function(self, ply)
            if self.cd and self.cd > CurTime() then return end
            local sell = math.random(80,120)
            if IsValid(ply) and ply:IsPlayer() then
                local found_box = nil
                for _, ent in ipairs(ents.FindInSphere(self:GetPos(), CFG.useDist)) do
                    if ent:GetClass() == "boxsys_divan" then
                        found_box = ent
                        break
                    end
                end
                if IsValid(found_box) then
                    found_box:Remove()
                    found_box.LocalOwner:GiveSalary(sell)
                    self:EmitSound("vo/npc/male01/yeah02.wav", EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
                else
                    DarkRP.notify(ply, 1, 4, "Приходи ко мне когда у тебя появится груз...")
                    timer.Simple(0.25, function()
                        self:EmitSound(table.Random(EML_Meth_Salesman_NoMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
                    end)
                end
            end
            self.cd = CurTime() + 3
        end,
        overhead = "Кладовщик",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_06.mdl",
    },
    ["axe"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        overhead = "Дровосек",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_07.mdl",
        shop_list = {
            {
                name = "Топор",
                price = SELL_MULT * 100,
                model = "models/props/cs_militia/axe.mdl",
                wep = "axe",
            },
            {
                name = "Древесина",
                price = SELL_MULT * 20,
                model = "models/props_docks/channelmarker_gib01.mdl",
                ent = "shizlib_resource_wood",
            },
        },
    },
    ["pickaxe"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        overhead = "Шахтер",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_07.mdl",
        shop_list = {
            {
                name = "Кирка",
                price = SELL_MULT * 180,
                model = "models/jobs/pickaxe.mdl",
                wep = "pickaxe",
            },
            {
                name = "Камень",
                price = SELL_MULT * 25,
                model = "models/props_junk/rock001a.mdl",
                ent = "shizlib_resource_stone",
            },
        },
    },
    ["citywork"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        customCheck = function(ply, ent)
            if IsGov(ply:GetPlayerClass()) then
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
        end,
        overhead = "Захар",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_07.mdl",
        shop_list = {
            {
                name = "Инструменты",
                price = SELL_MULT * 200,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_tools",
            },
                        {
                name = "Огнетушитель",
                price = SELL_MULT * 500,
                model = "models/weapons/tfa_nmrih/w_tool_extinguisher.mdl",
                wep = "weapon_hg_extinguisher",
            },
        },
    },
    ["spirtmake"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        customCheck = function(ply, ent)
            if IsGov(ply:GetPlayerClass()) then
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
        end,
        overhead = "Джеймс",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_09.mdl",
        shop_list = {
            {
                name = "Бочка для брожения",
                price = SELL_MULT * 500,
                model = "models/props_citizen_tech/firetrap_propanecanister01a.mdl",
                ent = "alco_part_barrel",
            },
            {
                name = "Банка для смешивания",
                price = SELL_MULT * 45,
                model = "models/props_junk/plasticbucket001a.mdl",
                ent = "alco_jar",
            },
            {
                name = "Труба для перегонки",
                price = SELL_MULT * 30,
                model = "models/props_wasteland/prison_pipefaucet001a.mdl",
                ent = "alco_part_pipe",
            },
            {
                name = "Кухонный стол",
                price = SELL_MULT * 250,
                model = "models/props_wasteland/kitchen_counter001c.mdl",
                ent = "alco_povovarna",
            },
            {
                name = "Пустая бутылка",
                price = SELL_MULT * 15,
                model = "models/props_junk/glassjug01.mdl",
                ent = "alco_jar_empty",
            },
            {
                name = "Ящик для самогона",
                price = SELL_MULT * 100,
                model = "models/props_junk/plasticcrate01a.mdl",
                ent = "alco_crate",
            },
            {
                name = "Спирт",
                price = SELL_MULT * 150,
                model = "models/props_junk/garbage_milkcarton001a.mdl",
                ent = "alco_alcohol",
            },
            {
                name = "Дрожжи",
                price = SELL_MULT * 120,
                model = "models/props_junk/garbage_bag001a.mdl",
                ent = "alco_yeast",
            },
            {
                name = "Вода",
                price = SELL_MULT * 50,
                model = "models/props_junk/garbage_plasticbottle003a.mdl",
                ent = "alco_water",
            },
        },
    },
    ["printer"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        customCheck = function(ply, ent)
            if IsGov(ply:GetPlayerClass()) then
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
        end,
        overhead = "Продавец",
        sequence = "pose_ducking_01",
        model = "models/player/group01/male_07.mdl",
        shop_list = {
            {
                name = "Денежный принтер новейшей модели",
                price = SELL_MULT * 2500,
                model = "models/stromic/money_printer.mdl",
                ent = "rp_money_printer_pro",
                customCheck = function(item, npcTable, ply)
                    if !ply:HasPremium() and !ply:IsSuperAdmin() then
                        return false
                    end
                end,
            },
            {
                name = "Денежный принтер",
                price = SELL_MULT * 1500,
                model = "models/stromic/money_printer.mdl",
                ent = "rp_money_printer",
            },
            {
                name = "Рем. комплект для принтера",
                price = SELL_MULT * 150,
                model = "models/props_c17/BriefCase001a.mdl",
                ent = "rp_money_printer_fix",
            },
            {
                name = "Чернила для принтера",
                price = SELL_MULT * 100,
                model = "models/props_lab/reciever01d.mdl",
                ent = "rp_money_printer_ink",
            },
            {
                name = "Комплект деталей",
                price = SELL_MULT * 700,
                model = "models/props_lab/box01a.mdl",
                ent = "rp_money_printer_speed",
            },
            {
                name = "Комплект бронелистов",
                price = SELL_MULT * 250,
                model = "models/maxofs2d/hover_plate.mdl",
                ent = "rp_money_printer_hp",
            },
            {
                name = "Ёмкостный бак",
                price = SELL_MULT * 470,
                model = "models/thrusters/jetpack.mdl",
                ent = "rp_money_printer_max",
            },
        },
    },
    ["weed-b"] = {
        use = function(self, caller)
            if self.cd and self.cd > CurTime() then return end
            if not caller.weedAmount or caller.weedAmount <= 0 then
                caller:Notify("У тебя нет \"Травы\" для меня? Иди отсюда тогда!")
                timer.Simple(0.25, function()
                    self:EmitSound(table.Random(EML_Meth_Salesman_NoMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
                end)
            else
                local finalMoney = 60 * caller.weedAmount * INCOME_MULT

                if caller:HasPremium() then
                    finalMoney = finalMoney * 1.2
                end

                caller:Notify("Спасибо вот твои ".. shizlib.FormatMoney(finalMoney))
                caller:AddMoney(finalMoney)
                caller.weedAmount = 0
                timer.Simple(0.25, function()
                    self:EmitSound(table.Random(EML_Meth_Salesman_GotMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
                end)
            end
            self.cd = CurTime() + 3
        end,
        overhead = "",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_08.mdl",
    },
    ["weed"] = {
        use = function(self, caller)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(caller)
        end,
        customCheck = function(ply, ent)
            if IsGov(ply:GetPlayerClass()) then
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
        end,
        overhead = "Продавец",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_08.mdl",
        shop_list = {
            {
                name = "Вода",
                price = SELL_MULT * 20,
                model = "models/props_junk/garbage_plasticbottle003a.mdl",
                ent = "adrug_water",
            },
            {
                name = "Горшок",
                price = SELL_MULT * 100,
                model = "models/props_junk/terracotta01.mdl",
                ent = "adrug_weed_plant",
            },
            {
                name = "Лампа",
                price = SELL_MULT * 210,
                model = "models/props_c17/light_floodlight02_off.mdl",
                ent = "adrug_heat_lamp",
            },
            {
                name = "Подзарядник",
                price = SELL_MULT * 100,
                model = "models/items/car_battery01.mdl",
                ent = "adrug_battery",
            },
            {
                name = "Семена травки",
                price = SELL_MULT * 100,
                model = "models/props/de_inferno/crate_fruit_break_gib2.mdl",
                ent = "adrug_weed_seed",
            },
        }
    },
    ["opium-b"] = {
        use = function(self, caller)
            if self.cd and self.cd > CurTime() then return end

            if not caller.OpiumPrice or caller.OpiumPrice <= 0 then
                caller:Notify("У тебя нет опиума для меня? Иди отсюда тогда!")
                timer.Simple(0.25, function()
                    if IsValid(self) then self:EmitSound(table.Random(EML_Meth_Salesman_NoMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume) end
                end)
            else
                local totalMoney = caller.OpiumPrice
                local finalMoney = caller:HasPremium() and totalMoney * 1.5 or totalMoney
                finalMoney = finalMoney * INCOME_MULT
                
                caller:AddMoney(finalMoney)
                caller:Notify("Отличный товар! Держи " .. shizlib.FormatMoney(finalMoney))
                caller.OpiumPrice = 0
                
                timer.Simple(0.25, function()
                    if IsValid(self) then self:EmitSound(table.Random(EML_Meth_Salesman_GotMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume) end
                end)
            end

            self.cd = CurTime() + 3
        end,
        overhead = "",
        sequence = "pose_standing_01",
        model = "models/player/group03/male_06.mdl",
    },
    ["opium"] = {
        use = function(self, caller)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(caller)
        end,
        customCheck = function(ply, ent)
            if IsGov(ply:GetPlayerClass()) then
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
        end,
        overhead = "",
        sequence = "pose_standing_01",
        model = "models/player/group03/male_02.mdl",
        shop_list = {
            {
                name = "Бочка",
                price = SELL_MULT * 300,
                model = "models/props_c17/oildrum001.mdl",
                ent = "the_opium_barrel",
            },
            {
                name = "Теплодуховка",
                price = SELL_MULT * 500,
                model = "models/hunter/blocks/cube075x075x025.mdl",
                ent = "the_opium_heater",
            },
            {
                name = "Сборщик опиума",
                price = SELL_MULT * 600,
                model = "models/hunter/blocks/cube075x1x075.mdl",
                ent = "the_opium_packer",
            },
            {
                name = "Газ",
                price = SELL_MULT * 100,
                model = "models/props_junk/propane_tank001a.mdl",
                ent = "the_opium_gas",
            },
            {
                name = "Бутылка",
                price = SELL_MULT * 15,
                model = "models/props_lab/jar01a.mdl",
                ent = "the_opium_bottle",
            },
            {
                name = "Кодеин",
                price = SELL_MULT * 150,
                model = "models/props_junk/cardboard_box003a.mdl",
                ent = "the_opium_codeine",
            },
            {
                name = "Паравельден",
                price = SELL_MULT * 180,
                model = "models/props_junk/cardboard_box003a.mdl",
                ent = "the_opium_papaverine",
            },
            {
                name = "Сульфат",
                price = SELL_MULT * 120,
                model = "models/props_junk/cardboard_box003a.mdl",
                ent = "the_opium_sulfate",
            },
            {
                name = "Вода",
                price = SELL_MULT * 30,
                model = "models/props_junk/garbage_plasticbottle003a.mdl",
                ent = "the_opium_water",
            },
        }
    },
    ["eml-b"] = {
        use = function(self, caller)
            if (not self.nextUse or CurTime() >= self.nextUse) then
                if (caller:GetNWInt("player_meth") == 0) then
                    caller:Notify("Ты меня на****ь удумал? Приходи когда у тебя будут \"Синие Кристаллы\"!")
        
                    timer.Simple(0.25, function()
                        self:EmitSound(table.Random(EML_Meth_Salesman_NoMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
                    end)
                elseif caller:GetNWInt("player_meth") > 0 then
                    hook.Call("metvarim", nil, caller, caller.methkolvo)
                    caller.methkolvo = nil
                    local money = caller:GetNWInt("player_meth") * INCOME_MULT
                    caller:AddMoney(caller:HasPremium() and money * 1.5 or money)

                    caller:Notify("Ты настоящий бро! Держи свои " .. shizlib.FormatMoney(money) .. " и рви когти пока копы не спалили!")
        
                    caller:SetNWInt("player_meth", 0)
        
                    -- if not caller:IsWanted() then
                    --     caller:wanted(nil, "Продажа Мета")
                    -- end
        
                    timer.Simple(0.25, function()
                        self:EmitSound(table.Random(EML_Meth_Salesman_GotMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
                    end)
        
                    timer.Simple(2.5, function()
                        self:EmitSound("vo/npc/male01/moan0" .. math.random(1, 5) .. ".wav", EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
                    end)
                end
        
                self.nextUse = CurTime() + 3
            end
        end,
        overhead = "",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_08.mdl",
    },
    ["eml"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        customCheck = function(ply, ent)
            if IsGov(ply:GetPlayerClass()) then
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
        end,
        overhead = "Продавец",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_08.mdl",
        shop_list = {
            {
                name = "Плита",
                price = SELL_MULT * 500,
                model = "models/props_c17/furniturestove001a.mdl",
                ent = "eml_stove",
            },
            {
                name = "Газ",
                price = SELL_MULT * 100,
                model = "models/props_c17/canister01a.mdl",
                ent = "eml_gas",
            },
            {
                name = "Кастрюля",
                price = SELL_MULT * 50,
                model = "models/props_c17/metalpot001a.mdl",
                ent = "eml_spot",
            },
            {
                name = "Красный фосфор",
                price = SELL_MULT * 125,
                model = "models/props_junk/rock001a.mdl",
                ent = "eml_redp",
            },
            {
                name = "Банка",
                price = SELL_MULT * 50,
                model = "models/props_lab/jar01a.mdl",
                ent = "eml_jar",
            },
            {
                name = "Соляная Кислота",
                price = SELL_MULT * 250,
                model = "models/props_junk/garbage_plasticbottle001a.mdl",
                ent = "eml_macid",
            },
            {
                name = "Соль",
                price = SELL_MULT * 45,
                model = "models/props_junk/garbage_milkcarton002a.mdl",
                ent = "eml_salt",
            },
            {
                name = "Жидкий Йод",
                price = SELL_MULT * 150,
                model = "models/props_lab/jar01b.mdl",
                ent = "eml_iodine",
            },
            {
                name = "Вода",
                price = SELL_MULT * 40,
                model = "models/props_junk/garbage_plasticbottle003a.mdl",
                ent = "eml_water",
            },
        },
    },
    ["sig-b"] = {
        use = function(self, caller)
            if (not self.nextUse or CurTime() >= self.nextUse) then
                if not IsValid( caller ) or !caller:IsPlayer() then return end
                if caller.cfCigsAmount > 0 then
                    local amount = caller.cfCigsAmount*(cf.sellPrice)*INCOME_MULT
                    if caller:HasPremium() then
                        amount = amount * 1.5
                    end
                    caller:AddMoney(amount)
                    caller:Notify(cf.SellText1..caller.cfCigsAmount..cf.SellText2..shizlib.FormatMoney(amount)..cf.CurrencyText.."!")
                    caller.cfCigsAmount = 0
                    self:EmitSound(self.SellSound, 80, 100, 1) 
                else
                    timer.Simple(0.25, function()
                        self:EmitSound(table.Random(EML_Meth_Salesman_NoMeth_Sound), EML_Sound_Level, EML_Sound_Pitch, EML_Sound_Volume)
                    end)
                    caller:Notify("У тебя нет \"Сигарет\" для меня? Пошел прочь!")
                end
                self.nextUse = CurTime() + 3
            end
        end,
        overhead = "",
        sequence = "pose_standing_02",
        model = "models/player/group01/male_06.mdl",
    },
    ["sig"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        customCheck = function(ply, ent)
            if IsGov(ply:GetPlayerClass()) then
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
        end,
        overhead = "Продавец",
        sequence = "pose_standing_02",
        model = "models/player/group01/male_06.mdl",
        shop_list = {
            {
                name = "AUTO-CIG 2000",
                price = SELL_MULT * 500,
                model = "models/cigarette_factory/cf_machine.mdl",
                ent = "cf_cigarette_machine",
            },
            {
                name = "Модуль \"Скорость\"",
                price = SELL_MULT * 100,
                model = "models/maxofs2d/thruster_propeller.mdl",
                ent = "cf_engine_upgrade",
            },
            {
                name = "Модуль \"Ёмкость\"",
                price = SELL_MULT * 75,
                model = "models/thrusters/jetpack.mdl",
                ent = "cf_storage_upgrade",
            },
            {
                name = "Коробка для сбора сигарет",
                price = SELL_MULT * 60,
                model = "models/props_junk/cardboard_box003a.mdl",
                ent = "cf_delievery_box",
            },
            {
                name = "Бумага",
                price = SELL_MULT * 50,
                model = "models/cigarette_factory/cf_rollpaper.mdl",
                ent = "cf_roll_paper",
            },
            {
                name = "Табак",
                price = SELL_MULT * 150,
                model = "models/cigarette_factory/cf_tobacco_pack.mdl",
                ent = "cf_tobacco_pack",
            },
        },
    },
    ["ashot"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        overhead = "Ашот",
        sequence = "pose_standing_02",
        model = "models/player/group01/male_03.mdl",
        shop_list = {
            {
                name = "Хот-дог",
                price = SELL_MULT * 165,
                model =  "models/food/hotdog.mdl",
                food = "hotdog",
            },
            {
                name = "Гамбургер",
                price = SELL_MULT * 200,
                model =  "models/food/burger.mdl",
                food = "hamburger",
            },
        }
    },
    ["medic"] = {
        use = function(self, ply)
            if ply:GetPlayerClass() == TEAM_MEDIC then
                if ply.__LastMedicGet and ply.__LastMedicGet > CurTime() then
                    ply:Notify("Ты уже брал от меня аптечку, иди лечи людей!")
                    self:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                    return
                end
                self:EmitSound("vo/npc/male01/letsgo01.wav", 80, 100, 1)
                ply.__LastMedicGet = CurTime() + 30
                local wepTable = TEAM_MEDIC.Weapons
                for _, wep in pairs(wepTable) do
                    if ply:HasWeapon(wep) then
                        ply:GetWeapon(wep):Remove()
                    end
                end
                timer.Simple(.1, function()
                    for _, wep in pairs(wepTable) do
                        local weap = ply:Give(wep)
                        weap.UnDroppable = true 
                    end
                end)
                return
            end
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        overhead = "",
        sequence = "pose_standing_02",
        model = "models/player/group03/male_05.mdl",
        shop_list = {
            {
                name = "Набор ПМП",
                price = SELL_MULT * 500,
                model = "models/w_models/weapons/w_eq_medkit.mdl",
                wep = "weapon_medkit_sh",
            },
            {
                name = "Бинты",
                price = SELL_MULT * 100,
                model = "models/w_models/weapons/w_eq_medkit.mdl",
                wep = "weapon_bigbandage_sh",
            },
            {
                name = "Обезболивающие",
                price = SELL_MULT * 175,
                model = "models/morphine_syrette/morphine.mdl",
                wep = "weapon_painkillers",
            },
            {
                name = "Турникет",
                price = SELL_MULT * 100,
                model = "models/tourniquet/tourniquet.mdl",
                wep = "weapon_tourniquet",
            },
        }
    },
    ["gun"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        overhead = "Продавец",
        sequence = "pose_standing_02",
        model = "models/player/group01/male_04.mdl",
        customCheck = function(ply, ent)
            if not ply:GetNWBool("HasGunlicense", false) then
                ply:Notify("У тебя нет лицензии на оружие! Поговори с секретарем в мэрии чтобы купить её!")
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
        end,
        shop_list = {
            {
                name = "Glock 17",
                price = SELL_MULT * 1600,
                model = "models/weapons/tfa_ins2/w_glock_p80.mdl",
                wep = "weapon_glock17",
            },
            {
                name = "Glock 26",
                price = SELL_MULT * 900,
                model = "models/weapons/tfa_ins2/w_glock_p80.mdl",
                wep = "weapon_glock26",
            },
            {
                name = "Colt M1911",
                price = SELL_MULT * 1300,
                model = "models/weapons/arccw/c_ur_m1911.mdl",
                wep = "weapon_m1911",
            },
            {
                name = "Colt M45A1",
                price = SELL_MULT * 1100,
                model = "models/weapons/arccw/c_ur_m1911.mdl",
                wep = "weapon_m45",
            },
            {
                name = "Beretta M9",
                price = SELL_MULT * 1100,
                model = "models/weapons/zcity/v_beretta.mdl",
                wep = "weapon_m9beretta",
            },
            {
                name = "Beretta PX4",
                price = SELL_MULT * 1000,
                model = "models/weapons/zcity/w_pist_px4.mdl",
                wep = "weapon_px4beretta",
            },
            {
                name = "Draco",
                price = SELL_MULT * 3800,
                model = "models/draco/w_draco.mdl",
                wep = "weapon_draco",
            },
            {
                name = "Walther P22",
                price = SELL_MULT * 1200,
                model = "models/weapons/zcity/c_p22.mdl",
                wep = "weapon_p22",
            },
            {
                name = "ARP",
                price = SELL_MULT * 3600,
                model = "models/ar15/w_colt6149.mdl",
                wep = "weapon_ar_pistol",
            },
            {
                name = "Colt King Cobra",
                price = SELL_MULT * 2000,
                model = "models/weapons/zcity/w_thanez_cobra.mdl",
                wep = "weapon_revolver357",
            },
            {
                name = "Desert Eagle",
                price = SELL_MULT * 2500,
                model = "models/weapons/arccw/c_ud_deagle.mdl",
                wep = "weapon_deagle",
            },
            {
                name = "Remington 870",
                price = SELL_MULT * 4800,
                model = "models/weapons/arccw/c_ud_870.mdl",
                wep = "weapon_remington870",
            },
            {
                name = "Mossberg 590A1",
                price = SELL_MULT * 5000,
                model = "models/pwb/weapons/w_m590a1.mdl",
                wep = "weapon_m590a1",
            },
            {
                name = "Izh-43",
                price = SELL_MULT * 4000,
                model = "models/weapons/tfa_ins2/w_doublebarrel.mdl",
                wep = "weapon_doublebarrel",
            },
            {
                name = "VPO-209",
                price = SELL_MULT * 5600,
                model = "models/weapons/arccw/c_ur_ak.mdl",
                wep = "weapon_vpo209",
            },
            {
                name = "AR-15",
                price = SELL_MULT * 6000,
                model = "models/weapons/arccw/c_ud_m16.mdl",
                wep = "weapon_ar15",
            },
        },
    },
    ["turner"] = {
        use = function(self, ply)
            if ply:GetPlayerClass() ~= TEAM_TURNER then
                ply:Notify("Я поставляю материалы только лицензированным токарям!")
                self:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return
            end
            
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        overhead = "Поставщик материалов",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_09.mdl",
        shop_list = {
            {
                name = "Верстак",
                price = SELL_MULT * 2500,
                model = "models/props/cs_militia/table_shed.mdl",
                ent = "shizlib_bench_workbench",
            },
            {
                name = "Ткань",
                price = SELL_MULT * 70,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_cloth",
            },
            {
                name = "Болты",
                price = SELL_MULT * 180,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_screws",
            },
            {
                name = "Пружина",
                price = SELL_MULT * 300,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_spring",
            },
            {
                name = "Изолента",
                price = SELL_MULT * 100,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_tape",
            },
            {
                name = "Уголь",
                price = SELL_MULT * 150,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_coal",
            },
            {
                name = "Камень",
                price = SELL_MULT * 100,
                model = "models/props_junk/rock001a.mdl",
                ent = "shizlib_resource_stone",
            },
            {
                name = "Древесина",
                price = SELL_MULT * 350,
                model = "models/props_docks/channelmarker_gib01.mdl",
                ent = "shizlib_resource_wood",
            },
            {
                name = "Стекло",
                price = SELL_MULT * 225,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_glass",
            },
            {
                name = "Труба",
                price = SELL_MULT * 500,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_pipe",
            },
            {
                name = "Железо",
                price = SELL_MULT * 170,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_iron",
            },
            {
                name = "Сталь",
                price = SELL_MULT * 300,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_steel",
            },
            {
                name = "Алюминий",
                price = SELL_MULT * 240,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_aluminum",
            },
            {
                name = "Медь",
                price = SELL_MULT * 200,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_copper",
            },
            {
                name = "Свинец",
                price = SELL_MULT * 250,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_lead",
            },
            {
                name = "Золото",
                price = SELL_MULT * 800,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_gold",
            },
            {
                name = "Аккумулятор",
                price = SELL_MULT * 250,
                model = "models/props_junk/cardboard_box004a.mdl",
                ent = "shizlib_resource_battery",
            },
        }
    },
    ["workshop"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        overhead = "Продавец",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_06.mdl",
        customCheck = function(ply, ent)
            if IsGov(ply:GetPlayerClass()) then
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
            if not ply:GetNWBool("HasGunlicense", false) then
                ply:Notify("У тебя нет лицензии на оружие! Поговори с секретарем в мэрии чтобы купить её!")
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
        end,
        shop_list = {
            {
                name = "9x19mm Parabellum",
                price = SELL_MULT * 13 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_9x19mmparabellum",
            },
            {
                name = ".45 ACP",
                price = SELL_MULT * 15 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_.45acp",
            },
            {
                name = ".357 Magnum",
                price = SELL_MULT * 18 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_.357magnum",
            },
            {
                name = ".38 Special",
                price = SELL_MULT * 15 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_.38special",
            },
            {
                name = "7.62x39mm",
                price = SELL_MULT * 23 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_7.62x39mm",
            },
            {
                name = ".22 lr",
                price = SELL_MULT * 12 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_.22longrifle",
            },
            {
                name = "7.65x17mm",
                price = SELL_MULT * 24 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_7.65x17mm",
            },
            {
                name = "5.56x45mm",
                price = SELL_MULT * 24 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_5.56x45mm",
            },
            {
                name = ".50 AE",
                price = SELL_MULT * 25 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_.50actionexpress",
            },
            {
                name = "12/70 gauge",
                price = SELL_MULT * 15 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_12/70gauge",
            },
            {
                name = ".366 TKM",
                price = SELL_MULT * 24 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_.366tkm",
            },
            {
                name = "7.62x51mm",
                price = SELL_MULT * 40 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_7.62x51mm",
            },
            {
                name = "4.6x30mm",
                price = SELL_MULT * 20 * 3,
                model = "models/props_lab/box01a.mdl",
                ent = "ent_ammo_4.6x30mm",
            },
        }
    },
    ["ilegaldealer"] = {
        use = function(self, ply)
            net.Start("kas.shop_npc")
                net.WriteEntity(self)
            net.Send(ply)
        end,
        overhead = "Продавец",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_05.mdl",
        shop_list = {
            {
                name = "Отмычки",
                price = SELL_MULT * 250,
                model = "models/sterling/w_enhanced_lockpicks.mdl",
                wep = "rp_lockpick",
            },
            {
                name = "Устройство взлома",
                price = SELL_MULT * 800,
                model = "models/bkeypads/cracker.mdl",
                wep = "bkeypads_cracker",
            },
            -- {
            --     name = "Kevlar III Vest",
            --     price = 10000,
            --     model = "models/jworld_equipment/kevlar.mdl",
            --     ent = "ent_armor_vest4",
            -- },
            -- {
            --     name = "ACH Helmet III",
            --     price = 10000,
            --     model = "models/barney_helmet.mdl",
            --     ent = "ent_armor_helmet1",
            -- },
            
            -- {
            --     name = "Нож",
            --     price = SELL_MULT * 250,
            --     model = "models/zcity/weapons/w_sog_knife.mdl",
            --     wep = "weapon_sogknife",
            -- },
            -- {
            --     name = "Молоток",
            --     price = SELL_MULT * 300,
            --     model = "models/weapons/w_jjife_t.mdl",
            --     wep = "weapon_hammer",
            -- },
            -- {
            --     name = "Дубинка",
            --     price = SELL_MULT * 250,
            --     model = "models/weapons/tacint_melee/w_tonfa.mdl",
            --     wep = "weapon_hg_tonfa",
            -- },
            -- {
            --     name = "Топорик",
            --     price = SELL_MULT * 700,
            --     model = "models/weapons/tfa_nmrih/w_me_hatchet.mdl",
            --     wep = "weapon_hatchet",
            -- },
            -- {
            --     name = "Удавка",
            --     price = 900,
            --     model = "models/hmc/weapons/w_fibrewire.mdl",
            --     wep = "weapon_hg_fiberwire",
            -- },
        }
    },
    ["food_seller"] = {
        use = function(self, ply)
            if ply:GetPlayerClass() == TEAM_COOK then
                net.Start("kas.shop_npc")
                    net.WriteEntity(self)
                net.Send(ply)
            end
        end,
        customCheck = function(ply, ent)
            if ply:GetPlayerClass() != TEAM_COOK then
                ent:EmitSound("vo/npc/male01/busy02.wav", 80, 100, 1)
                return false
            end
        end,
        overhead = "Джон",
        sequence = "pose_standing_01",
        model = "models/player/group01/male_09.mdl",
        shop_list = {
            {
                name = "Плита",
                price = SELL_MULT * 500,
                model = "models/props_c17/furniturestove001a.mdl",
                ent = "eml_stove",
            },
            {
                name = "Газ",
                price = SELL_MULT * 100,
                model = "models/props_c17/canister01a.mdl",
                ent = "eml_gas",
            },
            {
                name = "Кастрюля",
                price = SELL_MULT * 50,
                model = "models/props_c17/metalpot001a.mdl",
                ent = "eml_spot",
            },
            {
                name = "Вода",
                price = SELL_MULT * 10,
                model = "models/props_everything/waterbottle.mdl",
                ent = "water",
            },
            {
                name = "Яблоко",
                price = SELL_MULT * 5,
                model = "models/props_everything/applegreen.mdl",
                ent = "apple",
            },
            {
                name = "Капуста",
                price = SELL_MULT * 10,
                model = "models/tsbb/vegetables/cabbage.mdl",
                ent = "cabbage",
            },
            {
                name = "Сыр",
                price = SELL_MULT * 5,
                model = "models/props_everything/cheeseswiss.mdl",
                ent = "cheese",
            },
            {
                name = "Кофейные зерна",
                price = SELL_MULT * 5,
                model = "models/props_lab/jar01b.mdl",
                ent = "coffe_seed",
            },
            {
                name = "Огурец",
                price = SELL_MULT * 5,
                model = "models/tsbb/vegetables/cucumber.mdl",
                ent = "cucumber",
            },
            {
                name = "Яйцо",
                price = SELL_MULT * 5,
                model = "models/props_everything/egg.mdl",
                ent = "egg",
            },
            {
                name = "Сырое мясо",
                price = SELL_MULT * 15,
                model = "models/checha/meat/meat.mdl",
                ent = "meat",
            },
            {
                name = "Молоко",
                price = SELL_MULT * 15,
                model = "models/props_everything/milk.mdl",
                ent = "milk",
            },
            {
                name = "Масло",
                price = SELL_MULT * 5,
                model = "models/props_everything/orangejuice.mdl",
                ent = "oil",
            },
            {
                name = "Лук",
                price = SELL_MULT * 5,
                model = "models/props_everything/onionwhite.mdl",
                ent = "onion",
            },
            {
                name = "Сырая картошка",
                price = SELL_MULT * 5,
                model = "models/tsbb/vegetables/sweet_potato.mdl",
                ent = "potato",
            },
            {
                name = "Пшеница",
                price = SELL_MULT * 5,
                model = "models/tsbb/vegetables/wheat.mdl",
                ent = "wheat",
            },
        },
    },
}

kas.shop_npc.police = kas.shop_npc.police or {}
kas.shop_npc.police.cfg = {
    {
        name = "Патруль",
        description = "Тазер, USP",
        model = "models/props_interiors/pot01a.mdl",
        weapon = {
            "weapon_taser", // change to weapon_taser
            "usp"
        },
    },
    {
        name = "Поддержка",
        description = "Тазер, P228, Аптечка",
        model = "models/Items/combine_rifle_ammo01.mdl",
        weapon = {
            "weapon_taser", // change to weapon_taser
            "p228",
            "med_kit",
        },
    },
    {
        name = "Рейдер",
        description = "Тазер, USP, M4A1, Таран",
        model = "models/Items/ammocrate_grenade.mdl",
        check = function() return GetGlobalBool("DarkRP_LockDown") end,
        errorMsg = "Данный набор доступен только во время ком. часа",
        weapon = {
            "weapon_taser", // change to weapon_taser
            "usp",
            "m4a1",
            "door_ram"
        },
    },
}

kas.shop_npc.skills = kas.shop_npc.skills or {}
kas.shop_npc.skills.cfg = {
    {
        id = 1,
        name = "Дополнительное здоровье",
        description = "Дает дополнительные +10 к максимальному здоровью за каждое очко улучшения",
        price = 1000000,
        nextStage = 400000,
        max = 20,
        model = "models/balloons/balloon_classicheart.mdl",
    },
    {
        id = 2,
        name = "Керамическая пластина",
        description = "Дает дополнительные +10 к максимальной брони за каждое очко улучшения",
        price = 1000000,
        nextStage = 300000,
        max = 5,
        model = "models/thrusters/jetpack.mdl",
    },
    {
        id = 3,
        name = "Спринтер",
        description = "Дает дополнительные +10 к скорости обычной ходьбы/бега за каждое очко улучшения",
        price = 1000000,
        nextStage = 300000,
        max = 10,
        model = "models/Humans/Group01/Male_Cheaple.mdl",
    },
    {
        id = 4,
        name = "Кенгуру",
        description = "Дает дополнительные +10 к высоте прыжка за каждое очко улучшения",
        price = 1000000,
        nextStage = 300000,
        max = 10,
        model = "models/Humans/Group01/Male_Cheaple.mdl",
    },
    {
        id = 5,
        name = "Зачарованные пули \"Отдача\"",
        description = "При поподание по игроку отталкивает его в противоположную сторону",
        price = 5000000,
        nextStage = 0,
        max = 1,
        model = "models/Combine_Helicopter/helicopter_bomb01.mdl",
    },
}


-- WL
FACTION_CONFIG = {
    ["SWAT"] = {
        name = "SWAT",
        ranks = {
            ["SWAT.User"]   = "Боец SWAT",
            ["SWAT.Leader"] = "Командир SWAT"
        },
    },
    ["FBI"] = {
        name = "FBI",
        ranks = {
            ["FBI.User"]   = "Агент FBI",
            ["FBI.Deputy"] = "Заместитель Руководителя",
            ["FBI.Leader"] = "Руководитель FBI"
        },
    },
    ["POLICE"] = {
        name = "Полиция",
        ranks = {
            ["POLICE.User"]   = "Сотрудник Полиции",
            ["POLICE.Deputy"] = "Заместитель Начальника",
            ["POLICE.Leader"] = "Начальник Полиции"
        },
    },
    ["GND"] = {
        name = "GND",
        ranks = {
            ["GND.User"]   = "Детектив GND",
            ["GND.Leader"] = "Супервайзер GND"
        },
    },
}


-- for name, tbl in pairs(hg.armor) do
-- 	local ITEM = setmetatable( {}, { __index = Item } )
-- 	ITEM.Class = 'ent_ammo_' .. string.Replace( string.lower( name ), " ", "" )
-- 	ITEM.Name = tbl.name and tbl.name or 'nil'
-- 	ITEM.Description = tbl.description and tbl.description or ''
-- 	ITEM.Stackable = true
-- 	ITEM.HighlightColor = itemstore.config.HighlightColours.Ammo
-- 	ITEM.Base = "base_auto"

-- 	itemstore.items.Register( ITEM )
-- 	itemstore.config.DisabledItems['ent_ammo_' .. string.Replace( string.lower( name ), " ", "" )] = true
-- end

-- for name, tbl in pairs(hg.attachments) do
-- 	local ITEM = setmetatable( {}, { __index = Item } )
-- 	ITEM.Class = 'ent_ammo_' .. string.Replace( string.lower( name ), " ", "" )
-- 	ITEM.Name = tbl.name and tbl.name or 'nil'
-- 	ITEM.Description = tbl.description and tbl.description or ''
-- 	ITEM.Stackable = true
-- 	ITEM.HighlightColor = itemstore.config.HighlightColours.Ammo
-- 	ITEM.Base = "base_auto"

-- 	itemstore.items.Register( ITEM )
-- 	itemstore.config.DisabledItems['ent_ammo_' .. string.Replace( string.lower( name ), " ", "" )] = true
-- end
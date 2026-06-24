local PLAYER = FindMetaTable('Player')

local math_Round = math.Round
local math_abs = math.abs
local ipairs = ipairs
local IsValid = IsValid
local ents_GetAll = ents.GetAll
local timer_Create = timer.Create
local player_GetAll = player.GetAll
local hook_Run = hook.Run

function PLAYER:GetOwnedPropertiesCount()
    local count = 0
    local sid64 = self:SteamID64Safe()
    if not sid64 or sid64 == "" then return 0 end

    local counted = {}
    for _, ent in ipairs(ents_GetAll()) do
        if IsValid(ent) and ent.IsManagedDoor and ent:IsManagedDoor() and ent:GetDoorOwnerSID64() == sid64 then
            local dCfg = ent:GetDoorCfg()
            if dCfg and dCfg.Name and not counted[dCfg.Name] then
                counted[dCfg.Name] = true
                count = count + 1
            end
        end
    end
    return count
end

function PLAYER:GiveSalary(num, text)
    if num <= 0 then return end

    local netSalary = num

    if self.HasPremium and self:HasPremium() then
        netSalary = math_Round(num * 1.5)
    else
        netSalary = ECONOMICS.ApplyTax("Salary", num)
    end

    if netSalary <= 0 then return end

    hook_Run("playerGetSalary", self, netSalary)
    notif(self, "Зарплата! Вы получили " .. FormatMoney(netSalary), 'ok')
end

function InitSalaryTimer()
    timer.Create("PayDayTimer", cfg.slarytimer, 0, function()
        for _, pl in ipairs(player_GetAll()) do
            local salary = pl:GetPlayerClass() and pl:GetPlayerClass().Salary or 0
            
            if salary > 0 then
                pl:GiveSalary(salary)
            end

            local propCount = pl:GetOwnedPropertiesCount()
            if propCount > 0 then
                local baseTaxCalc = salary > 0 and salary or 100
                local estateTaxRate = ECONOMICS.Taxes and ECONOMICS.Taxes["Estate"] or 0
                local estateTaxAmount = math_Round(baseTaxCalc * estateTaxRate * propCount)

                if estateTaxAmount > 0 then
                    ECONOMICS.BUDGET.Add(estateTaxAmount)
                    if pl.AddMoney then pl:AddMoney(-estateTaxAmount) end
                    notif(pl, "Удержан налог на недвижимость (" .. propCount .. " шт.): " .. FormatMoney(estateTaxAmount), 'error')
                end
            end
        end
    end)
end

hook.Add("InitPostEntity", "InitSalaryTimer?", InitSalaryTimer)
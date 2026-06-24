-- -- shizlib_taxes.lua
-- shizlib = shizlib or {}

-- shizlib.TaxRate_Purchase = 0.05 -- 5%
-- shizlib.TaxRate_Salary = 0.10   -- 10%

-- function shizlib.CalculateTax(amount, taxType)
--     local rate = (taxType == "purchase" and shizlib.TaxRate_Purchase) or (taxType == "salary" and shizlib.TaxRate_Salary) or 0
--     return math.floor(amount * rate), math.floor(amount * (1 - rate))
-- end

-- function shizlib.ApplyTax(amount, taxType)
--     local tax, net = shizlib.CalculateTax(amount, taxType)
--     return tax, net
-- end

-- if SERVER then
--     -- Example usage function for Mayor
--     function shizlib.SetTaxRate(rateType, rate)
--         rate = math.Clamp(rate, 0, 0.25)
--         if rateType == "purchase" then
--             shizlib.TaxRate_Purchase = rate
--         elseif rateType == "salary" then
--             shizlib.TaxRate_Salary = rate
--         end
--     end
-- end

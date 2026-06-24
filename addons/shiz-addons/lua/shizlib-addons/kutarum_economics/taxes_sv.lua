function ECONOMICS.ApplyTax( taxType, num )
    local newnum, tax = ECONOMICS.CalcTax( taxType, num )
    ECONOMICS.BUDGET.Add( tax )

    return newnum
end
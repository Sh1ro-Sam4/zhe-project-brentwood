ECONOMICS = ECONOMICS or {}
ECONOMICS.Taxes = {
    Sell = .05,
    Purchase = .05,
    Salary = .1,
    Estate = .1
}

function ECONOMICS.CalcTax( taxType, num )
    local tax = math.ceil( num * ECONOMICS.Taxes[taxType] )

    return num - tax, tax
end
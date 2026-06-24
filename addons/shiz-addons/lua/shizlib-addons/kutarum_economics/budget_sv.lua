local BUDGET = ECONOMICS.BUDGET
function BUDGET.Set( num )
    BUDGET.amount = num
    ECONOMICS.Sync()
end

function BUDGET.Add( num )
    BUDGET.amount = BUDGET.amount + num
    ECONOMICS.Sync()
end
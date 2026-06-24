local PLAYER = FindMetaTable('Player')
local string_comma = string.Comma

function PLAYER:GetMoney()
    return self:GetNW2Int("Money", 0)
end

function FormatMoney(a)
    return shizlib.FormatMoney(a)
end
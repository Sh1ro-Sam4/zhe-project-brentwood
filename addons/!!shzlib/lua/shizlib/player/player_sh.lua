local Player = FindMetaTable('Player')
local Entity = FindMetaTable('Entity')

function Entity:IsValidPlayer()
    return self and self:IsValid() and self:IsPlayer() and not self:IsBot()
end

function Player:isFemale()
	if !self:IsPlayer() then return false end
	if string.match(self:GetModel(),"female") || string.match(self:GetModel(),"alyx") || string.match(self:GetModel(),"mossman") then
		return true
	else
		return false
	end
end

function Player:IsGodBlessed()
	return false
end

function Player:IsStuff()
	return CFG.isAdmin[self:GetUserGroup()]
end

function Player:HasFullSpawnMenu()
	return CFG.spawnMenuBuy[self:SteamID64()] or sam.ranks.get_rank(self:GetUserGroup()).immunity >= 85
end

function Player:CanDoCommonThings()
	if not self:Alive() then return false end

	return true
end

function PLAYER:CanAfford(amount)
	return tonumber(self:GetMoney()) > tonumber(amount)
end

if not PLAYER.SteamName then
	PLAYER.SteamName = PLAYER.SteamName or PLAYER.Name
	function PLAYER:GetName()
		return (IsValid(self) and (self:GetNetVar('Name') or self:SteamName()) or "Unknown")
	end
	function PLAYER:Name()
		return (IsValid(self) and (self:GetNetVar('Name') or self:SteamName()) or "Unknown")
	end
	function PLAYER:Nick()
		return (IsValid(self) and (self:GetNetVar('Name') or self:SteamName()) or "Unknown")
	end
end
-- function PLAYER:Name()
-- 	return (IsValid(self) and (self:GetNetVar('Name') or self:SteamName()) or "Unknown")
-- end

function player.Find(info)
	info = tostring(info)
	for k, v in ipairs(player.GetAll()) do
		if (info == v:SteamID()) or (info == v:SteamID64()) or (string.find(string.lower(v:Name()), string.lower(info), 1, true) ~= nil) then
			return v
		end
	end
end
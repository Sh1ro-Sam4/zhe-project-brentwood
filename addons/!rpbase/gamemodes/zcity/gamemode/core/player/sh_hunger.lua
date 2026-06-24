local PLAYER = FindMetaTable('Player')

function PLAYER:GetHunger()
	return self:GetNetVar('Energy')
end
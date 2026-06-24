local PLAYER = FindMetaTable('Player')

function PLAYER:SetPremium(day)
	day = day or 1
	local time = tonumber(self:GetDRPData("premium", 0))

	if time > os.time() then
		time = time + 24 * day * 60 * 60
	else
		time = os.time() + 24 * day * 60 * 60
	end

	self:SetDRPData("premium", time)
	self:SetNWInt("premium", time)
end

function PLAYER:HasPremium()
	if self:SteamID64() == GetGlobalString("OnyxTop1Donator_Day", "") then
		return true
	end
	return self:GetNWInt("premium", 0) > os.time()
end

hook.Add("PlayerInitialSpawn", "Premium.Initial", function(ply)
	local time
	if ply:GetDRPData("premium") then
		time = tonumber(ply:GetDRPData("premium", 0))
	else
		time = tonumber(ply:GetDRPData("premium", 0))
		ply:SetDRPData("premium", time)
	end

	if time > os.time() then
		ply:SetNWInt("premium", time)
	end
end)

hook.Add("HG_OnOtrub", "СдатьсяНахуй", function(ply)
	ply.__OtrubLast = CurTime() + 300
end)

hook.Add("Org Think", "НеБудешьСдаваться", function(owner, org, timeValue)
	if not owner or not IsValid(owner) then return end
	if not org or not owner or not IsValid(owner) then return end
	-- if owner == Player(77) then
	-- 	print(org.otrub, owner.__OtrubLast, CurTime())
	-- end
	if org.otrub and (owner.__OtrubLast and owner.__OtrubLast < CurTime()) and not owner.__OtrubStarted then
		owner.__OtrubStarted = true
		netstream.Start(owner, "otrbu_surredent")
	end
end)

netstream.Hook("otrbu_surredent", function(ply, data)
	if not ply:Alive() then return end
	if not ply.organism then return end
	if not ply.organism.otrub then return end
	if not ply.__OtrubStarted then return end

	ply:Kill()
	ply.__OtrubStarted = nil
	ply.__OtrubLast = nil
end)
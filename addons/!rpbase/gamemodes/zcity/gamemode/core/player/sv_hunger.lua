local PLAYER = FindMetaTable('Player')

hook.Add("PlayerSpawn", "Golod_ForceSyncOnSpawn", function(ply)
	if !ply:GetHunger() then
		ply:SetNetVar('Energy', 100)
	end
end)

hook.Add("PlayerInitialSpawn", "Golod_AssignPlayerData", function(ply) 
    timer.Simple(8, function()
		ply:SetNetVar('Energy', 100)
    end)
end)

function PLAYER:SetHunger(amount)
	self:SetNetVar('Energy', amount)
end

function PLAYER:GetHunger()
	return self:GetNetVar('Energy') or 100
end

function PLAYER:AddHunger(amount)
	self:SetHunger(self:GetHunger() + amount)
end

function PLAYER:TakeHunger(amount)
	self:AddHunger(-math.abs(amount))
end

local hungry_a_bit = {
	"Ммм, я проголодался...",
	"Было бы здорово перекусить...",
	"Я проголодался...",
	"Пора подкрепиться.",
}

local very_hungry = {
	"Мой желудок пуст...",
	"Если я не поем, мне будет еще хуже...",
	"Желудок... Черт возьми... Я чувствую себя больным",
}

timer.Create('HungerTick', cfg.hungerrate, 0, function()
	--print("meow")
    for _, v in ipairs(player.GetAll()) do
        if !v:InSpawnZone() and v:Alive() then
			if tonumber(v:GetHunger()) < 50 and tonumber(v:GetHunger()) > 25 then
				if !timer.Exists('HungerTickGolodCD'..v:SteamID64()) then
					timer.Create('HungerTickGolodCD'..v:SteamID64(), 120, 1, function() end)
					v:Notify(table.Random(hungry_a_bit), 1, "phrase", 1, nil, Color(255, 255, 255, 255))
				end
			elseif tonumber(v:GetHunger()) < 25 then
				if !timer.Exists('HungerTickGolodCD'..v:SteamID64()) then
					timer.Create('HungerTickGolodCD'..v:SteamID64(), 120, 1, function() end)
					v:Notify(table.Random(very_hungry), 1, "phrase", 1, nil, Color(255, 255, 255, 255))
				end
			end
			
        	if tonumber(v:GetHunger()) <= 20 then
        		v:EmitSound("zcitysnd/uni/hungry_"..math.random(1,6)..".mp3")
        	end
        	if tonumber(v:GetHunger()) < 10 then
        	    local org = v.organism
        	    org.painadd = org.painadd + 50

        	    v:EmitSound("zcitysnd/uni/hungry_"..math.random(1,6)..".mp3")
        	end
        	if tonumber(v:GetHunger()) > 0 then
        	    v:TakeHunger(cfg.hungertake)
        	end
		end
    end
end)


hook.Add("Org Clear","Removehunger",function(org)
	if IsValid(org.owner) and org.owner:IsPlayer() then
		org.owner:SetHunger(100)
	end
end)

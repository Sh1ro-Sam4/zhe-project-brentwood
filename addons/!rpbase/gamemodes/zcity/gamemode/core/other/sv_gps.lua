util.AddNetworkString('rp.GovernmentRequare_vec')
util.AddNetworkString('rp.GovernmentRequare')
util.AddNetworkString('rp.GovernmentRequareMed')


net.Receive('rp.GovernmentRequare',function(len,ply)
	local rsn = net.ReadString()
	if rsn == '' then return end

	notif(ply, 'Вы вызвали полицию', 'ok')

	local playerName = ply:GetNWString("PlayerName", ply:Name())
	local color = Color(255, 255, 255)
	local chatdist = (cfg and cfg.chatdist) or 450
	for _, target in ipairs(player.GetAll()) do
		if IsValid(target) and target:GetPos():Distance(ply:GetPos()) <= chatdist then
			sendMessageCustom(target, color, playerName .. " вызывает полицию")
		end
	end

	for k,v in pairs(player.GetAll()) do
		if not IsGov(v:GetPlayerClass()) then continue end
		net.Start('rp.GovernmentRequare')
		net.WriteEntity(ply)
		net.WriteString(rsn)
		net.Send(v)
	end
end)

net.Receive('rp.GovernmentRequareMed',function(len,ply)
	local rsn = net.ReadString()
	if rsn == '' then return end

	notif(ply, 'Вы вызвали врачей', 'ok')

	local playerName = ply:GetNWString("PlayerName", ply:Name())
	local color = Color(255, 255, 255)
	local chatdist = (cfg and cfg.chatdist) or 450
	for _, target in ipairs(player.GetAll()) do
		if IsValid(target) and target:GetPos():Distance(ply:GetPos()) <= chatdist then
			sendMessageCustom(target, color, playerName .. " вызывает врачей")
		end
	end

	for k,v in pairs(player.GetAll()) do
		if not IsMedic(v:GetPlayerClass()) then continue end
		net.Start('rp.GovernmentRequareMed')
		net.WriteEntity(ply)
		net.WriteString(rsn)
		net.Send(v)
	end
end)

function CP_Call(vec,str)
	for k,v in pairs(player.GetAll()) do
		if not IsGov(v:GetPlayerClass()) then continue end
		net.Start('rp.GovernmentRequare_vec')
		net.WriteVector(vec)
		net.WriteString(str)
		net.Send(v)
	end
end
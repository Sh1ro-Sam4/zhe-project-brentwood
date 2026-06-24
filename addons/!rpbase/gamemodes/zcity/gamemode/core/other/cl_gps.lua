function DrawPosInfo(icon, pos, text)
    local d = math.floor(LocalPlayer():GetPos():Distance(pos)/100)
    local pos = pos:ToScreen()
    local x, y = math.Clamp(pos.x, 0, ScrW() - 26), math.Clamp(pos.y, 0, ScrH() - 26)

    if pos.x > 0 and pos.x < ScrW() and pos.y > 0 and pos.y < ScrH() then
        local h = select(2, draw.SimpleText(text, 'ui.22', pos.x + 30, pos.y, Color(255,255,255), 0, 0))

        draw.SimpleText("Дистанция: " .. d .. "m", 'ui.22', pos.x + 30, pos.y + h, Color(255,255,255), 0, 0)
    end

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(Material(icon))
    surface.DrawTexturedRect(x, y, 21, 21)
end

hook.Add("HUDPaint", "sup.gps", function()
    for k,v in pairs(gpspos) do
        DrawPosInfo(v.i, v.p, k)

        if LocalPlayer():GetPos():DistToSqr(v.p) <= 8000 then
            if gpspos[k] ~= nil then
                gpspos[k] = nil
                //chat.AddText(Color(0,255,128), "[GPS] ", Color(255,255,255), "Вы пришли к месту назначения!")
                EmitSound( Sound( "garrysmod/balloon_pop_cute.wav" ), LocalPlayer():GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
            end
        end
    end
end)


net.Receive("rp.GovernmentRequare_vec", function()
	local pos = net.ReadVector()
	local reason = net.ReadString()

	chat.AddText(Color(200,0,0), "[911] ", Color(255,255,125), reason .. "!")
    -- EmitSound( Sound( "garrysmod/balloon_pop_cute.wav" ), LocalPlayer():GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
    EmitSound( Sound( "ambient/alarms/apc_alarm_pass1.wav" ), LocalPlayer():GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )

    AddGPSPos(pos, 180, "Вызов: " .. reason, "icon16/sound.png")
end)

net.Receive("rp.GovernmentRequare",function()
    local ply = net.ReadEntity()
    if not ply then return end
    local reason = net.ReadString()
    if not reason then return end

    local pos = ply:GetPos()

    chat.AddText(Color(200,0,0), "[911] ", ply:GetPlayerColor():ToColor(), ply:GetPlayerName(), Color(255,255,255), " вызывает полицию: ", Color(255,255,125), reason .. "!")
    -- EmitSound( Sound( "garrysmod/balloon_pop_cute.wav" ), LocalPlayer():GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
    EmitSound( Sound( "ambient/alarms/apc_alarm_pass1.wav" ), LocalPlayer():GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )

    AddGPSPos(pos, 180, "Вызов: " .. reason, "icon16/sound.png")
end)

net.Receive("rp.GovernmentRequareMed",function()
    local ply = net.ReadEntity()
    if not ply then return end
    local reason = net.ReadString()
    if not reason then return end

    local pos = ply:GetPos()

    chat.AddText(Color(200,0,0), "[911] ", ply:GetPlayerColor():ToColor(), ply:GetPlayerName(), Color(255,255,255), " вызывает врачей: ", Color(255,255,125), reason .. "!")
    -- EmitSound( Sound( "garrysmod/balloon_pop_cute.wav" ), LocalPlayer():GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
    EmitSound( Sound( "ambient/alarms/apc_alarm_pass1.wav" ), LocalPlayer():GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )

    AddGPSPos(pos, 180, "Вызов: " .. reason, "icon16/sound.png")
end)

hook.Add("PostDrawTranslucentRenderables", "PoliceWH", function(depth, sky)
	if depth or sky then return end
	if IsGov(lply:GetPlayerClass()) or IsMedic(lply:GetPlayerClass()) then
        for k, v in ipairs(player.GetAll()) do
            if IsGov(v:GetPlayerClass()) or IsMedic(v:GetPlayerClass()) then continue end
            if not v:Alive() then continue end

            local dist = v:GetPos():DistToSqr(LocalPlayer():EyePos())
            if dist > 1250000 then continue end
        end
	end
end)
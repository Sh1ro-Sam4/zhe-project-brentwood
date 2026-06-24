shizlib.action_with_player = shizlib.action_with_player or {}
shizlib.action_with_door = shizlib.action_with_door or {}
function shizlib.action_with_player.Open(ply)
    -- local opts = {
    --     {
    --         'Передать денег',
    --         'shizlib/icon17/64/money.png',
    --         function()
    --             shizlib.request.number('Передача денег', 'Сколько хотите передать?', '', function(val)
    --                 RunConsoleCommand('say', '/givemoney ' .. val)
    --             end)
    --         end,
    --     },
    --     --{
    --     --    'Отправить предложение обмена',
    --     --    'shizlib/icon17/64/writing.png',
    --     --    function()
    --     --        RunConsoleCommand('say', '/trade '.. ply:Name())
    --     --    end,
    --     --},
    --     {
    --         'Показать паспорт',
    --         'shizlib/icon17/64/licence.png',
    --         function()
    --             netstream.Start("shizlib.ques.ShowPassport", { target = ply })
    --         end,
    --     },
    -- }
    -- if IsGov(LocalPlayer():GetPlayerClass()) then
    --     local tr = hg.eyeTrace(LocalPlayer()).Entity
    --     local ragowner = hg.RagdollOwner(tr) or tr

    --     table.insert(opts, {
    --         'Выписать штраф',
    --         'shizlib/icon17/64/writing.png',
    --         function()
    --             shizlib.request.number('Штрафы', 'Введите сумму штрафа', '', function(val)
    --                 netstream.Start("shizlib.ques.Penalty", { target = ply, sum = val })
    --             end)
    --         end,
    --     })
    --     if ragowner:GetNetVar('handcuffed') then
    --         table.insert(opts, {
    --             'Осмотреть паспорт',
    --             'shizlib/icon17/64/licence.png',
    --             function()
    --                 netstream.Start("shizlib.ques.CheckPassport", { target = ply })
    --             end,
    --         })
            
    --         table.insert(opts, {
    --             'Положить/Поднять',
    --             'shizlib/icon17/64/licence.png',
    --             function()
    --                 netstream.Start("shizlib.ques.FakeDown", { target = ply })
    --             end,
    --         })
    --     end
    -- end

    -- if IsSWAT(LocalPlayer():GetPlayerClass()) or IsCop(LocalPlayer():GetPlayerClass()) then
    --     table.insert(opts, {
    --         'Проверить лицензию на оружие',
    --         'shizlib/icon17/64/order.png',
    --         function()
    --             netstream.Start("shizlib.ques.CheckLisence", { target = ply })
    --         end,
    --     })
    -- end

    -- shizlib.circularMenu(opts)

    local tbl = {}
    local tr = hg.eyeTrace(LocalPlayer())
	local pl = hg.RagdollOwner(tr.Entity) or tr.Entity

    
    local canrobbone = {
        ["ValveBiped.Bip01_Pelvis"] = false,
        ["ValveBiped.Bip01_Spine"] = true,
        ["ValveBiped.Bip01_L_Thigh"] = true,
        ["ValveBiped.Bip01_R_Thigh"] = true,
    }

	tbl[#tbl + 1] = {function()
		shizlib.request.number('Передача денег', 'Сколько хотите передать?', '', function(val)
			RunConsoleCommand('say', '/givemoney ' .. val)
        end)
	end, 'Передать денег'}

	tbl[#tbl + 1] = {function()
		netstream.Start("shizlib.ques.ShowPassport", { target = ply })
	end, 'Показать паспорт'}

    if LocalPlayer():GetPlayerClass() == TEAM_CITIZEN and canrobbone[pl:GetBoneName(pl:TranslatePhysBoneToBone(tr.PhysicsBone))] then
        tbl[#tbl + 1] = {function()
            netstream.Start("shizlib.ques.RobMoney", { target = ply })
        end, 'Украсть деньги'}
    end

	if IsGov(LocalPlayer():GetPlayerClass()) then

		tbl[#tbl + 1] = {function()
			shizlib.request.number('Штрафы', 'Введите сумму штрафа', '', function(val)
				netstream.Start("shizlib.ques.Penalty", { target = ply, sum = val })
			end)
		end, 'Выписать штраф'}

		if pl:GetNetVar('handcuffed') then
			tbl[#tbl + 1] = {function()
				netstream.Start("shizlib.ques.CheckPassport", { target = ply })
			end, 'Осмотреть паспорт'}

			tbl[#tbl + 1] = {function()
				netstream.Start("shizlib.ques.FakeDown", { target = ply })
			end, 'Положить/Поднять'}
		end
	end

	hg.CreateRadialMenu(tbl)
end

function shizlib.action_with_door.Open(ent)
    -- local opts = {
    --     {
    --         'Постучать в дверь',
    --         'shizlib/icon17/64/licence.png',
    --         function()
    --             netstream.Start("shizlib.doors.KnockKnock", { target = ent })
    --         end,
    --     },
    -- }

    -- shizlib.circularMenu(opts)
    local tbl = {}
    tbl[#tbl + 1] = {function()
		netstream.Start("shizlib.doors.KnockKnock", { target = ent })
	end, 'Постучать в дверь'}

	hg.CreateRadialMenu(tbl)
end

local a = 0
hook.Add('Think', 'shizlib.action_with_player.hook', function()
    local ply = LocalPlayer()
    
    if not IsValid(ply) then return end
    if IsValid(MENUPANELHUYHUY) then return end

    local tr = hg.eyeTrace(ply, CFG.useDist)
    local ent = tr.Entity
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and ishgweapon(wep) then return end

    if IsValid(ply.FakeRagdoll) then return end
    if ply:GetNWBool("isGhost") then return end
    if IsValid(shizlib.usePnl) or not (ent:IsRagdoll() or ent:IsPlayer()) then return end
    if ent:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end
    if ply:KeyDown(IN_USE) then
        a = a + FrameTime()
    else
        a = 0
    end

    if a >= .5 then
        a = 0
        shizlib.action_with_player.Open(ent)
    end 
end)

hook.Remove('Think', 'shizlib.action_with_door.hook', function()
    local ply = LocalPlayer()
    
    if not IsValid(ply) then return end
    if IsValid(MENUPANELHUYHUY) then return end

    local ent = hg.eyeTrace(ply).Entity

    if IsValid(shizlib.usePnl) or not (hgIsDoor(ent) and ent:IsManagedDoor()) then return end
    if ent:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end
    if ply:KeyDown(IN_WALK) then
        a = a + FrameTime()
    else
        a = 0
    end

    if a >= .25 then
        a = 0
        shizlib.action_with_door.Open(ent)
    end 
end)

/*
    FUSE:GOVORILKA
*/

local Tag = "LibFuse:Govorilka"

local CharToHex = function( char ) return string.format( "%%%02X", string.byte(char) ) end
local function UrlEncode( str )
    return str:gsub( "[^%w _~%.%-%,]", CharToHex ):gsub( " ", "+" )
end

net.Receive(Tag, function()
    v = net.ReadEntity()
    s = UrlEncode(net.ReadString())
    local g_station = nil
    sound.PlayURL ( string.format("https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=%s&tl=RU", s), "3d", function( ss )
        if ( IsValid( ss ) ) then
            ss:SetPos( v:GetPos() )
            ss:SetVolume(1)
            ss:Play()

            g_station = station
        end
    end)
end)
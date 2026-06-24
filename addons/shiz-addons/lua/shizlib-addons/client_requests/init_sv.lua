Question = {}
Questions = {}

shizlib.ques = shizlib.ques or {}

util.AddNetworkString("DoQuestion")
util.AddNetworkString("KillQuestionVGUI")

function ccDoQuestion(ply, cmd, args)
    if not ply:CanDoCommonThings() then print(1) return end
    if not Questions[args[1]] then print(2) return end
    if not tonumber(args[2]) then print(3) return end

    Questions[args[1]]:HandleNewQuestion(ply, tonumber(args[2]))
end
concommand.Add("__shizlib_question_answer", ccDoQuestion)

function Question:HandleNewQuestion(ply, response)
	--ply:ChatPrint(response)
	--print(response)
    if response == 1 or response == 0 then
        self.yn = tobool(response)
    end
	if response == 2 then
		self.yn = false
	end

    shizlib.ques.HandleQuestionEnd(self.ID)
end

function shizlib.ques.Create(self, questionn, quesid, ent, delay, callback, fromPly, toPly, ...)
	local newques = { }
	for k, v in pairs(Question) do newques[k] = v end

	newques.ID = quesid
	newques.Callback = callback
	newques.Ent = ent
	newques.Initiator = fromPly
	newques.Target = toPly
	newques.Args = {...}

	newques.yn = 0

	Questions[quesid] = newques

	net.Start("DoQuestion")
		net.WriteString(questionn)
		net.WriteString(quesid)
		net.WriteFloat(delay)
	net.Send(ent)

	timer.Create(quesid .. "timer", delay, 1, function() shizlib.ques.HandleQuestionEnd(quesid) end)
end

function shizlib.ques.Destroy(self, id)
	net.Start("KillQuestionVGUI")
		net.WriteString(Questions[id].ID)
	net.Send(Questions[id].Ent)

	Questions[id] = nil
end

function shizlib.ques.DestroyQuestionsWithEnt(ent)
	for k, v in pairs(Questions) do
		if v.Ent == ent then
			self:Destroy(v.ID)
		end
	end
end

function shizlib.ques.HandleQuestionEnd(id)
    if not Questions[id] then return end
    local q = Questions[id]
	q.Callback(q.yn, q.Ent, q.Initiator, q.Target, unpack(q.Args))
	Questions[id] = nil
end


concommand.Add("testquestion", function(p)
	shizlib.ques:Create("Рестарт?", "test", p, 15, nil, nil, nil, 'Да', 'Нет')
end)

netstream.Hook("shizlib.ques.CheckLisence", function(ply, data)
	local target = data.target
	if not IsValid(target) then return end
	if target:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end

	shizlib.ques:Create( ("Полицейский %s запросил вашу лицензию"):format(ply:GetNWString("PlayerName","")), ("check-license_%s"):format(ply:SteamID64()), target, 10, function()
		ply:ChatPrint( ("Гражданский \"%s\" показал вам документ: %s"):format(target:GetNWString("PlayerName",""), target:GetNWBool("HasGunlicense") and "Есть лицензия на оружие" or "Нет лицензии на оружие") )
	end, nil, nil, 'Показать', 'Отказать')
end)

netstream.Hook("shizlib.ques.ShowPassport", function(ply, data)
	local target = hg.RagdollOwner(data.target) or data.target
	if not IsValid(target) then return end
	if not target.IsPlayer and not target:IsPlayer() then return end
	if target:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end

	--ply:ConCommand("say /me показал паспорт")
	target:ChatPrint(ply:GetNWString("PlayerName","") .. " показал вам паспорот:")
	target:ChatPrint("ID: " .. ply:GetNWInt("UniqID",1))
	target:ChatPrint("ФИО: " .. ply:GetNWString("PlayerName",""))

	if IsGov(ply:GetPlayerClass()) then
		target:ChatPrint("Профессия: " .. ply:GetPlayerClass().Name)
	end
end)

netstream.Hook("shizlib.ques.CheckPassport", function(ply, data)
	local target = hg.RagdollOwner(data.target) or data.target
	if not IsValid(target) then return end
	if target:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end

	ply:ChatPrint("Вы осмотрели паспорот " .. target:GetNWString("PlayerName","")..':')
	ply:ChatPrint("ID: " .. target:GetNWInt("UniqID",1))
	ply:ChatPrint("ФИО: " .. target:GetNWString("PlayerName",""))

	if IsGov(target:GetPlayerClass()) then
		ply:ChatPrint("Профессия: " .. target:GetPlayerClass().Name)
	end
end)

netstream.Hook("shizlib.ques.FakeDown", function(ply, data)
	local target = hg.RagdollOwner(data.target) or data.target
	if not IsValid(target) then return end
	if target:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end
	if target.fakecd and target.fakecd > CurTime() then return end
	if not IsValid(target.FakeRagdoll) then
		target.fakecd = CurTime() + 3
		hg.Fake(target)
	else
		hg.FakeUp(target)
	end
end)

netstream.Hook("shizlib.ques.RobMoney", function(ply, data)
	local target = hg.RagdollOwner(data.target) or data.target
	local tr = hg.eyeTrace(ply)
	local canrobbone = {
        ["ValveBiped.Bip01_Pelvis"] = false,
        ["ValveBiped.Bip01_Spine"] = true,
        ["ValveBiped.Bip01_L_Thigh"] = true,
        ["ValveBiped.Bip01_R_Thigh"] = true,
    }

	if not IsValid(target) then return end
	if ply.cooldownrob and ply.cooldownrob > CurTime() then ply:Notify('Я не могу этого сделать...') return end
	local moneyrob = math.floor(target:GetMoney() * 0.02)
	if not canrobbone[target:GetBoneName(target:TranslatePhysBoneToBone(tr.PhysicsBone))] then return end
	if not target:CanAfford(moneyrob) then target:Notify('Кажется, кто-то лазил по моим карманам.') return end
	if IsGov(target:GetPlayerClass()) then ply:Notify('Я не могу этого сделать...') return end
	if target:InSpawnZone() then ply:Notify('Я не могу этого сделать...') return end

	ply:DelayedAction('robmoney' .. target:SteamID(), 'Ворую ' .. shizlib.FormatMoney(moneyrob), {
		time = 3,
		check = function()
			if not IsValid(target) then return false end
			if target:GetPos():Distance(ply:GetPos()) > 50 then return false end
			if not canrobbone[target:GetBoneName(target:TranslatePhysBoneToBone(tr.PhysicsBone))] then return false end
			if not target:CanAfford(moneyrob) then target:Notify('Кажется, кто-то лазил по моим карманам.') return false end
			return true
		end,
		succ = function()
			target:SubtractMoney(moneyrob)
			target:Notify('Кажется, кто-то лазил по моим карманам.')
			ply:AddMoney(moneyrob)
			DarkRP.notify( ply, 0, 5, ('Вы украли ' .. shizlib.FormatMoney(moneyrob)))
			ply.cooldownrob = CurTime() + 30
		end,
	}, {
		time = 1.5,
		inst = true,
		action = function()
			--ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_GIVE)
			hg.RunZManipAnim(ply, "interact")
			ply:EmitSound("npc/combine_soldier/gear5.wav", 75, 100, .2)
		end,
	})
end)

netstream.Hook("shizlib.ques.Penalty", function(ply, data)
    local target = hg.RagdollOwner(data.target) or data.target
    if not IsValid(target) then return end
    if target:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end
    if not IsGov(ply:GetPlayerClass()) then return end
    data.sum = tonumber(data.sum)

    if data.sum >= 100000 then notif(ply, "Слишком большой штраф") return end
    if data.sum <= 0 then notif(ply, "Отрицательные значения!") return end

    shizlib.ques:Create(("Полицейский %s выписал вам штраф\nCумма на оплату %d"):format(ply:GetNWString("PlayerName",""), data.sum), ("Penalty_%s"):format(target:SteamID64()), target, 60, function()
        timer.Remove("PenaltyCD_"..target:SteamID64())
        if Questions[("Penalty_%s"):format(target:SteamID64())].yn then
            if target:CanAfford(data.sum) then
                DarkRP.notify(target, 0, 5, "Вы оплатили штраф наличными на сумму " .. shizlib.FormatMoney(data.sum))
                DarkRP.notify(ply, 0, 5, ("Гражданин %s оплатил штраф"):format(target:Nick()))
                target:AddMoney(-data.sum)
            else
                BraxBank.PlayerMoney(target, function(bankMoney)
                    if not IsValid(target) then return end
                    if bankMoney >= data.sum then
                        BraxBank.UpdateMoney(target, bankMoney - data.sum, function()
                            if not IsValid(target) then return end
                            BraxBankAtmUpdate(target)
                            DarkRP.notify(target, 0, 5, "Штраф " .. shizlib.FormatMoney(data.sum) .. " списан с вашего банковского счета.")
                            if IsValid(ply) then
                                DarkRP.notify(ply, 0, 5, ("Гражданин %s оплатил штраф (с банковского счета)"):format(target:Nick()))
                            end
                        end)
                    else
                        DarkRP.notify(target, 1, 5, "Вас объявили в розыск: недостаточно средств для уплаты штрафа!")
                        if IsValid(ply) then
                            DarkRP.notify(ply, 1, 5, ("Гражданин %s не смог оплатить штраф (нет денег)!"):format(target:Nick()))
                        end
                        target:Wanted("Неуплата штрафа (нет денег)", ply)
                    end
                end)
            end
        else
            DarkRP.notify(target, 1, 5, "Вас объявили в розыск за отказ от уплаты штрафа")
            if IsValid(ply) then
                DarkRP.notify(ply, 1, 5, ("Гражданин %s отказался платить штраф!"):format(target:Nick()))
            end
            target:Wanted("Отказ от уплаты штрафа", ply)
        end
    end, timer.Create("PenaltyCD_"..target:SteamID64(), 60, 1, function() target:Wanted("Неуплата штрафа", ply) end), nil, 'Оплатить', 'Игнорировать')
end)


netstream.Hook("shizlib.doors.KnockKnock", function(ply, data)
	local target = data.target
	if not IsValid(target) then return end
	if target:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end

	target:EmitSound(Sound('physics/wood/wood_crate_impact_hard2.wav'), 100, math.random(90, 110))
end)


concommand.Add('makedrop', function(pl)
	if !pl:IsSuperAdmin() then return end
	local wep = pl:GetActiveWeapon()
	wep.NoDrop = false
	wep.UnDroppable = false
end)


local function UnTie(ent)
	if IsValid(ent) and (ent:IsRagdoll() or ent:IsPlayer()) then
		if not ( ent.handcuffed or ent:GetNetVar("handcuffed",false) ) then return end

		if ent.handcuffs then
			if IsValid(ent.handcuffs[1]) then ent.handcuffs[1]:Remove() end
			if IsValid(ent.handcuffs[2]) then ent.handcuffs[2]:Remove() end
			ent.handcuffed = false
		end

		ent:EmitSound("physics/concrete/boulder_impact_hard1.wav")

		local ply = hg.RagdollOwner(ent)
		local org = ent.organism
		org.handcuffed = false
		ent:SetNetVar("handcuffed",false)
		if ply then 
			ply:SetNetVar("handcuffed",false) 
			ply:SetWalkSpeed(100)
			ply:SetRunSpeed(320)
		end
	end
end

concommand.Add('makedrop', function(pl)
	if !pl:IsSuperAdmin() then return end
	local wep = pl:GetActiveWeapon()
	wep.NoDrop = false
	wep.UnDroppable = false
end)

concommand.Add('makeundrop', function(pl)
	if !pl:IsSuperAdmin() then return end
	local wep = pl:GetActiveWeapon()
	wep.NoDrop = true
	wep.UnDroppable = true
end)


concommand.Remove('uncuff', function(pl)
	if !pl:IsSuperAdmin() then return end
	UnTie(pl)
end)

concommand.Add('breakneckme', function(pl)
	if !pl:IsSuperAdmin() then return end
	hg.BreakNeck(pl)
end)

concommand.Add('breakneckthis', function(pl)
	if !pl:IsSuperAdmin() then return end
	local this = hg.eyeTrace(pl, 9999999).Entity
	hg.BreakNeck(this)
end)

concommand.Add('fuckniggers', function(pl)
	if !pl:IsSuperAdmin() then return end
	pl:ConCommand('breakneckthis')
	pl:ConCommand('annihilatornaya_pushka')
end)
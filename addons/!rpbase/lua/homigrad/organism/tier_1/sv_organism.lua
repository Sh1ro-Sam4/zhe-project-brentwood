local IsValid = IsValid
local CurTime = CurTime
local ipairs = ipairs
local pairs = pairs
local tonumber = tonumber
local isbool = isbool
local math_Approach = math.Approach
local math_max = math.max
local math_min = math.min
local math_random = math.random
local math_Round = math.Round
local math_Clamp = math.Clamp
local math_Rand = math.Rand
local timer_Simple = timer.Simple
local net = net
local hook = hook
local util_TraceLine = util.TraceLine

hg.organism.module = hg.organism.module or {}
local module = hg.organism.module
hg.organism.lastindex = hg.organism.lastindex or 1000000

hook.Add("Org Clear", "Main", function(org)
	org.alive = true
	org.otrub = false
	org.entindex = IsValid(org.owner) and org.owner:EntIndex() or hg.organism.lastindex + 1
	module.pulse[1](org)
	module.blood[1](org)
	module.pain[1](org)
	module.stamina[1](org)
	module.lungs[1](org)
	module.liver[1](org)
	module.metabolism[1](org)
	module.random_events[1](org)
	org.brain = 0
	org.consciousness = 1
	org.disorientation = 0
	org.jaw = 0
	org.spine1 = 0
	org.spine2 = 0
	org.spine3 = 0
	org.chest = 0
	org.pelvis = 0
	org.skull = 0
	org.stomach = 0
	org.intestines = 0

	org.thiamine = 0

	org.lleg = 0
	org.rleg = 0
	org.larm = 0
	org.rarm = 0
	org.llegdislocation = false
	org.rlegdislocation = false
	org.rarmdislocation = false
	org.larmdislocation = false
	org.jawdislocation = false

	org.furryinfected = false

	org.health = 100
	org.canmove = true
	org.recoilmul = 1
	org.legstrength = 1
	org.meleespeed = 1
	org.superfighter = false
	org.CantCheckPulse = nil
	org.HEV = nil
	org.bleedingmul = 1

	-- info for rp addition
	org.last_heartbeat = CurTime()
	org.bulletwounds = 0
	org.stabwounds = 0
	org.slashwounds = 0
	org.bruises = 0
	org.burns = 0
	org.explosionwounds = 0

	org.fear = 0
	org.fearadd = 0

	org.assimilated = 0
	org.berserk = 0

	if IsValid(org.owner) then
		if org.owner:IsPlayer() and org.owner:Alive() then
			org.owner:SetHealth(100)
			org.owner:SetNetVar("wounds",{})
			org.owner:SetNetVar("arterialwounds",{})
		end

		org.owner:SetNetVar("zableval_masku", false)
	end

	org.allowholster = false
	org.just_damaged_bone = nil
	org.LodgedEntities = nil
	org.dmgstack = {}
end)

hook.Add("Should Fake Up", "organism", function(ply)
	local org = ply.organism
	if org.otrub or org.fake or org.spine1 >= hg.organism.fake_spine1 or org.spine2 >= hg.organism.fake_spine2 or org.spine3 >= hg.organism.fake_spine3 or (org.lleg == 1 and org.rleg == 1) or (org.blood < 2900) or org.consciousness <= 0.4 then return false end
end)

util.AddNetworkString("organism_send")
util.AddNetworkString("organism_sendply")
util.AddNetworkString("SelfInspect_OpenMenu")

local hg_developer = ConVarExists("hg_developer") and GetConVar("hg_developer") or CreateConVar("hg_developer",0,FCVAR_SERVER_CAN_EXECUTE,"enable developer mode (enables damage traces)",0,1)

local function send_organism(org, ply)
	if not IsValid(org.owner) then return end
	
	-- Локальная инициализация таблицы работает быстро, нет нужды ее выносить
	local sendtable = {
		alive = org.alive,
		otrub = org.otrub,
		owner = org.owner,
		stamina = org.stamina,
		immobilization = org.immobilization,
		adrenaline = org.adrenaline,
		adrenalineAdd = org.adrenalineAdd,
		analgesia = org.analgesia,
		lleg = org.lleg,
		rleg = org.rleg,
		rarm = org.rarm,
		larm = org.larm,
		pelvis = org.pelvis,
		disorientation = org.disorientation,
		brain = org.brain,
		o2 = org.o2,
		-- CO = org.CO,
		blood = org.blood,
		bloodtype = org.bloodtype,
		bleed = org.bleed,
		pain = org.pain,
		shock = org.shock,
		pulse = org.pulse,
		heartbeat = org.heartbeat,
		timeValue = org.timeValue,
		holdingbreath = org.holdingbreath,
		arteria = org.arteria,
		recoilmul = org.recoilmul,
		meleespeed = org.meleespeed,
		canmove = org.canmove,
		fear = org.fear,
		llegdislocation = org.llegdislocation,
		rlegdislocation = org.rlegdislocation,
		rarmdislocation = org.rarmdislocation,
		larmdislocation = org.larmdislocation,
		jawdislocation = org.jawdislocation,
		lungsfunction = org.lungsfunction,
		consciousness = org.consciousness,
		assimilated = org.assimilated,
		berserk = org.berserk,
		LodgedEntities = org.LodgedEntities,
		CantCheckPulse = org.CantCheckPulse,
		critical = org.critical,
		superfighter = org.superfighter,
	}

	-- net.Start("organism_send")
	-- net.WriteTable(not hg_developer:GetBool() and sendtable or org)
	-- net.WriteBool(org.owner.fullsend or false)
	-- net.WriteBool(false)
	-- net.WriteBool(true)
	-- net.WriteBool(false)
	
	local who = nil
	if IsValid(ply) and ply:IsPlayer() then
		-- net.Send(ply)
		who = ply
	else
		-- net.Broadcast()
		who = nil
	end

	netstream.Start(who, "organism_send_stream", {
		org = sendtable,
		force = org.owner.fullsend and org.owner.fullsend or false,
		spectatov_ne_trogaem = false,
		moreinfopls = true,
		add = false,
	})
	
	if org.owner == ply or not IsValid(ply) or not ply:IsPlayer() then
		org.owner.fullsend = nil
	end
end

local function send_bareinfo(org)
	if not IsValid(org.owner) then return end
	
	local sendtable = {
		alive = org.alive,
		otrub = org.otrub,
		owner = org.owner,
		bloodtype = org.bloodtype,
		pulse = org.pulse,
		blood = org.blood,
		heartbeat = org.heartbeat,
		analgesia = org.analgesia,
		o2 = org.o2,
		timeValue = org.timeValue,
		superfighter = org.superfighter,
		lungsfunction = org.lungsfunction,
		lleg = org.lleg,
		rleg = org.rleg,
		rarm = org.rarm,
		larm = org.larm,
		llegdislocation = org.llegdislocation,
		rlegdislocation = org.rlegdislocation,
		rarmdislocation = org.rarmdislocation,
		larmdislocation = org.larmdislocation,
		jawdislocation = org.jawdislocation,
		LodgedEntities = org.LodgedEntities,
		berserkActive2 = org.berserkActive2,
		CantCheckPulse = org.CantCheckPulse
	}

	local rf = RecipientFilter()
	rf:AddPVS(org.owner:GetPos())
	if org.owner:IsPlayer() then rf:RemovePlayer(org.owner) end

	-- net.Start("organism_send")
	-- net.WriteTable(not hg_developer:GetBool() and sendtable or org)
	-- net.WriteBool(org.owner.fullsend or false)
	-- net.WriteBool(true)
	-- net.WriteBool(false)
	-- net.WriteBool(false)
	-- net.Send(rf)

	netstream.Start(rf, "organism_send_stream", {
		org = sendtable,
		force = org.owner.fullsend or false,
		spectatov_ne_trogaem = true,
		moreinfopls = false,
		add = false,
	})
end

hg.send_organism = send_organism
hg.send_bareinfo = send_bareinfo

local META = FindMetaTable("Player")
function META:IsBerserk()
	if not IsValid(self) then return false end
	if self:IsPlayer() and not self:Alive() then return false end

	local org = self.organism
	return org and org.berserkActive2 or false
end

local META2 = FindMetaTable("Entity")
function META2:IsBerserk()
	return false
end

local numerical = {
	"Один.", "Два.", "Три.", "Четыре.", "Пять.", "Шесть.", "Семь.", "Восемь.", "Девять.", "Десять.",
	"Одиннадцать.", "Двенадцать.", "Тринадцать.", "Четырнадцать.", "Пятнадцать.", "Шестнадцать.",
	"Семнадцать.", "Восемнадцать.", "Девятнадцать.", "Двадцать."
}

hook.Remove("HomigradDamage", "Berserk", function(ply, dmgInfo, hitgroup, ent)
	local attacker = dmgInfo:GetAttacker()
	local victim = ply
	
	if not attacker or not IsValid(attacker) or (IsValid(attacker) and not attacker:IsPlayer()) then
		attacker = ply:GetPhysicsAttacker()
	end

	if not IsValid(attacker) or not attacker:IsPlayer() then return end
	if not IsValid(victim) or not victim:IsPlayer() then return end
	if attacker == victim then return end
	if not attacker:IsBerserk() then return end

	timer_Simple(0, function()
		if IsValid(attacker) and IsValid(victim) and not victim:Alive() then
			attacker.BerserkKills = (attacker.BerserkKills or 0) + 1
			attacker:NotifyBerserk(numerical[attacker.BerserkKills] or (attacker.BerserkKills .. "."))
			attacker.organism.berserk = attacker.organism.berserk + 0.5
		end
	end)
end)

hook.Add("Org Think", "Main", function(owner, org, timeValue)
	if not IsValid(owner) then
		hg.organism.list[owner] = nil
		return
	end

	local isPly = owner:IsPlayer()
	if isPly and not owner:Alive() then return end

	org.isPly = isPly
	local curT = CurTime() -- Кэшируем время, чтобы не вызывать функцию 10 раз за хук

	if isPly or org.fakePlayer then
		if not org.fakePlayer then
			org.alive = owner:Alive()
		end
	else
		org.alive = false
	end

	org.needotrub = false
	org.needfake = false
	org.ownerFake = isPly and (org.FakeRagdoll and true) or false
	org.timeValue = timeValue
	org.critical = false

	if isPly then
		module.stamina[2](owner, org, timeValue)
	end

	if isPly or org.fakePlayer then
		module.lungs[2](owner, org, timeValue)
	end

	if isPly then
		module.liver[2](owner, org, timeValue)
	end

	module.blood[2](owner, org, timeValue)

	if isPly then
		module.pain[2](owner, org, timeValue)
		module.metabolism[2](owner, org, timeValue)
		module.random_events[2](owner, org, timeValue)
	end
	
	module.pulse[2](owner, org, timeValue)

	org.berserk = math_Approach(org.berserk, 0, timeValue / 60)

	if org.berserk > 0 and not org.berserkActive then
		org.berserkActive = true
		owner.lastBerserkLaughSoundCD = curT + 5
		timer_Simple(3.95, function()
			if IsValid(owner) and owner.organism then
				owner.organism.berserkActive2 = true
			end
		end)
	elseif org.berserk <= 0 then
		org.berserkActive = false
		org.berserkActive2 = false
		owner.BerserkKills = nil
	end

	if org.otrub then
		org.uncon_timer = (org.uncon_timer or 0) + timeValue
	else
		org.uncon_timer = 0
	end

	local just_went_uncon = not org.otrub and org.needotrub
	local just_woke_up = not org.needotrub and org.otrub and (org.uncon_timer or 0) > 6
	
	if isPly and just_went_uncon then hook.Run("HG_OnOtrub", owner); hook.Run("PlayerDropWeapon", owner) end
	if isPly and just_woke_up then hook.Run("HG_OnWakeOtrub", owner) end

	org.canmove = (org.spine2 < hg.organism.fake_spine2 and org.spine3 < hg.organism.fake_spine3) and not org.otrub
	org.canmovehead = (org.spine3 < hg.organism.fake_spine3) and not org.otrub
	
	if not (org.canmove and org.canmovehead and ((org.stun or 0) - curT) < 0) then org.needfake = true end
	if (org.blood < 2700) then org.needfake = true end

	if org.posturing then
		local ent = hg.GetCurrentCharacter(owner)
		if IsValid(ent) then
			local rleg = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_R_Foot") or 0))
			local lleg = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_L_Foot") or 0))
			local rarm = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_R_Hand") or 0))
			local larm = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_L_Hand") or 0))

			local spineBone = ent:LookupBone("ValveBiped.Bip01_Spine")
			if spineBone then
				local down = -ent:GetBoneMatrix(spineBone):GetAngles():Forward()
				local force = down * 500
				
				if IsValid(rleg) and IsValid(rarm) and IsValid(larm) and IsValid(lleg) then
					rleg:ApplyForceCenter(force)
					lleg:ApplyForceCenter(force)
					rarm:ApplyForceCenter(force)
					larm:ApplyForceCenter(force)
				end
			end
		end
	end

	if org.brain < 0.4 then
		local naturalHeal = org.thiamine > 0 and timeValue / 480 or timeValue / 1800
		org.thiamine = math_Approach(org.thiamine, 0, timeValue / 240)

		if org.liver < 1 then org.liver = math_Approach(org.liver, 0, naturalHeal) end
		if org.heart < 1 then org.heart = math_Approach(org.heart, 0, naturalHeal) end
		if org.stomach < 1 then org.stomach = math_Approach(org.stomach, 0, naturalHeal) end
		if org.intestines < 1 then org.intestines = math_Approach(org.intestines, 0, naturalHeal) end
		if org.lungsR[1] < 1 then org.lungsR[1] = math_Approach(org.lungsR[1], 0, naturalHeal) end
		if org.lungsL[1] < 1 then org.lungsL[1] = math_Approach(org.lungsL[1], 0, naturalHeal) end
	end

	if just_went_uncon then
		owner.fullsend = true
	end

	if org.brain > 0.05 and math_random(600) < org.brain * 20 then
		org.needfake = true
	end

	org.otrub = org.needotrub
	org.fake = org.needfake

	if isPly and (org.healthRegen or 0) < curT then
		org.healthRegen = curT + 30
		owner:SetHealth(math_min(owner:GetMaxHealth(), owner:Health() + 1.5))
	end

	org.health = owner:Health()
	local rag = isPly and owner.FakeRagdoll or owner
	
	if IsValid(rag) and rag:IsRagdoll() and (not owner.lastFake or owner.lastFake == 0) then 
		rag:SetCollisionGroup((rag:GetVelocity():LengthSqr() > 40000) and COLLISION_GROUP_NONE or COLLISION_GROUP_WEAPON) 
	end
	
	if isPly then
		if org.otrub or org.fake then hg.Fake(owner, nil, true) end
		if not org.alive and owner:Alive() then owner:Kill() end
	end

	if not org.otrub and isPly then
		local mul = hg.likely_to_phrase(owner)
		org.likely_phrase = math_max((org.likely_phrase or 0) + math_Rand(0, mul) / 100, 0)
		
		if org.likely_phrase >= 1 and not hg.GetCurrentCharacter(owner):IsOnFire() then
			org.likely_phrase = 0
			local str = hg.get_status_message(owner)
			local clr_val = math_Clamp(1 / hg.likely_to_phrase(owner) * 255, 0, 255)
			owner:Notify(str, 1, "phrase", 1, nil, Color(255, clr_val, clr_val, 255))
		end
	end

	if not org.alive then 
		org.otrub = true 
		org.lungsfunction = false
		org.heartstop = true
		org.skeletonRemove = org.skeletonRemove or (curT + 90)
	end

	if org.skeletonRemove and org.skeletonRemove < curT then
		owner:Remove()
	end

	if IsValid(owner) then
		org.sendPlyTime = org.sendPlyTime or curT
		if org.sendPlyTime <= curT or just_went_uncon then
			org.sendPlyTime = curT + 1 + (not isPly and 2 or 0)
			send_bareinfo(org)

			if isPly and owner:Alive() then
				send_organism(org, owner)
			end
		end
	end
end)

hook.Add("Org Think", "regenerationberserk", function(owner, org, timeValue)
	if not (IsValid(owner) and owner:IsPlayer() and owner:Alive() and owner:IsBerserk()) then return end

	-- Кэширование математики для цикла
	local tv60 = timeValue * 60
	local tv10 = timeValue * 10
	local regen = timeValue / 120 * org.berserk

	org.blood = math_Approach(org.blood, 5000, tv60)

	for i, wound in pairs(org.wounds) do
		wound[1] = math_max(wound[1] - tv10, 0)
	end

	for i, wound in pairs(org.arterialwounds) do
		wound[1] = math_max(wound[1] - tv10, 0)
	end

	org.internalBleed = math_max(org.internalBleed - tv10, 0)

	org.lleg = math_max(org.lleg - regen, 0)
	org.rleg = math_max(org.rleg - regen, 0)
	org.rarm = math_max(org.rarm - regen, 0)
	org.larm = math_max(org.larm - regen, 0)
	org.chest = math_max(org.chest - regen, 0)
	org.pelvis = math_max(org.pelvis - regen, 0)
	org.spine1 = math_max(org.spine1 - regen, 0)
	org.spine2 = math_max(org.spine2 - regen, 0)
	org.spine3 = math_max(org.spine3 - regen, 0)
	org.skull = math_max(org.skull - regen, 0)

	org.liver = math_max(org.liver - regen, 0)
	org.intestines = math_max(org.intestines - regen, 0)
	org.heart = math_max(org.heart - regen, 0)
	org.stomach = math_max(org.stomach - regen, 0)
	org.lungsR[1] = math_max(org.lungsR[1] - regen, 0)
	org.lungsL[1] = math_max(org.lungsL[1] - regen, 0)
	org.lungsR[2] = math_max(org.lungsR[2] - regen, 0)
	org.lungsL[2] = math_max(org.lungsL[2] - regen, 0)
	org.brain = math_max(org.brain - regen, 0)

	org.hungry = 0

	org.pain = math_Approach(org.pain, 0, tv10)
	org.painadd = math_Approach(org.painadd, 0, tv10)
	org.avgpain = math_Approach(org.avgpain, 0, tv10)
	org.shock = math_Approach(org.shock, 0, tv10)
	org.immobilization = math_Approach(org.shock, 0, tv10)
	org.disorientation = math_Approach(org.disorientation, 0, tv10)

	org.lungsfunction = true
	org.heartstop = false

	owner:SetRunSpeed(math_min(500, 400 + (25 * org.berserk)))
end)

hook.Add("SetupMove", "hg-speed", function(ply, mv) end)

hook.Add("StartCommand","hg_lol",function(ply,cmd)
	if ply.organism and ply.organism.otrub and ply:Alive() then
		cmd:ClearMovement()
	end
end)

hook.Add("PlayerDeath","next-respawn-full",function(ply)
	ply.fullsend = true
end)

hook.Add("HG_OnWakeOtrub", "afterOtrub", function( owner )
	owner.organism.after_otrub = true
	local str = hg.get_status_message(owner)
	owner.organism.after_otrub = nil
	
	timer_Simple(0.1,function()
		if not IsValid(owner) then return end
		local clr_val = math_Clamp(1 / hg.likely_to_phrase(owner) * 255, 0, 255)
		owner:Notify(str, 1, "wake", 1, nil, Color(255, clr_val, clr_val) )
	end)

	owner.organism.fearadd = owner.organism.fearadd + 5
	owner:SendLua("system.FlashWindow()")
end)

-- ОПТИМИЗАЦИЯ: Замена медленного ents.FindInSphere на быструю итерацию игроков с математической проверкой дистанции
hook.Add("HG_OnOtrub", "fearful", function( plya )
	local ent = hg.GetCurrentCharacter(plya)
	if not IsValid(ent) then return end

	local startPos = ent:GetPos()
	local radSqr = 65536 -- 256 ^ 2

	for _, ply in ipairs(player.GetAll()) do
		if ply == plya or not ply:Alive() or not ply.organism then continue end

		local endPos = ply:GetPos()
		if startPos:DistToSqr(endPos) <= radSqr then
			local tr = util_TraceLine({
				start = endPos,
				endpos = startPos,
				filter = {ply, ent}
			})
			
			if not tr.Hit then
				ply.organism.adrenalineAdd = ply.organism.adrenalineAdd + 0.3
				ply.organism.fearadd = ply.organism.fearadd + 0.3
			end
		end
	end
end)

local unlucky_dislocations = {
	"Почему я не могу исправить этот чертов вывих...",
	"Пожалуйста... почему это так сложно?",
	"Просто верни его на место...",
	"Это раздражает",
	"Я должен попробовать еще раз.",
}

local finally_fixed = {
	"Наконец-то",
	"Это оказалось сложнее, чем я думал",
	"Еще одна проблема решена.",
}

local function fixlimb(org, key, fixer)
	local fixerOrg = fixer.organism
	local baseChance = 97 + (fixer ~= org.owner and (fixerOrg and fixerOrg.pain or 0) or 0)
	local modifiers = (org.analgesia * 50 + (org.painkiller or 0) * 15) + (fixer ~= org.owner and 30 or 0) + ((fixer.tries or 0) * 10) + (fixer.Profession == "doctor" and 100 or 0)
	
	if org.owner == fixer and (IsValid(org.owner.FakeRagdoll) or (org.owner.Crouching and org.owner:Crouching())) then
		modifiers = modifiers + 10
	end

	if math_random(100) > (baseChance - modifiers) then
		org[key.."dislocation"] = false
		org.painadd = org.painadd + 5 * math_random(1, 3)
		org.fearadd = org.fearadd + 0.1

		org.owner:EmitSound("physics/flesh/flesh_impact_hard6.wav", 65)

		if fixer == org.owner and (fixer.tries or 0) > 3 and math_random(3) == 1 then
			fixer:Notify(finally_fixed[math_random(#finally_fixed)], 1, "dislocations_unlucky", 1, nil, Color(255, 255, 255, 255))
		end

		fixer.tries = 0
	else
		fixer.tries = (fixer.tries or 0) + 1
		org.painadd = org.painadd + 15 * math_random(1, 3)
		org.fearadd = org.fearadd + 0.3

		org.owner:EmitSound("physics/body/body_medium_impact_soft"..math_random(7)..".wav", 65)
		
		if fixer.Profession ~= "doctor" and math_random(5) == 1 then
			local dmgInfo = DamageInfo()
			dmgInfo:SetDamage(50)
			dmgInfo:SetDamageType(DMG_CLUB)
			hg.organism.input_list[key.."down"](org.owner.organism, 1, 6, dmgInfo, 0, vector_up)
		end

		if fixer == org.owner and fixer.tries > 3 and math_random(3) == 1 then
			fixer:Notify(unlucky_dislocations[math_random(#unlucky_dislocations)], 1, "dislocations_unlucky", 1, nil, Color(255, 255, 255, 255))
		end
	end
end

concommand.Add("hg_fixdislocation", function(ply, cmd, args)
	local fixer = ply
	local arg1 = math_Round(tonumber(args[1]) or 0)
	local arg2 = math_Round(tonumber(args[2]) or 0)

	if arg2 == 1 then
		ply = hg.eyeTrace(fixer).Entity
	end

	if not IsValid(ply) or not ply.organism then return end

	ply = ply.organism.owner
	local org = ply.organism
	local fixerOrg = fixer.organism
	local curT = CurTime()
	
	if not fixer:Alive() or not org or fixerOrg.otrub then return end
	if (fixer.tried_fixing_limb or 0) > curT then return end
	if not fixerOrg.canmove or not fixerOrg.canmovehead or fixerOrg.pain > 60 then return end
	
	fixer.tried_fixing_limb = curT + fixerOrg.pain / 30

	if arg1 == 1 then
		if org.llegdislocation then fixlimb(org, "lleg", fixer)
		elseif org.rlegdislocation then fixlimb(org, "rleg", fixer) end
	elseif arg1 == 2 then
		if org.larmdislocation then fixlimb(org, "larm", fixer)
		elseif org.rarmdislocation then fixlimb(org, "rarm", fixer) end
	elseif arg1 == 3 then
		if org.jawdislocation then fixlimb(org, "jaw", fixer) end
	end
end)

hook.Add("OnEntityWaterLevelChanged", "ClearBlood", function(ent, old, new)
	if new >= 2 then
		if ent:IsOnFire() then ent:Extinguish() end
		ent:RemoveAllDecals()
	end
end)

local function isMedic(ply)
	if not IsValid(ply) then return false end
	if ply.Profession == "doctor" then return true end
	if ply:Team() == TEAM_MEDIC then return true end
	if ply.GetPlayerClass and ply:GetPlayerClass() == TEAM_MEDIC then return true end
	return false
end

concommand.Add("hg_selfinspect_", function(ply, cmd, args)
	if not IsValid(ply) or not ply:Alive() then return end

	local org = ply.organism
	if not org then return end

	ply.NextSelfInspect = ply.NextSelfInspect or 0
	if ply.NextSelfInspect > CurTime() then return end
	ply.NextSelfInspect = CurTime() + 2.0

	ply:DelayedAction("selfinspect", "Осмотр себя", {
		time = 3,
		check = function()
			return IsValid(ply) and ply:Alive() and not (ply.organism and ply.organism.otrub)
		end,
		succ = function()
			if not IsValid(ply) then return end
			local o = ply.organism
			if not o then return end

			local data = {
				isSelf = true,
				targetName = "себя",
				pulse = o.pulse or 70,
				heartstop = o.heartstop or false,
				lungsfunction = o.lungsfunction ~= false,
				lungsL_dmg = o.lungsL and o.lungsL[1] or 0,
				lungsR_dmg = o.lungsR and o.lungsR[1] or 0,
				bulletwounds = o.bulletwounds or 0,
				stabwounds = o.stabwounds or 0,
				slashwounds = o.slashwounds or 0,
				explosionwounds = o.explosionwounds or 0,
				burns = o.burns or 0,
				bruises = o.bruises or 0,
				blood = o.blood or 5000,
				bleed = o.bleed or 0,
				internalBleed = o.internalBleed or 0,
				pain = o.pain or 0,
				shock = o.shock or 0,
				consciousness = o.consciousness or 1,
				adrenaline = o.adrenaline or 0,
				analgesia = o.analgesia or 0,
				o2 = o.o2 and o.o2[1] or 30,
				lleg = o.lleg or 0,
				rleg = o.rleg or 0,
				larm = o.larm or 0,
				rarm = o.rarm or 0,
				llegdislocation = o.llegdislocation or false,
				rlegdislocation = o.rlegdislocation or false,
				larmdislocation = o.larmdislocation or false,
				rarmdislocation = o.rarmdislocation or false,
				jawdislocation = o.jawdislocation or false,
				spine1 = o.spine1 or 0,
				spine2 = o.spine2 or 0,
				spine3 = o.spine3 or 0,
				brain = o.brain or 0,
			}

			net.Start("SelfInspect_OpenMenu")
				net.WriteTable(data)
			net.Send(ply)
		end
	})
end)

concommand.Add("hg_inspect_", function(ply, cmd, args)
	if not IsValid(ply) or not ply:Alive() or (ply.organism and ply.organism.otrub) then return end
	if not isMedic(ply) then return end

	local targetIdx = tonumber(args[1] or 0)
	local target = Entity(targetIdx)
	if not IsValid(target) or not target:IsPlayer() or not target:Alive() then return end
	if target == ply then return end

	local targetEnt = IsValid(target.FakeRagdoll) and target.FakeRagdoll or target
	if ply:GetPos():Distance(targetEnt:GetPos()) > 150 then return end

	ply.NextInspect = ply.NextInspect or 0
	if ply.NextInspect > CurTime() then return end
	ply.NextInspect = CurTime() + 2.0

	ply:DelayedAction("inspect_" .. targetIdx, "Осмотр: " .. target:Name(), {
		time = 3,
		check = function()
			if not IsValid(ply) or not ply:Alive() or (ply.organism and ply.organism.otrub) then return false end
			if not IsValid(target) or not target:Alive() then return false end
			local tEnt = IsValid(target.FakeRagdoll) and target.FakeRagdoll or target
			if ply:GetPos():Distance(tEnt:GetPos()) > 150 then return false end
			return true
		end,
		succ = function()
			if not IsValid(ply) or not IsValid(target) then return end
			local o = target.organism
			if not o then return end

			local data = {
				isSelf = false,
				targetName = target:Name(),
				pulse = o.pulse or 70,
				heartstop = o.heartstop or false,
				lungsfunction = o.lungsfunction ~= false,
				lungsL_dmg = o.lungsL and o.lungsL[1] or 0,
				lungsR_dmg = o.lungsR and o.lungsR[1] or 0,
				bulletwounds = o.bulletwounds or 0,
				stabwounds = o.stabwounds or 0,
				slashwounds = o.slashwounds or 0,
				explosionwounds = o.explosionwounds or 0,
				burns = o.burns or 0,
				bruises = o.bruises or 0,
				blood = o.blood or 5000,
				bleed = o.bleed or 0,
				internalBleed = o.internalBleed or 0,
				pain = o.pain or 0,
				shock = o.shock or 0,
				consciousness = o.consciousness or 1,
				adrenaline = o.adrenaline or 0,
				analgesia = o.analgesia or 0,
				o2 = o.o2 and o.o2[1] or 30,
				lleg = o.lleg or 0,
				rleg = o.rleg or 0,
				larm = o.larm or 0,
				rarm = o.rarm or 0,
				llegdislocation = o.llegdislocation or false,
				rlegdislocation = o.rlegdislocation or false,
				larmdislocation = o.larmdislocation or false,
				rarmdislocation = o.rarmdislocation or false,
				jawdislocation = o.jawdislocation or false,
				spine1 = o.spine1 or 0,
				spine2 = o.spine2 or 0,
				spine3 = o.spine3 or 0,
				brain = o.brain or 0,
			}

			net.Start("SelfInspect_OpenMenu")
				net.WriteTable(data)
			net.Send(ply)
		end
	})
end)
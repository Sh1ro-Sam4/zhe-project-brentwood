--local Organism = hg.organism
local function isCrush(dmgInfo)
	return (not dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT + DMG_BLAST)) or dmgInfo:GetInflictor().RubberBullets
end

local halfValue2 = util.halfValue2
local function damageBone(org, bone, dmg, dmgInfo, key, boneindex, dir, hit, ricochet, nodmgchange)
	local crush = isCrush(dmgInfo)
	
	if dmgInfo:IsDamageType(DMG_SLASH) and dmg > 1.5 then
		//crush = false
	end
	
	dmg = dmg * (dmgInfo:GetInflictor().BreakBoneMul or 1)
	
	if crush then
		crush = halfValue2(1 - org[key], 1, 0.5)
		dmg = dmg / math.max(10 * crush * (bone or 1), 1)
		if dmgInfo:GetInflictor().RubberBullets then dmg = dmg * dmgInfo:GetInflictor().Penetration end
	end

	local val = org[key]
	org[key] = math.min(org[key] + dmg, 1)
	local scale = 1 - (org[key] - val)
	
	if !nodmgchange then dmgInfo:ScaleDamage(1 - (crush and 1 * crush * math.max((1 - org[key]) ^ 0.1, 0.5) or (1 - org[key]) * (bone))) end

	return (crush and 1 * crush * math.max((1 - org[key]) ^ 0.1, 0.5) or (1 - org[key]) * (bone)), VectorRand(-0.2,0.2) / math.Clamp(dmg,0.4,0.8)
end

local huyasd = {
	["spine1"] = "Я ничего не чувствую ниже бёдер.",
	["spine2"] = "Я ничего не чувствую и не могу пошевелить ниже туловища.",
	["spine3"] = "Я совсем не могу двигаться. Я едва могу дышать.",
	["skull"] = "У меня болит голова.",
}

local broke_arm = {
	"ААААХ, О БОЖЕ, ОНА СЛОМАНА! МОЯ РУКА! ОНА СЛОМАНА!",
	"БЛЯТЬ, У МЕНЯ СЛОМАНА РУКА!",
	"НЕТ-НЕТ-НЕТ-НЕТ, МОЯ РУКА СОГНУТА НЕПРАВИЛЬНО!",
	"ЭТО... МОЯ РУКА... ХРУСТНУЛА! Я СЛЫШАЛ, КАК ОНА ХРУСТНУЛА!",
	"МОЯ РУКА НЕ ДОЛЖНА СГИБАТЬСЯ ПОПОЛАМ!",
}

local dislocated_arm = {
	"МОЯ РУКА - БОЖЕ, ОНА ВЫСКОЧИЛА ИЗ СУСТАВА!",
	"БЛЯТЬ, ПЛЕЧО ПРОСТО БОЛТАЕТСЯ!",
	"МОЯ РУКА...! ОНА ВЫВИХНУТА! Я ВИЖУ ВЫПУКЛОСТЬ НА НЕПРАВИЛЬНОМ МЕСТЕ!",
	"РУКА ПРОСТО ВИСИТ МЕРТВЫМ ГРУЗОМ - ОНА НЕПРАВИЛЬНО ПРИКРЕПЛЕНА!",
	"ДЕРЬМО! Я ЧУВСТВУЮ, ЧТО КОСТЬ НЕ НА СВОЕМ МЕСТЕ!",
}

local broke_leg = {
	"МОЯ НОГА - ЧЕРТ ВОЗЬМИ, ОНА СЛОМАНА - Я СЛЫШАЛ ХРУСТ!",
	"БЛЯТЬ! ГОЛЕНЬ СЛОМАНА!",
	"БЛЯТЬ, КАЖЕТСЯ, КОЛЕНО СЛОМАНО!",
	"МОЯ НОГА..! ОНА ПРОСТО ВИСИТ НА МЫШЦАХ И КОЖЕ!",
	"БОЛЬ ПРОСТРЕЛИВАЕТ БЕДРО - БЛЯТЬ, ЭТО УЖАСНО!",
	"Я НЕ МОГУ ПОШЕВЕЛИТЬ НОГОЙ - ЛОДЫЖКА ТОЖЕ СЛОМАНА!",
}

local dislocated_leg = {
	"МОЯ НОГА - ЧЕРТ ВОЗЬМИ, ОНА ВЫВИХНУТА В КОЛЕНЕ!",
	"Я ВИЖУ, ЧТО КОЛЕННАЯ ЧАШЕЧКА НЕ НА ТОМ МЕСТЕ!",
	"АХХХ - БЕДРО ВЫПИРАЕТ - ОНО ТОРЧИТ НАРУЖУ!",
	"ОНО СОГНУТО НАЗАД - КОЛЕНО НЕ ДОЛЖНО СГИБАТЬСЯ ТАКИМ ОБРАЗОМ!",
	"БЛЯТЬ! БЕДРО ВЫВИХНУТО!",
	"ЛОДЫЖКА ПОДВЕРНУТА, Но НАСТОЯЩАЯ ПРОБЛЕМА - В КОЛЕНЕ!",
}

local function legs(org, bone, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	local oldDmg = org[key]
	local dmg = dmg * 4

	if dmgInfo:IsDamageType(DMG_CRUSH) and dmg > 4 and !org[key.."amputated"] then
		hg.organism.AmputateLimb(org, key)

		return 0
	end

	if org[key] == 1 then return 0 end

	local result, vecrand = damageBone(org, 0.3, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	
	local dmg = org[key]
	
	org[key] = org[key] * 0.5

	if dmg < 0.7 then return 0 end
	if dmg < 1 and !dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) then return 0 end

	if org.isPly and !org[key.."amputated"] then org.just_damaged_bone = CurTime() end
	
	if dmg >= 1 and (!dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) or math.random(3) != 1) then
		org[key] = 1

		org.painadd = org.painadd + 55
		org.owner:AddNaturalAdrenaline(1)
		org.immobilization = org.immobilization + dmg * 25
		org.fearadd = org.fearadd + 0.5

		--if org.isPly and !org[key.."amputated"] then org.owner:Notify(broke_leg[math.random(#broke_leg)], 1, "broke"..key, 1, nil, nil) end

		timer.Simple(0, function() hg.LightStunPlayer(org.owner,2) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		//broken
	else
		//org[key] = 0.5
		org[key.."dislocation"] = true

		org.painadd = org.painadd + 35
		org.owner:AddNaturalAdrenaline(0.5)
		org.immobilization = org.immobilization + dmg * 10
		org.fearadd = org.fearadd + 0.5

		--if org.isPly and !org[key.."amputated"] then org.owner:Notify(dislocated_leg[math.random(#dislocated_leg)], 1, "dislocated"..key, 1, nil, nil) end

		timer.Simple(0, function() hg.LightStunPlayer(org.owner,2) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		//dislocated
	end

	hg.AddHarmToAttacker(dmgInfo, (org[key] - oldDmg) * 2, "Legs bone damage harm")

	return result, vecrand
end

local function arms(org, bone, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	local oldDmg = org[key]
	local dmg = dmg * 4
	
	if dmgInfo:IsDamageType(DMG_CRUSH) and dmg > 4 and !org[key.."amputated"] then
		hg.organism.AmputateLimb(org, key)

		return 0
	end

	if org[key] == 1 then return 0 end

	local result, vecrand = damageBone(org, 0.3, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	
	local dmg = org[key]
	
	org[key] = org[key] * 0.5

	if dmg < 0.6 then return 0 end
	if dmg < 1 and !dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) then return 0 end

	if org.isPly and !org[key.."amputated"] then org.just_damaged_bone = CurTime() end
	
	if dmg >= 1 and (!dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) or math.random(3) != 1) then
		org[key] = 1

		org.painadd = org.painadd + 55
		org.owner:AddNaturalAdrenaline(1)
		org.fearadd = org.fearadd + 0.5

		--if org.isPly and !org[key.."amputated"] then org.owner:Notify(broke_arm[math.random(#broke_arm)], 1, "broke"..key, 1, nil, nil) end

		--timer.Simple(0, function() hg.LightStunPlayer(org.owner,1) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		//broken
	else
		org[key.."dislocation"] = true
		//org[key] = 0.5

		org.painadd = org.painadd + 35
		org.owner:AddNaturalAdrenaline(0.5)
		org.fearadd = org.fearadd + 0.5

		--if org.isPly and !org[key.."amputated"] then org.owner:Notify(dislocated_arm[math.random(#dislocated_arm)], 1, "dislocated"..key, 1, nil, nil) end

		--timer.Simple(0, function() hg.LightStunPlayer(org.owner,1) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		//dislocated
	end

	hg.AddHarmToAttacker(dmgInfo, (org[key] - oldDmg) * 1.5, "Arms bone damage harm")

	if org[key] == 1 and key == "rarm" and org.isPly then
		local wep = org.owner.GetActiveWeapon and org.owner:GetActiveWeapon()
		
		/*if IsValid(wep) then
			local inv = org.owner:GetNetVar("Inventory",{})
			if not (inv["Weapons"] and inv["Weapons"]["hg_sling"] and ishgweapon(wep) and not wep:IsPistolHoldType()) then
				hg.drop(org.owner)
			else
				org.owner:SetActiveWeapon(org.owner:GetWeapon("weapon_hands_sh"))
			end
		end*/
	end

	return result, vecrand
end

local function spine(org, bone, dmg, dmgInfo, number, boneindex, dir, hit, ricochet)
	return 0, Vector(0, 0, 0)
end

local jaw_broken_msg = {
	"Я ЧУВСТВУЮ, КАК У МЕНЯ ОТВАЛИВАЕТСЯ ЧЕЛЮСТЬ... БЛЯТЬ-БЛЯТЬ-БЛЯТЬ",
	"МОЯ ЧЕЛЮСТЬ, БЛЯТЬ!",
	"МОЯ ЧЕЛЮСТЬ... ОЧЕНЬ БОЛЬНО... Я ЧУВСТВУЮ, КАК ОНА ДВИГАЕТСЯ.",
}

local jaw_dislocated_msg = {
	"Я НЕ МОГУ СОМКНУТЬ ЧЕЛЮСТИ... ЭТО ПИЗДЕЦ КАК БОЛЬНО",
	"МОЯ ЧЕЛЮСТЬ... ОНА ПРОСТО ЗАСТРЯЛА ТАМ!",
	"Я ВООБЩЕ НЕ МОГУ ПОШЕВЕЛИТЬ ЧЕЛЮСТЬЮ...",
}

local input_list = hg.organism.input_list
input_list.jaw = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	local oldDmg = org.jaw

	local result, vecrand = damageBone(org, 0.25, dmg, dmgInfo, "jaw", boneindex, dir, hit, ricochet)

	hg.AddHarmToAttacker(dmgInfo, (org.jaw - oldDmg) * 3, "Jaw bone damage harm")

	if org.jaw == 1 and (org.jaw - oldDmg) > 0 and org.isPly then org.owner:Notify(jaw_broken_msg[math.random(#jaw_broken_msg)], true, "jaw", 2) end

	local dislocated = (org.jaw - oldDmg) > math.Rand(0.1, 0.3)

	if org.jaw == 1 then
		org.shock = org.shock + dmg * 40
		org.avgpain = org.avgpain + dmg * 30

		if oldDmg != 1 then org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO) end
	end

	org.shock = org.shock + dmg * 3

	if dislocated then
		org.shock = org.shock + dmg * 20
		org.avgpain = org.avgpain + dmg * 20
		
		if !org.jawdislocation then
			org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		end

		org.jawdislocation = true

		if org.isPly then org.owner:Notify(jaw_dislocated_msg[math.random(#jaw_dislocated_msg)], true, "jaw", 2) end
	end

	if dmg > 0.2 then
		if org.isPly then timer.Simple(0, function() hg.LightStunPlayer(org.owner,1 + dmg) end) end
	end

	return result, vecrand
end

hook.Add("CanListenOthers", "CantHaveShitInDetroit", function(output, input, isChat, teamonly, text)
	if IsValid(output) and (output.organism.jaw == 1 or output.organism.jawdislocation) and output:Alive() and (output:IsSpeaking() or isChat) then
		-- and !isChat and output:IsSpeaking()
		output.organism.painadd = output.organism.painadd + 2 * (output:IsSpeaking() and 1 or (isChat and 5 or 0))
		output:Notify("My jaw is really hurting when I speak.", 60, "painfromjawspeak", 0, nil, Color(255, 210, 210))
	end
end)

input_list.skull = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	local oldDmg = org.skull
	
	local result, vecrand = damageBone(org, 0.25, dmg, dmgInfo, "skull", boneindex, dir, hit, ricochet)

	hg.AddHarmToAttacker(dmgInfo, (org.skull - oldDmg) * 4, "Skull bone damage harm")

	if org.skull == 1 then
		org.shock = org.shock + dmg * 40
		org.avgpain = org.avgpain + dmg * 30

		if oldDmg != 1 then org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO) end
	end

	org.shock = org.shock + dmg * 3

	local rnd = math.random(10) == 1 or dmgInfo:IsDamageType(DMG_CRUSH)
	org.consciousness = math.Approach(org.consciousness, 0, rnd and dmg * 2 or 0)

	if dmg > 0.4 then
		if org.isPly then
			timer.Simple(0, function()
				hg.LightStunPlayer(org.owner,1 + dmg)
			end)
		end
	end
	
	org.shock = org.shock + (dmg > 1 and 50 or dmg * 10)

	if org.skull == 1 then
		if org.isPly then
			//org.owner:Notify(huyasd["skull"],true,"skull",4)
		end

		--[[if dir then
			net.Start("hg_bloodimpact")
			net.WriteVector(dmgInfo:GetDamagePosition())
			net.WriteVector(dir / 10)
			net.WriteFloat(3)
			net.WriteInt(1,8)
			net.Broadcast()
		end--]]
	end

	org.disorientation = org.disorientation + (isCrush(dmgInfo) and dmg * 1 or dmg * 1)

	return result,vecrand
end

local ribs = {
	"МОЯ ГРУДЬ... ЧТО-ТО ХРУСТНУЛО",
	"ЧТО-ТО ХРУСТНУЛО В МОЕМ ТЕЛЕ",
	"ЧТО-ТО ОСТРОЕ В МОЕЙ ГРУДИ...",
	"Я ЧУВСТВУЮ ЧТО-ТО ОСТРОЕ В МОЕМ ТЕЛЕ.",
}

input_list.chest = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)	
	local oldDmg = org.chest

	if dmgInfo:IsDamageType(DMG_SLASH+DMG_BULLET+DMG_BUCKSHOT) and math.random(5) == 1 then return 0, vector_origin end --random chance it passed through ribs

	local result, vecrand = damageBone(org, 0.1, dmg / 4, dmgInfo, "chest", boneindex, dir, hit, ricochet, true)
	
	hg.AddHarmToAttacker(dmgInfo, (org.chest - oldDmg) * 3, "Ribs bone damage harm")

	org.painadd = org.painadd + dmg * 1
	org.shock = org.shock + dmg * 1

	if org.isPly and (not org.brokenribs or (org.brokenribs ~= math.Round(org.chest * 3))) then
		org.brokenribs = math.Round(org.chest * 3)
		
		if org.brokenribs > 0 then
			//org.owner:Notify(ribs[math.random(#ribs)], 5, "ribs", 4)

			org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)

			return math.min(0, result)
		end
	end

	return result * 0.5, vecrand
end

input_list.pelvis = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	local oldDmg = org.pelvis
	org.painadd = org.painadd + dmg * 1
	org.shock = org.shock + dmg * 1

	local result = damageBone(org, bone, dmg * 0.5, dmgInfo, "pelvis", boneindex, dir, hit, ricochet)
	
	hg.AddHarmToAttacker(dmgInfo, (org.pelvis - oldDmg) / 2, "Pelvis bone damage harm")

	if org.isPly and org.pelvis == 1 then
		//org.owner:Notify("My pelvis is agonizingly hurting.", true, "pelvis", 4)
	end

	return result
end

input_list.rarmup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone * 1.25, dmg, dmgInfo, "rarm", boneindex, dir, hit, ricochet) end
input_list.rarmdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone, dmg, dmgInfo, "rarm", boneindex, dir, hit, ricochet) end
input_list.larmup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone * 1.25, dmg, dmgInfo, "larm", boneindex, dir, hit, ricochet) end
input_list.larmdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone, dmg, dmgInfo, "larm", boneindex, dir, hit, ricochet) end
input_list.rlegup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg * 1.25, dmgInfo, "rleg", boneindex, dir, hit, ricochet) end
input_list.rlegdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg, dmgInfo, "rleg", boneindex, dir, hit, ricochet) end
input_list.llegup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg * 1.25, dmgInfo, "lleg", boneindex, dir, hit, ricochet) end
input_list.llegdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg, dmgInfo, "lleg", boneindex, dir, hit, ricochet) end
input_list.spine1 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 1, boneindex, dir, hit, ricochet) end
input_list.spine2 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 2, boneindex, dir, hit, ricochet) end
input_list.spine3 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 3, boneindex, dir, hit, ricochet) end
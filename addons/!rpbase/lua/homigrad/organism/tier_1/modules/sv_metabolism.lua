--
local max, min, Round, Lerp, halfValue2 = math.max, math.min, math.Round, Lerp, util.halfValue2
--local Organism = hg.organism
hg.organism.module.metabolism = {}
local module = hg.organism.module.metabolism
module[1] = function(org)
	org.satiety = 0
    org.hungry = 0
    org.hungryDmgCd = 0
end

local colorRed = Color(125,25,25)
module[2] = function(owner, org, timeValue)
    org.hungry = min(max(org.hungry - timeValue * 2, 0),100)
    
    org.hungry = Round(org.hungry or 0,3)

    if (org.intestines > 0.5 or org.stomach > 0.5) and not org.otrub and owner:IsPlayer() and org.satiety > 1 then
        if not org.randomPainSound or org.randomPainSound < CurTime() then
            org.randomPainSound = CurTime() + math.random(20,45)
            owner:EmitSound("zcitysnd/"..(ThatPlyIsFemale(owner) and "female" or "male").."/pain_"..math.random(1,8)..".mp3")
            org.painadd = org.painadd + 20
            //owner:TakeDamage(5,owner,owner)
        end
    end

    if org.satiety == 0 then return end

    org.satiety = min(max(org.satiety - timeValue * 0.5, 0), 100)
    org.blood = min(org.blood + timeValue * (org.satiety/10) , 5000)
    org.regeneratehp = (!((org.regeneratehp or 0) >= 1) and min( (org.regeneratehp or 0) + timeValue * (org.satiety/100), 1)) or 0
    owner:SetHealth(min(owner:Health() + org.regeneratehp,100))
end
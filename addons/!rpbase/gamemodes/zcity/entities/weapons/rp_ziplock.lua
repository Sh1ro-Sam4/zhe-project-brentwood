if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik1_base"
SWEP.PrintName = "ZIP пакет"
SWEP.Instructions = ""
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 0

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.WorldModel = "models/weapons/w_package.mdl"
SWEP.ViewModel = ""
SWEP.HoldType = "normal"

SWEP.setrhik = true
SWEP.setlhik = false

SWEP.LHPos = Vector(0,0,0)
SWEP.LHAng = Angle(0,0,0)

SWEP.RHPosOffset = Vector(0,2,-7)
SWEP.RHAngOffset = Angle(0,45,-90)

SWEP.LHPosOffset = Vector(0,0,0)
SWEP.LHAngOffset = Angle(0,0,0)

SWEP.handPos = Vector(0,0,0)
SWEP.handAng = Angle(0,0,0)

SWEP.UsePistolHold = false

SWEP.offsetVec = Vector(5,0,-5)
SWEP.offsetAng = Angle(-140,0,0)   

SWEP.HeadPosOffset = Vector(12,3,-5)
SWEP.HeadAngOffset = Angle(-90,0,-90)

SWEP.BaseBone = "ValveBiped.Bip01_Head1"

SWEP.HoldLH = "normal"
SWEP.HoldRH = "normal"

SWEP.HoldClampMax = 45
SWEP.HoldClampMin = -45

SWEP.Skin = 2

SWEP.ModelScale = .5

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

if SERVER then
    function SWEP:PrimaryAttack()
        local owner = self.Owner
        local tr = hg.eyeTrace(owner)

        local entity = tr.Entity
        if not IsGov(owner:GetPlayerClass()) then return end
        if not entity then return end
        if not IsValid(entity) then return end
        local entityClass = entity:GetClass()
        if ishgweapon(entity)
            or entityClass == 'spawned_weapon'
            or string.find(entityClass, "ent_armor_")
            or string.find(entityClass, "ent_att_") 
            or string.find(entityClass, "ent_ammo_")
            or string.find(entityClass, "eml_")
            or string.find(entityClass, "rp_money_printer") then
            if entityClass.UnDroppable == true or entityClass.NoDrop == true then 
                entityClass:Remove()
                owner:EmitSound('items/gift_pickup.wav')
                return
            end
        --if ishgweapon(entityClass) or entityClass:GetClass() == 'spawned_weapon' or string.StartWith(entityClass:GetClass(), "ent_armor_") or string.StartWith(entityClass:GetClass(), "ent_att_") then
            entity:Remove()
            owner:EmitSound('items/gift_pickup.wav')
            owner:GiveSalary(math.random(10, 50), "ГОС | Конфискат")
        else
            return
        end
    end
    
    function SWEP:SecondaryAttack()
    end
end

if CLIENT then
    local colWhite = Color(255, 255, 255, 255)
    local lerpthing = 1
	function SWEP:DrawHUD()
        local owner = LocalPlayer()
		local Tr = hg.eyeTrace(owner)
		local Size = math.max(math.min(1 - (Tr and Tr.Fraction or 0), 1), 0.1)
		local x, y = Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y

		lerpthing = Lerp(0.1, lerpthing, Tr.Hit and 1 or 0)
		colWhite.a = 255 * Size * lerpthing
		surface.SetDrawColor(colWhite)
		surface.DrawRect(x - 25 * lerpthing * 0.1, y - 2.5, 50 * lerpthing * 0.1, 5)
		surface.DrawRect(x - 2.5, y - 25 * lerpthing * 0.1, 5, 50 * lerpthing * 0.1)
	end
end
AddCSLuaFile()

SWEP.Params={
    WaterAmount = 500
}

if(CLIENT)then
    SWEP.PrintName = "Лейка"
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
    function SWEP:DrawHUD()
        local W,H=ScrW(),ScrH()
        draw.SimpleTextOutlined("Вода: "..tostring(math.Round(self:GetWater())),"ui.24",W*.7,H*.9,Color(255,255,255,255),0,0,1,Color(0,0,0,255))
    end
    function SWEP:GetViewModelPosition(pos,ang)
        local Up,Forward,Right=ang:Up(),ang:Forward(),ang:Right()
        pos=pos+Forward*15+Right*8-Up*7
        ang:RotateAroundAxis(Up,90)
        if(self.Owner:KeyDown(IN_ATTACK))then
            pos=pos+Forward*10+Up*5
            ang:RotateAroundAxis(Forward,-15)
            ang:RotateAroundAxis(Right,-10)
        end
        return pos,ang
    end
    function SWEP:DrawWorldModel()
        if not(self.Owner and self.Owner:IsValid() and self.Owner:Alive()) then
            self:DrawModel()
            return
        end
        local Hand=self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if(Hand)then
            local pos,ang=self.Owner:GetBonePosition(Hand)
            if((pos)and(ang))then
                local Fw=ang:Forward()
                self.WModel:SetRenderOrigin(pos+Fw*6+ang:Right()*5+ang:Up()*2)
                ang:RotateAroundAxis(Fw,190)
                ang:RotateAroundAxis(ang:Up(),140)
                self.WModel:SetRenderAngles(ang)
                self.WModel:DrawModel()
            end
        end
    end
end

SWEP.Author = "york"
SWEP.Instructions = "Left click to water a plant. Touch water entity to refill."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IsDarkRPKeys = true
SWEP.WorldModel = "models/props_interiors/pot01a.mdl"
SWEP.ViewModel = "models/props_interiors/pot01a.mdl"
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.AnimPrefix  = "rpg"
SWEP.UseHands = true
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "RP"
SWEP.Sound = "doors/door_latch3.wav"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:SetupDataTables()
    self:NetworkVar("Float",0,"Water")
end

function SWEP:Initialize()
    if(SERVER)then
        self:SetWater(0)
        self:SetHoldType("slam")
    elseif(CLIENT)then
        self.WModel=ClientsideModel(self.WorldModel)
        self.WModel:SetPos(self:GetPos())
        self.WModel:SetParent(self)
        self.WModel:SetNoDraw(true)
    end
end

function SWEP:Deploy()
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:PreDrawViewModel()
    return false
end

function SWEP:PrimaryAttack()
    if(CLIENT)then return end
    local Tr = hg.eyeTrace(self.Owner)
    if((Tr.Hit) and ((Tr.HitPos-self.Owner:GetShootPos()):Length() < 70)) then
        local HitEnt = Tr.Entity
        if HitEnt:GetClass() == "zone_pot" then
            if (HitEnt:GetHasWater() and HitEnt:GetWaterAmount() >= 100) then
                notif(self.Owner, "Горшок уже полон воды!", "fail")
            else
                local CurrentWater = self:GetWater()
                if (CurrentWater > 0) then
                    local WaterToAdd = math.min(25, CurrentWater)
                    HitEnt:AddWaterAmount(WaterToAdd)
                    local NewWater = math.max(0, CurrentWater - WaterToAdd)
                    self:SetWater(NewWater)
                    if (NewWater <= 0) then
                        notif(self.Owner, "Вы использовали всю воду в лейке!", "fail")
                    else
                        notif(self.Owner, "Вы полили растение!", "succsess")
                        self.Owner:EmitSound('ambient/water/water_spray2.wav')
                    end
                else
                    notif(self.Owner, "В лейке закончилась вода!", "fail")
                end
            end
        else

        end
    else

    end
end

function SWEP:Touch(toucher)
    if CLIENT then return end
    if toucher:GetClass() == "zone_water" then
        local currentWater = self:GetWater()
        local maxWater = self.Params.WaterAmount
        if currentWater < maxWater then
            local waterToAdd = math.min(100, maxWater - currentWater)
            self:SetWater(currentWater + waterToAdd)
            notif(self.Owner, "Лейка пополнена!", "fail")
            toucher:Remove()
        else
            notif(self.Owner, "Лейка уже полна!", "fail")
        end
    end
end

function SWEP:OnRemove()
    if CLIENT and self.WModel and self.WModel:IsValid() then
        self.WModel:Remove()
    end
end

function SWEP:OnDrop()
    if CLIENT and self.WModel and self.WModel:IsValid() then
        self.WModel:Remove()
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end
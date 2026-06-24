if(SERVER)then 
    AddCSLuaFile() 
end

SWEP.Base = "weapon_base"
SWEP.PrintName = "Рация"
SWEP.Instructions = "Используйте рацию для связи с другими людьми в радиусе 4 км. Вы должны быть на одной частоте."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IdleHoldType = "normal"
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/sirgibs/ragdoll/css/terror_arctic_radio.mdl"

if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_walkietalkie")
    SWEP.IconOverride = "vgui/wep_jack_hmcd_walkietalkie.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 5
SWEP.SlotPos = 5
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(6, 5.5, -41)
SWEP.offsetAng = Angle(180, 160, 180)

SWEP.Frequency = 101.8
SWEP.Frequencies = {
    101.8,
    107.8,
	110.8,
}

local ST_TYPE_LOCALFILE = 0
local ST_TYPE_URL = 1

function SWEP:BippSound(ent, pitch)
    ent:EmitSound("radio/voip_end_transmit_beep_0" .. math.random(1,8) .. ".wav", 35, pitch)
end

if SERVER then
    function SWEP:CanListen(listener, talker, isChat)
        if not self:GetIsOn() then return false end
        
        local targetWep = listener:GetWeapon("weapon_walkie_talkie")
        if not IsValid(targetWep) or not targetWep:GetInternalVariable("m_bIsOn") then 
            if not targetWep.GetIsOn or not targetWep:GetIsOn() then return false end
        end

        if not listener:Alive() or not talker:Alive() then return false end

        if (talker.organism and talker.organism.otrub) or (listener.organism and listener.organism.otrub) then
            return false
        end

        if (self.Frequency == targetWep.Frequency) then 
            return true
        end

        return false
    end

    hook.Remove("PlayerCanHearPlayersVoice", "Radio_VoiceLoop", function(listener, talker)
        local wep = talker:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_walkie_talkie" then
            if wep:CanListen(listener, talker, false) then
                return true, false 
            end
        end
    end)

    hook.Add("PlayerSay", "Radio_ChatLoop", function(sender, text, teamOnly)
        local wep = sender:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_walkie_talkie" and wep:GetIsOn() then
            
            wep:BippSound(sender, 100)

            for _, listener in ipairs(player.GetAll()) do
                if listener == sender then continue end
                
                if wep:CanListen(listener, sender, true) then
                    wep:BippSound(listener, 100)

                    if listener:GetPos():DistToSqr(sender:GetPos()) > 600000 then
                        listener:ChatPrint("[Рация] " .. sender:Nick() .. ": " .. text)
                    end
                end
            end
        end
    end)

    hook.Add("PlayerStartVoice", "Radio_StartBeep", function(ply)
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_walkie_talkie" and wep:GetIsOn() then
            wep:SetInUsing(true)
            wep:BippSound(ply, 100)
            
            for _, listener in ipairs(player.GetAll()) do
                if listener ~= ply and wep:CanListen(listener, ply, false) then
                    wep:BippSound(listener, 100)
                end
            end
        end
    end)

    hook.Add("PlayerEndVoice", "Radio_EndBeep", function(ply)
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_walkie_talkie" then
            wep:SetInUsing(false)
            if wep:GetIsOn() then
                wep:BippSound(ply, 100)
                
                for _, listener in ipairs(player.GetAll()) do
                    if listener ~= ply and wep:CanListen(listener, ply, false) then
                        wep:BippSound(listener, 100)
                    end
                end
            end
        end
    end)
end

function SWEP:DrawWorldModel()
    if !self:GetOwner():IsPlayer() then
        self:DrawModel()
    end
end

function SWEP:SetupDataTables()
    self:NetworkVar( "Float", 0, "HudFrequency" )
    self:NetworkVar( "Bool", 0, "IsOn" )
    self:NetworkVar( "Bool", 1, "InUsing" )
end

local walkietalkie_clr = Color(0,0,0)
local bg_clr = Color(0,75,0)
local bg_off_clr = Color(0,32,0)

SWEP.ScreenPosOffset = Vector(3.4,-2.22,3.57)
SWEP.ScreenAngleOffset = Angle(-5,-18.5,91)

if CLIENT then
    surface.CreateFont("Walkie-Talkie_Fixed-Font", {
        font = "Ari-W9500",
        size = 64,
        weight = 600,
        outline = false
    })

    surface.CreateFont("Walkie-Talkie_Fixed-SmallFont", {
        font = "Ari-W9500",
        size = 50,
        weight = 600,
        outline = false
    })
end

function SWEP:DrawWorldModel2()
    self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
    local WorldModel = self.model
    local owner = hg.GetCurrentCharacter(self:GetOwner())

    WorldModel:SetNoDraw(true)
    WorldModel:SetModelScale(self.ModelScale or 1)

    if(IsValid(owner))then
        local offsetVec = self.offsetVec
        local offsetAng = self.offsetAng
        local boneid = owner:LookupBone("ValveBiped.Bip01_L_Hand")

        if(not boneid)then 
            return 
        end

        local matrix = owner:GetBoneMatrix(boneid)

        if(not matrix)then 
            return
        end

        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
        WorldModel:SetPos(newPos)
        WorldModel:SetAngles(newAng)
        WorldModel:SetupBones()

        WorldModel:DrawModel()

        newPos, newAng = LocalToWorld(self.ScreenPosOffset, self.ScreenAngleOffset, matrix:GetTranslation(), matrix:GetAngles())

        cam.Start3D2D( newPos, newAng, 0.005 )
            local Frequency = math.Round(self:GetHudFrequency(),1) .. " MHz"
            local width, height = 264, 145
            draw.RoundedBox(3, 0 - width / 2, 0 - height / 2, width, height, self:GetIsOn() and bg_clr or bg_off_clr)
            if self:GetIsOn() then
                draw.SimpleText(Frequency, "Walkie-Talkie_Fixed-Font", 0, -15, walkietalkie_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(self:GetOwner():IsSpeaking() and "ПЕРЕДАЧА" or "ПРИЕМ", "Walkie-Talkie_Fixed-SmallFont", 0, 40, walkietalkie_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        cam.End3D2D()

    else
        WorldModel:SetPos(self:GetPos())
        WorldModel:SetAngles(self:GetAngles())
        WorldModel:DrawModel()
    end
end

function SWEP:SetHold(value)
    self:SetWeaponHoldType(value)
    self:SetHoldType(value)
    self.holdtype = value
end



local bone, name
function SWEP:BoneSet(lookup_name, vec, ang)
    local owner = self:GetOwner()
    if IsValid(owner) and !owner:IsPlayer() then return end
    hg.bone.Set(owner, lookup_name, vec, ang, "walkietalkie", 0.01)
end

local handAng1, handAng2 = Angle(-15, -10, 10), Angle(5, -65, -60)
local actAng1, actAng2 = Angle(0, -40, -18), Angle(-5, -5, -70)
function SWEP:Step()
    local owner = self:GetOwner()
    local active = owner:KeyDown(IN_ATTACK) and self:GetIsOn()

    if active then
        self:SetHold(self.HoldType)
    elseif self:GetHoldType() ~= self.IdleHoldType then 
        self:SetHold(self.IdleHoldType)
    end

    if owner:OnGround() and owner:GetVelocity():LengthSqr() <= 1000 and not owner:IsTyping() and not owner:IsFlagSet(FL_ANIMDUCKING) then
        self:BoneSet("l_upperarm", vector_origin, self:GetIsOn() and handAng1 or angle_zero)
        self:BoneSet("l_forearm", vector_origin, self:GetIsOn() and handAng2 or angle_zero)

        self:BoneSet("r_upperarm", vector_origin, active and actAng1 or angle_zero)
        self:BoneSet("r_forearm", vector_origin, active and actAng2 or angle_zero)
    end
end

if SERVER then
    concommand.Add("hg_walkietalkie_adjust", function(ply, cmd, args)
        if SERVER then
            if not args[1] then return end
            local ActiveWep = ply:GetActiveWeapon()
            local walkietalkie = IsValid(ActiveWep) and ActiveWep:GetClass() == "weapon_walkie_talkie" and ActiveWep or false
            if not walkietalkie then return end
            walkietalkie:AdjustFrequency( tonumber( args[1] ) )
        end
    end)
end

function SWEP:PrimaryAttack()
    if SERVER then return end
    local tbl = {}
    if self:GetIsOn() then
        tbl[#tbl + 1] = {function()
            local tbl1 = {}
            for i = 1, #self.Frequencies do
                local station = math.Round(self.Frequencies[i], 1)
                tbl1[#tbl1 + 1] = { function() RunConsoleCommand("hg_walkietalkie_adjust", station - self:GetHudFrequency() ) end, station .. " MHz" }
                hg.CreateRadialMenu(tbl1)
            end
            return -1
        end, "Каналы"}
    end

    tbl[#tbl + 1] = {function()
        RunConsoleCommand("+reload")
        timer.Simple(0,function() RunConsoleCommand("-reload") end)
    end, self:GetIsOn() and "Выключить рацию" or "Включить рацию"}
    hg.CreateRadialMenu(tbl)
end

function SWEP:AdjustFrequency(numAdjust)
    self.Frequency = math.Round(math.Clamp(self.Frequency + numAdjust, 101.8, 110.8),1)
    self:SetHudFrequency(self.Frequency)

    local owner = self:GetOwner()
    owner:EmitSound("radiotune.mp3", 45, math.random(95, 105))
    owner:SetAnimation(PLAYER_ATTACK1)

    return self.Frequency
end

function SWEP:Initialize()
    self:SetIsOn(true)
    self.isOn = true
    self:SetHudFrequency(self.Frequency or 101.8)
    self:SetHold(self.HoldType)
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
    local owner = self:GetOwner()
    if SERVER and (!self.turnOnCD or self.turnOnCD < CurTime()) then
        self.turnOnCD = CurTime() + 0.5
        self.isOn = !self.isOn
        self:SetIsOn(self.isOn)
        self:BippSound(owner)
        owner:SetAnimation(PLAYER_ATTACK1)
    end
end

if(SERVER)then
    function SWEP:SetFakeGun(ent)
        self:SetNWEntity("fakeGun", ent)
        self.fakeGun = ent
    end

    function SWEP:RemoveFake()
        if(not IsValid(self.fakeGun))then 
            return 
        end

        self.fakeGun:Remove()
        self:SetFakeGun()
    end

    SWEP.RHandPos = Vector(0, 0, 0)

    function SWEP:CreateFake(ragdoll)
        if(IsValid(self:GetNWEntity("fakeGun")))then 
            return
        end

        local ent = ents.Create("prop_physics")
        local lh = ragdoll:GetPhysicsObjectNum(5)
        local rh = ragdoll:GetPhysicsObjectNum(7)

        rh:SetPos(rh:GetPos() + self:GetOwner():EyeAngles():Forward() * 20)
        rh:SetAngles(self:GetOwner():EyeAngles() + Angle(0, 0, -90))
        lh:SetPos(rh:GetPos())

        ent:SetModel(self.WorldModel)
        ent:SetPos(rh:GetPos())
        ent:SetAngles(rh:GetAngles() + Angle(0, 0, 180))
        ent:Spawn()

        ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        ent:SetOwner(ragdoll)
        ent:GetPhysicsObject():SetMass(0)
        ent:SetNoDraw(true)
        ent.dontPickup = true
        ent.fakeOwner = self

        ragdoll:DeleteOnRemove(ent)
        ragdoll.fakeGun = ent

        if(IsValid(ragdoll.ConsRH))then 
            ragdoll.ConsRH:Remove()
        end

        self:SetFakeGun(ent)
        ent:CallOnRemove("homigrad-swep", self.RemoveFake, self)

        local vec = Vector(0, 0, 0)
        vec:Set(-self.RHandPos or vector_origin)
        vec:Rotate(ent:GetAngles())

        rh:SetPos(ent:GetPos() + vec)
    end

    function SWEP:RagdollFunc(pos, angles, ragdoll)
        shadowControl = shadowControl or hg.ShadowControl
        local fakeGun = ragdoll.fakeGun
        shadowControl(ragdoll, 5, 0.001, angles, 500, 30, pos, 500, 50)
    end
end
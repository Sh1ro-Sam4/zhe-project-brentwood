if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Удавка"
SWEP.Instructions = "This is a single cylindrical, flexible strand of metal connected to two ergonomic grips made of carbon fibre and metal. Use it to strange people.\n\nHold LMB to strangle.\nRelease LMB to stop strangling."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/hmc/weapons/w_fibrewire.mdl"
SWEP.WorldModelReal = "models/hmc/weapons/v_fibrewire.mdl"
SWEP.ViewModel = ""

SWEP.HoldType = "melee"

SWEP.HoldPos = Vector(-3,0,0)

SWEP.AttackTime = 0.4
SWEP.AnimTime1 = 1.3
SWEP.WaitTime1 = 1
SWEP.ViewPunch1 = Angle(0,-5,3)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-4)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,-8)
SWEP.weaponAng = Angle(0,-90,0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 0
SWEP.DamageSecondary = 0

SWEP.BlockHoldPos = Vector(-6,0,0)
SWEP.BlockHoldAng = Angle(0, 0, 0)

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 3

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 12
SWEP.StaminaSecondary = 8

SWEP.AttackLen1 = 70
SWEP.AttackLen2 = 40

SWEP.AnimList = {
    ["idle"] = "charge_idle",
    ["idle2"] = "charge_idle",
    ["deploy"] = "idle2_to_charge",
    ["attack"] = "Swing",
    ["attack2"] = "Swing",
    ["charge_idle"] = "charge_idle",
    ["holster"] = "holster",
    ["drop"] = "drop",

    ["Idle1_To_Charge"] = "Idle1_To_Charge",
    ["Idle2_To_Charge"] = "Idle2_To_Charge",
    ["strangle_start"] = "strangle_start",
    ["strangle_loop"] = "strangle_loop",
    ["strangle_end"] = "strangle_end",
}

local StopStrangle
StopStrangle = function(self)
    if CLIENT then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if IsValid(self.StrangleRag) then
        self.StrangleRag.Strangler = nil
        self.StrangleRag.StrangleLocked = nil
        if self.StrangleRag._oldCollisionGroup then
            self.StrangleRag:SetCollisionGroup(self.StrangleRag._oldCollisionGroup)
            self.StrangleRag._oldCollisionGroup = nil
        end
    end
    self:SetStrangling(false)
    self.StrangleRag = nil
    self.NoIdleLoop = nil
    if CLIENT or (IsValid(owner) and owner:IsPlayer()) then
        self:PlayAnim("idle", 10, true, nil, false, true)
    end
    self._fw_looping = false
    self._fw_loop_at = nil
    self._fw_button_held = nil

    local ragPly = hg.RagdollOwner and hg.RagdollOwner(self.StrangleRag) or nil
    if IsValid(ragPly) and ragPly:IsPlayer() and ragPly:Alive() and ragPly.organism then
        local org = ragPly.organism
        if org._fw_original_pulse then
            org.pulse = org._fw_original_pulse
            org._fw_original_pulse = nil
        end
        if org._fw_original_blood then
            org.blood = org._fw_original_blood
            org._fw_original_blood = nil
        end
        if org._fw_original_o2 and org.o2 and org.o2[1] then
            org.o2[1] = math.max(org.o2[1], org._fw_original_o2)
            org._fw_original_o2 = nil
        end
        org._fw_being_strangled = nil
    elseif IsValid(ragPly) and ragPly.organism then
        ragPly.organism._fw_being_strangled = nil
        ragPly.organism._fw_original_pulse = nil
        ragPly.organism._fw_original_blood = nil
        ragPly.organism._fw_original_o2 = nil
    end

    if IsValid(owner) and owner:IsPlayer() and self._fw_prev_run then
        owner:SetRunSpeed(self._fw_prev_run)
        self._fw_prev_run = nil
    end

    if IsValid(owner) and owner.SetNetVar then
        owner:SetNetVar("slowDown", 0)
    end
    self._fw_lock_until = nil
end

function SWEP:HideDummyBone()
    if CLIENT then
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        local vm = owner:GetViewModel()
        if not IsValid(vm) then return end
        vm:ManipulateBoneScale(60, Vector(0, 0, 0))
        vm:ManipulateBonePosition(60, Vector(0, 0, 0))
    end
end

function SWEP:PlayAnim(anim, time, cycling, callback, reverse, sendtoclient)
    if CLIENT then
        self:HideDummyBone()
    end
    return self.BaseClass.PlayAnim(self, anim, time, cycling, callback, reverse, sendtoclient)
end

function SWEP:OnRemove()
    if self:GetStrangling() then
        if SERVER then StopStrangle(self) end
    end
end

function SWEP:OnDrop()
    if self:GetStrangling() then
        if SERVER then StopStrangle(self) end
    end
end

function SWEP:Deploy()
    local ok = self.BaseClass.Deploy(self)
    if CLIENT then
        timer.Simple(0.04, function()
            if not IsValid(self) then return end
            local owner = self:GetOwner()
            if not IsValid(owner) then return end
            if owner:GetActiveWeapon() ~= self then return end
            if self.GetStrangling and self:GetStrangling() then return end
            self:PlayAnim("idle", 10, true)
            self:HideDummyBone()
        end)
    end
    return ok
end

function SWEP:Holster(target)
    if self:GetStrangling() then
        if SERVER then StopStrangle(self) end
    end
    if self.BaseClass and self.BaseClass.Holster then
        return self.BaseClass.Holster(self, target)
    end
    return true
end


if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_fibrewire")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_fibrewire"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis"
SWEP.holsteredPos = Vector(6, -1.5, -6)
SWEP.holsteredAng = Angle(65, 0, 0)
SWEP.Concealed = false
SWEP.HolsterIgnored = false



SWEP.AttackHit = "Plastic_Box.ImpactHard"
SWEP.Attack2Hit = "Plastic_Box.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "Plastic_Box.ImpactSoft"

SWEP.AttackPos = Vector(0,0,0)

function SWEP:CanSecondaryAttack()
    return false
end

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 85
SWEP.AttackRads2 = 0

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

function SWEP:SetupDataTables()
    if self.BaseClass and self.BaseClass.SetupDataTables then
        self.BaseClass.SetupDataTables(self)
    end
    self:NetworkVar("Bool", 13, "Strangling")
end

local function IsFromBehind(attacker, target)
    if not IsValid(attacker) or not IsValid(target) then return false end

    local targetEnt = target
    local targetPlayer = target
    if target:IsRagdoll() then
        targetPlayer = hg.RagdollOwner and hg.RagdollOwner(target) or nil
    end

    local targetPos = target:GetPos()
    local attackerPos = attacker:IsPlayer() and attacker:EyePos() or attacker:GetPos()

    local toAttacker = (attackerPos - targetPos):GetNormalized()

    local targetForward
    if IsValid(targetPlayer) and targetPlayer:IsPlayer() then
        targetForward = targetPlayer:EyeAngles():Forward()
    else
        local targetAng = target:GetAngles()
        targetForward = targetAng:Forward()
    end

    local dot = targetForward:Dot(toAttacker)

    return dot < 0
end

local function StartStrangle(self, victim)
    if CLIENT then return end
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    if IsValid(owner.FakeRagdoll) then return end

    local rag = victim
    if IsValid(victim) and victim:IsPlayer() then
        hg.Fake(victim)
        rag = victim.FakeRagdoll
    end

    if not IsValid(rag) or not rag:IsRagdoll() then return end

    local ragOwner = (hg.RagdollOwner and hg.RagdollOwner(rag)) or nil
    if ragOwner == owner then return end

    local ragPly = ragOwner
    if IsValid(ragPly) and ragPly:IsPlayer() and ragPly.organism then
        local org = ragPly.organism
        org._fw_original_pulse = org.pulse
        org._fw_original_blood = org._fw_original_blood
        org._fw_original_o2 = org.o2 and org.o2[1] or nil
    end

    -- Mark strangling state
    self:SetStrangling(true)
    self.StrangleRag = rag
    rag.Strangler = owner
    rag.StrangleLocked = true
    self.NoIdleLoop = true

    rag._oldCollisionGroup = rag:GetCollisionGroup()
    rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self._fw_looping = false
    self._fw_loop_at = CurTime() + 0.6
    self._fw_lock_until = CurTime() + 1
    self._fw_button_held = true
    owner:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1,7) .. ".wav", 60, math.random(95,105))

    do
        local hands = owner:GetWeapon("weapon_hands_sh")
        if IsValid(hands) and hands.SetCarrying then
            hands:SetCarrying()
        end
        if hg and hg.SetCarryEnt2 then
            hg.SetCarryEnt2(owner)
        end
    end

    self._fw_prev_run = owner:GetRunSpeed()
    owner:SetRunSpeed(owner:GetWalkSpeed())

    if owner.organism and owner.organism.stamina and owner.organism.stamina[1] then
        owner.organism.stamina[1] = math.max(owner.organism.stamina[1] - 50, 0)
    end

    self:PlayAnim("strangle_start", 0.6, false, nil, false, true)
    timer.Simple(0.6, function()
        if not IsValid(self) then return end
        if not self:GetStrangling() then return end
        self:PlayAnim("strangle_loop", 4.0, true, nil, false, true)
        self._fw_looping = true
    end)
end

function SWEP:PrimaryAttack()
    if self:GetStrangling() then
        self._fw_holding_button = true
        return
    end
    self._fw_holding_button = true
    return self.BaseClass.PrimaryAttack(self)
end

function SWEP:CustomAttack()
    if CLIENT then return true end
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return true end

    if IsValid(owner.FakeRagdoll) then return true end

    local filter = {owner}
    local fr = owner.FakeRagdoll
    if IsValid(fr) then filter[#filter+1] = fr end
    local tr = util.QuickTrace(owner:GetShootPos(), owner:GetAimVector() * 80, filter)
    local hitEnt = tr.Entity
    if not IsValid(hitEnt) then return true end

    local isRagdoll = hitEnt:IsRagdoll()
    local isPlayer = hitEnt:IsPlayer()

    local headHit = false
    local neckBones = {"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine1"}
    local hitDistanceThreshold = 18

    if isPlayer then
        for _, boneName in ipairs(neckBones) do
            local boneIndex = hitEnt:LookupBone(boneName)
            if boneIndex then
                local bonePos = hitEnt:GetBonePosition(boneIndex)
                if bonePos and tr.HitPos:Distance(bonePos) <= hitDistanceThreshold then
                    headHit = true
                    break
                end
            end
        end

        if not headHit then
             headHit = (tr.HitGroup == 1 or tr.HitGroup == 2)
        end
    elseif isRagdoll then
        if tr.PhysicsBone then
            headHit = (tr.PhysicsBone == hg.realPhysNum(hitEnt, 10))
        end
        if not headHit then
            local headIdx = hg.realPhysNum(hitEnt, 10)
            local headObj = hitEnt:GetPhysicsObjectNum(headIdx)
            if IsValid(headObj) and tr.HitPos then
                if headObj:GetPos():Distance(tr.HitPos) <= hitDistanceThreshold then
                    headHit = true
                end
            end
        end
        if not headHit then
            for _, boneName in ipairs(neckBones) do
                local boneIndex = hitEnt:LookupBone(boneName)
                if boneIndex then
                    local bonePos = hitEnt:GetBonePosition(boneIndex)
                    if bonePos and tr.HitPos:Distance(bonePos) <= hitDistanceThreshold then
                        headHit = true
                        break
                    end
                end
            end
        end
    end

    local angleOK = IsFromBehind(owner, hitEnt)
    if headHit and angleOK then
        local ragTarget = hitEnt
        if isPlayer then
            if hg and hg.Fake then hg.Fake(hitEnt) end
            ragTarget = hitEnt.FakeRagdoll or ragTarget
        end

        StartStrangle(self, ragTarget)

        self:SetInAttack(false)
        return true
    end

    return true
end

function SWEP:CustomThink()
    if self.BaseClass and self.BaseClass.CustomThink then
        self.BaseClass.CustomThink(self)
    end

    if CLIENT then return end
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end
    local rag = self.StrangleRag

    if self:GetStrangling() then
        local holdingButton = self._fw_button_held or false

        if not holdingButton then
            if (self._fw_lock_until or 0) <= CurTime() then
                StopStrangle(self)
            end
            return
        end
    end

    if not self:GetStrangling() then return end

    if not IsValid(rag) or not rag:IsRagdoll() then
        StopStrangle(self)
        return
    end

    local ragPlyAlive
    do
        local rp = hg.RagdollOwner and hg.RagdollOwner(rag) or nil
        ragPlyAlive = IsValid(rp) and rp:IsPlayer() and rp:Alive()
    end
    if not owner:Alive() or not ragPlyAlive then
        StopStrangle(self)
        return
    end

    local lb = owner:LookupBone("ValveBiped.Bip01_L_Hand")
    local rb = owner:LookupBone("ValveBiped.Bip01_R_Hand")
    if not lb or not rb then return end
    local lm = owner:GetBoneMatrix(lb)
    local rm = owner:GetBoneMatrix(rb)
    if not lm or not rm then return end

    local mid = (lm:GetTranslation() + rm:GetTranslation()) * 0.5
    local fwd = owner:GetAimVector()
    local up = owner:GetAngles():Up()

    local left = owner:GetAngles():Right() * -1
    local targetPos = mid + up * 6 + fwd * 20 + left * 3
    local neckAng = owner:EyeAngles()
    neckAng:RotateAroundAxis(neckAng:Forward(), 90)
    neckAng:RotateAroundAxis(neckAng:Up(), 90)

    hg.ShadowControl(rag, 10, 0.2, neckAng, 300, 30, targetPos, 800, 200)

    local spinePos = targetPos - fwd * 8
    hg.ShadowControl(rag, 1, 0.2, nil, nil, nil, spinePos, 500, 120)
    hg.ShadowControl(rag, 2, 0.2, nil, nil, nil, spinePos, 500, 120)

    local ragPly2 = hg.RagdollOwner and hg.RagdollOwner(rag) or nil
    local ragOrg = ragPly2 and ragPly2.organism or nil
    local knockedOut = ragOrg and ragOrg.otrub == true
    if not knockedOut then
        local headPhys = rag:GetPhysicsObjectNum(hg.realPhysNum(rag, 10))
        local lhandPhys = rag:GetPhysicsObjectNum(hg.realPhysNum(rag, 5))
        local rhandPhys = rag:GetPhysicsObjectNum(hg.realPhysNum(rag, 7))
        if IsValid(headPhys) and IsValid(lhandPhys) and IsValid(rhandPhys) then
            local pos = headPhys:GetPos()
            local lpos = lhandPhys:GetPos()
            local rpos = rhandPhys:GetPos()

            local leftOffset = pos - (pos - lpos):GetNormalized() * (2 + math.sin(CurTime() * 2) * 0.5)
            local rightOffset = pos - (pos - rpos):GetNormalized() * (2 + math.cos(CurTime() * 1.8) * 0.5)

            hg.ShadowControl(rag, 5, 0.001, nil, nil, nil, leftOffset, 80, 60)
            hg.ShadowControl(rag, 7, 0.001, nil, nil, nil, rightOffset, 80, 60)
        end
    end

    local ragPly = hg.RagdollOwner(rag)
    if IsValid(ragPly) and ragPly:IsPlayer() and ragPly.organism then
        local org = ragPly.organism
        local dt = FrameTime()

        org._fw_being_strangled = true

        if org.o2 and org.o2[1] then
            org.o2[1] = math.max(org.o2[1] - 4 * dt, 0)
        end

        if org.stamina and org.stamina.subadd ~= nil then
            org.stamina.subadd = org.stamina.subadd + 20 * dt
        end

        if org.painadd then
            org.painadd = org.painadd + 8 * dt
        end

        if org.shock then
            org.shock = math.min((org.shock or 0) + 5 * dt, 100)
        end

        if org.o2 and org.o2[1] then
            local o2Level = org.o2[1]

            if o2Level < 2 then
                if org.pulse then
                    org.pulse = math.max(org.pulse - 10 * dt, 10)
                end
                if org.blood then
                    org.blood = math.max(org.blood - 13 * dt, 500)
                end
            elseif o2Level < 5 then
                if org.pulse then
                    org.pulse = math.max(org.pulse - 5 * dt, 12)
                end
                if org.blood then
                    org.blood = math.max(org.blood - 7 * dt, 800)
                end
            elseif o2Level < 8 then
                if org.pulse then
                    org.pulse = math.max(org.pulse - 3 * dt, 15)
                end
            end
        end

        if ragPly._fw_break_attempt then
            ragPly._fw_break_attempt = nil

            local knockedOut = org and org.otrub == true
            if knockedOut then
                return
            end

            if IsValid(ragPly) then
                local lastSoundTime = ragPly._fw_last_break_sound or 0
                if CurTime() - lastSoundTime >= 0.5 then
                    ragPly:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 6) .. ".wav", 75, math.random(95, 105))
                    ragPly._fw_last_break_sound = CurTime()
                end
            end


            local baseChance = 0.023
            local currentO2 = org.o2 and org.o2[1] or 0
            local maxO2 = (org.o2 and org.o2.max) or (org.o2 and org.o2.range) or 100

            local o2Ratio = math.max(0, math.min(1, currentO2 / maxO2))

            local breakChance = baseChance * o2Ratio

            if math.random() < breakChance then
                if IsValid(ragPly) then
                    ragPly:EmitSound("physics/metal/metal_computer_impact_soft2.wav", 85, math.random(95, 105))
                end
                if IsValid(owner) then
                    owner:EmitSound("physics/metal/metal_computer_impact_soft2.wav", 85, math.random(95, 105))
                end
                StopStrangle(self)
                return
            end
        end
    end

    if (self._fw_loop_at or 0) > 0 and CurTime() >= self._fw_loop_at and not self._fw_looping then
        self:PlayAnim("strangle_loop", 4.0, true, nil, false, true)
        self._fw_looping = true
    end

    self:HideDummyBone()
end

function SWEP:PrimaryAttackAdd(ent, trace)
    if CLIENT then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if IsValid(owner.FakeRagdoll) then return end

    local filter = {owner}
    local fr = owner.FakeRagdoll
    if IsValid(fr) then filter[#filter+1] = fr end
    local tr = util.QuickTrace(owner:GetShootPos(), owner:GetAimVector() * 80, filter)
    local hitEnt = tr.Entity
    if not IsValid(hitEnt) then return end

    local isRagdoll = hitEnt:IsRagdoll()
    local isPlayer = hitEnt:IsPlayer()

    local headHit = false
    local neckBones = {"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine1"}
    local hitDistanceThreshold = 18

    if isPlayer then
        for _, boneName in ipairs(neckBones) do
            local boneIndex = hitEnt:LookupBone(boneName)
            if boneIndex then
                local bonePos = hitEnt:GetBonePosition(boneIndex)
                if bonePos and tr.HitPos:Distance(bonePos) <= hitDistanceThreshold then
                    headHit = true
                    break
                end
            end
        end
        if not headHit then
             headHit = (tr.HitGroup == 1 or tr.HitGroup == 2)
        end
    elseif isRagdoll then
        if tr.PhysicsBone then
            headHit = (tr.PhysicsBone == hg.realPhysNum(hitEnt, 10))
        end
        if not headHit then
            local headIdx = hg.realPhysNum(hitEnt, 10)
            local headObj = hitEnt:GetPhysicsObjectNum(headIdx)
            if IsValid(headObj) and tr.HitPos then
                if headObj:GetPos():Distance(tr.HitPos) <= hitDistanceThreshold then
                    headHit = true
                end
            end
        end
        if not headHit then
            for _, boneName in ipairs(neckBones) do
                local boneIndex = hitEnt:LookupBone(boneName)
                if boneIndex then
                    local bonePos = hitEnt:GetBonePosition(boneIndex)
                    if bonePos and tr.HitPos:Distance(bonePos) <= hitDistanceThreshold then
                        headHit = true
                        break
                    end
                end
            end
        end
    end

    if self:GetStrangling() then return end
    local angleOK2 = IsFromBehind(owner, hitEnt)
    if headHit and angleOK2 then
        local ragTarget = hitEnt
        if isPlayer then
            if hg and hg.Fake then hg.Fake(hitEnt) end
            ragTarget = hitEnt.FakeRagdoll or ragTarget
        end

        StartStrangle(self, ragTarget)

        self:SetInAttack(false)
    end
end

if SERVER then
    hook.Add("HG_MovementCalc_2", "FiberwireSlowMove", function(mul, ply, cmd)
        local wep = IsValid(ply) and ply:GetActiveWeapon() or nil
        if not IsValid(wep) then return end
        if wep:GetClass() ~= "weapon_hg_fiberwire" then return end
        if wep.GetStrangling and wep:GetStrangling() then
            mul[1] = mul[1] * 0.6
        end
    end)
end

if SERVER then
    hook.Add("CanControlFake", "FiberwireStrangleLock", function(ply, rag)
        local r = ply and ply.FakeRagdoll
        if IsValid(r) and r.StrangleLocked then
            return false
        end
    end)

    hook.Add("Should Fake Up", "FiberwireStrangleLockUp", function(ply)
        local r = ply and ply.FakeRagdoll
        if IsValid(r) and r.StrangleLocked then
            return true
        end
    end)

    hook.Remove("Org Think", "FiberwirePreventOtrub", function(owner, org, timeValue)
        if org._fw_being_strangled and org.o2 and org.o2[1] and org.o2[1] < 4 then
            org.needotrub = false
            if org.pulse then
                org.pulse = math.max(org.pulse - 5 * timeValue, 10)
            end

        end
    end)

    hook.Add("StartCommand", "FiberwireButtonTrack", function(ply, cmd)
        local wep = IsValid(ply) and ply:GetActiveWeapon() or nil
        if not IsValid(wep) then return end
        if wep:GetClass() ~= "weapon_hg_fiberwire" then return end

        wep._fw_button_held = bit.band(cmd:GetButtons(), IN_ATTACK) ~= 0

        if wep.GetStrangling and wep:GetStrangling() then
            cmd:RemoveKey(IN_SPEED)
        end
    end)

    hook.Add("StartCommand", "FiberwireBreakFree", function(ply, cmd)
        if not IsValid(ply) or not ply:IsPlayer() then return end

        local rag = ply.FakeRagdoll
        if not IsValid(rag) or not rag.StrangleLocked then return end

        local strangler = rag.Strangler
        if not IsValid(strangler) or not strangler:IsPlayer() then return end

        local wep = strangler:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "weapon_hg_fiberwire" then return end
        if not wep.GetStrangling or not wep:GetStrangling() then return end

        local buttons = cmd:GetButtons()
        local wasPressed = ply._fw_last_buttons or 0

        local attackPressed = bit.band(buttons, IN_ATTACK) ~= 0
        local attack2Pressed = bit.band(buttons, IN_ATTACK2) ~= 0
        local jumpPressed = bit.band(buttons, IN_JUMP) ~= 0

        local attackWasPressed = bit.band(wasPressed, IN_ATTACK) ~= 0
        local attack2WasPressed = bit.band(wasPressed, IN_ATTACK2) ~= 0
        local jumpWasPressed = bit.band(wasPressed, IN_JUMP) ~= 0

        if (attackPressed and not attackWasPressed) or
           (attack2Pressed and not attack2WasPressed) or
           (jumpPressed and not jumpWasPressed) then
            ply._fw_break_attempt = true
        end

        ply._fw_last_buttons = buttons
    end)
end
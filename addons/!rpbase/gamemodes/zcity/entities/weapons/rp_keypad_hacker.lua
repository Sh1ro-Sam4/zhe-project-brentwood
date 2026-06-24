if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Устройство взлома"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false

if CLIENT then
	--SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_handcuffskey")
	--SWEP.IconOverride = "vgui/wep_jack_hmcd_handcuffskey"
end

SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/wania/w_ciad.mdl"
SWEP.WorldModelReal = "models/weapons/wania/c_ciad.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.WorkWithFake = true

SWEP.setlh = false
SWEP.setrh = true

SWEP.HoldAng = Angle(0, 0, 45)
SWEP.HoldPos = Vector(0, 4, -1)

SWEP.AnimList = {
	["deploy"] = {"draw", 1, false},
	["use"] = {"use", 1.5, false, false, function(self) if CLIENT then return end self:Hack() end},
	--["unlock"] = {"unlock", 1.5, false, false, function(self) if CLIENT then return end self:Unlock() end},
	["idle"] = {"idle", 5, true}
}


SWEP.CallbackTimeAdjust = 1.8
SWEP.showstats = false
SWEP.DistUse = 32

SWEP.RequireHandleBone = true
SWEP.HandleBoneName = "handle"
SWEP.HandleAimRadius = 16
SWEP.HandleMaxDistance = 28	

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self:PlayAnim("deploy")
end

if SERVER then
	function SWEP:Deploy()
		self.Initialzed = true
		self:PlayAnim("deploy")
		self:SetHold(self.HoldType)
		return true
	end

	function SWEP:Sound()
		local owner = self:GetOwner()
		if IsValid(owner) then
			owner:EmitSound("key/keyuse.wav", 60)
		end
	end

	function SWEP:PrimaryAttack()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
	
		local trace = hg.eyeTrace(owner, self.DistUse)
		if not trace or not trace.Hit or not IsValid(trace.Entity) then return end
	
		local ent = trace.Entity
		if ent:GetClass() != "keypad" then return end
		ent:EmitSound("nextoren/others/monitor/start_hacking.wav", 75, 100, 1, CHAN_AUTO)
		ent:SetHacked("> Hacking")
    	timer.Simple(10, function()
			if math.random(0, 100) > 25 then
				ent:SetHacked("Loser >:3")
				timer.Simple(3, function()
					ent:SetHacked("")
				end)
				ent:EmitSound("nextoren/others/button_unlocked.wav")
			else
				ent:EmitSound("nextoren/others/chaos_radio_open.wav")
				timer.Simple(3, function()
					ent:Process(true)
				end)
				ent:SetHacked("Shit OwO")
				timer.Simple(3, function()
					ent:SetHacked("")
				end)
			end
			ent:EmitSound("nextoren/others/monitor/start_hacking.wav", 75, 100, 1, CHAN_AUTO,SND_STOP)
		end)
	
		--self:Sound()
		self:PlayAnim("use")
		self:SetNextPrimaryFire(CurTime() + 15)
	end

	-- function SWEP:Hack()
	-- 	local owner = self:GetOwner()
	-- 	if not IsValid(owner) then return end

	-- 	local ent = self:GetPendingDoor()
	-- 	if not IsValid(ent) then return end
	-- 	if not hgIsDoor(ent) then return end

	-- 	local ok = IsLookingNearHandle(owner, ent, self)
	-- 	if not ok then return end

	-- 	ent:Fire("Lock", "", 0)
	-- end

end
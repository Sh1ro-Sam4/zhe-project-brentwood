if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Ключи"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_handcuffskey")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_handcuffskey"
end

SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/craphead_scripts/adv_keys_2/w_key3.mdl"
SWEP.WorldModelReal = "models/craphead_scripts/adv_keys_2/c_key3.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.WorkWithFake = true

SWEP.setlh = false
SWEP.setrh = true

SWEP.HoldAng = Angle(0, 0, 45)
SWEP.HoldPos = Vector(0, 0, -1)

SWEP.AnimList = {
	["deploy"] = {"draw", 1, false},
	["lock"] = {"lock", 1.5, false, false, function(self) if CLIENT then return end self:Lock() end},
	["unlock"] = {"unlock", 1.5, false, false, function(self) if CLIENT then return end self:Unlock() end},
	["idle"] = {"idle", 5, true}
}

SWEP.modeValues = nil
SWEP.modeValuesdef = {
	[1] = 1,
}

SWEP.CallbackTimeAdjust = 1.8
SWEP.showstats = false
SWEP.DistUse = 32

SWEP.RequireHandleBone = true
SWEP.HandleBoneName = "handle"
SWEP.HandleAimRadius = 16
SWEP.HandleMaxDistance = 28	

local function GetDoorHandlePos(door, boneName)
	if not IsValid(door) then return nil end

	local bone = door:LookupBone(boneName or "handle")
	if not bone then return nil end

	if door.SetupBones then
		door:SetupBones()
	end

	local pos = nil
	if door.GetBonePosition then
		pos = select(1, door:GetBonePosition(bone))
	end

	if pos then return pos end

	if door.GetBoneMatrix then
		local mat = door:GetBoneMatrix(bone)
		if mat then
			return mat:GetTranslation()
		end
	end

	return nil
end

local function ClosestPointOnSegment(a, b, p)
	local ab = b - a
	local abLenSqr = ab:LengthSqr()
	if abLenSqr <= 0.0001 then return a end
	local t = (p - a):Dot(ab) / abLenSqr
	t = math.Clamp(t, 0, 1)
	return a + ab * t
end

local function IsLookingNearHandle(ply, door, wep)
	if not IsValid(ply) or not IsValid(door) or not IsValid(wep) then return false, "invalid" end

	local handlePos = GetDoorHandlePos(door, wep.HandleBoneName)
	if not handlePos then
		if wep.RequireHandleBone then
			return true, "no_handle_bone"
		end
		return true
	end

	local eye = ply:EyePos()
	local dir = ply:GetAimVector()

	local maxDist = wep.HandleMaxDistance or wep.DistUse or 32
	local segEnd = eye + dir * maxDist

	local closest = ClosestPointOnSegment(eye, segEnd, handlePos)
	local dist = closest:Distance(handlePos)

	if dist > (wep.HandleAimRadius or 14) then
		return false, "not_near_handle"
	end

	if eye:Distance(handlePos) > maxDist + 6 then
		return false, "too_far"
	end

	return true
end

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self:PlayAnim("deploy")
	self.modeValues = {
		[1] = 1
	}
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

	function SWEP:SetPendingDoor(door)
		self.__pendingDoor = IsValid(door) and door or nil
		self.__pendingDoorTime = CurTime()
	end

	function SWEP:GetPendingDoor()
		if not IsValid(self.__pendingDoor) then return nil end
		if not self.__pendingDoorTime then return nil end
		if CurTime() - self.__pendingDoorTime > 2.5 then return nil end
		return self.__pendingDoor
	end

	function SWEP:PrimaryAttack()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
	
		local trace = hg.eyeTrace(owner, self.DistUse)
		if not trace or not trace.Hit or not IsValid(trace.Entity) then return end
	
		local ent = trace.Entity
		if not hgIsDoor(ent) then return end
		if not ent:IsManagedDoor() then return end
	
		if !ent:CanPlayerAccessDoor(owner) then
			notif(owner, "Эта дверь не принадлежит вам!", 'fail')
			return
		end
	
		local ok, why = IsLookingNearHandle(owner, ent, self)
		if not ok then
			if why == "no_handle_bone" then
			else
				notif(owner, "Наведи прицел ближе к ручке двери или подойди ближе.", 'fail')
			end
			return
		end
	
		self:SetPendingDoor(ent)
	
		self:Sound()
		self:PlayAnim("lock")
		self:SetNextPrimaryFire(CurTime() + 1.5)
	end

	function SWEP:SecondaryAttack()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local trace = hg.eyeTrace(owner, self.DistUse)
		if not trace or not trace.Hit or not IsValid(trace.Entity) then return end

		local ent = trace.Entity
		if not hgIsDoor(ent) then return end
		if not ent:IsManagedDoor() then return end

		if not ent:CanPlayerAccessDoor(owner) then
			notif(owner, "Эта дверь не принадлежит вам!", 'fail')
			return
		end

		local ok, why = IsLookingNearHandle(owner, ent, self)
		if not ok then
			if why == "no_handle_bone" then
			else
				notif(owner, "Наведи прицел ближе к ручке двери или подойди ближе.", 'fail')
			end
			return
		end

		self:SetPendingDoor(ent)

		self:Sound()
		self:PlayAnim("unlock")
		self:SetNextSecondaryFire(CurTime() + 1.5)
	end

	function SWEP:Lock()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local ent = self:GetPendingDoor()
		if not IsValid(ent) then return end
		if not hgIsDoor(ent) then return end

		local ok = IsLookingNearHandle(owner, ent, self)
		if not ok then return end

		ent:Fire("Lock", "", 0)
	end

	function SWEP:Unlock()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local ent = self:GetPendingDoor()
		if not IsValid(ent) then return end
		if not hgIsDoor(ent) then return end

		local ok = IsLookingNearHandle(owner, ent, self)
		if not ok then return end

		ent:Fire("Unlock", "", 0)
	end
end
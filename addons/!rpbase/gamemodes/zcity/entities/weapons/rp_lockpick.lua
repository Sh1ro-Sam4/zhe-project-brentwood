if SERVER then AddCSLuaFile() end

CFG = CFG or {}

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Отмычка"
SWEP.Category = "RP"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/sterling/w_enhanced_lockpicks.mdl"
SWEP.WorldModelReal = "models/sterling/c_enhanced_lockpicks.mdl"
SWEP.WorldModelExchange = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.setlh = true
SWEP.setrh = true

SWEP.HoldAng = Angle(0, 0, 0)
SWEP.HoldPos = Vector(0, 0, -1)

SWEP.AnimList = {
	["lock"] = {"picklocking_01", 1.5, true},
	["idle"] = {"idle", 5, true}
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
	self:PlayAnim("idle")
end

if SERVER then
	util.AddNetworkString("dbg_lockpick_open")
	util.AddNetworkString("yes")
	util.AddNetworkString("chared")

	function SWEP:Deploy()
		self.Initialzed = true
		self:PlayAnim("idle")
		self:SetHold(self.HoldType)
		return true
	end

	function SWEP:OnRemove()
		return true
	end

	function SWEP:Holster()
		return true
	end

	function SWEP:SetPendingDoor(door)
		self.__pendingDoor = IsValid(door) and door or nil
		self.__pendingDoorTime = CurTime()
	end

	function SWEP:GetPendingDoor()
		if not IsValid(self.__pendingDoor) then return nil end
		if not self.__pendingDoorTime then return nil end
		if CurTime() - self.__pendingDoorTime > 6 then return nil end
		return self.__pendingDoor
	end

	function SWEP:AbortLockpick()
		self.__lockpickSuccess = false
		self.__pendingDoor = nil
		self.__pendingDoorTime = nil
		self.__noBreakUntil = nil
	end

	function SWEP:UnTie(ent)
		local owner = self:GetOwner()
		if IsValid(ent) and (ent:IsRagdoll() or ent:IsPlayer()) then
			if not ( ent.handcuffed or ent:GetNetVar("handcuffed",false) ) then return end

			if ent.handcuffs then
				if IsValid(ent.handcuffs[1]) then ent.handcuffs[1]:Remove() end
				if IsValid(ent.handcuffs[2]) then ent.handcuffs[2]:Remove() end
				ent.handcuffed = false
			end

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

	function SWEP:PrimaryAttack()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
	
		local trace = hg.eyeTrace(owner, self.DistUse)
		if not trace or not trace.Hit or not IsValid(trace.Entity) then return end
	
		local trent = trace.Entity
		local ent = hg.RagdollOwner(trent) or trent
		if not hgIsDoor(ent) and not ent:GetNetVar("handcuffed") then return end
	
		local ok, why = IsLookingNearHandle(owner, ent, self)
		if not ok then
			if why == "no_handle_bone" then
			else
				notif(owner, "Наведи прицел ближе к ручке двери или подойди ближе.", 'fail')
			end
			return
		end
	
		self:AbortLockpick()
		self:SetPendingDoor(ent)
	
		self.__lockpickSuccess = false
		self.__noBreakUntil = CurTime() + (self.NoBreakGrace or 2)
	
		self:PlayAnim("lock")
		self:SetNextPrimaryFire(CurTime() + 1.5)
	
		hook.Run("lockpickStarted", owner)
	
		net.Start("dbg_lockpick_open")
			net.WriteEntity(self)
			net.WriteUInt(tonumber(cfg.lockpickpns), 8)
			net.WriteFloat(tonumber(self.NoBreakGrace) or 2)
		net.Send(owner)
	end

	net.Receive("yes", function(_, ply)
		if ply:GetActiveWeapon():GetClass() ~= "rp_lockpick" then return end
		local trent = hg.eyeTrace(ply).Entity
		local target = hg.RagdollOwner(trent) or trent
		local ent = ply:GetNetVar("handcuffed") and ply or target
		if hgIsDoor(ent) then
			ent:Fire("unlock", "", 0)
		end
		if ent:GetNetVar("handcuffed") then
			ply:GetActiveWeapon():UnTie(ent)
		end
		hook.Run("onLockpickCompleted", ply, true)
	end)

	net.Receive("chared", function(_, ply)
		local wep = net.ReadEntity()
		if not IsValid(ply) or not IsValid(wep) or wep:GetOwner() ~= ply or ply:GetActiveWeapon() ~= wep then return end

		local graceEnd = wep.__noBreakUntil or 0
		if CurTime() < graceEnd then return end

		if wep.AbortLockpick then
			wep:AbortLockpick()
		end

		hook.Run("onLockpickCompleted", ply, false)

		if wep.BreakOnFail and math.random(1, 100) < 50 then
			ply:StripWeapon("rp_lockpick")
		end
	end)
end

if CLIENT then
	local cols = {
		b = Color(65, 132, 209, 255),
		y = Color(240, 202, 77, 255),
		r = Color(222, 91, 73, 255),
		g = Color(102, 170, 170, 255),
		o = Color(170, 119, 102, 255),
		bg = Color(0, 0, 10, 255),
	}

	surface.CreateFont("dbg-lockpick.normal", {
		font = "Calibri",
		extended = true,
		size = 24,
		weight = 350,
	})

	cols.bg95 = Color(cols.bg.r, cols.bg.g, cols.bg.b, 241)
	cols.bg60 = Color(cols.bg.r, cols.bg.g, cols.bg.b, 150)
	cols.bg50 = Color(cols.bg.r / 2, cols.bg.g / 2, cols.bg.b / 2, 255)

	cols.bg_d = Color(70, 54, 70, 255)
	cols.bg_l = Color(cols.bg.r * 1.25, cols.bg.g * 1.25, cols.bg.b * 1.25, 255)
	cols.bg_grey = Color(180, 180, 180, 255)
	cols.g_d = Color(cols.g.r * 0.75, cols.g.g * 0.75, cols.g.b * 0.75, 255)
	cols.r_d = Color(cols.r.r * 0.75, cols.r.g * 0.75, cols.r.b * 0.75, 255)

	cols.hvr = Color(0, 0, 0, 50)
	cols.dsb = Color(255, 255, 255, 50)

	CFG.skinColors = cols

	local function lockpick_push_sound()
		local sndtbl = {1,3,4}
		surface.PlaySound("weapons/357/357_reload" .. table.Random(sndtbl) .. ".wav")
	end

	local function lockpick_failed_sound()
		surface.PlaySound("weapons/crowbar/crowbar_impact" .. math.random(1, 2) .. ".wav")
	end

	local function lockpick_reach_sound()
		surface.PlaySound("weapons/aug/aug_forearm.wav")
	end

	local DBG_LP = DBG_LP or { opened = false, wep = nil, grace = 2, start = 0 }

	local function offlockpick()
		timer.Simple(0.3, function()
			hook.Remove("HUDPaint", "dbg-lockpick")
			hook.Remove("Think", "dbg-lockpick")
			hook.Remove("RenderScreenspaceEffects", "dbg-lockpick")
			hook.Remove("InputMouseApply", "dbg-lockpick")
			hook.Remove("CreateMove", "dbg-lockpick")
			hook.Remove("dbg-view.chPaint", "dbg-lockpick")
			timer.Remove("dbg-lockpick")
			timer.Remove("timer-dbg")
			DBG_LP.opened = false
			if IsValid(DBG_LP.wep) then
				DBG_LP.wep:PlayAnim("idle")
			end
			DBG_LP.wep = nil
		end)
	end

	function vzlom_menu(pinsInput, graceSeconds)
		if DBG_LP.opened then return end
		DBG_LP.opened = true

		DBG_LP.grace = tonumber(graceSeconds) or DBG_LP.grace or 2
		DBG_LP.start = RealTime()

		local function InGrace()
			return (RealTime() - (DBG_LP.start or 0)) < (DBG_LP.grace or 2)
		end

		local pinsCount = tonumber(pinsInput)

		local R = ([[Подними все пины[n]и поверни цилиндр[n][n]Мышь - двигать отмычку[n]ЛКМ - повернуть цилиндр[n]ПКМ - отменить взлом]]):gsub("%[n%]", string.char(10))
		local pinBgColor = Color(150, 150, 150)
		local pinColor = Color(50, 50, 50)
		local h = CFG.skinColors

		local pin = {}
		local pinTime = 0.75
		local pinWidth = 25
		local pinSpace = 40

		local lockpick_Border = pinsCount * pinSpace / 2
		local r_lockpickBorder = -lockpick_Border

		local a = 0
		local n = RealTime()
		local d = true

		for i = 1, pinsCount do
			local px = r_lockpickBorder + (i - 1) * pinSpace + (pinSpace - pinWidth) / 2
			pin[i] = {
				xmin = px,
				xmax = px + pinWidth,
				time = i * pinTime,
				st = 0,
			}
		end

		for i = 1, pinsCount do
			local j = math.random(1, pinsCount)
			pin[i].time, pin[j].time = pin[j].time, pin[i].time
		end

		local function PaintLockPick(x, y)
			x, y = math.floor(x), math.floor(y)
			draw.NoTexture()
			surface.SetDrawColor(150, 150, 150)
			surface.DrawRect(x - 1, y, 4, 8)
			surface.DrawPoly({
				{ x = x - 1,   y = y + 10 },
				{ x = x - 1,   y = y + 6  },
				{ x = x + 201, y = y + 4  },
				{ x = x + 201, y = y + 12 },
			})
			surface.DrawRect(x + 200, y, 100, 16)
		end

		local r = pinsCount * pinSpace
		local scrw, scrh = ScrW(), ScrH()
		local lockBg = Color(255, 255, 255, 10)
		local o = (scrw - r) / 2 - 5
		local _ = scrh / 2 - 110
		local T = r + 10
		local k = 190
		local s = shizlib.surface.s
		local RNDX = include("shizlib/client/rndx_cl.lua")
		local colors = CFG.theme

		hook.Add("HUDPaint", "dbg-lockpick", function()
			RNDX.Draw(8, o, _, T, k, ColorAlpha(colors.bg_alt, 200))

			local c_x = scrw / 2
			local c_y = scrh / 2

			for i = 1, pinsCount do
				local p = pin[i]
				draw.RoundedBox(4, c_x + p.xmin, c_y - 100, pinWidth, 150, pinBgColor)
				draw.RoundedBox(2, c_x + p.xmin + 1, c_y - p.st * 98 - 1, pinWidth - 2, 50, pinColor)
			end

			local e = c_y + 60
			if RealTime() < n then
				e = e - (n - RealTime()) / .3 * 16
			end

			PaintLockPick(c_x + a, e)
			draw.DrawText(R, "dbg-lockpick.normal", c_x + r / 2 + 20, c_y - 95, color_white, TEXT_ALIGN_LEFT)
		end)

		local lastCT = CurTime()
		hook.Add("Think", "dbg-lockpick", function()
			local lp = LocalPlayer()
			if not IsValid(lp) or not lp:Alive() then
				offlockpick()
				return
			end
			if IsValid(DBG_LP.wep) and lp:GetActiveWeapon() ~= DBG_LP.wep then
				offlockpick()
				return
			end

			local now = CurTime()
			local dt = now - lastCT
			lastCT = now

			for i = 1, pinsCount do
				local p = pin[i]
				if p.st > 0 then
					p.st = math.Approach(p.st, 0, dt / p.time)
				end
			end
		end)

		local exploitC = 0
		local exploitX, exploitY = 0, 0
		timer.Create("dbg-lockpick", .5, 0, function()
			if (exploitX ~= 0 and exploitY == 0) or (exploitX == 0 and exploitY ~= 0) then
				exploitC = exploitC + 1
			elseif exploitX ~= 0 or exploitY ~= 0 then
				exploitC = math.max(exploitC - 1, 0)
			end

			if exploitC > 3 then
				offlockpick()
				print("dbg-lockpick.exploit")
			end

			exploitX, exploitY = 0, 0
		end)

		local sensitivity = GetConVar("sensitivity"):GetFloat()
		hook.Add("InputMouseApply", "dbg-lockpick", function(cmdinfo, mouseX, mouseY)
			local p = false

			if RealTime() > n and d then
				a = math.Clamp(a + mouseX * sensitivity / 50, r_lockpickBorder, lockpick_Border)

				if FrameTime() > 0 and (-mouseY / FrameTime() > 3000) then
					local hitPin = nil
					for i = 1, pinsCount do
						local pp = pin[i]
						if a > pp.xmin and a < pp.xmax then
							hitPin = pp
							break
						end
					end

					if not hitPin then
						if InGrace() then
							n = RealTime() + .3
							p = true
						else
							net.Start("chared")
								net.WriteEntity(DBG_LP.wep or LocalPlayer():GetActiveWeapon())
							net.SendToServer()

							lockpick_failed_sound()
							offlockpick()
						end
					else
						hitPin.st = 1
						lockpick_push_sound()
					end

					n = RealTime() + .3
					p = true
				end
			end

			exploitX = exploitX + mouseX
			if math.abs(mouseY) > 1e-4 and not p then
				exploitY = exploitY + mouseY
			end

			cmdinfo:SetMouseX(0)
			cmdinfo:SetMouseY(0)
			return true
		end)
		
		local cooldown = RealTime()
		hook.Add("CreateMove", "dbg-lockpick", function(cmd)
			if not cmd:KeyDown(IN_ATTACK) then
				d = true
			end

			if cmd:KeyDown(IN_ATTACK) and RealTime() > cooldown and d then
				local lockPicked = true
				for i = 1, pinsCount do
					local pp = pin[i]
					if pp.st <= 0 then
						lockPicked = false

						if InGrace() then
							cooldown = RealTime() + .35
						else
							net.Start("chared")
								net.WriteEntity(LocalPlayer():GetActiveWeapon())
							net.SendToServer()

							lockpick_failed_sound()
							offlockpick()
						end

						break
					end
				end

				if lockPicked then
					offlockpick()
					lockpick_reach_sound()

					net.Start("yes")
						net.WriteEntity(LocalPlayer():GetActiveWeapon())
					net.SendToServer()

					hook.Remove("Think", "dbg-lockpick")
					hook.Remove("CreateMove", "dbg-lockpick")
				end

				cooldown = RealTime() + .5
			end

			if cmd:KeyDown(IN_ATTACK2) then
				timer.Simple(0.1, function()
					hook.Remove("HUDPaint", "dbg-lockpick")
					hook.Remove("Think", "dbg-lockpick")
					hook.Remove("RenderScreenspaceEffects", "dbg-lockpick")
					hook.Remove("InputMouseApply", "dbg-lockpick")
					hook.Remove("CreateMove", "dbg-lockpick")
					hook.Remove("dbg-view.chPaint", "dbg-lockpick")
					timer.Remove("dbg-lockpick")
				end)
				DBG_LP.opened = false
				if IsValid(DBG_LP.wep) then
					DBG_LP.wep:PlayAnim("idle")
				end
				DBG_LP.wep = nil
			end

			cmd:RemoveKey(IN_ATTACK)
			cmd:RemoveKey(IN_ATTACK2)
			cmd:ClearMovement()
		end)

		local blurMaterial = Material("pp/blurscreen")
		hook.Add("RenderScreenspaceEffects", "dbg-lockpick", function()
			local blurAmount = .89
			if blurAmount > 0 then
				surface.SetDrawColor(0, 0, 0, blurAmount * 255)
				surface.SetMaterial(blurMaterial)
				for i = 1, 3 do
					blurMaterial:SetFloat("$blur", blurAmount * i * 2)
					blurMaterial:Recompute()
					render.UpdateScreenEffectTexture()
					surface.DrawTexturedRect(-1, -1, ScrW() + 2, ScrH() + 2)
				end

				local ob = h.bg
				draw.NoTexture()
				surface.SetDrawColor(ob.r, ob.g, ob.b, blurAmount * 100)
				surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
			end
		end)
	end

	net.Receive("dbg_lockpick_open", function()
		local wep = net.ReadEntity()
		local pins = net.ReadUInt(8)

		local grace = 2
		if net.BytesLeft and net.BytesLeft() >= 4 then
			grace = net.ReadFloat()
		end

		if not IsValid(wep) then
			wep = LocalPlayer():GetActiveWeapon()
		end

		DBG_LP.wep = wep
		vzlom_menu(pins, grace)
	end)
end
local pmeta = FindMetaTable('Player')

function pmeta:IsHandcuffed()
	return self:GetNetVar('handcuffed', false)
end

hook.Add('StartCommand', 'cuffs.drag', function(ply, cmd)
	local cuffed = ply:IsHandcuffed()
	if cuffed and IsValid(ply:GetNetVar('dragger')) then
		local cop = ply:GetNetVar('dragger')

		local pos = cop:EyePos() + cop:GetAimVector() * 50
		local dirFwd = ply:GetAimVector()
		local dirTgt = pos - ply:GetPos()
		local dist = dirTgt:Length2DSqr()
		if SERVER and dist > 100000 then
			ply:SetNetVar('dragger', nil)
			ply:SetNetVar('dragging', nil)
		end

		cmd:ClearMovement()

		local ang = ply.lastEyeAngles or ply:EyeAngles()
		ang.p = cmd:GetViewAngles().p
		local targetAng = cop:EyeAngles()
		targetAng.p = ang.p
		ang = LerpAngle(FrameTime() * 2, ang, targetAng)
		ply.lastEyeAngles = ang
		cmd:SetViewAngles(ang)
		cmd:SetButtons(0)
		if SERVER and cop:KeyDown(IN_JUMP) then
			cmd:SetButtons(IN_JUMP)
		end

		if dist > 50 then
			dirFwd.z = 0
			dirTgt.z = 0
			dirFwd:Normalize()
			dirTgt:Normalize()
			local dirSid = Vector(dirFwd.x, dirFwd.y, 0)
			dirSid:Rotate(Angle(0, 90, 0))

			cmd:SetForwardMove(dirFwd:Dot(dirTgt) * math.min(250, dist))
			cmd:SetSideMove(-dirSid:Dot(dirTgt) * math.min(75, dist))
		end
	end
end)


local function cancelDrag(cop, crim)
	if IsValid(crim) then
        if SERVER then
			crim:SetNetVar('dragger', nil)
        end
	end
	if IsValid(cop) then
        if SERVER then
			cop:SetNetVar('dragging', nil)
        end
		if SERVER then
			hg.SetCarryEnt2(cop)
		end
		cop.dragging = nil
	end
end

local noDragWeps = {['weapon_physgun'] = true, ['med_kit'] = true}

hook.Add('KeyPress', 'cuffs.drag', function(ply, key)
	if key ~= IN_ATTACK2 then return end
	if ply:InVehicle() or ply:IsHandcuffed() then return end
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and noDragWeps[wep:GetClass()] then return end

	local tgt = hg.eyeTrace(ply).Entity
	if not (IsValid(tgt) and tgt:IsPlayer() and tgt:IsHandcuffed()) then return end
	if IsValid(tgt:GetNetVar('dragger')) or IsValid(ply:GetNetVar('dragging')) then return end

    if SERVER then
	tgt:SetNetVar('dragger', ply)
	ply:SetNetVar('dragging', tgt)
    end
	
	local bone = 0
	local phys = tgt:GetPhysicsObject()
	--local mass = phys:GetMass()
	local carrypos = Vector(0, 10, 50)
	local targetpos = ply:GetAimVector() * 10 + ply:EyePos()
	if SERVER then
		hg.SetCarryEnt2(ply, tgt, bone, 0, carrypos, targetpos)
	end
end)

hook.Add('KeyRelease', 'cuffs.drag', function(ply, key)
	if key == IN_ATTACK2 and IsValid(ply:GetNetVar('dragging')) then
		cancelDrag(ply, ply:GetNetVar('dragging'))
	end
end)

if SERVER then
	hook.Add('PlayerDisconnected', 'cuffs.drag', function(ply)
		if IsValid(ply:GetNetVar('dragging')) then
			cancelDrag(ply, ply:GetNetVar('dragging'))
		end
		if IsValid(ply:GetNetVar('dragger')) then
			cancelDrag(ply:GetNetVar('dragger'), ply)
		end
	end)
end

if CLIENT then
	hook.Add('FindUseEntity', 'cuffs.drag', function(ply, ent)
		if not IsValid(ent) or ply:GetNetVar('dragging') then
			local traceEnt = util.TraceLine({
				start = ply:GetShootPos(),
				endpos = ply:GetShootPos() + ply:GetAimVector() * 72,
				filter = {ply, ply:GetNetVar('dragging')},
			}).Entity
			if IsValid(traceEnt) then return traceEnt end
		end
		return ent
	end)
end
include "sh_init.lua"
include "cl_maths.lua"
include "cl_panel.lua"

local mat = CreateMaterial("aeypad_baaaaaaaaaaaaaaaaaaase", "VertexLitGeneric", {
	["$basetexture"] = "white",
	["$color"] = "{ 36 36 36 }",
})

function ENT:Draw()
	render.SetMaterial(mat)

	render.DrawBox(self:GetPos(), self:GetAngles(), self.Mins, self.Maxs, color_white, true)

	local pos, ang = self:CalculateRenderPos(), self:CalculateRenderAng()

	local w, h = self.Width2D, self.Height2D
	local x, y = self:CalculateCursorPos()

	local scale = self.Scale -- A high scale avoids surface call integerising from ruining aesthetics

	cam.Start3D2D(pos, ang, self.Scale)
		self:Paint(w, h, x, y)
		if self:GetHacked() != nil then
			draw.SimpleText(self:GetHacked(), "Prn_Main", w-180, h - 480, Color(255,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end

function ENT:SendCommand(command, data)
	net.Start("huygad")
		net.WriteEntity(self)
		net.WriteUInt(command, 4)

		if data then
			net.WriteUInt(data, 8)
		end
	net.SendToServer()
end

hook.Add("PlayerBindPress", "Keypad", function(ply, bind, pressed)
	if not pressed then
		return
	end

	local tr = hg.eyeTrace(ply)

	local ent = tr.Entity

	if not IsValid(ent) or not ent.IsKeypad then
		return
	end

	if string.find(bind, "+use", nil, true) then
		local element = ent:GetHoveredElement()

		if not element or not element.click then
			return
		end

		element.click(ent)
	end
end)


local physical_keypad_commands = {
	[KEY_ENTER] = function(self)
		self:SendCommand(self.Command_Accept)
	end,

	[KEY_PAD_ENTER] = function(self)
		self:SendCommand(self.Command_Accept)
	end,

	[KEY_PAD_MINUS] = function(self)
		self:SendCommand(self.Command_Abort)
	end,

	[KEY_PAD_PLUS] = function(self)
		self:SendCommand(self.Command_Abort)
	end
}

for i = KEY_PAD_1, KEY_PAD_9 do
	physical_keypad_commands[i] = function(self)
		self:SendCommand(self.Command_Enter, i - KEY_PAD_1 + 1)
	end
end

local last_press = 0

local enter_strict = CreateConVar("keypad_willox_enter_strict", "0", FCVAR_ARCHIVE, "Only allow the numpad's enter key to be used to accept keypads' input")

hook.Add("CreateMove", "Keypad", function(cmd)
	if RealTime() - 0.1 < last_press then
		return
	end

	for key, handler in pairs(physical_keypad_commands) do
		if input.WasKeyPressed(key) then

			if enter_strict:GetBool() and key == KEY_ENTER then
				continue
			end

			local ply = LocalPlayer()

			-- local tr = util.TraceLine({
			-- 	start = ply:EyePos(),
			-- 	endpos = ply:EyePos() + ply:GetAimVector() * 65,
			-- 	filter = ply
			-- })
			local tr = hg.eyeTrace(ply)

			local ent = tr.Entity

			if not IsValid(ent) or not ent.IsKeypad then
				return
			end

			last_press = RealTime()
			handler(ent)
			return
		end
	end
end)
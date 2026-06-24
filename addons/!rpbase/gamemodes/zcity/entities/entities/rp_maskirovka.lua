ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.PrintName = "Шкафчик"
ENT.Category = "RP"

ENT.Spawnable = true
ENT.AdminOnly = true

if SERVER then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel( "models/props_c17/Lockers001a.mdl" )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		self:GetPhysicsObject():EnableMotion( false )
	end

	function ENT:SpawnFunction( pl, trace, class )
		local ent = ents.Create( class )
		ent:SetPos( trace.HitPos + trace.HitNormal * 16 )
		ent:Spawn()

		return ent
	end

	function ENT:Use( pl )
		if not IsValid( pl ) then return end
		if self:GetPos():Distance(pl:GetPos()) > CFG.useDist then return end
		if !CanUseDisguise(pl:GetPlayerClass()) then return end

		netstream.Start(pl, "rp_maskirovka_choose")
	end

	netstream.Hook("rp_maskirovka_choose", function(ply, data)
		local idx = data.idx
		local plyclass = ply:GetPlayerClass()
		if idx < 1 or idx > 2 then return end
		local flag = false
		for _, e in pairs(ents.FindInSphere(ply:GetPos(), CFG.useDist)) do
			if e:GetClass() ~= "rp_maskirovka" then continue end
			flag = true
		end
		if !CanUseDisguise(ply:GetPlayerClass()) then return end
		if not flag then
			return
		end

		if idx == 1 then
			ply.armors = {}
			ply:SyncArmor()
			ApplyAppearance(ply,nil,nil,nil,true)
			notif(ply, "Вы переоделись в штатскую одежду!")
		elseif idx == 2 then
			local clr = plyclass.Color:ToVector()
			local model = plyclass.Model[math.random(1, #plyclass.Model)]
			ply:SetModel(model)
			ply:SetNetVar("Accessories", "none")
			ply:SetBodyGroups("000000000000000000")
			ply:SetSubMaterial()
			ply:SetPlayerColor(clr)
			ply.armors = {}
			ply:SyncArmor()
			for _, eq in ipairs(plyclass.Equipment or {}) do
				hg.AddArmor(ply, eq)
			end
			
			timer.Simple(0, function()
				if plyclass.Bodygroups then
					ply:SetBodyGroups( plyclass.Bodygroups )
				end
				if (ply.CachedAppearance and ply.CachedAppearance["AName"] or ply.CurAppearance["AName"]) ~= ply:Nick() then
					ply:SetNWString("PlayerName", ply.CachedAppearance and ply.CachedAppearance["AName"] or ply.CurAppearance["AName"])
				end
			end)
		end
	end)
else
	netstream.Hook("rp_maskirovka_choose", function()
		local tbl = {}
		tbl[#tbl + 1] = {function()
			netstream.Start("rp_maskirovka_choose", {idx = 1})
		end, "Одеть штатскую одежду"}
		tbl[#tbl + 1] = {function()
			netstream.Start("rp_maskirovka_choose", {idx = 2})
		end, "Одеть служебную форму"}
		hg.CreateRadialMenu(tbl)
		-- local opts = {
		-- 	{
		-- 		"Одеть штатскую одежду",
		-- 		"shizlib/icon17/64/textile.png",
		-- 		function()
		-- 			netstream.Start("rp_maskirovka_choose", {idx = 1})
		-- 		end,
		-- 	},
		-- 	{
		-- 		"Одеть служебную форму",
		-- 		"shizlib/icon17/64/textile.png",
		-- 		function()
		-- 			netstream.Start("rp_maskirovka_choose", {idx = 2})
		-- 		end,
		-- 	}
		-- }

		-- shizlib.circularMenu(opts)
	end)

	local color_white = Color(255, 255, 255)
	local color_black = Color(0, 0, 0)
	local complex_off = Vector(0, 0, 9)

	function ENT:CalculateRenderPos()
		local vec = self:GetAngles():Forward() * 9 + self:GetAngles():Right() * -1 + self:GetAngles():Up() * 20
		local pos = self:GetPos() + vec
		return pos
	end

	function ENT:CalculateRenderAng()
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Forward(), 90)
		return ang
	end

	function ENT:Draw()
		self:DrawModel()

		local pos, ang = self:CalculateRenderPos(), self:CalculateRenderAng()
		local dist = LocalPlayer():GetPos():Distance(self:GetPos())
		local inView = dist <= 500
		if not inView then return end

		local alpha = 255 - (dist / 2)
		color_white.a = alpha
		color_black.a = alpha

		local x = math.sin(CurTime() * math.pi) * 0
	
		cam.Start3D2D(pos, ang, 0.03)
			draw.SimpleTextOutlined('Шкаф', '3d2d', 0, x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		cam.End3D2D()
	end
end
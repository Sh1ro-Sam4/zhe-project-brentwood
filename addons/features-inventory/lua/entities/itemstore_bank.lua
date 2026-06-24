ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.PrintName = "Банк"
ENT.Category = "SHZ | ItemStore"

ENT.Spawnable = true
ENT.AdminOnly = true

if SERVER then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel( "models/props_wasteland/controlroom_storagecloset001a.mdl" )

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

	local entity = nil

	function ENT:Use( pl )
		if not IsValid( pl ) then return end
		if self:GetPos():Distance(pl:GetPos()) > CFG.useDist then return end

		entity = self
		netstream.Start(pl, "itemstore_bank_choose")
	end

	netstream.Hook("itemstore_bank_choose", function(ply, data)
		local idx = data.idx
		if idx < 1 or idx > 2 then return end
		-- local ent = ents.FindByClass("itemstore_bank")[1]
		-- if ent:GetPos():Distance(ply:GetPos()) > CFG.useDist then return end
		local flag = false
		for _, e in pairs(ents.FindInSphere(ply:GetPos(), CFG.useDist)) do
			if e:GetClass() ~= "itemstore_bank" then continue end
			flag = true
		end
		if not flag then
			return
		end

		if idx == 1 then
			if IsSWAT(ply:GetPlayerClass()) then return end
			ply:DelayedAction('ApplyAppearance', 'Переодеваюсь', {
				time = 3,
				check = function() 
					if entity:GetPos():Distance(ply:GetPos()) > CFG.useDist then return false end
					return true 
				end,
				succ = function()
					ApplyAppearance(ply,nil,nil,nil,true)
					notif(ply, "Вы переоделись!")
				end,
			}, {
				time = 1.5,
				inst = true,
				action = function()
					ply:DoAnimationEvent((ACT_GMOD_GESTURE_ITEM_GIVE + math.random(0,1)))
					ply:EmitSound("player/clothes_generic_foley_0" .. math.random(1,5) .. ".wav")
				end,
			})
		elseif idx == 2 then
			ply.Bank:Sync()
			ply:OpenContainer( ply.Bank:GetID(), itemstore.Translate( "bank" ) )
		end
	end)

	concommand.Add( "itemstore_savebanks", function( pl )
		if not game.SinglePlayer() and IsValid( pl ) then return end

		local banks = {}

		for _, ent in ipairs( ents.FindByClass( "itemstore_bank" ) ) do
			table.insert( banks, {
				Position = ent:GetPos(),
				Angles = ent:GetAngles()
			} )
		end

		file.Write( "itemstore/banks/" .. game.GetMap() .. ".txt", util.TableToJSON( banks ) )

		print( "Banks for map " .. game.GetMap() .. " saved." )
	end )

	hook.Add( "InitPostEntity", "ItemStoreSpawnBanks", function()
		local banks = util.JSONToTable( file.Read( "itemstore/banks/" .. game.GetMap() .. ".txt", "DATA" ) or "" ) or {}

		for _, data in ipairs( banks ) do
			local bank = ents.Create( "itemstore_bank" )
			bank:SetPos( data.Position )
			bank:SetAngles( data.Angles )
			bank:Spawn()
		end
	end )
else
	netstream.Hook("itemstore_bank_choose", function()
		-- local opts = {
		-- 	{
		-- 		"Поменять одежду",
		-- 		"shizlib/icon17/64/textile.png",
		-- 		function()
		-- 			netstream.Start("itemstore_bank_choose", {idx = 1})
		-- 		end,
		-- 	},
		-- 	{
		-- 		"Открыть банк",
		-- 		"shizlib/icon17/64/workbench.png",
		-- 		function()
		-- 			netstream.Start("itemstore_bank_choose", {idx = 2})
		-- 		end,
		-- 	}
		-- }

		-- shizlib.circularMenu(opts)
		local tbl = {}
		tbl[#tbl + 1] = {function()
			netstream.Start("itemstore_bank_choose", {idx = 1})
		end, "Поменять одежду"}
		tbl[#tbl + 1] = {function()
			netstream.Start("itemstore_bank_choose", {idx = 2})
		end, "Открыть банк"}
		hg.CreateRadialMenu(tbl)
	end)

	function ENT:Draw()
		self:DrawModel()
		local Pos = self:GetPos() + Vector(0, 0, 1) * math.sin(CurTime() * 1) * 1
		local PlayersAngle = LocalPlayer():GetAngles()
		local Ang = Angle( 0, PlayersAngle.y - 180, 0 )
		Ang:RotateAroundAxis(Ang:Right(), -90)
		Ang:RotateAroundAxis(Ang:Up(), 90)
	end
end
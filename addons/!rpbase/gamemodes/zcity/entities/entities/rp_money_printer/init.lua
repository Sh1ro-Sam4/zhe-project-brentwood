AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString( "open_printer_menu" )
util.AddNetworkString( "printer_on_off" )
util.AddNetworkString( "printer_update_speed" )
util.AddNetworkString( "printer_update_hp" )
util.AddNetworkString( "printer_update_max" )

function ENT:Initialize()
	self:SetModel('models/stromic/money_printer.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()

	self:SetMaxInk(15)
	self:SetInk(15)
	self:SetHP(100)
	self:SetLastPrint(CurTime())

	self:SetUD_Speed(1)
	self:SetUD_Max(1)
	self:SetUD_HP(1)
	self:SetMoneyInMe(0)
	self:SetEnabled(true)
	self:SetSkin(1)

	self:EmitSound("ambient/levels/labs/equipment_printer_loop1.wav", 55, 100, 1)

	timer.Create(self:EntIndex() .. 'Print', 120 / self:GetUD_Speed(), 0, function()
		if not IsValid(self) then timer.Destroy(self:EntIndex() .. 'Print') return end
		self:PrintMoney()
	end)
end

	netstream.Hook("imperator_printer_choose", function(ply, data)
		local idx = data.idx
		if idx < 1 or idx > 2 then return end
		-- local ent = ply:GetEyeTrace().Entity
		local ent = hg.eyeTrace(ply).Entity
		if IsValid(ent) and string.find(ent:GetClass(), "rp_money_printer") then
			if idx == 1 then
				if timer.Exists("Printer_CD_"..ent:EntIndex()) then return end
				timer.Create("Printer_CD_"..ent:EntIndex(),1,1, function() end)
				if ent:GetEnabled() then
					ent:SetEnabled(false)
					ent:SetSkin(0)
					ent:StopSound("ambient/levels/labs/equipment_printer_loop1.wav")
					timer.Remove(ent:EntIndex() .. 'Print')
					DarkRP.notify( ply, 0, 5, "Денежный принтер был отключен" )
				else
					ent:SetEnabled(true)
					ent:SetSkin(1)
					ent:SetLastPrint(CurTime())
					ent:EmitSound("ambient/levels/labs/equipment_printer_loop1.wav", 55, 100, 1)
				
					timer.Create(ent:EntIndex() .. 'Print', 120 / ent:GetUD_Speed(), 0, function()
						if not IsValid(ent) then timer.Destroy(ent:EntIndex() .. 'Print') return end
						ent:PrintMoney()
					end)
					DarkRP.notify( ply, 0, 5, "Денежный принтер был включен" )
				end
			elseif idx == 2 then
				--ply.Bank:Sync()
				--ply:OpenContainer( ply.Bank:GetID(), itemstore.Translate( "bank" ) )
				if ent:GetMoneyInMe() == 0 then return end
				ply:AddMoney(ent:GetMoneyInMe())
				DarkRP.notify( ply, 0, 5, "Вы получили "..ent:GetMoneyInMe().."$" )
				ent:SetMoneyInMe(0)
			end
		end
	end)

function ENT:Use(ply)
	--if timer.Exists("Printer_CD_"..self:EntIndex()) then return end
	--timer.Create("Printer_CD_"..self:EntIndex(),1,1, function() end)
	--if self:GetEnabled() then
	--	self:SetEnabled(false)
	--	self:SetSkin(0)
	--	self:StopSound("ambient/levels/labs/equipment_printer_loop1.wav")
	--	timer.Remove(self:EntIndex() .. 'Print')
	--	DarkRP.notify( ply, 0, 5, "Денежный принтер был отключен" )
	--else
	--	self:SetEnabled(true)
	--	self:SetSkin(1)
	--	self:SetLastPrint(CurTime())
	--	self:EmitSound("ambient/levels/labs/equipment_printer_loop1.wav", 55, 100, 1)
--
	--	timer.Create(self:EntIndex() .. 'Print', 120 / self:GetUD_Speed(), 0, function()
	--		if not IsValid(self) then timer.Destroy(self:EntIndex() .. 'Print') return end
	--		self:PrintMoney()
	--	end)
	--	DarkRP.notify( ply, 0, 5, "Денежный принтер был включен" )
	--end
	netstream.Start(ply, "imperator_printer_used")
	--if pl != imper() then return end
	--	net.Start( "open_printer_menu" )
	--	net.Send(pl)
	--if (self:GetInk() >= self:GetMaxInk()) then
	--	DarkRP.notify(pl, 1, 7, "Денежный принтер полон чернил")
	--	return
	--end
--
	--local cost = ((self:GetMaxInk() - self:GetInk()) * 40)
--
	--if not pl:CanAfford(cost) then
	--	DarkRP.notify( pl, 0, 5, "Вы не можете себе это позволить это стоит " ..cost.. "$" )
	--	return
	--end
--
	--pl:AddMoney(-cost)
	--self:SetInk(self:GetMaxInk())
	--DarkRP.notify( pl, 0, 5, "Денежный принтер заправлен за " ..cost.. "$" )
	--sound.Play( "buttons/button15.wav", self:GetPos(), 100, 100, 1 )
end
--timer.Remove("Printer_CD_"..self:EntIndex())
net.Receive( "printer_on_off", function( len, ply )
	
	local printer =  hg.eyeTrace(ply).Entity
	if printer:GetClass() != "rp_money_printer" then return end
	local self = printer
	--timer.Remove("Printer_CD_"..self:EntIndex())
	if timer.Exists("Printer_CD_"..self:EntIndex()) then return end
	timer.Create("Printer_CD_"..self:EntIndex(),1,1, function() end)
	if self:GetEnabled() then
		self:SetEnabled(false)
		self:StopSound("ambient/levels/labs/equipment_printer_loop1.wav")
		timer.Remove(self:EntIndex() .. 'Print')
		DarkRP.notify( ply, 0, 5, "Денежный принтер был отключен" )
	else
		self:SetEnabled(true)
		self:SetLastPrint(CurTime())
		self:EmitSound("ambient/levels/labs/equipment_printer_loop1.wav", 55, 100, 1)

		timer.Create(self:EntIndex() .. 'Print', cfg.printdelay, 0, function()
			if not IsValid(self) then timer.Destroy(self:EntIndex() .. 'Print') return end
			self:PrintMoney()
		end)
		DarkRP.notify( ply, 0, 5, "Денежный принтер был включен" )
	end
end)

function ENT:OnRemove()
	self:StopSound("ambient/levels/labs/equipment_printer_loop1.wav")
end

function ENT:OnTakeDamage(damageData)
	self:SetHP(self:GetHP() - damageData:GetDamage())

	if (self:GetHP() <= 0) then
		self:Explode()
	end
end

function ENT:Explode()
	timer.Destroy(self:EntIndex() .. 'Print')
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect('Explosion', effectdata)

	self:Remove()
end

function ENT:PrintMoney()
	if (self:GetInk() <= 0) and (self:GetHP() > 0) then
		self:SetLastPrint(CurTime())
		self:SetHP(math.Clamp(self:GetHP() - 5, 0, 100))
	elseif (self:GetHP() <= 0) then
		self:Explode()
	else
		self:SetLastPrint(CurTime())
		self:SetInk(self:GetInk() - 1)

		--local effectdata = EffectData()
		--effectdata:SetOrigin(self:GetPos())
		--effectdata:SetMagnitude(1)
		--effectdata:SetScale(1)
		--effectdata:SetRadius(2)
		--util.Effect('Sparks', effectdata)

		--local amount = (hook.Call('calcPrintAmount', GAMEMODE, cfg.printamount) or cfg.printamount)
		--local money = rp.SpawnMoney(self:GetPos() + ((self:GetAngles():Up() * 15) + (self:GetAngles():Forward() * 20)), amount)
		--if IsValid(money) then
		--	money.PrinterMoney = true
		--end
		self:SetMoneyInMe(self:GetMoneyInMe() + math.random(50,100))
	end
end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/oildrum001.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:SetHP(opium.ahshop.BarrelHealth)
end

function ENT:OnTakeDamage( dmg )
	self:SetHP( ( self:GetHP() or 100 ) - dmg:GetDamage() )
    if ( self:GetHP() <= 0 ) then
		self:Remove()
  	end
end

function ENT:StartTouch( ent )

	if !self:GetCooked()  then
		if ent:GetClass() == "the_opium_water" then
			if !(self:Getwater() >= 100) then
				self:Setwater(self:Getwater() + 10)
				ent:Remove()
			end
		elseif ent:GetClass() == "the_opium_sulfate" then
			if !(self:Getsulfate() >= 100) then
				self:Setsulfate(self:Getsulfate() + 2)
				ent:Remove()
			end
		elseif ent:GetClass() == "the_opium_codeine" then
			if !(self:Getcodeine() >= 100) then
				self:Setcodeine(self:Getcodeine() + 2)	
				ent:Remove()
			end
		elseif ent:GetClass() == "the_opium_papaverine" then
			if !(self:Getpapaverine() >= 100) then
				self:Setpapaverine(self:Getpapaverine() + 4)
				ent:Remove()
			end
		end
	else
		if ent:GetClass() == "the_opium_bottle" and !ent:GetCooked() and !(self:Getbottle() >= 10) then

			local cod = self:Getcodeine()
			local pap = self:Getpapaverine()
			local sul = self:Getsulfate()
			local war = self:Getwater()

			self:Setbottle(self:Getbottle() + 1)
			if (self:Getbottle() >= 10) then
				self:Setcodeine(0)
				self:Setpapaverine(0)
				self:Setsulfate(0)
				self:Setwater(0)
				self:SetCookTime(0)
				self:Setbottle(0)
				self:SetCooked(false)
				self:SetColor(Color(255,255,255))
			end
			if ( war > -1 and war <= 20 ) and ( sul > -1 and sul <= 8 ) and ( pap > 10 and pap <= 22 ) and ( cod > 1 and cod <= 22 ) then 
				ent:SetValue("Premium")
				ent:SetCooked(true)
				ent:SetColor(Color(0,255,0))
			elseif ( war > 30 and war <= 50 ) and ( sul > 10 and sul <= 25 ) and ( pap > 2 and pap <= 10 ) and ( cod > 22 and cod <= 40 ) then
				ent:SetValue("Medium")
				ent:SetCooked(true)
				ent:SetColor(Color(0,255,0))
			else
				ent:SetValue("Low")
				ent:SetCooked(true)
				ent:SetColor(Color(0,255,0))
			end
		end
	end
end


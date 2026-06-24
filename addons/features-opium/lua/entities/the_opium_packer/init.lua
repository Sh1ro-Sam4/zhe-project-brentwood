AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube075x1x075.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:SetHP(opium.ahshop.PackerHealth)
	self:SetColor(opium.ahshop.PackerColor)
end

function ENT:Use( ply, ent )
	if ( ( self.lastUsed or CurTime() ) <= CurTime() ) then
		self.lastUsed = CurTime() + 0.25

		if (self:Getbottle() >= 5) then
			local pack = ents.Create( "the_opium_packed" )
			if ( !IsValid( pack ) ) then return end
			pack:SetPos( self:GetPos() + self:GetUp() * 40 )
			pack:Setprice(self:Getprice())
			pack:Spawn()
			self:Setbottle(0)
			self:Setprice(0)
		end
	end
end

function ENT:OnTakeDamage( dmg )
	self:SetHP( ( self:GetHP() or 100 ) - dmg:GetDamage() )
    if ( self:GetHP() <= 0 ) then
		self:Remove()
  	end
end

function ENT:StartTouch( ent )
	if ent:GetClass() == "the_opium_bottle" and ent:GetCooked() then
		if ent.placed then return end
		ent.placed = true
		if !(self:Getbottle() >= 5) then
			if ent:GetValue() == "Low" then
				self:Setprice(self:Getprice() + opium.ahshop.LowOpiumPrice)
			elseif ent:GetValue() == "Medium" then
				self:Setprice(self:Getprice() + opium.ahshop.mediumOpiumPrice)
			elseif ent:GetValue() == "Premium" then
				self:Setprice(self:Getprice() + opium.ahshop.PremiumOpiumPrice)
			end
			self:Setbottle(self:Getbottle() +1)
			ent:Remove()	
		end
	end
end
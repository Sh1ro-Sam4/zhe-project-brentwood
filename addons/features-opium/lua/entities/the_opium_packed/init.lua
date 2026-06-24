AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/cardboard_box001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:SetHP(opium.ahshop.PackedHealth)
end

function ENT:Use( ply )
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if ( ( self.lastUsed or CurTime() ) <= CurTime() )  then
		self.lastUsed = CurTime() + 0.25	
		if ( opium.ahshop.SellOpiumWithoutNpc )then
			ply:AddMoney( self:Getprice() )
			ply:ChatPrint("Спасибо вот твои деньги $"..self:Getprice())
			self:Remove()	
		else
			ply.OpiumPrice = (ply.OpiumPrice or 0) + self:Getprice()
			ply:Notify("Вы подобрали коробку опиума стоимостью " .. shizlib.FormatMoney(self:Getprice()))
			self:Remove()
		end
	end	
end

function ENT:OnTakeDamage( dmg )
	self:SetHP( ( self:GetHP() or 100 ) - dmg:GetDamage() )
    if ( self:GetHP() <= 0 ) then
		self:Remove()
  	end
end

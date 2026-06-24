AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube075x075x025.mdl")
	self:SetMaterial( "phoenix_storms/concrete0" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:SetHealth(opium.ahshop.HeaterHealth)
	self.GasAmount = 0
	self:SetColor(opium.ahshop.HeaterColor)
	self.CookSound = CreateSound(self,opium.ahshop.HeaterSound)
end

function ENT:OnTakeDamage( dmg )
	self:SetHealth( ( self:GetHealth() or 100 ) - dmg:GetDamage() )
    if ( self:GetHealth() <= 0 ) then
		self:Destruct()
		self:Remove()
    end   	
end

function ENT:Destruct()
    local vPoint = self:GetPos()
    local effectdata = EffectData()
    effectdata:SetStart(vPoint)
    effectdata:SetOrigin(vPoint)
    effectdata:SetScale(1)
    util.Effect("Explosion", effectdata) 
end

function ENT:StartTouch( ent )
	if ent:GetClass() == "the_opium_gas" then
	
		if self.GasAmount == 0 then
			self.GasAmount = ( self.GasAmount + 1 )
			self:SetGas(self:GetGas() + 50)
			self.gas = ents.Create( "prop_dynamic" )
			if ( !IsValid( self.gas ) ) then return end
			self.gas:SetModel( "models/props_junk/propane_tank001a.mdl" )
			self.gas:PhysicsInit( SOLID_VPHYSICS )
			self.gas:SetParent( self )
			self.gas:SetPos( Vector(-22, 6, 12) )
			self.gas:SetAngles( self:GetAngles() )
			self.gas:Spawn()
			ent:Remove()			
		elseif self.GasAmount == 1 then
			self.GasAmount = ( self.GasAmount + 1 )
			self:SetGas(self:GetGas() + 50)
			self.gas1 = ents.Create( "prop_dynamic" )
			if ( !IsValid( self.gas1 ) ) then return end
			self.gas1:SetModel( "models/props_junk/propane_tank001a.mdl" )
			self.gas1:PhysicsInit( SOLID_VPHYSICS )
			self.gas1:SetParent( self )
			self.gas1:SetPos( Vector(-22, -6, 12) )
			self.gas1:SetAngles( self:GetAngles() )
			self.gas1:Spawn()
			ent:Remove()
		end
		
	elseif ent:GetClass() == "the_opium_barrel" then
	
		-- No point of recalling.
		local cok = ent:GetCooking()
		local coc = ent:GetCooked()
		local cod = ent:Getcodeine()
		local pap = ent:Getpapaverine()
		local sul = ent:Getsulfate()
		local war = ent:Getwater()
		local gas = self:GetGas()
		
		if coc or cok or cod <= 0 or pap <= 0 or sul <= 0 or war <= 0 or gas <= 0 then return end
	
		self.CookSound:Play()
		self:SetCooking(true)
		ent:SetCooking(true)
		
		timer.Create( "simple_opium_boil"..self:EntIndex(), 1, 0, function()

			if self:GetGas() <= 0 then
				timer.Remove( "simple_opium_boil"..self:EntIndex() )
				self.CookSound:Stop()
				self:SetCooking(false)
				ent:SetCooking(false)
				self:SetGas(0)
				return
			end		
			
			if (ent:GetCooked()) then
				timer.Remove( "simple_opium_boil"..self:EntIndex() )
				self.CookSound:Stop()
				self:SetCooking(false)
				ent:SetCooking(false)
				return			
			end

			ent:SetCookTime(ent:GetCookTime() + 2)
			self:SetGas(self:GetGas() - 1)

			if self:GetGas() <= 0 then
				if IsValid( self.gas ) then 
					self.gas:Remove()
					self.GasAmount = 0
				end					
			elseif self:GetGas() <= 50 then	
				if IsValid( self.gas1 ) then 
					self.gas1:Remove()
					self.GasAmount = 1
				end		
			end
			
			if (ent:GetCookTime() >= opium.ahshop.HeaterCookTime) and (math.random(1,4) == 1) then
				ent:SetCooked(true)
				self:SetCooking(false)
				ent:SetCooking(false)
				ent:SetColor(Color(0,255,0))
				ent:SetPremium(cod + pap + sul + war + math.random(1,55))
			end
			
		end)
	end
end

function ENT:EndTouch( ent ) 
	if ( ( self.lastUsed or CurTime() ) <= CurTime() ) then
		self.lastUsed = CurTime() + 0.25
		if ent:GetClass() == "the_opium_barrel" then
			self.CookSound:Stop()
			self:SetCooking(false)
			ent:SetCooking(false)
			timer.Remove( "simple_opium_boil"..self:EntIndex() )
		end 
	end
end









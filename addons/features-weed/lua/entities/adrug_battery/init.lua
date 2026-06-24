AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 

include( 'shared.lua' )

local SOUND_ON = "items/ammo_pickup.wav"
local SOUND_OFF = ""
local SOUND_DEAD = ""

local dischargeRate = 1.2

local powerableEnts = {"adrug_heat_lamp"}

function ENT:SetupDataTables()
 
	self:NetworkVar( "Bool", 0, "IsBatOn" )
	self:NetworkVar( "Int", 1, "BatLevel" )
	self:NetworkVar( "Int", 2, "ConnectedDevices" )

end

function ENT:Initialize()

	self.linkedEnts = {}
    self.BatteryLevel = 100
	self.isOn = false

	self:SetConnectedDevices(0)

	self:SetUseType( SIMPLE_USE )
	self:SetModel( "models/items/car_battery01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then

		phys:Wake()

	end
end


function ENT:Use( ply)	
	if(	self.isOn ) then
    	self.isOn=false
		sound.Play( "npc/combine_soldier/vo/on1.wav", self:GetPos() )
		self:SetIsBatOn(false)
	else
		self.isOn=true
		sound.Play( "npc/combine_soldier/vo/off1.wav", self:GetPos() )
		self:SetIsBatOn(true)
	end 

	for k,v in pairs(self.linkedEnts) do	
		v:SetIsOn(self.isOn)
	end
end

function ENT:Think()

	if(self.BatteryLevel<=0) then
		
		removeBattery( self )

		return

	end

	if(self:GetAngles().x < -20) then
		
		self:SetAngles(Angle(-20, self:GetAngles().y, self:GetAngles().z));

	end

	if(self:GetAngles().x >20) then
		
		self:SetAngles(Angle(20, self:GetAngles().y, self:GetAngles().z));

	end

	if(self:GetAngles().z < -20) then
		
		self:SetAngles(Angle(self:GetAngles().x, self:GetAngles().y, -20));
		
	end

	if(self:GetAngles().z > 20) then
		
		self:SetAngles(Angle(self:GetAngles().x, self:GetAngles().y, 20));

	end

	if(self.isOn==true) then

		self.BatteryLevel = self.BatteryLevel - ((dischargeRate*FrameTime())*self:GetConnectedDevices())	

	end

	self:SetBatLevel(self.BatteryLevel)
end

function removeBattery( ent )
	for k,v in pairs(ent.linkedEnts) do
		if v:GetIsWired() then
			v:SetIsWired(false)
		end
	end

	ent:Remove()
end


function ENT:Touch(ent)

	for k,v in pairs(powerableEnts) do	
		if (ent:GetClass()==v) then
			local isLinked = false

			for k,v in pairs(self.linkedEnts) do				
				if(ent:EntIndex()==v:EntIndex()) then					
					isLinked=true
				end
			end

			if(ent:GetIsWired()==true) then			
				isLinked=true
			end

			if(isLinked==true) then				
			else
				table.insert( self.linkedEnts, ent )

				ent:SetIsWired(true)
				ent:SetIsOn(self.isOn)


				self:SetConnectedDevices(table.Count(self.linkedEnts))

			end
		end
	end

end



function ENT:VisualEffect()
	local effectData = EffectData()
	effectData:SetStart(self:GetPos())
	effectData:SetOrigin(self:GetPos())
	effectData:SetScale(8);
	util.Effect("GlassImpact", effectData, true, true)
end

function ENT:OnTakeDamage(dmginfo)
	self:VisualEffect()
	self:Remove()
end
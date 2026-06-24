AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 

include( 'shared.lua' )

local growthSpeed = 1.75
local deathSpeed = 32
 
local thirstSpeed = 1.6

function ENT:SetupDataTables()
 
	self:NetworkVar( "Bool", 0, "IsPlanted" )
	self:NetworkVar( "Int", 1, "GowthStage" )
	self:NetworkVar( "Int", 2, "PlantHealth" )
	self:NetworkVar( "Int", 3, "PlantThirst" )
	self:NetworkVar( "Bool", 4, "IsGrowing" )
	self:NetworkVar( "Bool", 6, "HasLight" )

end
 
function ENT:Initialize()
 
	self.isPlanted = false
	self.readyToHarvest = false

	self.growthStage = 0
	self.plantHealth = 100

	self.plantThirst = 80

	self.timerOne = CurTime()

	self:SetUseType( SIMPLE_USE )
	self:SetModel( "models/props_junk/terracotta01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

end

function ENT:Think()

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

	local result = ents.FindInSphere( self:GetPos(), 120 )
	local canGrow = false

	if(self.isPlanted) then
		if(table.Count(result)>0) then
			for k,v in pairs(result) do
				if(v:GetClass()=="adrug_heat_lamp") then
					if(v:GetIsOn()==true) then			
						growWeed(self)
						canGrow=true
						self:SetHasLight(false)
					end
				end
			end
		end
		if(canGrow==false) then
			killWeed(self)
			self:SetHasLight(true)
		end
	end 

	if(self.plantThirst>0) then
		
		if(self.plantThirst>100) then
			
			self.plantThirst=100

		end

		self.plantThirst = self.plantThirst - (thirstSpeed * FrameTime())

	else

		self.plantThirst = 0

		if(self.isPlanted)then

			killWeed(self)

		end
	end

	if(self.timerOne!=nil) then

		if(self.timerOne<CurTime()) then

			self.timerOne = CurTime() + 1 
			
			self:SetIsPlanted(self.isPlanted)
			self:SetGowthStage(self.growthStage)
			self:SetPlantHealth(self.plantHealth)
			self:SetPlantThirst(self.plantThirst)

		end

	else

		self.timerOne = CurTime()

	end

end

function growWeed(ent)

	if(ent.growthStage<100) then
		
		ent.growthStage = ent.growthStage + (growthSpeed * FrameTime())

	else

		ent.readyToHarvest=true
		ent:SetModel("models/props/cs_office/plant01.mdl")

	end
end

function killWeed(ent)

	if(ent.readyToHarvest!=true) then
	
		ent.plantHealth = ent.plantHealth - (deathSpeed * FrameTime())

		if(ent.plantHealth<=0) then
			
			ent.isPlanted=false
			ent.readyToHarvest=false
			ent.plantHealth = 100
			ent.growthStage = 0
			ent:SetModel("models/props_junk/terracotta01.mdl")

		end

	end

end

function ENT:Use(ent)
	if(self.readyToHarvest==true) then
		self.isPlanted=false
		self.readyToHarvest=false
		self:SetModel("models/props_junk/terracotta01.mdl")
		self.plantHealth = 100
		self.growthStage = 0
		local temp = ents.Create("adrug_weed")
		temp:SetPos(self:GetPos()+Vector(0,0,20))
		temp:Spawn()
	end
end

function ENT:Touch(ent)
	if (self.isPlanted==false) then
		if(ent:GetClass()=="adrug_weed_seed") then
			ent:Remove()
			self.isPlanted=true
		end
	end 

	if(ent:GetClass()=="adrug_water") then
		ent:Remove()
		self.plantThirst = self.plantThirst + 50

		if(self.plantThirst>100) then self.plantThirst = 100 return end
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
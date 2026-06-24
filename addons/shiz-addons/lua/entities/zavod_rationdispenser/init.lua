AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_phx/construct/metal_tube.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMaterial("phoenix_storms/metalfloor_2-3")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNWInt( "WorkInProgress", 0 )
	local phys = self:GetPhysicsObject()
	phys:Wake()

	self:SetUseType( SIMPLE_USE )

	--
	self.LastUse = 0
	self.Delay = 6.3
end

function ENT:Use(_, activator)
	local timerSound = "buttons/blip1.wav"
	local cSound = "buttons/button6.wav" -- звук закрытия

	if self.LastUse <= CurTime() then
		-- if activator:Team() != TEAM_RGRS and !GetGlobalBool('WorkingPhase') then return end
		self.LastUse = CurTime() + self.Delay
		self:SetNWInt( "WorkInProgress", 1 )

		self:EmitSound("buttons/lever8.wav")
		--aself:EmitSound("buttons/button1.wav")
		timer.Simple(0.4, function()
			self:EmitSound("buttons/button1.wav")
		end)

		timer.Simple(0.8, function()
			self:EmitSound(timerSound)
		end)
		timer.Simple(1.4, function()
			self:EmitSound(timerSound)
		end)
		timer.Simple(2, function()
			self:EmitSound(timerSound)
		end)


		timer.Simple(2, function()
			self:EmitSound("buttons/button9.wav")
		end)
		timer.Simple(2.6, function()
		self:EmitSound("buttons/button4.wav")
		self:SetNWInt( "WorkInProgress", 0 )
		local ent = ents.Create( "zavod_ration" )
		ent:SetPos( self:GetPos() + ( self:GetForward() * 3 ) + ( self:GetUp() * 40 ) )
		ent:SetAngles( self:GetAngles() + Angle( 0, 0, 0 ) )
		ent:Spawn()
		ent:Activate()
		ent:GetPhysicsObject():ApplyForceCenter( self:GetForward() * 10 )
		end)
		timer.Simple(5.8, function()
			self:EmitSound(cSound)
		end)
	end
end

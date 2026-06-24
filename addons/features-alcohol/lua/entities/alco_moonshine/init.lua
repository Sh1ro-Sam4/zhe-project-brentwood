AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/props_junk/glassjug01.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	self:PhysWake()
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetTrigger(true)
end

function ENT:Use(activator, caller)
	local curTime = CurTime()
	local org = activator.organism
	if (!self.nextUse or curTime >= self.nextUse) then
		if not org then return end
		if timer.Exists('Zaza_effect_'..activator:SteamID()) then timer.Remove('Zaza_effect_'..activator:SteamID()) end
		self:EmitSound("snd_jack_hmcd_drink"..math.random(3)..".wav")
		org.analgesiaAdd = org.analgesiaAdd + 0.25
		org.consciousness = -org.analgesiaAdd + 0.9
		timer.Simple(3, function(argments)
			org.assimilated = org.assimilated + 0.1
			timer.Create('Zaza_effect_'..activator:SteamID(), 25, 1, function()
				org.assimilated = 0.1
				timer.Simple(25, function()
					org.assimilated = 0
				end)
			end)
		end)
		self:Remove()

		self.nextUse = curTime + 0.5
	end
end
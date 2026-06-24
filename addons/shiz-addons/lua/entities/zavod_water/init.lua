AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/PopCan01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()
	-- предотвращение абуза
	self:SetUseType( SIMPLE_USE )
	self:SetCustomCollisionCheck(true)
	self.IsPassableRation = true
	-- автоудаление чтобы не спамили	
	timer.Simple(15, function()
		if IsValid( self ) then
			self:Remove()
		end
	end)
	self.LastUse = 0
	self.Delay = 2
	
end

function ENT:Use(activator)
-- таймер для предотвращения абуза
	if self.LastUse <= CurTime() then
		self.LastUse = CurTime() + self.Delay
		
		DarkRP.notify(activator, 3, 3, "Заполните рацион едой и водой.")
		timer.Simple(1.2, function()
		
			DarkRP.notify(activator, 3, 3, "Далее - положите заполненный рацион в коробку.")
		
		end)
		
	end
end

hook.Add("ShouldCollide", "RationPassThroughOwnedEntities", function(ent1, ent2)
	if ent1.IsPassableRation or ent2.IsPassableRation then
		
		local ourEnt = ent1.IsPassableRation and ent1 or ent2
		local otherEnt = ent1.IsPassableRation and ent2 or ent1
		
		if otherEnt:IsWorld() then return end
		
		if otherEnt.CPPIGetOwner then
			local owner = otherEnt:CPPIGetOwner()
			
			if IsValid(owner) then
				return false
			end
		end
		
	end
end)
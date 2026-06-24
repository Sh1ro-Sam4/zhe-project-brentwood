AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local detaltofinal = {
	["models/hunter/blocks/cube05x05x025.mdl"] = "models/props_phx/gears/bevel90_24.mdl",
	["models/hunter/blocks/cube025x025x025.mdl"] = "models/fc5/weapons/handguns/d50.mdl",
	["models/hunter/misc/sphere025x025.mdl"] = "models/eft_props/gear/helmets/helmet_achhc_b.mdl",
	["models/hunter/blocks/cube05x05x05.mdl"] = "models/eft_props/gear/armor/ar_6b13_flora.mdl",
}
--print(detaltofinal["models/hunter/blocks/cube05x05x05.mdl"])
function ENT:Initialize()
	local num = math.random(table.Count(detaltofinal))
	local count = 1
	local model = 'models/hunter/blocks/cube05x05x025.mdl'
	for k,v in pairs(detaltofinal) do
		if count == num then
			model = k
			--print(k)
			--continue 
		end
		count = count + 1
	end
	--print(model)
	self:SetModel(model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()
	self:SetCustomCollisionCheck(true)
	self.IsPassableRation = true
	self:SetSubMaterial(0,"phoenix_storms/gear")
	self:SetColor(Color(182,182,182))
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	local phys = self:GetPhysicsObject()

	if ( IsValid( phys ) ) then -- Always check with IsValid! The ent might not have physics!
		phys:SetMass(250)
	end

	timer.Create("SelfLifeTime_"..self:EntIndex(), 120, 1, function() 
		if IsValid(self) then
			self:Remove()
		end
	end)
end

function ENT:StartTouch(ent)
	if (not self.Used) and IsValid(ent) and (ent:GetClass() == 'zavod_stanoc') and !ent:GetEnabled() then
		self.Used = true
		ent:EmitSound('buttons/lever4.wav')
		ent:EmitSound('cigarette_factory/cf_machine_loop.wav')
		ent:SetEnabled(true)
		ent:SetLastPrint(CurTime())
		local ply = self.LocalOwner
		print(ply)
		local newmodel = detaltofinal[self:GetModel()]
		local newpos = ent:LocalToWorld(Vector(0, 50, 20))
		timer.Create("StanocPrint_"..ent:EntIndex(), 30, 1, function()
			ent:EmitSound('buttons/lever6.wav')
			ent:StopSound('cigarette_factory/cf_machine_loop.wav')
			ent:SetEnabled(false)
			ent:SetLastPrint(CurTime())
			local final = ents.Create( "zavod_final" )
			final:SetModel( newmodel )
			final:SetPos( newpos )
			final:Spawn()
			final.LocalOwner = ply
		end)
		self:Remove()
	end
end

function ENT:Use(ply)
	if true then 
		-- ГОЙДА
	end
end
function ENT:OnTakeDamage(damageData)
	self:Remove()
end

function ENT:Think()
	
	--for k,v in pairs(ents.FindInBox(Vector(2483, 3000, -169), Vector(1847, 3417, 201))) do
	--	
	--end
	if !self:GetPos():WithinAABox(Vector(1681, -2307, -97), Vector(1220, -1560, 421)) then
		self:Remove()
	end

	self:NextThink( CurTime() + 1 )

	return true
end

function OnRemove()
	if timer.Exists("SelfLifeTime_"..self:EntIndex()) then 
		timer.Remove("SelfLifeTime_"..self:EntIndex())
	end
end
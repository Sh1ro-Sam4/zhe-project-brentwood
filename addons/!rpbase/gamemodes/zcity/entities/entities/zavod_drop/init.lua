AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/props_phx/construct/metal_tube.mdl')
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	--self:PhysWake()
	--self:SetSubMaterial(0,"models/wireframe")
	--self:SetPos(Vector(2360,3151,-126))
	--self:SetColor(Color(9,255,0,110))
	--self:SetAngles(Angle(0,0,0))
	--self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	--timer.Create("SelfLifeTime_"..self:EntIndex(), 120, 1, function() 
	--	if IsValid(self) then
	--		self:Remove()
	--	end
	--end)
end

function ENT:Use(ply)
	if timer.Exists("DropperCD_"..self:EntIndex()) then return end
	timer.Create("DropperCD_"..self:EntIndex(), 5, 1, function() end)

	for _, ent in ents.Iterator() do
		if ent:GetClass() == "zavod_detal" and ent.LocalOwner == ply then
			ent:Remove()
		end
	end
	self:EmitSound('buttons/button4.wav')
	local final = ents.Create( "zavod_detal" )
	final:SetPos( self:GetPos() )
	--final.LocalOwner = ply
	final:Spawn()
	final.LocalOwner = ply
end

--function OnRemove()
--	if timer.Exists("SelfLifeTime_"..self:EntIndex()) then 
--		timer.Remove("SelfLifeTime_"..self:EntIndex())
--	end
--end
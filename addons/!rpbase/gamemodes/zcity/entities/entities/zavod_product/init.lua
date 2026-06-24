AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:SetModel('models/hunter/plates/plate2x4.mdl')
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	--self:PhysWake()
	self:SetSubMaterial(0,"models/wireframe")
	self:SetPos(Vector(1296, -2112, -30.011673))
	self:SetColor(Color(9,255,0,110))
	self:SetAngles(Angle(0,0,0))
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
end

function ENT:Think()
	
	for k,v in pairs(ents.FindInBox(Vector(1250, -2206, -68), Vector(1353, -2030, 142))) do
		if v:GetClass() == "zavod_final" then
			local sum = math.random(70,100) * INCOME_MULT
			if IsValid(v.LocalOwner) then
				v.LocalOwner:GiveSalary(sum)
				v:Remove()
			end
			--v:Remove()
		end
	end

	self:NextThink( CurTime() + 1 )

	return true
end

function ENT:Use(ply)
	if true then 
		-- ГОЙДА
	end
end
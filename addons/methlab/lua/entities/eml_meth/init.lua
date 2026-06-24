AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/props_junk/rock001a.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);

	self:SetMaterial("models/props_pipes/GutterMetal01a");
	self:SetColor(Color(0, 247, 255));	
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:SetNWInt("distance", EML_DrawDistance);
	self:SetNWInt("amount", 1);
	self:SetNWInt("maxAmount", 1);
	self:SetNWInt("value", 1);
	self:SetNWInt("valueMod", EML_Meth_ValueModifier);
	self:SetNWBool("salesman", EML_Meth_UseSalesman);
end;

function ENT:OnTakeDamage(dmginfo)
	self:VisualEffect();
end;

function ENT:VisualEffect()
	local effectData = EffectData();	
	effectData:SetStart(self:GetPos());
	effectData:SetOrigin(self:GetPos());
	effectData:SetScale(8);	
	util.Effect("GlassImpact", effectData, true, true);
	self:Remove();
end;

function ENT:Use(activator, caller)
    local curTime = CurTime()

    if (not self.nextUse or curTime >= self.nextUse) then
        activator:SetNWInt("player_meth", activator:GetNWInt("player_meth") + (self:GetNWInt("amount") * EML_Meth_ValueModifier))
        activator:ChatPrint('Вы подобрали ' .. math.Round(self:GetNWInt('amount')) .. 'грамм мета, продайте его скупщику.')
        activator.methkolvo = (activator.methkolvo or 0) + (self:GetNWInt("amount"))
        self:VisualEffect()
        self.nextUse = curTime + 0.5
    end
end
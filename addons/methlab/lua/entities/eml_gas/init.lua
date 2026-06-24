AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/props_c17/canister01a.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:SetNWInt("distance", EML_DrawDistance);
	self:SetNWInt("amount", EML_Gas_Amount);
	self:SetNWInt("maxAmount", EML_Gas_Amount);
	self:SetNWBool("open", false);
	self:SetNWBool("explode", false);
	self:GetPhysicsObject():SetMass(105);
	self:SetPos(self:GetPos()+Vector(0, 0, 32));
end;

function ENT:Use(activator, caller)
local curTime = CurTime();
	if (!self.nextUse or curTime >= self.nextUse) then
		if !self:GetNWBool("open") then
			self:SetNWBool("open", true);
			self.gasSound = CreateSound(self, Sound("ambient/gas/cannister_loop.wav"))
			self.gasSound:SetSoundLevel(42);
			self.gasSound:PlayEx(1, 150);
		else
			self:SetNWBool("open", false);
			if self.gasSound then
				self.gasSound:Stop();
			end;
		end;
		self.nextUse = curTime + 0.5;
	end;
end;

function ENT:Think()
local traceGas = {}	
traceGas.start = (self:GetPos()+(self:GetUp()*28));
traceGas.endpos = (self:GetPos()+(self:GetUp()*42));
traceGas.filter = self;

local traceConnect = util.TraceLine(traceGas);

	if ((!self.nextGas or CurTime() >= self.nextGas) and (self:GetNWInt("amount")>0) and self:GetNWBool("open")) then	
		if IsValid(traceConnect.Entity) then	
			if (traceConnect.Entity:GetClass() == "eml_stove") then
				self:SetNWInt("amount", math.Clamp(self:GetNWInt("amount")-1, 0, self:GetNWInt("maxAmount")));
				traceConnect.Entity:SetNWInt("gasStorage", math.Clamp(traceConnect.Entity:GetNWInt("gasStorage")+1, 0, traceConnect.Entity:GetNWInt("gasStorageMax")));			
			else
				self:SetNWInt("amount", math.Clamp(self:GetNWInt("amount")-1, 0, self:GetNWInt("maxAmount")));
			end;
		else
			self:SetNWInt("amount", math.Clamp(self:GetNWInt("amount")-1, 0, self:GetNWInt("maxAmount")));
		end;	
	self.nextGas = CurTime() + 0.01;
	end;
	
	if (self:GetNWInt("amount")==0) then
		if self.gasSound then
			self.gasSound:Stop();
		end;
		if EML_Gas_Remove then
			self:VisualEffect();
		end;
	end;
	
end;

function ENT:OnTakeDamage(dmginfo)
	if (EML_Gas_ExplosionType == 2) then
	-- if (EML_Gas_ExplosionType == 1) then
		if !self:GetNWBool("explode") then
			self:SetNWBool("explode", true);
			if (self:GetNWInt("amount")>0) then
				if self.gasSound then
					self.gasSound:Stop();
				end;	
				self:Explode();
			else
				self:VisualEffect();
			end;
		end;
	elseif (EML_Gas_ExplosionType == 1) then
	-- elseif (EML_Gas_ExplosionType == 2) then
		if self.gasSound then
			self.gasSound:Stop();
		end;	
		self:VisualEffect();
	elseif (EML_Gas_ExplosionType == 0) then		
		return false;
	end;
end;


function ENT:VisualEffect()
	local effectData = EffectData();	
	effectData:SetStart(self:GetPos());
	effectData:SetOrigin(self:GetPos());
	effectData:SetScale(8);	
	util.Effect("GlassImpact", effectData, true, true);
	self:Remove();
end;


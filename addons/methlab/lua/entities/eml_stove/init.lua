AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/props_c17/furnitureStove001a.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetHealth(EML_Stove_Health);
   
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
   
	self:SetNWInt("distance", EML_DrawDistance);
	self:SetNWInt("stoveConsumption", EML_Stove_Consumption);
	self:SetNWInt("stoveHeat", EML_Stove_Heat);
	self:SetNWInt("gasStorage", EML_Stove_Storage);
	self:SetNWInt("gasStorageMax", EML_Stove_Storage);
   
	self:SetNWBool("firePlace1", false);
	self:SetNWBool("firePlace2", false);
	self:SetNWBool("firePlace3", false);
	self:SetNWBool("firePlace4", false);
	self:SetNWBool("explode", false);
   
	self:SetPos(self:GetPos()+Vector(0, 0, 32));
   
	if EML_Stove_GravityGun then
		self:GetPhysicsObject():SetMass(105);
	end;   
end;

function ENT:OnTakeDamage(dmginfo)
	if (EML_Stove_ExplosionType == 1) then
		self:SetHealth(self:Health()-dmginfo:GetDamage());
		if self:Health() <= dmginfo:GetDamage() then
			if !self:GetNWBool("explode") then
				self:SetNWBool("explode", true);
				self:Explode();
			end;
		end;
	elseif (EML_Stove_ExplosionType == 2) then
		self:SetHealth(self:Health()-dmginfo:GetDamage());
		if self:Health() <= dmginfo:GetDamage() then
			self:Remove();
		end;
	elseif (EML_Stove_ExplosionType == 0) then             
		return false;
	end;
end;

function ENT:Think()
	if ((!self.nextHeat or CurTime() >= self.nextHeat) and (self:GetNWInt("gasStorage") > 0)) then   
		
		local burners = {
			{ f = 2.8, r = 11.5, name = "firePlace1" },
			{ f = 2.8, r = -11.2, name = "firePlace2" },
			{ f = -9.8, r = -11.2, name = "firePlace3" },
			{ f = -9.8, r = 11.5, name = "firePlace4" }
		}

		for _, offset in ipairs(burners) do
			local traceData = {}     
			traceData.start = self:GetPos() + (self:GetUp() * 20) + (self:GetForward() * offset.f) + (self:GetRight() * offset.r)
			traceData.endpos = self:GetPos() + (self:GetUp() * 24) + (self:GetForward() * offset.f) + (self:GetRight() * offset.r)
			traceData.filter = self
			
			local tr = util.TraceLine(traceData)
			local pot = tr.Entity
			local isCooking = false

			if IsValid(pot) then
				local isOldPot = (pot:GetClass() == "eml_pot" and pot:GetNWInt("sulfur") > 0 and pot:GetNWInt("macid") > 0 and pot:GetNWInt("status") ~= 1)
				
				local isNewPot = (pot:GetClass() == "eml_spot" and pot:GetNWInt("status") == 1)
				
				if (isOldPot or isNewPot) and pot:GetNWInt("time") > 0 then
					self:SetNWInt("gasStorage", math.Clamp(self:GetNWInt("gasStorage") - EML_Stove_Consumption, 0, self:GetNWInt("gasStorageMax")))
					
					pot:SetNWInt("time", math.Clamp(pot:GetNWInt("time") - 1, 0, pot:GetNWInt("maxTime")))                
					
					if (pot:GetNWInt("time") == 0) then
						if isNewPot then
							pot:SetNWInt("status", 2)
							pot:EmitSound("ambient/levels/canals/toxic_slime_sizzle2.wav")
						else
							pot:SetNWInt("status", 1)
						end
					end                                           
					
					if math.random(1, 2) == 2 then
						pot:EmitSound("ambient/levels/canals/toxic_slime_gurgle"..math.random(2, 8)..".wav")
					end
					
					isCooking = true
				end
			end
			
			self:SetNWBool(offset.name, isCooking)
		end
		
		self.nextHeat = CurTime() + 1
	end
end
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Humans/Group02/male_07.mdl");
	self:SetHullType(HULL_HUMAN);
	self:SetHullSizeNormal();
	self:SetNPCState(NPC_STATE_SCRIPT);
	self:SetSolid(SOLID_BBOX);
	self:SetUseType(SIMPLE_USE);
	self:SetBloodColor(BLOOD_COLOR_RED);
	self.Removed = true;
end


function ENT:AcceptInput(name, activator, caller)	

	if(caller.weedAmount!=nil) then
		if (!self.nextUse or CurTime() >= self.nextUse) then
			if (name == "Use" and caller:IsPlayer() and caller.weedAmount>0) then

				local money = 2000*caller.weedAmount

				caller.weedAmount = 0


				caller:PrintMessage( HUD_PRINTTALK, "Спасибо вот твои деньги $"..tostring(money).."!")

				caller:addMoney(money)

			end
			self.nextUse = CurTime() + 1
		end
	else

		caller.weedAmount=0

	end
end
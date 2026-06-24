AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("autorun/config.lua")

include("shared.lua")
include("autorun/config.lua")

function ENT:Initialize()
	self:SetModel(WEED_DEALERMODEL);
	self:SetHullType(HULL_HUMAN);
	self:SetHullSizeNormal();
	self:SetMoveType(MOVETYPE_STEP);
	self:SetSolid(SOLID_BBOX);
	self:SetUseType(SIMPLE_USE);
	self:SetBloodColor(BLOOD_COLOR_RED);

    local sequences = self:GetSequenceList()
    local idleSequences = {}

    for k, v in pairs(sequences) do
        if string.find(string.lower(v), "idle") then
            table.insert(idleSequences, v)
        end
    end

    --PrintTable(idleSequences)
    
    timer.Simple(0.1, function()
        if self:IsValid() then
            local seq = self:LookupSequence('LineIdle04')
            if seq > 0 then
                self:ResetSequence(seq)
                self:SetPlaybackRate(1)
            else
                self:ResetSequence(0)
            end
        end
    end)
end

function ENT:Think()
    if self:GetSequence() == 0 then
        local seq = self:LookupSequence('LineIdle04')
        if seq > 0 then
            self:ResetSequence(seq)
        end
    end
end

ENT.nextUse = 0
function ENT:AcceptInput(name, activator, caller)
   if (self.nextUse < CurTime()) then
	if IsValid(caller) and caller:IsPlayer() then
		local foundWeed = false
		local nearbyEnts = ents.FindInSphere(self:GetPos(), 50)
		
		for _, ent in pairs(nearbyEnts) do
			if ent:GetClass() == "zone_weedbag" or ent:GetClass() == "eml_meth" and ent:GetPos():Distance(caller:GetPos()) <= 100 then
				foundWeed = ent
				break
			end
		end

        if foundWeed and IsValid(foundWeed) then
            if foundWeed:GetClass() == "zone_weedbag" then
                local WEED_PRICE = math.random(500, 1200)
                caller:SendLua("local tab = {Color(76, 187, 23,255), [[(Джеймс)]], Color(255,255,255), [[:]], Color(255,255,255), [[ Спасибо за траву бро! Вот твои ]], Color(76, 187, 23), [[".. WEED_PRICE .. "$.]] } chat.AddText(unpack(tab))")
                timer.Simple(0.25, function() self:EmitSound(table.Random(WEED_YESSOUNDS), 100, 100) end);
                caller:AddMoney(WEED_PRICE)
                foundWeed:Remove()
            elseif foundWeed:GetClass() == "eml_meth" then
                local METH_PRICE = math.random(500, 1200)
                caller:SendLua("local tab = {Color(76, 187, 23,255), [[(Джеймс)]], Color(255,255,255), [[:]], Color(255,255,255), [[ Спасибо за мет бро! Вот твои ]], Color(76, 187, 23), [["..METH_PRICE.."$.]] } chat.AddText(unpack(tab))");
                timer.Simple(0.25, function() self:EmitSound(table.Random(WEED_YESSOUNDS), 100, 100) end);
                caller:AddMoney(METH_PRICE)
                foundWeed:Remove()
            end
        else
            caller:SendLua("local tab = {Color(76, 187, 23,255), [[(Джеймс)]], Color(255,255,255), [[:]], Color(255,255,255), [[ Принеси мне товар!]] } chat.AddText(unpack(tab))");
            timer.Simple(0.25, function() self:EmitSound(table.Random(WEED_NOSOUNDS), 100, 100) end);
        end
	end
   end
	self.nextUse = CurTime() + 1   
end
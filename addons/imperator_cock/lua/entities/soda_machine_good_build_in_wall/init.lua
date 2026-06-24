-- Author MostRush
-- GOOD Build in wall
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SetGlobalInt("ZAVOD_RATION", 30)

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 50
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local self = ents.Create( ClassName )
	self:SetPos( SpawnPos )
	self:SetAngles( SpawnAng )
	self:Spawn()
	self:Activate()

	return self
end

function ENT:Initialize()
	self:SetModel("models/props_interiors/VendingMachineSoda01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:GetPhysicsObject():SetMass(1000)
	if self:GetPhysicsObject():IsValid() then self:GetPhysicsObject():Wake() end
	--self:EmitSound("turnon.wav", 65, 100, 1, CHAN_AUTO)
end

local delay = true
function ENT:AcceptInput(name, ply, caller)
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
    if ply:GetPos():DistToSqr(self:GetPos()) > 10000 then return end

    if delay == true then
        if ply:CanAfford(30) then 
            ply:DelayedAction('BuyFood', 'Покупка еды', {
                time = 3,
                check = function()
                    if not IsValid(ply) or not ply:Alive() or not IsValid(self) then return false end
                    if ply:GetPos():DistToSqr(self:GetPos()) > 10000 then
                        ply:ChatPrint("Вы отошли слишком далеко!") -- Опционально
                        return false
                    end
                    if GetGlobalInt("ZAVOD_RATION") <= 0 then
                        return false
                    end
                    return true
                end,
                succ = function()
                    ply:ChatPrint("Вы оплатили 30$.")
                    ply:SubtractMoney(30)
                    self:EmitSound("buttons/button14.wav")
                    delay = false
                    SetGlobalInt("ZAVOD_RATION", GetGlobalInt("ZAVOD_RATION") - 1)
                    timer.Simple(2, function()
                        if not IsValid(self) then return end 
                        if not IsValid(ply) then return end
                        
                        local weapon_prototype = ents.Create("ration_bad")
                        if not IsValid(weapon_prototype) then return end
                        local pos = self:GetPos()
                        local ang = self:GetAngles()
                        weapon_prototype:SetPos(self:LocalToWorld(Vector(25, -2, -25)))
                        weapon_prototype:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 90)))
                        weapon_prototype:Spawn()
                        weapon_prototype:PhysWake()
                        
                        local phys = weapon_prototype:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:SetVelocity(ang:Forward() * 75)
                        end
                        self:EmitSound('buttons/button4.wav')
                    end)
                    
                    timer.Simple(2.5, function()
                        delay = true
                    end)
                end,
            }, {
                time = 1.5,
                inst = true,
                action = function()
                    if not IsValid(ply) then return end
                    ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_GIVE + math.random(0,1))
                    ply:EmitSound("player/clothes_generic_foley_0" .. math.random(1,5) .. ".wav")
                end,
            })
        else
            ply:ChatPrint("У вас недостаточно средств!")
        end
    end
end

	
function ENT:Think()
	self:EmitSound("worked_short.wav", 50, 100, 1, CHAN_AUTO)
end
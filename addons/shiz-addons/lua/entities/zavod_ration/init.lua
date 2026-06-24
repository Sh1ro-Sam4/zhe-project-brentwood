AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

	self:SetModel("models/weapons/w_package.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType( SIMPLE_USE )

	local phys = self:GetPhysicsObject()
	phys:Wake()

	self:SetNWInt("RWater", 0)
	self:SetNWInt("RFood", 0)
	self:SetCustomCollisionCheck(true)
	self.IsPassableRation = true

	timer.Simple(15, function() if IsValid( self ) then self:Remove() end end)

	self.LastUse = 0
	self.Delay = 2

end

function ENT:Use(activator)

	if self.LastUse <= CurTime() then
		-- if activator:Team() != TEAM_RGRS and !GetGlobalBool('WorkingPhase') then return end

		if self:GetNWInt("RWater") == 0 or self:GetNWInt("RFood") == 0 then
			return activator:CPrint(Color(255,255,255), "Вы должны положить в рацион 1 воду и 1 еду!")
		end

		activator:SetNWBool("userat", true)
		activator:SendLua([[RationMenu()]])

		self.LastUse = CurTime() + self.Delay
		self:Remove()
	end
end

function ENT:StartTouch( hitEnt )
	if hitEnt:GetClass() == "zavod_water" && self:GetNWInt("RWater") == 0 then
		self:EmitSound("items/medshot4.wav");
		self:SetNWInt("RWater", 1)
		hitEnt:Remove()
	end
	if hitEnt:GetClass() == "zavod_food" && self:GetNWInt("RFood") == 0 then
		self:EmitSound("items/medshot4.wav");
		self:SetNWInt("RFood", 1)
		hitEnt:Remove()
	end
end

util.AddNetworkString("rationSuccess")

net.Receive("rationSuccess",function(len,ply)
	if not ply:GetNWBool("userat") then return end

    local basemoney = 25 * INCOME_MULT
    ply:GiveSalary(basemoney, 'Заработок - Рацион')
    ply:SetNWBool("userat", false)
    hook.Call('rationSuccess',GAMEMODE,ply)
    hook.Call("PlayerRationOK", nil, ply)

	SetGlobalInt("ZAVOD_RATION", GetGlobalInt("ZAVOD_RATION") + 1)
end)

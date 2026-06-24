AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- include("autorun/shared/bank_config.lua")

local function spawn()
	for k, v in pairs(BANK_CONFIG.Locations) do
		local money = ents.Create("rob_bank_vault_money")
		money:SetPos(v.pos)
		money:SetAngles(v.ang)
		money:Spawn()

		local phys = money:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion(false)
		end
	end
end

hook.Add("InitPostEntity", "SpawnBanksOnLoad", spawn)
hook.Add("PostCleanupMap", "RespawnBanksOnCleanup", spawn)

concommand.Add('resbank', function(ply)
    if not ply:IsSuperAdmin() then return end
	spawn()
end)

local playerGA = player.GetAll
local musara = {}
timer.Create('cachevault', 5, 0, function()
    musara = {}
    for _, pl in ipairs(player.GetAll()) do
        if IsGov(pl:GetPlayerClass()) then
            table.insert(musara, pl)
        end
    end
end)
local function isAllowedToRob()
	local cops = 0

	for k, v in pairs(musara) do
		cops = cops + 1
	end

	return cops >= BANK_CONFIG.MinCopJobs, cops
end

function ENT:Initialize()
	self:SetModel(BANK_CONFIG.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(CONTINUOUS_USE)

	self:SetHeldMoney(BANK_CONFIG.StartingAmount)

	self:SetDelay(CurTime() + BANK_CONFIG.Delay)
	self:SetCooldown(0)
	self.UseCooldown = 0

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:Use(activator, caller)
	if self:GetCooldown() > CurTime() then
		if self.UseCooldown < CurTime() then
			local timeLeft = math.ceil((self:GetCooldown() - CurTime()) / 60)
			DarkRP.notify(caller, NOTIFY_ERROR, 4, "Хранилище заблокировано! Приходите через " .. timeLeft .. " мин.")
			self.UseCooldown = CurTime() + 2 
		end
		return 
	end

	if self.UseCooldown > CurTime() then return else self.UseCooldown = CurTime() + BANK_CONFIG.PickupDelay end

	if caller:IsValid() and caller:IsPlayer() then
		if (table.Count(BANK_CONFIG.AllowedJobs) < 0) or IsGov(caller:GetPlayerClass()) then //76561198092742034
			DarkRP.notify(caller, NOTIFY_GENERIC, 4, string.format(BANK_CONFIG.CannotRobAsCopString, caller:GetPlayerClass().Name))
			return
		end

		if self:GetHeldMoney() <= 0 then
			DarkRP.notify(caller, NOTIFY_GENERIC, 4, BANK_CONFIG.EmptyMessage)
			return
		end

		local allowed, copCount = isAllowedToRob()

		if !allowed then
			caller:PrintMessage(HUD_PRINTTALK, string.format(BANK_CONFIG.CannotRobCopString, copCount, BANK_CONFIG.MinCopJobs)) //76561198092742034
			return
		end

		sound.Play(BANK_CONFIG.PickupSound, self:GetPos())
		self:StartAlarm()

		local bagMoney
		if self:GetHeldMoney() - BANK_CONFIG.Amount < 0 then
			bagMoney = self:GetHeldMoney()
		end

		local actualTaken = bagMoney or BANK_CONFIG.Amount

		self:SetHeldMoney(math.Clamp(self:GetHeldMoney() - BANK_CONFIG.Amount, 0, BANK_CONFIG.Max))

		if BANK_CONFIG.WantOnRobbery and !caller:IsWanted() then
			caller:Wanted(BANK_CONFIG.WantedReason, caller)
		end

		if BANK_CONFIG.UseBags then
			local trace = {}
		    trace.start = caller:EyePos()
		    trace.endpos = trace.start + caller:GetAimVector() * 85
		    trace.filter = caller

		    local tr = util.TraceLine(trace)

			local bag = ents.Create("rob_bank_money_bag")
			bag:SetPos(tr.HitPos)
			bag:SetAngles(caller:GetAngles())
			bag:SetPlayer(caller)
			bag:SetVault(self)
			bag:SetMoney(actualTaken)
			bag:Spawn()

			DarkRP.notify(caller, NOTIFY_GENERIC, 4, string.Comma(string.format(BANK_CONFIG.RobNotification, actualTaken))) //76561198092742034
			hook.Call('::RobBank', nil, caller)
		else
			caller:addMoney(actualTaken)
		end

		for k, v in pairs(player.GetAll()) do
			if IsGov(v:GetPlayerClass()) then
				v:ChatPrint(string.format(BANK_CONFIG.PoliceRobNotification, caller:Nick()))
			end
		end

		self.SessionStolen = (self.SessionStolen or 0) + actualTaken
		self.LastRobbedTime = CurTime()

		if self.SessionStolen >= 25000 then
			self:SetCooldown(CurTime() + 1800)
			self.SessionStolen = 0
			self:StopAlarm()
			DarkRP.notify(caller, NOTIFY_ERROR, 5, "Вы украли максимальную сумму (250к)! Хранилище закрывается на 30 минут.")
		else
			if BANK_CONFIG.UseCooldowns then
				if self:GetHeldMoney() <= 0 then
					self:SetCooldown(CurTime() + BANK_CONFIG.CooldownTime)
				end
			end
		end

		self:SetDelay(CurTime() + BANK_CONFIG.Delay)
	end
end

function ENT:StartAlarm()
	if(!BANK_CONFIG.UseAlarm) then return end

	self.alarmSound = CreateSound(self, BANK_CONFIG.AlarmSound)
	if(self.alarmSound:IsPlaying()) then return end
	self.alarmSound:Play()
end

function ENT:StopAlarm()
	if(!BANK_CONFIG.UseAlarm) then return end

	if(self.alarmSound) then
		self.alarmSound:Stop()
		self.alarmSound = nil
	end
end

function ENT:StartTouch(ent)
	if(ent:GetClass() != "rob_bank_money_bag") then return end
	if(self:GetCooldown() != 0) then return end

	if(self:GetHeldMoney() >= BANK_CONFIG.Max) then return end

	if(self:GetHeldMoney() + ent:GetMoney() > BANK_CONFIG.Max) then
		local amt = ent:GetMoney() - ((self:GetHeldMoney() + ent:GetMoney()) - BANK_CONFIG.Max)
		self:SetHeldMoney(self:GetHeldMoney() + amt)
		ent:SetMoney(ent:GetMoney() - amt)

		return
	end

	self:SetHeldMoney(self:GetHeldMoney() + ent:GetMoney())
	ent:Remove()
	self:EmitSound("ambient/office/coinslot1.wav")
end

function ENT:Think()
	if self.LastRobbedTime and self.SessionStolen and self.SessionStolen > 0 then
		if CurTime() - self.LastRobbedTime > 900 then -- 900 секунд = 15 минут простоя
			self.SessionStolen = 0
		end
	end

	if self:GetHeldMoney() >= BANK_CONFIG.Max then return end
	if self:GetDelay() > CurTime() then return else self:SetDelay(CurTime() + BANK_CONFIG.Delay) end

	if self:GetCooldown() ~= 0 then
		//76561198092742034
		if self:GetCooldown() > CurTime() then return else self:SetCooldown(0) end
	end

	-- self:SetHeldMoney(self:GetHeldMoney() + math.min(BANK_CONFIG.AmountGenerated, BANK_CONFIG.Max - self:GetHeldMoney()))
	self:StopAlarm()
end
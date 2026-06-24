AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_wasteland/kitchen_counter001c.mdl")

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    self.jarModels = {}

    self:SetNWInt("progress", 0)
    self:SetNWInt("status", 0)
    self:SetNWInt("EmptyJars", 0)
    self:SetNWInt("fill_progress", 0)
    self:SetNWInt("needed_beer", 0)
end

local modCheck = {

    ["alco_part_barrel"] = function(self, ent)
        if self:GetHasBarrel() then return end

        ent.UsedInAlco = true

        timer.Simple(0, function()
            if not IsValid(self) or not IsValid(ent) then return end

            ent:Remove()
            self:SetHasBarrel(true)
            self:EmitSound("ambient/energy/newspark07.wav")
        end)
    end,

    ["alco_part_pipe"] = function(self, ent)
        if not self:GetHasBarrel() or self:GetHasPipe() then return end

        ent.UsedInAlco = true

        timer.Simple(0, function()
            if not IsValid(self) or not IsValid(ent) then return end

            ent:Remove()
            self:SetHasPipe(true)
            self:EmitSound("ambient/energy/newspark07.wav")
        end)
    end,

    ["alco_dobeer"] = function(self, ent)
        if not self:GetHasPipe() then return end
        if self:GetNWInt("status") ~= 0 then return end

        if self:GetBraga() < 4 then
            ent.UsedInAlco = true

            timer.Simple(0, function()
                if not IsValid(self) or not IsValid(ent) then return end

                self:SetBraga(self:GetBraga() + 1)

                ent:Remove()

                self:EmitSound("ambient/energy/newspark07.wav")
            end)
        end
    end,

    ["alco_jar_empty"] = function(self, ent)
        if self:GetNWInt("EmptyJars") >= 4 then return end

        ent.UsedInAlco = true

        timer.Simple(0, function()
            if not IsValid(self) or not IsValid(ent) then return end

            ent:Remove()

            self:SetNWInt(
                "EmptyJars",
                self:GetNWInt("EmptyJars") + 1
            )

            self:EmitSound("ambient/energy/newspark07.wav")
        end)
    end,
}

function ENT:PhysicsCollide(data, phys)
    local ent = data.HitEntity

    if not IsValid(ent) or ent.UsedInAlco then return end

    local class = ent:GetClass()

    if modCheck[class] then
        modCheck[class](self, ent)
    end
end

function ENT:Think()
    self:NextThink(CurTime())

    if not (self:GetHasBarrel() and self:GetHasPipe()) then
        return true
    end

    local curTime = CurTime()

    if not self.progressTime or curTime >= self.progressTime then

        local status = self:GetNWInt("status")

        if status == 1 then

            local speed = 2 / math.max(self:GetBraga(), 1)

            self:SetNWInt(
                "progress",
                math.min(self:GetNWInt("progress") + speed, 100)
            )

            self:EmitSound(
                "ambient/levels/canals/toxic_slime_gurgle" ..
                math.random(2, 8) ..
                ".wav",
                60,
                100
            )

            if self:GetNWInt("progress") >= 100 then
                self:SetNWInt("status", 2)

                self:SetBeer(
                    self:GetNWInt("needed_beer")
                )
            end

        elseif status == 3 then

            local jarsCount = self:GetNWInt("EmptyJars")

            if self:GetBeer() > 0 and jarsCount > 0 then

                local ed = EffectData()
                ed:SetOrigin(
                    self:LocalToWorld(Vector(-22, -35, 18))
                )
                ed:SetScale(1)

                util.Effect("WaterSplash", ed)

                local fillSpeed = 25

                self:SetNWInt(
                    "fill_progress",
                    self:GetNWInt("fill_progress") + fillSpeed
                )

                self:EmitSound(
                    "ambient/water/water_spray" ..
                    math.random(1, 3) ..
                    ".wav",
                    55,
                    120
                )

                if self:GetNWInt("fill_progress") >= 100 then

                    local b = ents.Create("alco_moonshine")

                    if IsValid(b) then
                        b:SetPos(
                            self:LocalToWorld(Vector(-22, -35, 7))
                        )

                        b:SetAngles(self:GetAngles())

                        b:Spawn()

                        local phys = b:GetPhysicsObject()

                        if IsValid(phys) then
                            phys:SetVelocity(
                                self:GetForward() * -60
                            )
                        end
                    end

                    self:SetBeer(self:GetBeer() - 1)

                    self:SetNWInt(
                        "EmptyJars",
                        jarsCount - 1
                    )

                    self:SetNWInt("fill_progress", 0)

                    if self:GetBeer() <= 0 then
                        self:SetNWInt("progress", 0)
                        self:SetNWInt("status", 0)

                        self:SetBraga(0)
                    end
                end
            end
        end

        self.progressTime = curTime + 1
    end

    return true
end

local useTable = {

    [0] = function(self)

        if self:GetBraga() <= 0 then return end

        self:SetNWInt("status", 1)

        self:SetNWInt(
            "needed_beer",
            self:GetBraga()
        )

        self:EmitSound("buttons/button1.wav")
    end,

    [2] = function(self)

        if self:GetBeer() <= 0 then return end

        self:SetNWInt("status", 3)

        self:EmitSound("buttons/lever7.wav")
    end,
}

function ENT:Use(activator)
    local status = self:GetNWInt("status")

    if useTable[status] then
        useTable[status](self)
    end
end

function ENT:OnRemove()

    if IsValid(self.shelfProp) then
        self.shelfProp:Remove()
    end

    for _, jar in pairs(self.jarModels) do
        if IsValid(jar) then
            jar:Remove()
        end
    end
end
local fancyrain = CreateClientConVar("atmos_cl_rainsplash", 1, true, false)
local clouds = CreateClientConVar("atmos_cl_rainclouds", 1, true, false)
local maxrain = CreateClientConVar("atmos_cl_rainperparticle", 16, true, false)
local maxrainheight = CreateClientConVar("atmos_cl_maxrainheight", 180, true, false)
local dieTime = CreateClientConVar("atmos_cl_raindietime", 5, true, false)

function atmos_Outside( pos )
	if ( pos != nil ) then
		local trace = { };
		trace.start = pos;
		trace.endpos = trace.start + Vector( 0, 0, 32768 );
		trace.mask = MASK_BLOCKLOS;

		local tr = util.TraceLine( trace );

		AtmosHeightMin = ( tr.HitPos - trace.start ):Length();

		if ( tr.StartSolid ) then return false end
		if ( tr.HitSky ) then return true end
	end
	return false;
end

function atmos_outside( pos )
	return atmos_Outside( pos );
end

function EFFECT:Init(data)
    -- КОПИРУЕМ данные из CEffectData сразу, не сохраняем сам data!
    self.Origin = data:GetOrigin()
    self.Magnitude = data:GetMagnitude()
    self.Radius = data:GetRadius()

    self.em3D = ParticleEmitter(self.Origin, true)
    self.em2D = ParticleEmitter(self.Origin)
    self.Live = true
end

function EFFECT:Think()
    if not AtmosStorming then
        self:Die()
        return false
    end

    if not self.Live then
        return false
    end

    -- Обновляем позицию эмиттеров относительно игрока (как предполагалось)
    local playerPos = LocalPlayer():GetPos()
    self.Origin = Vector(playerPos.x, playerPos.y, self.Origin.z) -- сохраняем высоту облаков

    local m = 512 -- или self.Magnitude, если нужно
    local n = self.Radius

    if self.em3D then
        self.em3D:SetPos(self.Origin)

        for i = 1, maxrain:GetInt() do
            local pos = self.Origin + Vector(
                math.random(-m, m),
                math.random(-m, m),
                math.min(maxrainheight:GetInt(), math.random(m, 2 * m))
            )

            if atmos_Outside(pos) then
                local p = self.em3D:Add("atmos/water_drop", pos)
                if p then
                    p:SetAngles(Angle(0, 0, -90))
                    p:SetVelocity(Vector(0, 0, -1000))
                    p:SetDieTime(dieTime:GetInt())
                    p:SetStartAlpha(230)
                    p:SetStartSize(4)
                    p:SetEndSize(4)
                    p:SetColor(255, 255, 255)

                    if fancyrain:GetInt() >= 1 then
                        p:SetCollide(true)
                        p:SetCollideCallback(function(part, hitPos, normal)
                            if render.GetDXLevel() > 90 and fancyrain:GetInt() >= 1 and math.random(1, 10) == 1 then
                                local ed = EffectData()
                                ed:SetOrigin(hitPos)
                                util.Effect("atmos_rainsplash", ed)
                            end
                            part:SetDieTime(0)
                        end)
                    end
                end
            end
        end
    end

    if self.em2D then
        self.em2D:SetPos(self.Origin)

        if clouds:GetInt() >= 1 and math.random() < 0.5 then
            local pos = self.Origin + Vector(
                math.random(-m, m),
                math.random(-m, m),
                math.min(maxrainheight:GetInt(), math.random(m, 2 * m))
            )

            if atmos_Outside(pos) then
                local p = self.em2D:Add("atmos/rainsmoke", pos)
                if p then
                    p:SetVelocity(Vector(0, 0, -1000))
                    p:SetDieTime(5)
                    p:SetStartAlpha(6)
                    p:SetStartSize(166)
                    p:SetEndSize(166)
                    p:SetColor(150, 150, 200)
                    p:SetCollide(true)
                    p:SetCollideCallback(function(part)
                        part:SetDieTime(0)
                    end)
                end
            end
        end
    end

    return true
end

function EFFECT:Die()
    if not self.Live then return end
    self.Live = false

    if self.em3D then
        self.em3D:Finish()
        self.em3D = nil
    end
    if self.em2D then
        self.em2D:Finish()
        self.em2D = nil
    end
end

function EFFECT:Render()
end
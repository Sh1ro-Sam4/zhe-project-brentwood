/*
    https://github.com/XenPare/gmod-xpgui/blob/master/lua/xpgui/surface.lua
*/

shizlib.surface = shizlib.surface or {}

local scrW, scrH
local cos, sin, pi =  math.cos, math.sin, math.pi

--(1 - t) * from + t * to
function shizlib.surface.LerpColor(t, from, to)
	return Color(
		(1 - t) * from.r + t * to.r,
		(1 - t) * from.g + t * to.g,
		(1 - t) * from.b + t * to.b,
		(1 - t) * from.a + t * to.a
	)
end

function shizlib.surface.FormatTime(time)
    local s = time % 60
    time = math.floor(time / 60)
    local m = time % 60
    time = math.floor(time / 60)
    local h = time % 24
    time = math.floor(time / 24)
    local d = time % 7

    if d >= 1 then
        return string.format("%id %02ih %02im", d, h, m)
    elseif d < 1 and h >= 1 then
        return string.format("%02ih %02im", h, m)
    elseif h < 1 and m >= 1 and s > 0 then
        return string.format("%02im %02is", m, s)
    elseif h < 1 and m >= 1 then
        return string.format("%02im", m)
	elseif m < 1 and h < 1 and d < 1 and s >= 0 then
        return string.format("%02is", s)
	else
		return string.format("%id %02ih %02is", s)
    end
end

function shizlib.surface.clickSound()
	sound.PlayURL('http://46.174.49.71/basewars/click.mp3', 'mono', function(a)
		if not IsValid(a) then return end
		a:SetPos(LocalPlayer():GetPos())
		a:SetVolume(10)
		a:Play()
	end)
end

local pan_x, pan_y
local blur = Material("pp/blurscreen")
function shizlib.surface.DrawPanelBlur(panel, amount)
	pan_x, pan_y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor(color_white)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(pan_x * -1, pan_y * -1, ScrW(), ScrH())
	end
end

function shizlib.surface.PrecacheRoundedRect(x, y, w, h, r, seg)
	local min = (w > h and h or w) * 0.5
	r = r > min and min or r

	local poly = {}
	for i = 0, seg do
		local a = pi * 0.5 * i / seg
		local cosine, sine = r * cos(a), r * sin(a)
		poly[i+1] = {
			x = x + r - cosine,
			y = y + r - sine
		}
		poly[i + seg + 1] = {
			x = x + w - r + sine,
			y = y + r - cosine
		}
		poly[i + seg * 2 + 1] = {
			x = x + w - r + cosine,
			y = y + h - r + sine
		}
		poly[i + seg * 3 + 1] = {
			x = x + r - sine,
			y = y + h - r + cosine
		}
	end
	return poly
end

/*
	kasanov
*/

function shizlib.surface.DTR(x, y, w, h, col, icon)
    if type(icon) == "string" then
        icon = Material(icon)
    end
    surface.SetMaterial(icon)
    surface.SetDrawColor(col)
    surface.DrawTexturedRect(x, y, w, h)
end

function shizlib.surface.s(y)
    local scrW, scrH = ScrW(), ScrH()
	if scrH >= 1440 then
		return math.Round(y * math.min(scrW, scrH) / 1080)
	else
		return math.Round(y * math.min(scrW, scrH) / 1080)
	end
end

local math = CLIENT and math
local math_Round = CLIENT and math.Round
local string = string
local string_format = string.format

local registerFonts = function()
	for i = 1, 140 do
		local sizee = i
		local size = math_Round(i / 1920 * ScrW())
		surface.CreateFont( string_format("font.%s", sizee), {
			font = 'Inter Bold',
			antialias = true,
			extended = true;
			size = size,
			weight = i > 14 and 1000 or 500,
		} )
	end
end
concommand.Add("shizlib_font_reload", registerFonts)
registerFonts()

do
    local newfont = surface.CreateFont
    local s = shizlib.surface.s

    newfont('IB_14', {
        font = 'Inter Bold',
        weight = 500,
        size = s(16),
        extended = true,
    })

    newfont('IB_15', {
        font = 'Inter Bold',
        weight = 500,
        size = s(17),
        extended = true,
    })

    newfont('IB_16', {
        font = 'Inter Bold',
        weight = 500,
        size = s(18),
        extended = true,
    })

    newfont('IB_20', {
        font = 'Inter Bold',
        weight = 500,
        size = s(22),
        extended = true,
    })

    newfont('IB_25', {
        font = 'Inter Bold',
        weight = 500,
        size = s(27),
        extended = true,
    })

    newfont('IB_32', {
        font = 'Inter Bold',
        weight = 500,
        size = s(34),
        extended = true,
    })

    newfont('IR_60', {
        font = 'Imprima',
        weight = 500,
        size = s(62),
        extended = true,
    })
end

/*
	Special THX: c0nfuse (right using chatGPT)
*/

function shizlib.surface.DrawRightRect(centerX, centerY, maxW, maxH, col, icon)
    local texW = icon:Width()
    local texH = icon:Height()
    local aspectRatio = texW / texH
    local drawW, drawH

    if texW > texH then
        drawW = math.min(maxW, texW)
        drawH = drawW / aspectRatio
    else
        drawH = math.min(maxH, texH)
        drawW = drawH * aspectRatio
    end
    
    local drawX = centerX - drawW / 2
    local drawY = centerY - drawH / 2
    
    surface.SetMaterial(icon)
    surface.SetDrawColor(col)
    surface.DrawTexturedRect(drawX, drawY, drawW, drawH)
end

do
	local IsExists, CreateDir, cachedMats, Fetch, CRC, Write, Read, format, sub = file.Exists, file.CreateDir, {}, http.Fetch, util.CRC, file.Write, file.Read, string.format, string.sub

	local _PATH, PATH, Material = 'data/surfTextures/%s.png', 'GAME', Material
	local ERROR = Material 'error'

	CreateDir 'surfTextures'

	local function checkRel(link, aSum)
		local uName = format(_PATH, aSum)
		local dat = Read(uName, PATH) or ''
		cachedMats[link] = ERROR
		Fetch(link, function(res)
			local crcRes = CRC(res)
			local oldRes = CRC(dat)
			if crcRes ~= oldRes then
				Write( sub(uName,6), res)
				print( format('EM > CheckSum Updated (%s, %s)', crcRes, oldRes) )
			end
			local mat = Material(uName)
			cachedMats[link] = mat
			return mat
		end)
	end

	function surface.GetWeb( link )
		if cachedMats[link] then return cachedMats[link] end

		local checkSum = CRC(link)
		return checkRel(link, checkSum) or ERROR
	end

	function surface.GetWebCache()
		return cachedMats
	end
end

-- I try too hard
local LocalPlayer = LocalPlayer
local ENTITY = FindMetaTable('Entity')
local GetPos = ENTITY.GetPos
local EyePos = ENTITY.EyePos
local VECTOR = FindMetaTable('Vector')
local DistToSqr = VECTOR.DistToSqr
local IsLineOfSightClear = ENTITY.IsLineOfSightClear
local util_TraceLine = util.TraceLine
local PLAYER = FindMetaTable('Player')
local GetAimVector = PLAYER.GetAimVector
local DotProduct = VECTOR.DotProduct
local lp
 
local trace = {
    mask = -1,
    filter = {}
}
 
-- Check if the ent is in your line of sight, fastish
function ENTITY:InSight()
    return false
end
 
function PLAYER:InSight()
    return false
end
 
-- Check if the ent is in your line of sight, very slow
function ENTITY:InTrace()
    return false
end
 
function PLAYER:InTrace()
    return false
end
 
-- Check if the ent is on your screen, very fast
function ENTITY:InView()
    return false
end
 
function ENTITY:InDistance()
    return false
end
 
hook.Add('Think', 'VisChecks', function()
    if IsValid(LocalPlayer()) then
        lp = LocalPlayer()
        trace.filter[1] = LocalPlayer()

        function ENTITY:InSight()
            if (DistToSqr(GetPos(self), GetPos(lp)) < 250000) then return IsLineOfSightClear(lp, self) end

            return false
        end

        function PLAYER:InSight()
            if (DistToSqr(EyePos(self), EyePos(lp)) < 250000) then return IsLineOfSightClear(lp, self) end

            return false
        end

        function ENTITY:InTrace()
            trace.start = EyePos(lp)
            trace.endpos = GetPos(self)
            trace.filter[2] = self

            return not util_TraceLine(trace).Hit
        end

        function PLAYER:InTrace()
            trace.start = EyePos(lp)
            trace.endpos = EyePos(self)
            trace.filter[2] = self

            return not util_TraceLine(trace).Hit
        end

        function ENTITY:InView()
            return (DotProduct(GetPos(self) - GetPos(lp), GetAimVector(lp)) > 0)
        end

        function ENTITY:InDistance(maxDistance)
            local dist = DistToSqr(GetPos(self), GetPos(lp))

            return (dist < (maxDistance or 250000)), dist
        end

        hook.Remove('Think', 'VisChecks')
    end
end)
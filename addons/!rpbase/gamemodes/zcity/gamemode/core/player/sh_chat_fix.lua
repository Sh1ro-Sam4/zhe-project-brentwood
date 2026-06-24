ba = ba or {}

local function writeargs(...)
	for k, v in ipairs({...}) do
		local t = type(v)
		if (t == 'Player') then
			net.WriteUInt(0, 2)
			net.WritePlayer(v)
		elseif (t == 'Entity') then
			net.WriteUInt(1, 2)
		elseif (t == 'Number') then
			net.WriteUInt(2, 2)
			net.WriteUInt(v, 32)
		else
			net.WriteUInt(3, 2)
			net.WriteString(tostring(v))
		end
	end
end

local color_red 	= Color(255,0,0)
local color_white 	= Color(235,235,235)
local color_console = Color(200,200,200)
local color_green 	= Color(175,255,175)
local color_grey 	= Color(190,190,190)

local function readtype(input)
	local t = net.ReadUInt(2)
	if (t == 0) then
		local v = net.ReadPlayer()
		if IsValid(v) then
			table.insert(input, team.GetColor(v:Team()))
			table.insert(input, v:Name())
			table.insert(input, color_grey)
			table.insert(input,'(' .. v:SteamID() .. ')')
			table.insert(input, color_white)
		else
			table.insert(input, color_console)
			table.insert(input, 'Unknown')
			table.insert(input, color_white)
		end
	elseif (t == 1) then
		local v = net.ReadEntity()
		table.insert(input, color_console)

		if isentity(v) and v:IsWorld() then
			table.insert(input, '(Console)')
		else
			table.insert(input, IsValid(v) and (v.PrintName or v:GetClass()) or 'Unknown Entity')
		end

		table.insert(input, color_white)
	else
		local val = (t == 2 and tostring(net.ReadUInt(32)) or net.ReadString())
		table.insert(input, color_green)
		table.insert(input, val)
		table.insert(input, color_white)
	end
end

local needle = '#'
local function readargs(msg)
	local ret = {color_white}

	local startp, endp, lastp, isfristpss = 1, 1, 1, true

	if (msg:sub(1, 1) == needle) then
		readtype(ret)
		endp = endp + 1
		lastp = endp
	end

	while (true) do
		endp = endp + 1
		startp, endp = msg:find(needle, endp)

		if (endp == nil) then
			if (not isfristpss) then
				readtype(ret)
			end
			if (msg:sub(lastp):Trim() ~= '') then
				table.insert(ret, msg:sub(lastp))
			end
			break
		end

		if (not isfristpss) then
			readtype(ret)
		end

		table.insert(ret, msg:sub(lastp, endp - 1))
		lastp = endp + 1
		isfristpss = false
	end

	return ret
end

function ba.ReadTerm()
	return readargs(term.GetString(net.ReadUInt(10)))
end

-- Messages
function ba.WriteMsg(msg, ...)
	net.WriteString(msg)
	writeargs(...)
end

function ba.ReadMsg()
	return readargs(net.ReadString())
end
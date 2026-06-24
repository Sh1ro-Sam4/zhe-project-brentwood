local receivers = {}
local currentMode = "chat"
local chatText = {}
local modes = {}

local function addChatMode(name, label, func)
    modes[name] = {
        label = label,
        canHear = func
    }
end

-- local function getReceivers()
--     receivers = {}
    
--     if not modes[currentMode] then return end
    
--     local hearFunc = modes[currentMode].canHear
--     if not hearFunc then return end
    
--     for _, ply in ipairs(player.GetAll()) do
--         if not IsValid(ply) or ply == LocalPlayer() or ply:GetNoDraw() then continue end
        
--         local canHear = hearFunc(ply, chatText)
--         if canHear == true then
--             table.insert(receivers, ply)
--         end
--     end
-- end

-- local function drawReceivers()
--     if not receivers then return end
    
--     local font = "ui.22"
--     surface.SetFont(font)
--     local fontHeight = surface.GetTextSize("A")
--     local x, y = chat.GetChatBoxPos()
--     local startY = y - fontHeight - 22
--     local receiversCount = #receivers
    
--     if receiversCount == 0 then
--         draw.WordBox(4, x, startY, "Вас никто не слышит", font, Color(0, 0, 0, 180), Color(255, 50, 50, 255))
--         return
--     elseif receiversCount == player.GetCount() - 1 then
--         draw.WordBox(4, x, startY, "Все слышат вас!", font, Color(0, 0, 0, 180), Color(50, 200, 50, 255))
--         return
--     end

--     draw.WordBox(4, x, startY - (receiversCount * (fontHeight + 22)), "Вас слышат:", font, Color(0, 0, 0, 180), Color(50, 200, 50, 255))
    
--     for i = 1, receiversCount do
--         if not IsValid(receivers[i]) then continue end
--         draw.WordBox(4, x, startY - ((i - 1) * (fontHeight + 22)), receivers[i]:GetPlayerName(), font, Color(0, 0, 0, 180), color_white)
--     end
-- end

-- local function onChatStart()
    -- currentMode = "chat"
    -- hook.Add("Think", "ChatReceiversThink", getReceivers)
    -- hook.Add("HUDPaint", "ChatReceiversDraw", drawReceivers)
-- end
-- hook.Add("StartChat", "ChatReceiversStart", onChatStart)

-- local function onChatFinish()
--     hook.Remove("Think", "ChatReceiversThink")
--     hook.Remove("HUDPaint", "ChatReceiversDraw")
--     receivers = nil
-- end
-- hook.Add("FinishChat", "ChatReceiversStop", onChatFinish)

-- local function onVoiceStart(ply)
--     if ply ~= LocalPlayer() then return end
--     currentMode = "voice"
--     hook.Add("Think", "ChatReceiversThink", getReceivers)
--     hook.Add("HUDPaint", "ChatReceiversDraw", drawReceivers)
-- end
-- hook.Add("PlayerStartVoice", "VoiceReceiversStart", onVoiceStart)

-- local function onVoiceEnd(ply)
--     if ply ~= LocalPlayer() then return end
--     onChatFinish()
-- end
-- hook.Add("PlayerEndVoice", "VoiceReceiversStop", onVoiceEnd)

addChatMode("chat", "обычный чат", function(ply)
    return LocalPlayer():GetPos():Distance(ply:GetPos()) < cfg.chatdist
end)

addChatMode("voice", "голосовой чат", function(ply)
    return LocalPlayer():GetPos():Distance(ply:GetPos()) < cfg.chatdist
end)
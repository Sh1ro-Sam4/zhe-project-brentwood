-- local developer = GetConVar("developer")
-- local cl_animated_avatars = CreateClientConVar("cl_animated_avatars", "1", true, false, "Enable/disable animated avatars in-game (changing will require rejoining)", 0, 1)

-- file.CreateDir("animated_avatars")

-- local vmtSrc = file.Read("data_static/animated_avatars/animated_avatarimage.vmt.txt", "GAME")
-- local wasm = util.Base64Encode(file.Read("data_static/animated_avatars/wasm_gif_to_vtf.wasm.dat", "GAME"), true)
-- local wasmJs = file.Read("data_static/animated_avatars/wasm_gif_to_vtf.js.txt", "GAME")
-- local wasmHtml = file.Read("data_static/animated_avatars/wasm_gif_to_vtf.html.txt", "GAME")
-- wasmHtml = wasmHtml:gsub("\"%%WASM_JS%%\"", wasmJs)
-- wasmHtml = wasmHtml:gsub("%%WASM_BASE64%%", wasm)

-- local animatedAvatars = {}
-- local playerAvatarUrlCache = {}

-- do
--     local f = file.Find("animated_avatars/*.vmt", "DATA")
--     for _, vmtPath in ipairs(f) do
--         local avatarUrlHash = string.StripExtension(vmtPath)
--         local material = Material("../data/animated_avatars/" .. avatarUrlHash)
--         if material and not material:IsError() then
--             animatedAvatars[avatarUrlHash] = material
--         end
--     end
-- end

-- if IsValid(AnimatedAvatarImage_DHTML) then
--     AnimatedAvatarImage_DHTML:Remove()
-- end

-- local function getDHTML()
--     if not IsValid(AnimatedAvatarImage_DHTML) then
--         local queue = {}

--         AnimatedAvatarImage_DHTML = vgui.Create("DHTML")
--         AnimatedAvatarImage_DHTML.Paint = function() end
--         AnimatedAvatarImage_DHTML:SetMouseInputEnabled(false)
--         AnimatedAvatarImage_DHTML:SetKeyboardInputEnabled(false)
--         AnimatedAvatarImage_DHTML:SetHTML(wasmHtml)

--         AnimatedAvatarImage_DHTML:AddFunction("window", "wasmGifToVtf_Ready", function()
--             local q = queue
--             queue = nil
--             for _, args in ipairs(q) do
--                 AnimatedAvatarImage_DHTML:QueueGifToVtf(unpack(args))
--             end
--         end)

--         AnimatedAvatarImage_DHTML:AddFunction("window", "wasmGifToVtf_Callback", function(succOrErr, data, avatarUrlHash, steamid64)
--             if isstring(succOrErr) or data == nil then
--                 if developer:GetBool() then
--                     print("[AnimatedAvatarImage] Failed to convert GIF to VTF for " .. steamid64 .. ": " .. (succOrErr or "unknown error"))
--                 end
--                 return
--             end

--             local avgDelay, vtfBase64 = string.match(data, "(.-):(.*)")

--             local vtf = util.Base64Decode(vtfBase64)
--             local vmt = vmtSrc
--                 :gsub("%%BASETEXTURE%%", avatarUrlHash)
--                 :gsub("%%FRAMERATE%%", tostring(1 / tonumber(avgDelay)))

--             file.Write("animated_avatars/" .. avatarUrlHash .. ".vtf", vtf)
--             file.Write("animated_avatars/" .. avatarUrlHash .. ".vmt", vmt)

--             local material = Material("../data/animated_avatars/" .. avatarUrlHash)
--             if not material or material:IsError() then
--                 if developer:GetBool() then
--                     print("[AnimatedAvatarImage] Got animated avatar material error for " .. steamid64)
--                 end
--                 return
--             end

--             animatedAvatars[avatarUrlHash] = material
--         end)

--         function AnimatedAvatarImage_DHTML:QueueGifToVtf(gifData, avatarUrlHash, steamid64)
--             if queue then
--                 queue[#queue + 1] = {gifData, avatarUrlHash, steamid64}
--             else
--                 AnimatedAvatarImage_DHTML:QueueJavascript("window.wasmGifToVtf(\"" .. util.Base64Encode(gifData, true) .. "\", \"" .. avatarUrlHash .. "\", \"" .. steamid64 .. "\")")
--             end
--         end
--     end

--     return AnimatedAvatarImage_DHTML
-- end

-- local PANEL = {}

-- AccessorFunc(PANEL, "vertices", "Vertices", FORCE_NUMBER)
-- AccessorFunc(PANEL, "rotation", "Rotation", FORCE_NUMBER)

-- function PANEL:Init()
--     self.rotation = 0
--     self.vertices = 30
--     self.scaler = 1
    
--     if cl_animated_avatars:GetBool() then
--         self.avatar = vgui.Create("AvatarImage", self)
--         self.avatar:SetPaintedManually(true)
--     else
--         self.avatar = vgui.Create("AvatarImage", self)
--         self.avatar:SetPaintedManually(true)
--     end
    
--     self.m_AnimatedAvatarSteamID64 = nil
--     self.m_AnimatedAvatarUrlHash = nil
-- end

-- function PANEL:CalculatePoly(w, h)
--     local poly = {}
--     local x = w / 2
--     local y = h / 2 * self.scaler
--     local radius = h / 2

--     table.insert(poly, {x = x, y = y})

--     for i = 0, self.vertices do
--         local a = math.rad((i / self.vertices) * -360) + self.rotation
--         table.insert(poly, {
--             x = x + math.sin(a) * radius,
--             y = y + math.cos(a) * (radius * self.scaler)
--         })
--     end

--     local a = math.rad(0)
--     table.insert(poly, {
--         x = x + math.sin(a) * radius,
--         y = y + math.cos(a) * (radius * self.scaler)
--     })
--     self.data = poly
-- end

-- function PANEL:PerformLayout(w, actualH)
--     local h = self:GetTall()
--     if (self.scaler < 1) then
--         h = h * self.scaler
--     end

--     self.avatar:SetPos(0, h - actualH)
--     self.avatar:SetSize(self:GetWide(), actualH)
--     self:CalculatePoly(self:GetWide(), self:GetTall())
-- end

-- function PANEL:SetPlayer(ply, size)
--     if cl_animated_avatars:GetBool() then
--         self:LoadAnimatedAvatar(IsValid(ply) and ply:SteamID64() or nil, size)
--     end
--     self.avatar:SetPlayer(ply, size)
-- end

-- function PANEL:SetSteamID(sid64, size)
--     if cl_animated_avatars:GetBool() then
--         self:LoadAnimatedAvatar(sid64, size)
--     end
--     self.avatar:SetSteamID(sid64, size)
-- end

-- function PANEL:DrawPoly(w, h)
--     if (!self.data) then
--         self:CalculatePoly(w, h)
--     end
--     surface.DrawPoly(self.data)
-- end

-- function PANEL:LoadAnimatedAvatar(steamid64, size)
--     if not steamid64 or not isstring(steamid64) or self.m_AnimatedAvatarSteamID64 == steamid64 or string.match(steamid64, "^7656119%d+$") == nil then
--         return
--     end

--     self.m_AnimatedAvatarSteamID64 = steamid64
--     self.m_AnimatedAvatarUrlHash = nil

--     local cached = playerAvatarUrlCache[steamid64]
--     if cached ~= nil then
--         self:OnSteamProfileFetched(steamid64, cached, 200)
--     else
--         http.Fetch("https://steamcommunity.com/profiles/" .. steamid64, function(body, len, headers, code)
--             if (not IsValid(self)) then return end
--             self:OnSteamProfileFetched(steamid64, body, code)
--         end)
--     end
-- end

-- function PANEL:OnSteamProfileFetched(steamid64, body, code)
--     if not body or code ~= 200 or not isstring(body) then
--         playerAvatarUrlCache[steamid64] = false
--         if developer:GetBool() then
--             print("[AnimatedAvatarImage] Failed to fetch Steam profile for " .. steamid64)
--         end
--         return
--     else
--         playerAvatarUrlCache[steamid64] = body
--     end

--     if self.m_AnimatedAvatarSteamID64 ~= steamid64 then return end

--     local avatarUrl = body:gsub("\n", ""):gmatch("<div class=\"playerAvatar.-<img srcset=\"(.-%.gif)\"")()

--     if not avatarUrl then
--         if developer:GetBool() then
--             print("[AnimatedAvatarImage] No animated avatar found in HTML for " .. steamid64)
--             file.Write("animated_avatar_debug_" .. steamid64 .. ".html.txt", body)
--         end
--         return
--     end

--     self.m_AnimatedAvatarUrlHash = util.MD5(avatarUrl)

--     if animatedAvatars[self.m_AnimatedAvatarUrlHash] then
--         return
--     else
--         animatedAvatars[self.m_AnimatedAvatarUrlHash] = "loading/error"
--     end

--     http.Fetch(avatarUrl, function(gifData, gifLen, gifHeaders, gifCode)
--         if (not IsValid(self)) then return end
--         self:OnAvatarGifFetched(steamid64, avatarUrl, gifData, gifCode)
--     end)
-- end

-- function PANEL:OnAvatarGifFetched(steamid64, avatarUrl, data, code)
--     if not data or code ~= 200 or not isstring(data) then
--         if developer:GetBool() then
--             print("[AnimatedAvatarImage] Failed to fetch animated avatar GIF for " .. steamid64)
--         end
--         return
--     end

--     if self.m_AnimatedAvatarSteamID64 ~= steamid64 then return end
--     getDHTML():QueueGifToVtf(data, self.m_AnimatedAvatarUrlHash, steamid64)
-- end

-- function PANEL:Paint(w, h)
--     if cl_animated_avatars:GetBool() and self.m_AnimatedAvatarUrlHash then
--         local material = animatedAvatars[self.m_AnimatedAvatarUrlHash]
--         if type(material) == "IMaterial" then
--             render.ClearStencil()
--             render.SetStencilEnable(true)

--             render.SetStencilWriteMask(1)
--             render.SetStencilTestMask(1)

--             render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
--             render.SetStencilPassOperation(STENCILOPERATION_ZERO)
--             render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
--             render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
--             render.SetStencilReferenceValue(1)

--             draw.NoTexture()
--             surface.SetDrawColor(color_white)
--             self:DrawPoly(w, h)

--             render.SetStencilFailOperation(STENCILOPERATION_ZERO)
--             render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
--             render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
--             render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
--             render.SetStencilReferenceValue(1)

--             surface.SetMaterial(material)
--             surface.SetDrawColor(255, 255, 255, 255)
--             surface.DrawTexturedRect(0, 0, w, h)

--             render.SetStencilEnable(false)
--             render.ClearStencil()
--             return
--         end
--     end

--     render.ClearStencil()
--     render.SetStencilEnable(true)

--     render.SetStencilWriteMask(1)
--     render.SetStencilTestMask(1)

--     render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
--     render.SetStencilPassOperation(STENCILOPERATION_ZERO)
--     render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
--     render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
--     render.SetStencilReferenceValue(1)

--     draw.NoTexture()
--     surface.SetDrawColor(color_white)
--     self:DrawPoly(w, h)

--     render.SetStencilFailOperation(STENCILOPERATION_ZERO)
--     render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
--     render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
--     render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
--     render.SetStencilReferenceValue(1)

--     self.avatar:PaintManual()

--     render.SetStencilEnable(false)
--     render.ClearStencil()
-- end

-- vgui.Register("SHZAvatarImage", PANEL)

-- if cl_animated_avatars:GetBool() then
--     ANIMATED_AVATARIMAGE_VGUI_CREATEX = ANIMATED_AVATARIMAGE_VGUI_CREATEX or vgui.CreateX
--     local creating = false

--     vgui.CreateX = function(classname, ...)
--         if not creating and classname == "AvatarImage" then
--             creating = true
--             local succ, err = pcall(vgui.Create, "SHZAvatarImage", ...)
--             creating = false
--             if not succ then
--                 error(err, 2)
--             end
--             return err
--         end
--         return ANIMATED_AVATARIMAGE_VGUI_CREATEX(classname, ...)
--     end
-- end
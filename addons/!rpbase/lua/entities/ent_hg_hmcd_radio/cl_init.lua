include("shared.lua")
local Presets = {
	-- === РОССИЙСКИЕ РАДИОСТАНЦИИ ===
	{name = "Европа Плюс", genre = "Pop/Hits", url = "https://ep256.hostingradio.ru:8052/ep256.mp3"},
	{name = "Русское Радио", genre = "Russian Pop", url = "https://rusradio.hostingradio.ru/rusradio128.mp3"},
	{name = "DFM", genre = "Dance/Club", url = "https://dfm.hostingradio.ru/dfm128.mp3"},
	{name = "Наше Радио", genre = "Russian Rock", url = "https://nashe1.hostingradio.ru/nashe-128.mp3"},
	{name = "Ретро FM", genre = "80s/90s/00s", url = "https://retroserver.streamr.ru:8043/retro256.mp3"},
	{name = "Дорожное Радио", genre = "Chanson/Pop", url = "https://dorognoe.hostingradio.ru:8027/dorognoe128.mp3"},
	{name = "Радио Record", genre = "EDM/Dance", url = "https://radiorecord.hostingradio.ru/rr_main96.aacp"},
	{name = "Record Russian Mix", genre = "Rus Dance", url = "https://radiorecord.hostingradio.ru/rus_96.aacp"},
	{name = "Радио ENERGY", genre = "Pop/Dance", url = "https://pub0201.101.ru:8000/stream/air/aac/64/99"},

	-- === ЗАРУБЕЖНЫЕ И ТЕМАТИЧЕСКИЕ (Рабочие) ===
	{name = "Lofi Girl (Chill Beats)", genre = "Chill/Lofi", url = "https://play.streamafrica.net/lofiradio"},
	{name = "Synthwave / Retrowave", genre = "Retro Electronic", url = "https://stream.nightride.fm/nightride.mp3"},
	{name = "Cyberpunk / Darksynth", genre = "Dark Electronic", url = "https://stream.nightride.fm/chillsynth.mp3"},
	
	-- Станции от сети 181.fm (очень стабильные потоки)
	{name = "Classic Rock (181.fm)", genre = "Rock", url = "http://listen.181fm.com/181-eagle_128k.mp3"},
	{name = "Hard Rock & Metal", genre = "Metal", url = "http://listen.181fm.com/181-hardrock_128k.mp3"},
	{name = "Awesome 80s", genre = "80s Hits", url = "http://listen.181fm.com/181-awesome80s_128k.mp3"},
	{name = "90s Alternative", genre = "90s Rock/Pop", url = "http://listen.181fm.com/181-90salternative_128k.mp3"},
	{name = "The Beat (HipHop & R&B)", genre = "Hip Hop", url = "http://listen.181fm.com/181-beat_128k.mp3"},
	{name = "Energy 98 (Dance Hits)", genre = "Eurodance", url = "http://listen.181fm.com/181-energy98_128k.mp3"},
	{name = "Chilled Out", genre = "Ambient/Chill", url = "http://listen.181fm.com/181-chilled_128k.mp3"},
	
	-- Джаз и Классика
	{name = "Smooth Jazz (Рабочий)", genre = "Jazz", url = "http://smoothjazz.cdnstream1.com/2585_128.mp3"},
	{name = "Classical Music", genre = "Classical", url = "http://live-icecast.omroep.nl/radio4-bb-mp3"},
	
	-- Аниме и Игры
	{name = "Anime Nexus", genre = "J-Pop/Anime", url = "http://radio.animenexus.mx:8000/animenexus"}
}
local history = {}
local function LoadHistory()
	if file.Exists("radio_history.txt", "DATA") then
		history = util.JSONToTable(file.Read("radio_history.txt", "DATA") or "") or {}
	end
end

local function SaveHistory()
	file.Write("radio_history.txt", util.TableToJSON(history))
end

local function AddToHistory(url)
	if not url or url == "" then return end
	for k, v in ipairs(history) do
		if v == url then
			table.remove(history, k)
			break
		end
	end
	table.insert(history, 1, url)
	if #history > 20 then
		table.remove(history)
	end
	SaveHistory()
end

hook.Add("NetworkEntityCreated", "Radiohuy", function(ent)
    if playingents[ent:EntIndex()] then
        local tbl = playingents[ent:EntIndex()]
        
        timer.Simple(0.2,function()
            if ent.PlayURL then
                ent:PlayURL(tbl[2],CurTime()-tbl[1])
            end
        end)
    end
end)

net.Receive("RadioChangeValue", function(len, ply)
	local val = net.ReadFloat()
	local index = net.ReadInt(32)

	if playingents[index] then
		if IsValid(playingents[index][3]) and not playingents[index][3]:IsBlockStreamed() then
			playingents[index][3]:SetTime(val)
		end
	end
end)

net.Receive("RadioChangeVolume", function(len, ply)
	local val = net.ReadFloat()
	local index = net.ReadInt(32)
	
	if playingents[index] then
		if IsValid(playingents[index][3]) then
			playingents[index][5] = val
		end
	end
end)

net.Receive("RadioPause", function(len, ply)
	local val = net.ReadBool()
	local index = net.ReadInt(32)
	
	if playingents[index] then
		if IsValid(playingents[index][3]) then
			if val then
				playingents[index][3]:Pause()
			else
				playingents[index][3]:Play()
			end
		end
	end
end)

net.Receive("RadioStop", function(len, ply)
	local index = net.ReadInt(32)
	
	if playingents[index] then
		if IsValid(playingents[index][3]) then
			playingents[index][3]:Stop()
			playingents[index][3] = nil
		end
	end
end)

net.Receive("RadioLooping", function(len, ply)
	local val = net.ReadBool()
	local index = net.ReadInt(32)
	
	if playingents[index] then
		if IsValid(playingents[index][3]) then
			playingents[index][3]:EnableLooping(val)
		end
	end
end)

local frame
local gradient_d = Material("vgui/gradient-d")
local blurMat = Material("pp/blurscreen")
local Dynamic = 0
local red = Color(150,0,0)

BlurBackground = BlurBackground or hg.DrawBlur

net.Receive("RadioURLInput", function()
	if IsValid(frame) then return end 
	LoadHistory()

	local ent = net.ReadEntity()
	frame = vgui.Create("DFrame")
	frame:SetSize(450, 400) 
	frame:SetPos(ScrW() / 2 - frame:GetWide() / 2,ScrH() + 500)
	frame:SetTitle(playingents[ent:EntIndex()] and ("Radio: In playing...") or "Radio")
	frame:MakePopup()
	frame:SetAlpha(0)
	frame.OnClose = function() frame = nil end 

	frame:MoveTo(ScrW() / 2 - frame:GetWide() / 2, ScrH() / 2 - frame:GetTall() / 2, 0.5, 0, 0.3, function() end)
	frame:AlphaTo( 255, 0.2, 0.1, nil )

	function frame:Close()
		self:MoveTo(ScrW() / 2 - frame:GetWide() / 2, ScrH()+ 500, 0.5, 0, 0.3, function()
			self:Remove()
		end)
		self:AlphaTo( 0, 0.1, 0, nil )
		self:SetKeyboardInputEnabled(false)
		self:SetMouseInputEnabled(false)
	end
	local sheet = vgui.Create("DPropertySheet", frame)
	sheet:Dock(FILL)
	local controlTab = vgui.Create("DPanel", sheet)
	controlTab.Paint = function() end

	local tEntryBG1 = vgui.Create("DPanel", controlTab)
	tEntryBG1:Dock(TOP)
	tEntryBG1:SetBackgroundColor(color_white)
	tEntryBG1:DockMargin(5,5,5,2.5)	
	tEntryBG1:SetSize(50,35)	

	local urlEntry = vgui.Create("DTextEntry", tEntryBG1)
	urlEntry:Dock( FILL )
	urlEntry:SetPlaceholderText( "Enter URL here..." )
	urlEntry:SetPaintBackground(false)

	local function SendPlayURL(url)
		if url == "" then return end
		net.Start("RadioURLInput")
		net.WriteString(url)
		net.WriteEntity(ent)
		net.SendToServer()
		AddToHistory(url)
		frame:Close()
	end

	urlEntry.OnEnter = function()
		SendPlayURL(urlEntry:GetValue())
	end

	local controlsPanel = vgui.Create("DPanel", controlTab)
	controlsPanel:Dock( TOP )
	controlsPanel:DockMargin(5,5,5,2.5)
	controlsPanel:SetSize(50,40)
	controlsPanel.Paint = function() end

	local playButton = vgui.Create("DButton", controlsPanel)
	playButton:SetText("Play")
	playButton:Dock( LEFT )
	playButton:DockMargin(1,2,1,2)		
	playButton:SetSize(90, 40)	
	playButton:SetTextColor(Color(255,255,255))
	playButton.DoClick = function()
		SendPlayURL(urlEntry:GetValue())
	end

	local stopButton = vgui.Create("DButton", controlsPanel)
	stopButton:SetText("Stop")
	stopButton:Dock( RIGHT )
	stopButton:DockMargin(1,2,1,2)			
	stopButton:SetSize(90, 40)	
	stopButton:SetTextColor(Color(255,255,255))
	stopButton.DoClick = function()
		net.Start("RadioStop")
		net.WriteEntity(ent)
		net.SendToServer()
		frame:Close()
	end

	local loopButton = vgui.Create("DButton", controlsPanel)
	loopButton:SetText("Looping")
	loopButton:Dock( RIGHT )
	loopButton:DockMargin(1,2,1,2)			
	loopButton:SetSize(90, 40)	
	loopButton:SetTextColor(Color(255,255,255))
	loopButton.DoClick = function()
		net.Start("RadioLooping")
		local snd = playingents[ent:EntIndex()] and playingents[ent:EntIndex()][3]
		net.WriteBool(IsValid(snd) and not snd:IsLooping() or false)
		net.WriteEntity(ent)
		net.SendToServer()
		frame:Close()
	end

	local pauseButton = vgui.Create("DButton", controlsPanel)
	pauseButton:SetText("Pause")
	pauseButton:Dock( FILL )
	pauseButton:DockMargin(1,2,1,2)		
	pauseButton:SetTextColor(Color(255,255,255))
	pauseButton.DoClick = function()
		net.Start("RadioPause")
		local snd = playingents[ent:EntIndex()] and playingents[ent:EntIndex()][3]
		net.WriteBool(IsValid(snd) and snd:GetState() != GMOD_CHANNEL_PAUSED or false)
		net.WriteEntity(ent)
		net.SendToServer()
		frame:Close()
	end

	if playingents[ent:EntIndex()] and IsValid(playingents[ent:EntIndex()][3]) then
		local lbl = vgui.Create( "DLabelURL", controlTab )
		lbl:Dock( TOP )
		lbl:DockMargin(10,5,5,2.5)	
		lbl:SetSize(50,30)	
		lbl:SetColor( Color( 255, 255, 255, 255 ) ) 
		lbl:SetText( ("Currently playing \n"..playingents[ent:EntIndex()][2]) ) 
		lbl:SetURL( playingents[ent:EntIndex()][2] )
	end
	if playingents[ent:EntIndex()] and IsValid(playingents[ent:EntIndex()][3]) then
		local DermaNumSlider = vgui.Create( "DNumSlider", controlTab )
		DermaNumSlider:Dock( TOP )
		DermaNumSlider:DockMargin(10,0,5,0)	
		DermaNumSlider:SetSize(50,35)	
		DermaNumSlider:SetText( "Time slider" )
		DermaNumSlider:SetMin( 0 )			
		DermaNumSlider:SetMax( playingents[ent:EntIndex()][3]:GetLength() )
		DermaNumSlider:SetDecimals( 2 )
		DermaNumSlider:SizeToContents()
		DermaNumSlider.isedited = false
		DermaNumSlider.OnValueChanged = function(self,val)
			if playingents[ent:EntIndex()][3]:IsBlockStreamed() then return end
			if self:IsEditing() then
				DermaNumSlider.isedited = true
				playingents[ent:EntIndex()][3]:SetTime(val)
			else
				if DermaNumSlider.isedited then
					net.Start("RadioChangeValue")
					net.WriteFloat(val)
					net.WriteInt(ent:EntIndex(),32)
					net.SendToServer()
					DermaNumSlider.isedited = false
				end
			end
		end

		playingents[ent:EntIndex()][4] = DermaNumSlider
		DermaNumSlider:SetValue( playingents[ent:EntIndex()][3]:GetTime() )
	end
	if playingents[ent:EntIndex()] and IsValid(playingents[ent:EntIndex()][3]) then
		local GlobalVolumeSlider = vgui.Create( "DNumSlider", controlTab )
		GlobalVolumeSlider:Dock( TOP )
		GlobalVolumeSlider:DockMargin(10,0,5,0)	
		GlobalVolumeSlider:SetSize(50,35)	
		GlobalVolumeSlider:SetText( "Global Vol (Everyone)" )
		GlobalVolumeSlider:SetMin( 0 )			
		GlobalVolumeSlider:SetMax( 200 )
		GlobalVolumeSlider:SetDecimals( 0 )
		GlobalVolumeSlider:SizeToContents()
		GlobalVolumeSlider.isedited = false
		GlobalVolumeSlider.OnValueChanged = function(self,val)
			if self:IsEditing() then
				GlobalVolumeSlider.isedited = true
				playingents[ent:EntIndex()][3]:SetVolume((val/100) * (playingents[ent:EntIndex()][6] or 1))
				playingents[ent:EntIndex()][5] = val/100
			else
				if GlobalVolumeSlider.isedited then
					net.Start("RadioChangeVolume")
					net.WriteFloat(val/100)
					net.WriteInt(ent:EntIndex(),32)
					net.SendToServer()
					GlobalVolumeSlider.isedited = false
				end
			end
		end
		GlobalVolumeSlider:SetValue( (playingents[ent:EntIndex()][5] or 1)*100 )
	end
	if playingents[ent:EntIndex()] and IsValid(playingents[ent:EntIndex()][3]) then
		local LocalVolumeSlider = vgui.Create( "DNumSlider", controlTab )
		LocalVolumeSlider:Dock( TOP )
		LocalVolumeSlider:DockMargin(10,0,5,0)	
		LocalVolumeSlider:SetSize(50,35)	
		LocalVolumeSlider:SetText( "My Volume (Local)" )
		LocalVolumeSlider:SetMin( 0 )			
		LocalVolumeSlider:SetMax( 100 )
		LocalVolumeSlider:SetDecimals( 0 )
		LocalVolumeSlider:SizeToContents()
		LocalVolumeSlider.OnValueChanged = function(self, val)
			playingents[ent:EntIndex()][6] = val / 100
			if IsValid(playingents[ent:EntIndex()][3]) then
				local globalVol = playingents[ent:EntIndex()][5] or 1
				playingents[ent:EntIndex()][3]:SetVolume(globalVol * (val / 100))
			end
		end
		LocalVolumeSlider:SetValue( (playingents[ent:EntIndex()][6] or 1)*100 )
	end

	sheet:AddSheet("Control", controlTab, "icon16/controller.png")
	local stationsTab = vgui.Create("DPanel", sheet)
	stationsTab:Dock(FILL)
	stationsTab.Paint = function() end

	local listStations = vgui.Create("DListView", stationsTab)
	listStations:Dock(FILL)
	listStations:SetMultiSelect(false)
	listStations:AddColumn("Name")
	listStations:AddColumn("Genre"):SetMaxWidth(120)

	for _, info in ipairs(Presets) do
		listStations:AddLine(info.name, info.genre)
	end

	listStations.OnRowSelected = function(lst, index, row)
		local selectedUrl = Presets[index].url
		urlEntry:SetValue(selectedUrl)
	end

	listStations.DoDoubleClick = function(lst, index, row)
		local selectedUrl = Presets[index].url
		SendPlayURL(selectedUrl)
	end

	local btnPlayStation = vgui.Create("DButton", stationsTab)
	btnPlayStation:Dock(BOTTOM)
	btnPlayStation:SetText("Play Selected Station")
	btnPlayStation:SetHeight(30)
	btnPlayStation:SetTextColor(Color(255,255,255))
	btnPlayStation.DoClick = function()
		local selectedLine = listStations:GetSelectedLine()
		if selectedLine then
			local url = Presets[selectedLine].url
			SendPlayURL(url)
		end
	end

	sheet:AddSheet("Radio Stations", stationsTab, "icon16/music.png")
	local historyTab = vgui.Create("DPanel", sheet)
	historyTab:Dock(FILL)
	historyTab.Paint = function() end

	local listHistory = vgui.Create("DListView", historyTab)
	listHistory:Dock(FILL)
	listHistory:SetMultiSelect(false)
	listHistory:AddColumn("URL")

	local function RefreshHistoryList()
		listHistory:Clear()
		for _, url in ipairs(history) do
			listHistory:AddLine(url)
		end
	end
	RefreshHistoryList()

	listHistory.OnRowSelected = function(lst, index, row)
		urlEntry:SetValue(row:GetValue(1))
	end

	listHistory.DoDoubleClick = function(lst, index, row)
		SendPlayURL(row:GetValue(1))
	end

	local historyBottomPanel = vgui.Create("DPanel", historyTab)
	historyBottomPanel:Dock(BOTTOM)
	historyBottomPanel:SetHeight(35)
	historyBottomPanel.Paint = function() end

	local btnClearHistory = vgui.Create("DButton", historyBottomPanel)
	btnClearHistory:Dock(LEFT)
	btnClearHistory:SetText("Clear History")
	btnClearHistory:SetWidth(150)
	btnClearHistory:SetTextColor(Color(255,255,255))
	btnClearHistory.DoClick = function()
		history = {}
		SaveHistory()
		RefreshHistoryList()
	end

	local btnPlayHistory = vgui.Create("DButton", historyBottomPanel)
	btnPlayHistory:Dock(FILL)
	btnPlayHistory:SetText("Play Selected")
	btnPlayHistory:SetTextColor(Color(255,255,255))
	btnPlayHistory.DoClick = function()
		local selected = listHistory:GetSelected()
		if selected and selected[1] then
			SendPlayURL(selected[1]:GetValue(1))
		end
	end

	sheet:AddSheet("History", historyTab, "icon16/time.png")
end)

local FFTs
function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang:RotateAroundAxis( self:GetUp(), 90 )
	ang:RotateAroundAxis( self:GetRight(), -90 )
	ang:RotateAroundAxis( self:GetForward(), 0 )

	local pos = self:GetPos()
	pos = pos + self:GetForward() * 2.5
	pos = pos + self:GetRight() * 0
	pos = pos + self:GetUp() * 4.1

	local resolution = 1.5

	cam.Start3D2D( pos, ang, 0.05 / resolution )
		FFTs = FFTs or {}
		surface.SetDrawColor( 10, 10, 10, 240 )
		surface.DrawRect( 0, -70, 65*3.3, 80 )
		surface.SetDrawColor( 35, 35, 35, 120 )
		for y = -70, 10, 10 do
			surface.DrawLine( 0, y, 65*3.3, y )
		end
		for x = 0, 65*3.3, 20 do
			surface.DrawLine( x, -70, x, 10 )
		end

		local statusText = "NO STREAM"
		local isPlaying = false

		if playingents[self:EntIndex()] and IsValid(playingents[self:EntIndex()][3]) then
			local state = playingents[self:EntIndex()][3]:GetState()
			if state == GMOD_CHANNEL_PLAYING then
				isPlaying = true
				statusText = "LIVE"
			elseif state == GMOD_CHANNEL_PAUSED then
				statusText = "PAUSED"
			end
		end

		if isPlaying then
			playingents[self:EntIndex()][3]:FFT(FFTs,FFT_2048)
			for i = 1, 65 do
				local val = FFTs[i+1] or 0
				draw.RoundedBox(0, 0+(i-1)*3.3, 10-math.min(val*255,80), 3, math.min(val*255,80), CFG and CFG.theme and CFG.theme.accent or Color(0, 150, 255))
			end
		end

		draw.SimpleText(statusText, "DermaDefault", 5, -65, statusText == "LIVE" and Color(0, 255, 0, 180) or Color(255, 0, 0, 150))
	cam.End3D2D()
end

playingents = playingents or {}

net.Receive("PlayRadioSound", function()
	local url = net.ReadString()
	local index = net.ReadInt(32)
	local ent = Entity(index)
	local previousLocalVol = playingents[index] and playingents[index][6] or 1
	playingents[index] = {[1] = CurTime(), [2] = url, [5] = 1, [6] = previousLocalVol}

	if IsValid(ent) then
		ent:PlayURL(url)
	end
end)

function ENT:Think()
	local view = render.GetViewSetup()

	self:SetNextClientThink( CurTime() + 0.025 )

	if CLIENT and playingents[self:EntIndex()] and IsValid(playingents[self:EntIndex()][3]) and IsValid(playingents[self:EntIndex()][4]) then
		playingents[self:EntIndex()][4]:SetValue(playingents[self:EntIndex()][3]:GetTime())
	end
	if playingents[self:EntIndex()] and IsValid(playingents[self:EntIndex()][3]) then
		playingents[self:EntIndex()][3]:SetPos(self:GetPos())
		if self:GetPos():Distance(view.origin) > 1000 then
			playingents[self:EntIndex()][3]:SetVolume(0)
			playingents[self:EntIndex()][3]:SetPos(self:GetPos())
		else
			local globalVol = playingents[self:EntIndex()][5] or 1
			local localVol = playingents[self:EntIndex()][6] or 1
			playingents[self:EntIndex()][3]:SetVolume( globalVol * localVol )
		end
	end
	return true
end
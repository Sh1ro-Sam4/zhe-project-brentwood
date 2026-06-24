include("shared.lua")

BraxATM = {}
BraxATM.UserMoney=0
BraxATM.ReturnCode=0

net.Receive( "BraxAtmFetch", function( length, client )
	BraxATM.UserMoney = net.ReadInt(32)
end )

net.Receive( "BraxAtmReturnCode", function( length, client )
	BraxATM.ReturnCode = net.ReadInt(32)
	if BraxATM.ReturnCode == 2 or BraxATM.ReturnCode == 4 then
		surface.PlaySound("buttons/button8.wav")
	else
		surface.PlaySound("buttons/bell1.wav")
	end
end )

local RC = {"NULL","Недостаточно средств!","","Недостаточно средств!",""}

--[[
	Return codes!!
	1 = NULL
	2 = Deposit, bank does not have money
	3 = Deposit, ok
	4 = Insert, User does not have enough money
	5 = Insert, ok
]]--

surface.CreateFont( "AtmFontTitle", {
	font = "Impact",
	size = 50,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true
} )

surface.CreateFont( "AtmFontButton", {
	font = "Arial",
	size = 24,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true
} )

surface.CreateFont( "AtmFontInput", {
	font = "Lucida Console",
	size = 24,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true
} )

surface.CreateFont( "AtmFontInfo", {
	font = "Arial",
	size = 22,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true
} )

surface.CreateFont( "AtmFontInfoBold", {
	font = "Arial",
	size = 24,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true
} )

local function WorldToScreen(vWorldPos,vPos,vScale,aRot)
    local vWorldPos=vWorldPos-vPos;
    vWorldPos:Rotate(Angle(0,-aRot.y,0));
    vWorldPos:Rotate(Angle(-aRot.p,0,0));
    vWorldPos:Rotate(Angle(0,0,-aRot.r));
    return vWorldPos.x/vScale,(-vWorldPos.y)/vScale;
end

function ENT:Initialize()

	self.cursor = {y=0,x=0,click=false}
	self.Action = 0
	self.InputValue = 0
	self.UserMoney = 0
	self.ReturnCode = 0
	self.ScrPos = 0
	self.ScrOff = 0
	self.ScrAng = 0
	self.ScrScale = 0.025
	self.Title = "BREND-BANK"
	self.ScreenSize = {340,270}
	self.Ding = false
	
end

function ENT:ScreenTop() return -self.ScreenSize[2]/2 end
function ENT:ScreenLeft() return -self.ScreenSize[1]/2 end
function ENT:ScreenBottom() return self.ScreenSize[2]/2 end
function ENT:ScreenRight() return self.ScreenSize[1]/2 end

function ENT:AddToTotal(num)
	if self.InputValue > 10000000 then return end
	self.InputValue = self.InputValue * 10 + num
end

function ENT:ATMWithdraw(val)
	if val == 0 then 
		surface.PlaySound("buttons/button8.wav")
		return 
	end
	net.Start( "BraxAtmWithdraw" )
		net.WriteInt(val, 32)
	net.SendToServer()
	self.InputValue = 0
	self.Action = 3
end

function ENT:ATMDeposit(val)
	if val == 0 then 
		surface.PlaySound("buttons/button8.wav")
		return 
	end
	net.Start( "BraxAtmDeposit" )
		net.WriteInt(val, 32)
	net.SendToServer()
	self.InputValue = 0
	self.Action = 3
end

function ENT:AddButton(text, x, y, w, h, pos, func, icon)

	surface.SetDrawColor( 60, 80, 80, 255, 255 );
	
	if not pos then return end
	
	if pos.x > x and pos.x < x+w and pos.y > y and pos.y < y+h then
		
		surface.SetDrawColor( 80, 80, 80, 255 );
		
		local ply = LocalPlayer()
		
		if ply:KeyDown(IN_USE) and !self.cursor.click then
			self.cursor.click = true
		elseif not ply:KeyDown(IN_USE) and self.cursor.click then
			self.cursor.click = false
			surface.PlaySound("buttons/lightswitch2.wav")
			func()
		end
		
	end

	surface.DrawRect( x, y, w, h );

	draw.TexturedQuad
	{
		texture = surface.GetTextureID "gui/gradient_up",
		color = Color(10, 10, 10, 180),
		x = x,
		y = y,
		w = w,
		h = h
	}
	
	surface.SetDrawColor( 25, 25, 25, 255, 255 );
	surface.DrawOutlinedRect( x, y, w, h );
	
	local tx = surface.GetTextSize("test")
	
	surface.SetFont("AtmFontButton")
	surface.SetTextColor(255,255,255,255)
	surface.SetTextPos(x+(icon and 32 or 4), y+4)
	surface.DrawText(text)
	
	if icon then
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(Material("icon16/"..icon..".png"))
		surface.DrawTexturedRect( x+8, y+8, 16, 16 )
	end
end

function ENT:AddNumPad(cursor, x, y)
	local sz = 32
	self:AddButton("1",	x,		y,		sz,	sz,	cursor, function() self:AddToTotal(1) end)
	self:AddButton("2",	x+sz,	y,		sz,	sz,	cursor, function() self:AddToTotal(2) end)
	self:AddButton("3",	x+sz*2,	y,		sz,	sz,	cursor, function() self:AddToTotal(3) end)
	
	self:AddButton("4",	x,		y+sz,	sz,	sz,	cursor, function() self:AddToTotal(4) end)
	self:AddButton("5",	x+sz,	y+sz,	sz,	sz,	cursor, function() self:AddToTotal(5) end)
	self:AddButton("6",	x+sz*2,	y+sz,	sz,	sz,	cursor, function() self:AddToTotal(6) end)
	
	self:AddButton("7",	x,		y+sz*2,	sz,	sz,	cursor, function() self:AddToTotal(7) end)
	self:AddButton("8",	x+sz,	y+sz*2,	sz,	sz,	cursor, function() self:AddToTotal(8) end)
	self:AddButton("9",	x+sz*2,	y+sz*2,	sz,	sz,	cursor, function() self:AddToTotal(9) end)
	
	self:AddButton("0",	x+sz*2,	y+sz*3,	sz,	sz,	cursor, function() self:AddToTotal(0) end)
	self:AddButton("DEL",	x,	y+sz*3,	sz*2,	sz,	cursor, function() self.InputValue = 0 end)
end

function ENT:Draw()

	self:DrawModel()

	local player = LocalPlayer()
	local dist = (player:GetShootPos() - self:GetPos()):Length()
	if (dist > 80) then
		self.Action = 0
		self.InputValue = 0
		self.Title = "BRENT-BANK"
		return 
	end
	
	self.ScrScale = 0.025

	self.ScrPos = self:GetPos()
	self.ScrAng = self:GetAngles() + Angle(75,0,0)
	self.ScrOff = self:GetUp() * 50.9 + self:GetForward()*7.8 + self:GetRight()*8.1
	
	self.ScrAng:RotateAroundAxis(self.ScrAng:Up(), 90)
	
	cam.Start3D2D(self.ScrPos + self.ScrOff, self.ScrAng, self.ScrScale )	
			
		self.cursor.lx = self.cursor.x
		self.cursor.ly = self.cursor.y

		self.cursor.x, self.cursor.y = WorldToScreen(hg.eyeTrace(LocalPlayer()).HitPos,self.ScrPos+self.ScrOff,self.ScrScale*0.9,self.ScrAng)

		surface.SetDrawColor(155,155,155,255)
		surface.SetMaterial(Material("newcity/atm.png"))
		surface.DrawTexturedRect( -self.ScreenSize[1]/2, -self.ScreenSize[2]/2, self.ScreenSize[1], self.ScreenSize[2] )

		surface.SetDrawColor(60,60,60, 255 )
		surface.DrawRect(self:ScreenLeft(), self:ScreenBottom()-32,self.ScreenSize[1],32)
		
		if self.Action == 0 then	
			draw.SimpleText("Добро пожаловать! " .. LocalPlayer():GetPlayerName(), "AtmFontInfoBold", 0, -10, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			self:AddButton("Снять", self:ScreenLeft(), self:ScreenBottom()-32, 150, 32, self.cursor, function()
				self.Action = 1
				self.InputValue = 0
				RunConsoleCommand("brax_atm_update")
			end,"arrow_down")		
			
			self:AddButton("Пополнить", self:ScreenRight()-150, self:ScreenBottom()-32, 150, 32, self.cursor, function()
				self.Action = 2
				self.InputValue = 0
				RunConsoleCommand("brax_atm_update")
			end,"arrow_up")
		end
		
		if self.Action == 1 or self.Action == 2 then
	
			local BalanceColor = Color(0,0,0,255)
			local money = FormatMoney(BraxATM.UserMoney)
			if self.InputValue > BraxATM.UserMoney and self.Action == 1 then BalanceColor = Color(255,0,0,255) end
			if self.InputValue > LocalPlayer():GetMoney() and self.Action == 2 then BalanceColor = Color(255,0,0,255) end
			if self.Action == 2 then
				money = FormatMoney(LocalPlayer():GetMoney())
			else
				money = FormatMoney(BraxATM.UserMoney)
			end
		
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawRect(-145,-55,180,32)
			draw.SimpleText(self.InputValue, "AtmFontInput", 30, -49, BalanceColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
		
			draw.SimpleText("Ваш баланс:", "AtmFontInfoBold", 35, -20, Color(0,0,0,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
			draw.SimpleText(money, "AtmFontInfo", 35, 4, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
			
			self:AddNumPad(self.cursor, 40,-55)
			
		end
		

		if self.Action == 2 then
			self:AddButton("Пополнить", self:ScreenRight()-150, self:ScreenBottom()-32, 150, 32,	self.cursor, function() self:ATMDeposit(self.InputValue) end,"arrow_up")
		end
		
		if self.Action == 1 then
			self:AddButton("Снять", self:ScreenRight()-150, self:ScreenBottom()-32, 150, 32,	self.cursor, function() self:ATMWithdraw(self.InputValue) end,"arrow_down")
		end
		
		if self.Action == 3 then
			if BraxATM.ReturnCode == 2 or BraxATM.ReturnCode == 4 then
				if not self.Ding then surface.PlaySound("buttons/button8.wav") self.Ding = true end
				surface.SetDrawColor(255,255,255,255)
				surface.SetMaterial(Material("icon16/cross.png"))
				surface.DrawTexturedRect( -32, -72, 64, 64 )
				draw.SimpleText("ОШИБКА", "AtmFontInfoBold", 0, 20, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				if not self.Ding then surface.PlaySound("buttons/bell1.wav") self.Ding = true end
				surface.SetDrawColor(255,255,255,255)
				surface.SetMaterial(Material("icon16/tick.png"))
				surface.DrawTexturedRect( -32, -72, 64, 64 )
				draw.SimpleText("УСПЕШНО", "AtmFontInfoBold", 0, 20, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			draw.SimpleText(language.GetPhrase(RC[BraxATM.ReturnCode] or ""), "AtmFontInfo", 0, 45, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			draw.SimpleText("КОД:".." "..BraxATM.ReturnCode, "AtmFontInfo", 0, 77, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		if self.Action > 0 then
			self:AddButton("Назад",self:ScreenLeft(),self:ScreenBottom()-32,	150,	32,	self.cursor, function()
				self.Action = 0
				self.Title = "BRENT-BANK"
				self.Ding = false
			end,"house")
		end
		
		surface.SetDrawColor(43,86,167, 255 )
		surface.DrawRect(self:ScreenLeft(), self:ScreenTop(),self.ScreenSize[1],self.ScreenSize[2]/6)
		draw.SimpleText(self.Title, "AtmFontTitle", self:ScreenLeft()+4, self:ScreenTop()+22, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)		
		
		surface.SetDrawColor(255,255,255,255 )
		
		for i=1,6 do
			local x = math.sin( CurTime() * 2+i ) * 12 + self:ScreenRight()-25
			local y = math.cos( CurTime() * 3+i ) * 12 + self:ScreenTop()+20
			surface.DrawRect(x,y,3,3)
		end
		
		if self.cursor.x > self:ScreenLeft() and self.cursor.x < self:ScreenRight() and self.cursor.y > self:ScreenTop() and self.cursor.y < self:ScreenBottom() then
			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(Material("icon16/cursor.png"))
			surface.DrawTexturedRect(self.cursor.x-3, self.cursor.y, 16, 16)
		end
						
	cam.End3D2D()
end
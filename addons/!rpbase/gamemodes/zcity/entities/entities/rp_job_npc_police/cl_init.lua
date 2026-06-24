include("shared.lua")

local s = shizlib.surface.s
local DTR = shizlib.surface.DTR
local RNDX = include("shizlib/client/rndx_cl.lua")
local mat1 = Material("rpui/check.png", "smooth mips")
local mat2 = Material("rpui/search.png", "smooth mips")

local color_white = Color(255, 255, 255)
local color_black = Color(0, 0, 0)
local complex_off = Vector(0, 0, 9)

function ENT:CalculateRenderPos()
    local vec = self:GetAngles():Forward() + self:GetAngles():Right() * -1 + self:GetAngles():Up() * -.5
    local pos = self:GetPos() + vec
    return pos
end

function ENT:CalculateRenderAng()
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 180)
    ang:RotateAroundAxis(ang:Forward(), 90)
    return ang
end

function ENT:Draw()
    self:DrawModel() 
    
    local pos, ang = self:CalculateRenderPos(), self:CalculateRenderAng()
    local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    local inView = dist <= 500
    if not inView then return end

    local alpha = 255 - (dist / 2)
    color_white.a = alpha
    color_black.a = alpha

    local x = math.sin(CurTime() * math.pi) * 0

    cam.Start3D2D(pos, ang, 0.03)
        draw.SimpleTextOutlined(self.NpcName, '3d2d', 0, x, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
    cam.End3D2D()
end

local selectedClass = nil

local function StartPoliceQuiz(selectedClass, ent)
    local theme = CFG.theme
    local quizFrame = vgui.Create("EditablePanel")
    quizFrame:SetSize(s(500), s(400))
    quizFrame:Center()
    quizFrame:MakePopup()
    function quizFrame:Paint(w, h)
        RNDX.Draw(8, 0, 0, w, h, theme.bg, RNDX.SHAPE_FIGMA)
    end

    local pnl = quizFrame

    pnl.cls = pnl:Add("DButton")
    local cls = pnl.cls
    cls:SetPos(s(500 - 20 - 95), s(20))
    cls:SetSize(s(95), s(26))
    cls:SetCursor("hand")
    cls:SetText("")
    cls.lerpHover = 0
    cls.Paint = function(self, w, h)
        self.lerpHover = math.Clamp(self:IsHovered() and self.lerpHover + FrameTime()*3 or self.lerpHover - FrameTime()*3, 0, 1)
        draw.RoundedBox(6,0,0,w,h, shizlib.surface.LerpColor(self.lerpHover,Color(255,255,255,0),color_white) )
        draw.RoundedBox(5,w-s(38),0,s(38),h,color_white)
        draw.SimpleText("Выход", "IB_14", s(5), h*.5, shizlib.surface.LerpColor(self.lerpHover,color_white,color_black), 0, 1)
        draw.SimpleText("Esc", "IB_14", w-s(7), h*.5, color_black, 2, 1)
    end
    cls.DoClick = function(self)
        pnl:SizeTo(0, s(400), .4, 0)
        pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(200), .4, 0, -1, function()
            pnl:Remove()
        end)
    end
    cls.DoRightClick = cls.DoClick
    cls.Think = function(self)
        if(input.IsKeyDown(KEY_ESCAPE) or gui.IsGameUIVisible()) then
            pnl:SizeTo(0, s(400), .4, 0)
            pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(200), .4, 0, -1, function()
                pnl:Remove()
            end)
        end
    end

-- База из 50 вопросов (Законы + Коды из КПК) без подсказок
local AllQuestions = {
        { text = "Является ли незнание закона основанием для освобождения от ответственности?", options = {"Да, если гражданин приезжий", "Нет, не является", "Да, на усмотрение офицера", "Зависит от тяжести преступления"}, correct = 2 },
        { text = "Когда допускается применение смертоносной силы (огнестрельного оружия)?", options = {"При любом нападении на человека", "Только для защиты государственного имущества", "Для предотвращения смерти или тяжкого вреда здоровью", "Когда подозреваемый убегает от ареста"}, correct = 3 },
        { text = "Какие зоны Полицейского Департамента считаются «Закрытой территорией»?", options = {"Кабинет шерифа и оружейная", "Только камеры предварительного заключения (КПЗ)", "Все зоны за пределами публичного вестибюля (холла)", "Весь департамент, включая вестибюль"}, correct = 3 },
        { text = "Какое из определений точно описывает «Грабёж»?", options = {"Тайное хищение имущества в ночное время", "Открытое хищение имущества с применением насилия или угрозы", "Завладение имуществом путем обмана", "Присвоение государственного имущества"}, correct = 2 },
        { text = "Что из перечисленного расценивается как Хулиганство в общественном месте?", options = {"Использование нецензурной брани, способной спровоцировать конфликт", "Съемка сотрудников полиции на камеру", "Открытое ношение лицензированного оружия", "Проведение согласованного митинга"}, correct = 1 },
        { text = "Разрешено ли открытое ношение огнестрельного оружия в общественном месте без лицензии?", options = {"Да, если оружие на предохранителе", "Нет, это уголовное преступление", "Да, но только в дневное время суток", "Разрешено только в пределах коммерческих предприятий"}, correct = 2 },
        { text = "В каком случае офицер имеет право использовать электрошокер (Taser)?", options = {"Если человек словесно оскорбляет офицера", "При активном невооруженном сопротивлении аресту", "Против вооруженного огнестрельным оружием преступника", "По личному желанию для устрашения"}, correct = 2 },
        { text = "Что должен сделать офицер полиции непосредственно при задержании подозреваемого?", options = {"Избить дубинкой для профилактики", "Назвать причину задержания и зачитать права (Правило Миранды)", "Сразу отвезти в тюрьму без объяснений", "Изъять все деньги в качестве штрафа"}, correct = 2 },
        { text = "Разрешено ли сотруднику полиции проводить обыск любого прохожего на улице?", options = {"Да, для профилактики преступности", "Да, если прохожий выглядит подозрительно", "Нет, только при аресте или наличии веских оснований", "Только в ночное время суток"}, correct = 3 },
        { text = "Какое наказание предусмотрено за бегство от полиции после требования остановиться?", options = {"Штраф до $3000 и конфискация авто", "Только штраф на усмотрение суда", "Пожизненное лишение свободы", "Лишение свободы до 1 года и/или штраф"}, correct = 4 },
        
        -- Новые вопросы (Логика и Полицейский RP)
        { text = "Что такое «Презумпция невиновности»?", options = {"Человек виновен, пока не доказано обратное", "Человек невиновен, пока его вина не будет доказана в суде", "Полицейский всегда прав", "Преступник должен сам доказывать свою невиновность"}, correct = 2 },
        { text = "Что следует предпринять при попытке дачи взятки со стороны гражданина?", options = {"Взять деньги и отпустить", "Задержать гражданина за попытку подкупа должностного лица", "Сделать предупреждение и забрать деньги", "Разделить деньги с напарником"}, correct = 2 },
        { text = "В каких случаях разрешено включать спецсигналы (сирену и маячки)?", options = {"Когда торопишься в участок", "При реагировании на экстренный вызов или в погоне", "Для объезда пробок в неслужебное время", "Всегда при патрулировании города"}, correct = 2 },
        { text = "Разрешено ли использовать служебный транспорт в личных целях?", options = {"Да, если нет вызовов", "Да, но только с разрешения Мэра", "Нет, это строго запрещено", "Да, для поездки за едой"}, correct = 3 },
        { text = "Что необходимо для проведения обыска частной собственности (дома)?", options = {"Личное желание офицера", "Ордер на обыск или веская причина (например, крики о помощи из дома)", "Только разрешение от владельца", "Разрешение от любого прохожего"}, correct = 2 },
        { text = "Разрешено ли открывать огонь на поражение по безоружному убегающему подозреваемому?", options = {"Да, чтобы не упустить", "Нет, это категорически запрещено", "Да, если он не остановился после 3-го предупреждения", "Да, если он украл что-то дорогое"}, correct = 2 },
        { text = "Как вы обязаны общаться с гражданами?", options = {"Уважительно, на «Вы», избегая оскорблений", "Как угодно, если они нарушили закон", "На «Ты», если гражданин младше вас", "С использованием нецензурной лексики для устрашения"}, correct = 1 },
        { text = "Что такое «Неподчинение законному требованию сотрудника полиции»?", options = {"Отказ гражданина выполнять абсолютно любые просьбы офицера", "Отказ выполнять требования, основанные на законе (например, отойти за оцепление)", "Несогласие с мнением офицера в словесном споре", "Отказ дать взятку"}, correct = 2 },
        { text = "Что вы должны сделать, если гражданин просит предъявить ваш жетон/удостоверение?", options = {"Проигнорировать просьбу", "Задержать за помеху работе", "Предъявить свой жетон или удостоверение", "Сказать, что вы из секретного подразделения"}, correct = 3 },
        { text = "Можете ли вы применять огнестрельное оружие в местах массового скопления людей?", options = {"Да, без ограничений", "Нет, если есть высокий риск задеть невинных граждан", "Да, если преступник один", "Да, если разрешил напарник"}, correct = 2 }
    }

    -- Генерация случайного набора из 8 вопросов
    local questions = {}
    local pool = table.Copy(AllQuestions)
    local questionsToAsk = 8 -- Сколько вопросов задавать (можно изменить)

    for i = 1, questionsToAsk do
        local r = math.random(1, #pool)
        table.insert(questions, pool[r])
        table.remove(pool, r) -- Удаляем, чтобы вопросы не повторялись
    end

    -- Генерация случайного набора из 8 вопросов
    local questions = {}
    local pool = table.Copy(AllQuestions)
    local questionsToAsk = 8

    for i = 1, questionsToAsk do
        local r = math.random(1, #pool)
        table.insert(questions, pool[r])
        table.remove(pool, r)
    end

    local currentQuestion = 1

    pnl.mtitle = pnl:Add("DLabel")
    pnl.mtitle:Dock(TOP)
    pnl.mtitle:DockMargin(s(40), s(20), 0, s(12))
    pnl.mtitle:SetTall(s(30))
    pnl.mtitle:SetText("Тест на вступление в полицию")
    pnl.mtitle:SetFont("IB_20")
    pnl.mtitle:SetTextColor(color_white)
    pnl.mtitle:SizeToContents()

    local qLabel = vgui.Create('DLabel', pnl)
    qLabel:Dock(TOP)
    qLabel:DockMargin(s(40),0,0,0)
    qLabel:SetFont('IB_14')
    qLabel:SetTextColor(Color(255,255,255,127))
    qLabel:SizeToContents()
    qLabel:SetWrap(true)
    qLabel:SetContentAlignment(7)
    qLabel:SetAutoStretchVertical(true)

    local line = pnl:Add("Panel")
    line:Dock(TOP)
    line:DockMargin(s(52), s(5), s(55), 0)
    line:SetTall(s(2))
    function line:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,Color(40,40,40))
    end

    local answerPanel = vgui.Create("DScrollPanel", quizFrame)
    answerPanel:Dock(FILL)
    answerPanel:DockMargin(s(25), s(26), s(25), s(33))
    function answerPanel:Paint(w, h)
        RNDX.Draw(0, 0, 0, w, h, theme.bg, RNDX.SHAPE_FIGMA)
    end

    local function ShowQuestion(index)
        local q = questions[index]
        qLabel:SetText(q.text)
        qLabel:SetFont('ui.20')
        answerPanel:Clear()

        for i, option in ipairs(q.options) do
            local btn = vgui.Create("DButton", answerPanel)
            btn:SetText("")
            btn:Dock(TOP)
            btn:SetTall(s(50))
            btn:DockMargin(0,0,0,s(10))
            function btn:Paint(w, h)
                local isHovered = self:IsHovered()
                local firstColor = isHovered and color_black or color_white
                local secondColor = isHovered and color_white or Color(32,32,32)

                draw.RoundedBox(8,0,0,w,h,secondColor)

                draw.RoundedBox(4,s(10),s(10),s(30),s(30),Color(24,24,24))
                surface.SetMaterial(mat2)
                surface.SetDrawColor(255,255,255)
                surface.DrawTexturedRect(s(19),s(19),s(12),s(12))

                draw.SimpleText(option,'IB_14',s(69),h/2,firstColor,0,1)
            end
            
            btn.DoClick = function()
                if i == q.correct then
                    if index == #questions then
                        pnl:SizeTo(0, s(400), .4, 0)
                        pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(200), .4, 0, -1, function()
                            pnl:Remove()
                        end)
                        net.Start("PlayerSelectJob")
                            net.WriteEntity(ent)
                            net.WriteString(selectedClass.Name)
                        net.SendToServer()
                        chat.AddText(Color(0, 255, 0), "Поздравляем! Вы сдали экзамен по законодательству и приняты на службу!")
                    else
                        currentQuestion = index + 1
                        ShowQuestion(currentQuestion)
                    end
                else
                   cookie.Set("PoliceQuizCooldown", tostring(os.time() + 900))
                    
                    chat.AddText(Color(255, 0, 0), "К сожалению вы не сдали.")
                    pnl:SizeTo(0, s(400), .4, 0)
                    pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(200), .4, 0, -1, function()
                        pnl:Remove()
                    end)
                end
            end
        end
    end

    if #questions > 0 then
        ShowQuestion(1)
    else
        chat.AddText(Color(255, 0, 0), "Ошибка: тест недоступен.")
        pnl:SizeTo(0, s(400), .4, 0)
        pnl:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(200), .4, 0, -1, function()
            pnl:Remove()
        end)
    end
end

local frame = nil

net.Receive("OpenJob.PoliceMenu", function()
    local theme = CFG.theme
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    local joballowed = {TEAM_POLICE}
    local joballowednabor = {TEAM_POLICE}

    if frame and IsValid(frame) then frame:Remove() end

    frame = vgui.Create("EditablePanel")
    frame:SetSize(0, s(250))
    frame:Center()
    frame:MakePopup()
    frame:SizeTo(s(400), s(250), .4, 0)
    frame:MoveTo(shizlib.hud.ScrW / 2 - s(200), shizlib.hud.ScrH / 2 - s(125), .4, 0)
    function frame:Paint(w, h)
        RNDX.Draw(8, 0, 0, w, h, theme.bg, RNDX.SHAPE_FIGMA)
    end

    frame.cls = frame:Add("DButton")
    local cls = frame.cls
    cls:SetPos(s(400 - 20 - 95), s(20))
    cls:SetSize(s(95), s(26))
    cls:SetCursor("hand")
    cls:SetText("")
    cls.lerpHover = 0
    cls.Paint = function(self, w, h)
        self.lerpHover = math.Clamp(self:IsHovered() and self.lerpHover + FrameTime()*3 or self.lerpHover - FrameTime()*3, 0, 1)
        draw.RoundedBox(6,0,0,w,h, shizlib.surface.LerpColor(self.lerpHover,Color(255,255,255,0),color_white) )
        draw.RoundedBox(5,w-s(38),0,s(38),h,color_white)
        draw.SimpleText("Выход", "IB_14", s(5), h*.5, shizlib.surface.LerpColor(self.lerpHover,color_white,color_black), 0, 1)
        draw.SimpleText("Esc", "IB_14", w-s(7), h*.5, color_black, 2, 1)
    end
    cls.DoClick = function(self)
        frame:SizeTo(0, s(250), .4, 0)
        frame:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(125), .4, 0, -1, function()
            frame:Remove()
        end)
    end
    cls.DoRightClick = cls.DoClick
    cls.Think = function(self)
        if(input.IsKeyDown(KEY_ESCAPE) or gui.IsGameUIVisible()) then
            frame:SizeTo(0, s(250), .4, 0)
            frame:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(125), .4, 0, -1, function()
                frame:Remove()
            end)
        end
    end

    frame.mtitle = frame:Add("DLabel")
    frame.mtitle:Dock(TOP)
    frame.mtitle:DockMargin(s(40), s(20), 0, s(12))
    frame.mtitle:SetTall(s(30))
    frame.mtitle:SetText("Гос. служба")
    frame.mtitle:SetFont("IB_25")
    frame.mtitle:SetTextColor(color_white)
    frame.mtitle:SizeToContents()

    local line = frame:Add("Panel")
    line:Dock(TOP)
    line:DockMargin(s(52), s(5), s(55), 0)
    line:SetTall(s(2))
    function line:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,Color(40,40,40))
    end

    local combo = vgui.Create("DComboBox", frame)
    combo:Dock(TOP)
    combo:DockMargin(s(40), s(26), s(40), s(26))
    combo:SetText("Выберите профессию")

    for k, rpclass in pairs(rp.Classes) do
        -- Убеждаемся, что не берем дубликаты (т.к. rp.Classes хранит и числовые и строковые ключи)
        if type(k) == "number" then
            -- Показываем в меню и обычного Кадета, и наборные профы (если у игрока к ним есть доступ)
            if table.HasValue(joballowed, rpclass) or table.HasValue(joballowednabor, rpclass) then
                combo:AddChoice(rpclass.Name)
            end
        end
    end

    local pClass = LocalPlayer():GetPlayerClass()
    if not (table.HasValue(joballowed, pClass) or table.HasValue(joballowednabor, pClass)) then
        local button = vgui.Create("DButton", frame)
        button:Dock(BOTTOM)
        button:DockMargin(s(37), s(37), s(37), s(37))
        button:SetTall(s(60))
        button:SetText("")
        function button:Paint(w, h)
            local isHovered = self:IsHovered()
            local firstColor = isHovered and color_black or color_white
            local secondColor = isHovered and color_white or Color(32,32,32)

            RNDX.Draw(8,0,0,w,h,secondColor)
            RNDX.Draw(4,s(10),s(10),s(40),s(40),Color(24,24,24))
            DTR(s(24),s(26),s(12),s(12), color_white, mat1)

            draw.SimpleText('Устроиться','IB_20',s(69),h/2,firstColor,0,1)
        end
        button.DoClick = function()
            local selectedName = combo:GetValue()
            if selectedName == "Выберите профессию" or selectedName == "" then
                chat.AddText(Color(255, 0, 0), "Выберите профессию!")
                return
            end
            
            local cooldownEnd = cookie.GetNumber("PoliceQuizCooldown", 0)
            if os.time() < cooldownEnd then
                local timeLeft = math.ceil((cooldownEnd - os.time()) / 60)
                chat.AddText(Color(255, 0, 0), "К сожалению вы не сдали прошлый тест. Следующая попытка через " .. timeLeft .. " мин.")
                return
            end
    
            for _, cls in ipairs(rp.Classes) do
                if cls.Name == selectedName then
                    selectedClass = cls
                    break
                end
            end
    
            if not table.HasValue(joballowed, LocalPlayer():GetPlayerClass()) then
                StartPoliceQuiz(selectedClass, ent)
            end

            if table.HasValue(joballowednabor, LocalPlayer():GetPlayerClass()) then
                net.Start("PlayerSelectJob")
                    net.WriteEntity(ent)
                    net.WriteString(selectedClass.Name)
                net.SendToServer()
            end

            frame:SizeTo(0, s(250), .4, 0)
            frame:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(125), .4, 0, -1, function()
                frame:Remove()
            end)
        end
    else
        local buttondem = vgui.Create("DButton", frame)
        buttondem:Dock(BOTTOM)
        buttondem:DockMargin(s(37), s(37), s(37), s(37))
        buttondem:SetTall(s(60))
        buttondem:SetText("")
        function buttondem:Paint(w, h)
            local isHovered = self:IsHovered()
            local firstColor = isHovered and color_black or color_white
            local secondColor = isHovered and color_white or Color(32,32,32)

            RNDX.Draw(8,0,0,w,h,secondColor)
            RNDX.Draw(4,s(10),s(10),s(40),s(40),Color(24,24,24))
            DTR(s(24),s(26),s(12),s(12), color_white, mat1)

            draw.SimpleText('Уволиться','IB_20',s(69),h/2,firstColor,0,1)
        end
        buttondem.DoClick = function()
            frame:SizeTo(0, s(250), .4, 0)
            frame:MoveTo(shizlib.hud.ScrW / 2, shizlib.hud.ScrH / 2 - s(125), .4, 0, -1, function()
                frame:Remove()
            end)
            net.Start("PlayerSelectJob")
                net.WriteEntity(ent) -- ТЕПЕРЬ ОТПРАВЛЯЕТСЯ ЭНТИТИ
                net.WriteString('Гражданин')
            net.SendToServer()
        end
    end
end)
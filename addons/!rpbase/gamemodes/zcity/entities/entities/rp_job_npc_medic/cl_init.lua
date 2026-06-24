include("shared.lua")

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

local function StarQuiz(selectedClass)
    local quizFrame = vgui.Create("DFrame")
    quizFrame:SetSize(500, 400)
    quizFrame:Center()
    quizFrame:SetTitle("")
    quizFrame:SetVisible(true)
    quizFrame:MakePopup()
    quizFrame:SetDraggable(true)

    local questions = {
        {
            text = "Что является приоритетом для медика при прибытии на место происшествия?",
            options = {
                "Немедленное оказание помощи пострадавшему",
                "Оценка безопасности сцены и собственной защиты",
                "Заполнение медицинской документации",
                "Транспортировка пациента в больницу"
            },
            correct = 2
        },
        {
            text = "Когда медик имеет право проводить лечение без согласия пациента?",
            options = {
                "Всегда, если пациент ранен",
                "Только если пациент без сознания или не способен дать осознанное согласие",
                "Если этого требует полицейский на месте",
                "Никогда, согласие обязательно в любой ситуации"
            },
            correct = 2
        },
        {
            text = "Какой цвет триажа обозначает пациента с угрожающими жизни состояниями, требующими немедленной помощи?",
            options = {
                "Зелёный",
                "Жёлтый",
                "Красный",
                "Чёрный"
            },
            correct = 3
        },
        {
            text = "Что должен сделать медик в первую очередь при работе с пациентом в сознании?",
            options = {
                "Сразу начать вводить лекарства",
                "Представиться, объяснить свои действия и получить согласие на лечение",
                "Требовать от пациента лечь на землю",
                "Вызвать полицию для контроля"
            },
            correct = 2
        },
        {
            text = "Какие действия медика являются нарушением медицинской этики?",
            options = {
                "Передача информации о состоянии пациента третьим лицам без согласия",
                "Отказ в помощи при угрозе жизни",
                "Работа в паре с другим медиком",
                "Использование стандартных протоколов лечения"
            },
            correct = 1
        },
        {
            text = "Когда медик должен запросить дополнительную помощь или эвакуацию вертолётом?",
            options = {
                "При любом вызове для перестраховки",
                "Только по требованию пациента",
                "При массовых происшествиях, тяжёлых травмах или невозможности безопасной транспортировки наземным путём",
                "Когда заканчивается смена"
            },
            correct = 3
        },
        {
            text = "Что означает аббревиатура ABC в первичном осмотре пациента?",
            options = {
                "Airway, Breathing, Circulation (Дыхательные пути, Дыхание, Кровообращение)",
                "Always Be Careful (Всегда будь осторожен)",
                "Ambulance, Bandage, Care (Скорая, Бинт, Помощь)",
                "Assess, Bandage, Call (Оценить, Забинтовать, Вызвать)"
            },
            correct = 1
        },
        {
            text = "Как поступить, если на месте происшествия продолжается угроза (перестрелка, пожар, обрушение)?",
            options = {
                "Немедленно войти и начать спасать пострадавших",
                "Ожидать устранения угрозы или эскорта от полиции, не подвергая себя риску",
                "Попросить пострадавших самостоятельно дойти до машины",
                "Работать без защитного снаряжения для скорости"
            },
            correct = 2
        }
    }

    local currentQuestion = 1

    local questionLabel = vgui.Create("DLabel", quizFrame)
    questionLabel:SetPos(20, 50)
    questionLabel:SetSize(460, 100)
    questionLabel:SetWrap(true)
    questionLabel:SetContentAlignment(7)
    questionLabel:SetAutoStretchVertical(true)

    local answerPanel = vgui.Create("DScrollPanel", quizFrame)
    answerPanel:SetPos(20, 160)
    answerPanel:SetSize(460, 200)
    answerPanel.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200))
    end

    local function ShowQuestion(index)
        local q = questions[index]
        questionLabel:SetText(q.text)
        questionLabel:SetFont('ui.20')
        answerPanel:Clear()

        local btnWidth = answerPanel:GetWide() - 20
        local btnHeight = 40
        local spacing = 10
        local startY = 10

        for i, option in ipairs(q.options) do
            local btn = vgui.Create("DButton", answerPanel)
            btn:SetText(option)
            btn:Dock(TOP)
            btn:DockMargin(5,5,5,5)
            btn:SetSize(btnWidth, btnHeight)
            btn.DoClick = function()
                if i == q.correct then
                    if index == #questions then
                        quizFrame:Close()
                        net.Start("PlayerSelectJob")
                            net.WriteString(selectedClass.Name)
                        net.SendToServer()
                        chat.AddText(Color(0, 255, 0), "Поздравляем! Вы прошли тест и приняты!")
                    else
                        currentQuestion = index + 1
                        ShowQuestion(currentQuestion)
                    end
                else
                    chat.AddText(Color(255, 0, 0), "Неверный ответ! Попробуйте ещё раз.")
                    quizFrame:Close()
                end
            end
        end
    end

    if #questions > 0 then
        ShowQuestion(1)
    else
        chat.AddText(Color(255, 0, 0), "Ошибка: тест недоступен.")
        quizFrame:Close()
    end
end

net.Receive("OpenJob.PoliceMenu", function()
    if not table.HasValue(joballowed, LocalPlayer():GetPlayerClass()) then
        for _, cls in ipairs(rp.Classes) do
            if cls == joballowed then
                selectedClass = cls
                break
            end
        end

        if not table.HasValue(joballowed, LocalPlayer():GetPlayerClass()) then StartQuiz(selectedClass) end
    else
        net.Start("PlayerSelectJob")
            net.WriteString('Гражданин')
        net.SendToServer()
    end
end)
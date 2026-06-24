if SERVER then function ScrW() return 1920 end function ScrH() return 1080 end end cats = cats or {} cats.config = {}

cats.config.spawnSize = { 450, 220 }
cats.config.spawnPosAdmin = { ScrW() - 500, 50 }
cats.config.spawnPosUser = { ScrW() - 500, ScrH() - 250 }
cats.config.punchCardMode = 'dots' 
cats.config.punchCardStart = 5
cats.config.defaultRating = 3
cats.config.ratingTimeout = 60
cats.config.newTicketSound = 'buttons/bell1.wav'

cats.lang = {
    openTickets = "Открытые жалобы",
    myTicket = "Моя жалоба",
    userDisconnected = "Пользователь вышел",
    claimedBy = "Разбирается",
    sendMessage = "Написать сообщение...",
    typeYourMessage = "Введите сообщение:",
    actions = "Действия",
    action_claim = "Взять жалобу",
    action_unclaim = "Передать жалобу",
    action_spectate = "Наблюдать",
    action_goto = "К нему",
    action_bring = "К себе",
    action_return = "Вернуть на место",
    action_returnself = "Вернуться на место",
    action_copySteamID = "Скопировать SteamID",
    action_callon = "Включить просьбу о помощи",
    action_calloff = "Выключить просьбу о помощи",
    action_close = "Закрыть жалобу",
    error_wait = "Тихо-тихо... Куда так разогнался?",
    error_noAccess = "Ошибка доступа",
    error_playerNotFound = "Игрок не найден",
    error_ticketNotEnded = "Жалоба не закрыта",
    error_ticketNotFound = "Жалоба не найдена",
    error_ticketEnded = "Жалоба уже решена",
    error_ticketNotClaimed = "Жалоба никем не взята",
    error_ticketAlreadyClaimed = "Жалоба уже взята",
    error_needToRate = "Ты должен оценить прошлую жалобу!",
	error_cantCancelHasAdmin = "Нельзя отменить жалобу, которую рассматривают",
    ticketClaimed = "Жалоба взята",
    ticketUnclaimed = "Жалоба отдана",
    ticketClaimedBy = "Твою жалобу принял %s",
    ticketUnclaimedBy = "Твоя жалоба передана",
    ticketClosed = "Жалоба закрыта",
    ticketClosedBy = "%s закрыл жалобу. Оцени его работу!",
    ticketRatedForAdmin = "Оценка по твоей жалобе: %s",
    ticketRatedForUser = "Ты оценил решение жалобы на %s",
    ticketUserLeft = "Пользователь, чью жалобу ты решал, вышел",
    rateAdmin = "Нажми ниже, чтобы выбрать оценку",
    ok = "Готово",
    cancel = "Отмена",
    ticket_noAdmins = "На сервере нет администраторов",
    dow = {"ПН","ВТ","СР","ЧТ","ПТ","СБ","ВС"},
}

cats.config.serverID = "Cats"

cats.config.getPlayerName = function(ply)
    return ply:Name() .. " (" .. ply:SteamName() .. ")"
end

cats.config.playerCanSeeTicket = function(ply, ticketSteamID)
    return ply:IsAdmin() or ply:SteamID() == ticketSteamID
end

cats.config.triggerText = function(ply, text)
    text = text:Trim()
    if text:sub(1, 4) == '/rep' then
		return true, text:sub(5):Trim()
	elseif text:sub(1, 4) == '!rep' then
		return true, text:sub(5):Trim()
    end
    if cats.config.playerCanSeeTicket(ply, "") then return false end
    if text:sub(1,1) == '@' then
        return true, text:sub(2):Trim()
    end
    return false
end

cats.config.notify = function(ply, msg, type, duration)
    if IsValid(ply) then
        DarkRP.notify(ply, type, duration, msg)
    else
        DarkRP.notifyAll(type, duration, msg)
    end
end

cats.config.commands = {
    {
        text = cats.lang.action_spectate,
        icon = 'camera_go',
        click = function(ply)
            RunConsoleCommand('FSpectate', ply:SteamID())
        end
    },
    {
        text = cats.lang.action_bring,
        icon = 'user_go',
        click = function(ply)
            RunConsoleCommand('sam', 'bring', ply:Name())
        end
    },
    {
        text = cats.lang.action_return,
        icon = 'arrow_undo',
        click = function(ply)
            RunConsoleCommand('sam', 'return', ply:Name())
        end
    },
    {
        text = cats.lang.action_goto,
        icon = 'arrow_right',
        click = function(ply)
            RunConsoleCommand('sam', 'goto', ply:Name())
        end
    },
    {
        text = cats.lang.action_returnself,
        icon = 'arrow_rotate_clockwise',
        click = function(ply)
            RunConsoleCommand('sam', 'return', LocalPlayer():Name())
        end
    },
    {
        text = cats.lang.action_copySteamID,
        icon = 'key_go',
        click = function(ply)
            SetClipboardText( ply:SteamID() )
        end
    },
}

if SERVER then
    ScrW = nil ScrH = nil
end

cats.mysqlite = {}
cats.mysqlite.EnableMySQL = true 
cats.mysqlite.Host = "" 
cats.mysqlite.Username = "" 
cats.mysqlite.Password = "" 
cats.mysqlite.Database_name = "" 
cats.mysqlite.Database_port = 3306 
cats.mysqlite.Preferred_module = "mysqloo" 

util.AddNetworkString"cats.dispatchMessage"
util.AddNetworkString"cats.syncTickets"
util.AddNetworkString"cats.claimTicket"
util.AddNetworkString"cats.closeTicket"
util.AddNetworkString"cats.setRating"
util.AddNetworkString"cats.getAdminList"
util.AddNetworkString"cats.getAdminData"
util.AddNetworkString"cats.requestSync"
util.AddNetworkString"cats.deleteAdmin"
util.AddNetworkString"cats.resetAdmin"
util.AddNetworkString"cats.clearAllAdmins"
util.AddNetworkString"cats.setClaimsTotal"

cats.currentTickets={}
cats.adminDataCache={}

local function n(e)
    local t={}
    for n,a in ipairs(player.GetAll())do 
        if cats.config.playerCanSeeTicket(a,e)then table.insert(t,a) end 
    end 
    return t 
end 

local e={}
for t=1,7 do 
    e[t]={}for a=1,24 do e[t][a]=0 end 
end 

function cats:Log(t)
    print("[CATS] "..t)
end 

function cats:Init()
    self.config.serverID=self.config.serverID:gsub('[^A-Za-z]','')
    MySQLite.initialize(self.mysqlite)
    self:Log("Initialized.")
end 

cats:Init()

function cats.QueryError(t,a)
    error("\n[CATS] Query error : "..t.." on query : '"..a.."'\n\n")
end 

function cats:Query(t,a)
    if not t or type(t)~="string"then return end 
    MySQLite.query(t,a,self.QueryError)
end 

function cats:DispatchMessage(a,t,e)
    local i=cats.config.getPlayerName(a)
    local n=n(t)
    if self.currentTickets[t]then 
        if self.currentTickets[t].ended then 
            cats.config.notify(a,cats.lang.error_needToRate,NOTIFY_ERROR,10)
            return
        end 
        table.insert(self.currentTickets[t].chatLog,{i,e,a:SteamID()~=t})
    else 
        self.currentTickets[t]={createdTime=os.time(),createdGameTime=CurTime(),chatLog={{i,e}},user=a,userID=t}
        if#n<2 then 
            cats.config.notify(a,cats.lang.ticket_noAdmins,NOTIFY_GENERIC,10)
        end 
    end 
    net.Start('cats.dispatchMessage')
    net.WriteString(t)
    net.WriteEntity(a)
    net.WriteString(e)
    net.Send(n)
end 

net.Receive('cats.dispatchMessage',function(a,t)
    local a=net.ReadString()
    local e=net.ReadString()
    local n=player.GetBySteamID(a)
    if not IsValid(n)then 
        cats.config.notify(t,cats.lang.error_playerNotFound,NOTIFY_ERROR,3)
        return 
    end 
    if not cats.config.playerCanSeeTicket(t,a)then 
        cats.config.notify(t,cats.lang.error_noAccess,NOTIFY_ERROR,3)
        return 
    end 
    cats:DispatchMessage(t,a,e)
end)

function cats:SaveTicket(e,a)
    local t=self.currentTickets[e]
    if not t then 
        self:Log('Trying to close inexistant ticket for '..e)
        return 
    end 
    local n=string.format([[ INSERT INTO rp_admin_ticket(user, admin, createdTime, ticketTime, rating) VALUES (%s, %s, %d, %d, %f); ]],MySQLite.SQLStr(e),MySQLite.SQLStr(t.adminID),t.createdTime,t.finishTime-t.claimTime,a)
    self:Query(n,function(n)
        if IsValid(t.user)then 
            cats.config.notify(t.user,string.format(cats.lang.ticketRatedForUser,tostring(a)),NOTIFY_CLEANUP,8)
        end 
        if IsValid(t.admin) then
            if t.admin.cats_adminData then
                t.admin.cats_adminData.claimsTotal = (t.admin.cats_adminData.claimsTotal or 0) + 1
            end
            cats.config.notify(t.admin,string.format(cats.lang.ticketRatedForAdmin,tostring(a)),NOTIFY_CLEANUP,8)
            local a=os.date('*t',os.time())
            a.wday=a.wday-1 
            day=a.wday~=0 and a.wday or 7 
            hour=a.hour~=0 and a.hour or 24 
            if t.admin.cats_adminData and t.admin.cats_adminData.claimCard then
                t.admin.cats_adminData.claimCard[day][hour]=(t.admin.cats_adminData.claimCard[day][hour] or 0)+1 
            end
        end
        if t.adminID then
            cats:Query(string.format("UPDATE cats_%s_admins SET claimsTotal = claimsTotal + 1 WHERE steamID = %s", self.config.serverID, MySQLite.SQLStr(t.adminID)))
        end
        self.currentTickets[e]=nil 
    end)
end 

net.Receive('cats.closeTicket',function(t,a)
    local e=net.ReadString()
    local t=cats.currentTickets[e]
    if not t then 
        cats.config.notify(a,cats.lang.error_ticketNotFound,NOTIFY_ERROR,3)
        return 
    end 
    if t.ended then 
        cats.config.notify(a,cats.lang.error_ticketEnded,NOTIFY_ERROR,3)
        return 
    end 
    if t.adminID==a:SteamID()then 
        t.ended=true 
        t.finishTime=os.time()
        net.Start('cats.closeTicket')
        net.WriteString(e)
        net.Send(n(e))
        if IsValid(t.user)then 
            cats.config.notify(t.user,string.format(cats.lang.ticketClosedBy,t.admin:Name()),NOTIFY_GENERIC,5)
        end 
        cats.config.notify(a,cats.lang.ticketClosed,NOTIFY_GENERIC,3)
    elseif t.userID==a:SteamID()and not IsValid(t.admin)then 
        net.Start('cats.closeTicket')
        net.WriteString(e)
        net.Send(n(e))
        cats.currentTickets[e]=nil 
    else 
        cats.config.notify(a,cats.lang.error_noAccess,NOTIFY_ERROR,3)
        return 
    end 
end)

net.Receive('cats.setRating',function(a,t)
    local e=t:SteamID()
    local n=math.Clamp(net.ReadUInt(8)or cats.config.defaultRating,1,5)
    local a=cats.currentTickets[e]
    if not a then 
        cats.config.notify(t,cats.lang.error_ticketNotFound,NOTIFY_ERROR,3)
        return 
    end 
    if not a.ended then 
        cats.config.notify(t,cats.lang.error_ticketNotEnded,NOTIFY_ERROR,3)
        return 
    end 
    net.Start('cats.setRating')
    net.WriteString(e)
    net.WriteUInt(n,8)
    net.Send({t,a.admin})
    cats:SaveTicket(e,n)
end)

function cats:ClaimTicket(e,a,i)
    local t=self.currentTickets[e]
    if not t then 
        self:Log('Trying to claim inexistant ticket for '..e)
        return 
    end 
    if t.adminID and t.adminID~=a:SteamID()then 
        cats.config.notify(a,cats.lang.error_noAccess,NOTIFY_ERROR,3)
        return
    end 
    if i then 
        t.admin=a 
        t.adminID=a:SteamID()
        t.claimTime=os.time()
    else 
        t.admin=nil 
        t.adminID=nil 
    end 
    net.Start('cats.claimTicket')
    net.WriteString(e)
    net.WriteEntity(a)
    net.WriteBool(i)
    net.Send(n(e))
end 

net.Receive('cats.claimTicket',function(a,t)
    local e=net.ReadString()
    local n=net.ReadBool()
    local a=cats.currentTickets[e]
    if not cats.config.playerCanSeeTicket(t,e)then 
        cats.config.notify(t,cats.lang.error_noAccess,NOTIFY_ERROR,3)
        return 
    end 
    if not a then 
        cats.config.notify(t,cats.lang.error_ticketNotFound,NOTIFY_ERROR,3)
        return 
    end 
    if n then 
        if IsValid(a.admin)then 
            cats.config.notify(t,cats.lang.error_ticketAlreadyClaimed,NOTIFY_ERROR,3)
            return 
        end 
        cats.config.notify(t,cats.lang.ticketClaimed,NOTIFY_GENERIC,5)
        cats.config.notify(a.user,string.format(cats.lang.ticketClaimedBy,t:Name()),NOTIFY_GENERIC,5)
    else 
        if not IsValid(a.admin)then 
            cats.config.notify(t,cats.lang.error_ticketNotClaimed,NOTIFY_ERROR,3)
            return 
        end 
        cats.config.notify(t,cats.lang.ticketUnclaimed,NOTIFY_GENERIC,5)
        cats.config.notify(a.user,string.format(cats.lang.ticketUnclaimedBy,t:Name()),NOTIFY_GENERIC,5)
    end 
    cats:ClaimTicket(e,t,n)
end)

function cats:GetAdminList(t,a)
    if not self.adminDataCache.lastUpdate or self.adminDataCache.lastUpdate+300>CurTime()then 
        cats:Query([[ SELECT steamID, lastNick, (SELECT AVG(rating) FROM rp_admin_ticket WHERE admin = steamID) AS ratingTotal FROM cats_]]..self.config.serverID..[[_admins; ]],function(t)
            if t and#t>0 then 
                for e,t in pairs(t)do 
                    t.ratingTotal = tonumber(t.ratingTotal) or 0
                    self.adminDataCache[t.steamID]=t 
                end 
                a(self.adminDataCache)
            end 
        end)
    else 
        a(self.adminDataCache)
    end
end 

net.Receive('cats.getAdminList',function(a,t)
    if t.cats_cooldowns.getAdminList and t.cats_cooldowns.getAdminList>CurTime()then 
        cats.config.notify(t,cats.lang.error_wait,NOTIFY_ERROR,3)
        return 
    end 
    t.cats_cooldowns.getAdminList=CurTime()+.2 
    if not cats.config.playerCanSeeTicket(t)then 
        cats.config.notify(t,cats.lang.error_noAccess,NOTIFY_ERROR,3)
        return 
    end 
    cats:Log('Sending admin list to '..tostring(t))
    cats:GetAdminList(steamID,function(a)
        if not IsValid(t)or not a then return end 
        net.Start('cats.getAdminList')
        net.WriteTable(a)
        net.Send(t)
    end)
end)

function cats:SavePlayer(a,c)
    local i=a:Name()
    local t=a.cats_adminData 
    if t then 
        t.playTimeTotal=a:GetPlayTime()
        local n=[[ SELECT SUM(ticketTime) AS ticketTimeTotal, COUNT(DISTINCT user) AS uniqueUsers, (SELECT AVG(rating) FROM rp_admin_ticket WHERE admin = ']]..t.steamID..[[') AS ratingTotal FROM rp_admin_ticket WHERE admin = ']]..t.steamID..[['; ]]
        self:Query(n,function(res)
            res=res and#res>0 and res[1]
            t.lastNick=i or"Unknown"
            t.lastPlayedTime=os.time()or 0 
            t.playTimeTotal=tonumber(t.playTimeTotal)or 0 
            t.ticketTimeTotal=res and tonumber(res.ticketTimeTotal) or 0 
            t.ratingTotal=res and tonumber(res.ratingTotal) or 0 
            t.uniqueUsers=res and tonumber(res.uniqueUsers) or 0 
            t.timeCard=t.timeCard or table.Copy(e)
            t.claimCard=t.claimCard or table.Copy(e)
            t.updateTime=os.time()or 0 
            local q=string.format([[ UPDATE cats_]]..self.config.serverID..[[_admins SET lastNick = %s, lastPlayedTime = %d, playTimeTotal = %d, ticketTimeTotal = %d, ratingTotal = %f, claimsTotal = %d, uniqueUsers = %d, timeCard = %s, claimCard = %s, updateTime = %d WHERE steamID = ']]..t.steamID..[['; ]],
                MySQLite.SQLStr(t.lastNick),
                t.lastPlayedTime,
                t.playTimeTotal,
                t.ticketTimeTotal,
                t.ratingTotal,
                t.claimsTotal or 0,
                t.uniqueUsers,
                MySQLite.SQLStr(util.TableToJSON(t.timeCard)),
                MySQLite.SQLStr(util.TableToJSON(t.claimCard)),
                t.updateTime or 0
            )
            self:Query(q,c)
        end)
    end 
end 

function cats:GetAdminData(e, a)
    local q = string.format([[
        SELECT 
            a.lastNick, 
            a.steamID,
            a.timeCard, 
            a.claimCard,
            a.playTimeTotal,
            a.claimsTotal,
            (SELECT AVG(rating) FROM rp_admin_ticket WHERE admin = a.steamID) AS ratingTotal,
            (SELECT COUNT(*) FROM rp_admin_ticket WHERE admin = a.steamID AND rating > 3) AS positiveClaims,
            (SELECT COUNT(*) FROM rp_admin_ticket WHERE admin = a.steamID AND rating <= 3) AS negativeClaims
        FROM cats_%s_admins a
        WHERE a.steamID = %s
    ]], self.config.serverID, MySQLite.SQLStr(e))
    self:Query(q, function(t)
        if t and #t > 0 then
            local data = t[1]
            data.claimsTotal = tonumber(data.claimsTotal) or 0
            data.ratingTotal = tonumber(data.ratingTotal) or 0
            data.positiveClaims = tonumber(data.positiveClaims) or 0
            data.negativeClaims = tonumber(data.negativeClaims) or 0
            a(data)
        else
            a()
        end
    end)
end

net.Receive('cats.getAdminData',function(a,t)
    local a=net.ReadString()
    if t.cats_cooldowns.getAdminData and t.cats_cooldowns.getAdminData>CurTime()then 
        cats.config.notify(t,cats.lang.error_wait,NOTIFY_ERROR,3)
        return 
    end 
    t.cats_cooldowns.getAdminData=CurTime()+.5 
    if not cats.config.playerCanSeeTicket(t)then 
        cats.config.notify(t,cats.lang.error_noAccess,NOTIFY_ERROR,3)
        return 
    end 
    cats:Log("Sending data of '"..a.."' to "..tostring(t))
    cats:GetAdminData(a,function(data)
        if not IsValid(t)or not data then return end 
        net.Start('cats.getAdminData')
        net.WriteTable(data)
        net.Send(t)
    end)
end)

hook.Add("PlayerSay","cats",function(t,a)
    local a,e=cats.config.triggerText(t,a)
    if a then 
        cats:DispatchMessage(t,t:SteamID(),e)
        return''
    end
end)

hook.Add("PlayerInitialSpawn", "cats", function(t)
    t.cats_cooldowns = {}
    timer.Simple(5, function()
        if not IsValid(t) then return end
        if cats.config.playerCanSeeTicket(t, "") then 
            cats:Query([[ SELECT * FROM cats_]]..cats.config.serverID..[[_admins WHERE steamID = ]]..MySQLite.SQLStr(t:SteamID())..[[; ]], function(a)
                if not IsValid(t) then return end 
                a = a and #a > 0 and a[1]
                if a then 
                    t.cats_adminData = a 
                    t.cats_adminData.timeCard = t.cats_adminData.timeCard and util.JSONToTable(t.cats_adminData.timeCard) or table.Copy(e)
                    t.cats_adminData.claimCard = t.cats_adminData.claimCard and util.JSONToTable(t.cats_adminData.claimCard) or table.Copy(e)
                else 
                    t.cats_adminData = {steamID = t:SteamID(), lastNick = t:Name(), createdTime = os.time(), playTimeTotal = t:GetPlayTime(), lastPlayedTime = os.time(), ticketTimeTotal = 0, ratingTotal = 0, claimsTotal = 0, uniqueUsers = 0, timeCard = table.Copy(e), claimCard = table.Copy(e), updateTime = os.time()}
                    cats:Query(string.format([[ INSERT INTO cats_]]..cats.config.serverID..[[_admins(steamID, lastNick, createdTime, playTimeTotal, lastPlayedTime, ticketTimeTotal, ratingTotal, claimsTotal, uniqueUsers, timeCard, claimCard, updateTime) VALUES (%s, %s, %d, %d, %d, %d, %f, %d, %d, %s, %s, %d); ]], MySQLite.SQLStr(t.cats_adminData.steamID), MySQLite.SQLStr(t.cats_adminData.lastNick), t.cats_adminData.createdTime, t.cats_adminData.playTimeTotal, t.cats_adminData.lastPlayedTime, t.cats_adminData.ticketTimeTotal, t.cats_adminData.ratingTotal, t.cats_adminData.claimsTotal, t.cats_adminData.uniqueUsers, MySQLite.SQLStr(util.TableToJSON(t.cats_adminData.timeCard)), MySQLite.SQLStr(util.TableToJSON(t.cats_adminData.claimCard)), os.time()))
                end 
                t:SetNWFloat("cats_adminRating", t.cats_adminData.ratingTotal)
                
                timer.Simple(20, function()
                    if not IsValid(t) then return end
                    net.Start('cats.syncTickets')
                    net.WriteTable(cats.currentTickets)
                    net.Send(t)
                end)
            end)
        end
        local a = [[ SELECT COUNT(rating) AS ratingsTotal, AVG(rating) AS averageRating FROM cats_]]..cats.config.serverID..[[_claims WHERE user = ']]..t:SteamID()..[['; ]]
        cats:Query(a, function(a)
            a = a and #a > 0 and a[1]
            if a and IsValid(t) then 
                t:SetNWInt("cats_ratingsTotal", tonumber(a.ratingsTotal) or 1)
                t:SetNWFloat("cats_averageRating", tonumber(a.averageRating) or 0)
            end 
        end)
    end)
end)

hook.Add("PlayerDisconnected","cats",function(a)
    cats:SavePlayer(a)
    for t,e in pairs(cats.currentTickets)do 
        if t==a:SteamID()then 
            net.Start('cats.closeTicket')
            net.WriteString(t)
            net.Send(n(t))
            if IsValid(e.admin)then 
                cats.config.notify(e.admin,cats.lang.ticketUserLeft,NOTIFY_ERROR,8)
            end 
            cats.currentTickets[t]=nil 
        elseif e.adminID==a:SteamID()then 
            cats:ClaimTicket(t,a,false)
        end 
    end 
end)

hook.Add("DatabaseInitialized","cats",function()
    local t=MySQLite.isMySQL()and"AUTO_INCREMENT"or"AUTOINCREMENT"
    cats:Query([[ CREATE TABLE IF NOT EXISTS cats_]]..cats.config.serverID..[[_admins( steamID VARCHAR(30) NOT NULL PRIMARY KEY, lastNick VARCHAR(255) NOT NULL, createdTime INTEGER(11) NOT NULL, lastPlayedTime INTEGER(11) NOT NULL, playTimeTotal INTEGER(11) NOT NULL, ticketTimeTotal INTEGER(8) NOT NULL, ratingTotal FLOAT NOT NULL, claimsTotal INTEGER NOT NULL, uniqueUsers INTEGER NOT NULL, timeCard TEXT NOT NULL, claimCard TEXT NOT NULL, updateTime INTEGER(11) NOT NULL ); ]])
    cats:Query([[ CREATE TABLE IF NOT EXISTS rp_admin_ticket( id INTEGER NOT NULL PRIMARY KEY ]]..t..[[, user VARCHAR(30) NOT NULL, admin VARCHAR(30) NOT NULL, createdTime INTEGER(11) NOT NULL, ticketTime INTEGER(5) NOT NULL, rating FLOAT NOT NULL ); ]])
    cats:Query([[ CREATE TABLE IF NOT EXISTS cats_]]..cats.config.serverID..[[_summary( id INTEGER NOT NULL PRIMARY KEY ]]..t..[[, checkTime INTEGER(11) NOT NULL, adminsAmount INTEGER(4) NOT NULL, playersAmount INTEGER(4) NOT NULL, casesClaimedAmount INTEGER(4) NOT NULL, casesUnclaimedAmount INTEGER(4) NOT NULL ); ]])
end)

local t,a=0,0 
hook.Add("Think","cats.timeCard",function()
    if CurTime()<t then return end 
    t=CurTime()+1 
    if os.time()>=a then 
        a=os.time()+600 
        local t=os.date('*t',os.time())
        t.wday=t.wday-1 
        for e,a in pairs(player.GetAll())do 
            if a.cats_adminData and a.cats_adminData.timeCard then 
                day=t.wday~=0 and t.wday or 7 
                hour=t.hour~=0 and t.hour or 24 
                a.cats_adminData.timeCard[day][hour]=a.cats_adminData.timeCard[day][hour]+1 
            end 
        end 
        cats:Log('TimeCard update.')
    end 
end)

local doingthis = false
net.Receive("cats.requestSync", function(len, ply)
    if doingthis then return end
    doingthis = true
    if not IsValid(ply) then return end
    if not cats.config.playerCanSeeTicket(ply, "") then return end
    net.Start("cats.syncTickets")
    net.WriteTable(cats.currentTickets)
    net.Send(ply)
    cats:Log("Sent sync tickets to " .. ply:Name() .. " after client refresh.")
end)
local function getEmptyCards()
    local e = {}
    for t = 1, 7 do e[t] = {} for a = 1, 24 do e[t][a] = 0 end end 
    return util.TableToJSON(e)
end

net.Receive("cats.deleteAdmin", function(len, ply)
    if not ply:IsSuperAdmin() and ply:GetUserGroup() ~= "curator" then return end
    local targetID = net.ReadString()
    local sid = MySQLite.SQLStr(targetID)
    cats:Query("DELETE FROM rp_admin_ticket WHERE admin = " .. sid)
    cats:Query("DELETE FROM cats_"..cats.config.serverID.."_admins WHERE steamID = " .. sid, function()
        cats.adminDataCache = {}
        cats:Log(ply:Name() .. " удалил админа " .. targetID)
        
        cats:GetAdminList(ply, function(data)
            net.Start("cats.getAdminList") net.WriteTable(data or {}) net.Send(ply)
        end)
    end)
end)

net.Receive("cats.resetAdmin", function(len, ply)
    if not ply:IsSuperAdmin() and ply:GetUserGroup() ~= "curator" then return end
    local targetID = net.ReadString()
    local sid = MySQLite.SQLStr(targetID)
    local emptyJson = MySQLite.SQLStr(getEmptyCards())
    cats:Query("DELETE FROM rp_admin_ticket WHERE admin = " .. sid)
    cats:Query("UPDATE cats_"..cats.config.serverID..[[_admins SET ticketTimeTotal=0, ratingTotal=0, claimsTotal=0, uniqueUsers=0, timeCard=]]..emptyJson..", claimCard="..emptyJson.." WHERE steamID = " .. sid, function()
        cats.adminDataCache = {} 
        
        -- Also update target player's online data if online
        local targetPly = player.GetBySteamID(targetID)
        if IsValid(targetPly) and targetPly.cats_adminData then
            targetPly.cats_adminData.claimsTotal = 0
        end

        cats:Log(ply:Name() .. " обнулил админа " .. targetID)
        
        cats:GetAdminList(ply, function(data)
            net.Start("cats.getAdminList") net.WriteTable(data or {}) net.Send(ply)
        end)
    end)
end)

net.Receive("cats.clearAllAdmins", function(len, ply)
    if not ply:IsSuperAdmin() and ply:GetUserGroup() ~= "curator" then return end
    local emptyJson = MySQLite.SQLStr(getEmptyCards())
    cats:Query("DELETE FROM rp_admin_ticket")
    cats:Query("UPDATE cats_"..cats.config.serverID..[[_admins SET ticketTimeTotal=0, ratingTotal=0, claimsTotal=0, uniqueUsers=0, timeCard=]]..emptyJson..", claimCard="..emptyJson, function()
        cats.adminDataCache = {}
        
        -- Update online players' data cache
        for _, p in ipairs(player.GetAll()) do
            if p.cats_adminData then
                p.cats_adminData.claimsTotal = 0
            end
        end

        cats:Log(ply:Name() .. " ОБНУЛИЛ СТАТИСТИКУ ВСЕМ АДМИНАМ!")
        
        cats:GetAdminList(ply, function(data)
            net.Start("cats.getAdminList") net.WriteTable(data or {}) net.Send(ply)
        end)
    end)
end)

net.Receive("cats.setClaimsTotal", function(len, ply)
    if not ply:IsSuperAdmin() and ply:GetUserGroup() ~= "curator" then return end
    local targetID = net.ReadString()
    local val = net.ReadUInt(32)
    local sid = MySQLite.SQLStr(targetID)

    cats:Query(string.format("UPDATE cats_%s_admins SET claimsTotal = %d WHERE steamID = %s", cats.config.serverID, val, sid), function()
        cats.adminDataCache = {}
        cats:Log(ply:Name() .. " изменил кол-во жалоб админа " .. targetID .. " на " .. val)
        
        -- Update online player data cache if the target admin is online
        local targetPly = player.GetBySteamID(targetID)
        if IsValid(targetPly) and targetPly.cats_adminData then
            targetPly.cats_adminData.claimsTotal = val
        end

        cats:GetAdminList(ply, function(data)
            if IsValid(ply) then
                net.Start("cats.getAdminList") net.WriteTable(data or {}) net.Send(ply)
            end
        end)
    end)
end)

hook.Add("PlayerSay", "CatsTempFix2", function(ply, text)
    if text == "!catsfix" and ply:IsSuperAdmin() then
        ply:ChatPrint("[CATS] Начинаю проверку всех игроков...")
        local e_table = {}
        for t = 1, 7 do e_table[t] = {} for a = 1, 24 do e_table[t][a] = 0 end end 
        local json_data = util.TableToJSON(e_table)
        for _, p in ipairs(player.GetAll()) do
            if cats.config.playerCanSeeTicket(p, "") then
                local sid = p:SteamID()
                cats:Query("SELECT steamID FROM cats_" .. cats.config.serverID .. "_admins WHERE steamID = " .. MySQLite.SQLStr(sid), function(data)
                    if not data or #data == 0 then
                        local playtime = p.GetPlayTime and p:GetPlayTime() or 0
                        local q = string.format([[INSERT INTO cats_%s_admins(steamID, lastNick, createdTime, playTimeTotal, lastPlayedTime, ticketTimeTotal, ratingTotal, claimsTotal, uniqueUsers, timeCard, claimCard, updateTime) VALUES (%s, %s, %d, %d, %d, 0, 0, 0, 0, %s, %s, %d)]], 
                            cats.config.serverID, MySQLite.SQLStr(sid), MySQLite.SQLStr(p:Name()), os.time(), playtime, os.time(), MySQLite.SQLStr(json_data), MySQLite.SQLStr(json_data), os.time())
                        
                        cats:Query(q, function()
                            ply:ChatPrint("[+] Успешно добавлен в базу: " .. p:Name())
                        end)
                    else
                        ply:ChatPrint("[=] Уже есть в базе: " .. p:Name())
                    end
                end)
            else
                ply:ChatPrint("[-] Пропущен (система не видит в нем админа): " .. p:Name())
            end
        end
        return ""
    end
end)



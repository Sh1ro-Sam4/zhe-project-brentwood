ORG_AIRDROP_SPAWNS = {
    { pos = Vector(3480.821289, -3426.373291, 58), name = "Заправка" },
    { pos = Vector(5765, -1230, 48), name = "Под мостом" },
    { pos = Vector(1354.404785, -150.772400, -260), name = "Пересечение водостоков" },
    { pos = Vector(-859.516357, 672.392395, -391), name = "Между Ж/Д путями метро" },
    { pos = Vector(520.750061, -2360.496338, 48), name = "За траснформаторами" }
}

local mysql_config = {
	host = "",
	user = "",
	//пароль не палим! помните?
	pass = "",
	db   = "",
	port = 3306
}

local db = mysqloo.connect(mysql_config.host, mysql_config.user, mysql_config.pass, mysql_config.db, mysql_config.port)

function db:onConnected()
	shizlib.msg("[Ipik-ORG] Успешно подключено к MySQL базе данных.")
	
	local q = db:query([[
		CREATE TABLE IF NOT EXISTS rp_orgs (
			name VARCHAR(64) PRIMARY KEY,
			owner_steamid VARCHAR(32) NOT NULL,
			color_r TINYINT NOT NULL DEFAULT 128,
			color_g TINYINT NOT NULL DEFAULT 128,
			color_b TINYINT NOT NULL DEFAULT 128,
			motd TEXT NOT NULL DEFAULT '',
			created INT NOT NULL,
			members TEXT NOT NULL,
			ranks TEXT NOT NULL,
			points DOUBLE NOT NULL DEFAULT 0,
			bank INT NOT NULL DEFAULT 0,
			slot_level INT NOT NULL DEFAULT 0,
			extra_slots INT NOT NULL DEFAULT 0
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	]])
	function q:onSuccess()
		LoadAllOrgs()
	end
	q:start()
end

function db:onConnectionFailed(err)
	shizlib.msg("[Ipik-ORG] Ошибка подключения к MySQL: " .. tostring(err))
end

db:connect()

DarkRP = DarkRP or {}
DarkRP.Orgs = DarkRP.Orgs or {}
DarkRP.OrgsData = DarkRP.OrgsData or {}

function DarkRP.FindPlayer(info)
    if not info or info == "" then return end
    info = tostring(info)
    for _, pl in ipairs(player.GetAll()) do
        if info == pl:SteamID() or info == pl:SteamID64() then
            return pl
        end
    end
end

function SaveOrg(org_name)
    local org = DarkRP.OrgsData[org_name]
    if not org then return end

    local members_json = util.TableToJSON(org.Members)
    local ranks_json = util.TableToJSON(org.Ranks)

    local query_str = string.format([[
		INSERT INTO rp_orgs (name, owner_steamid, color_r, color_g, color_b, motd, created, members, ranks, points, bank, slot_level, extra_slots)
		VALUES (%s, %s, %d, %d, %d, %s, %d, %s, %s, %f, %d, %d, %d)
		ON DUPLICATE KEY UPDATE 
			owner_steamid = VALUES(owner_steamid),
			color_r = VALUES(color_r),
			color_g = VALUES(color_g),
			color_b = VALUES(color_b),
			motd = VALUES(motd),
			members = VALUES(members),
			ranks = VALUES(ranks),
			points = VALUES(points),
			bank = VALUES(bank),
			slot_level = VALUES(slot_level),
			extra_slots = VALUES(extra_slots);
	]], 
		string.format("%q", org.Name),
		string.format("%q", org.Owner),
		org.Color.r, org.Color.g, org.Color.b,
		string.format("%q", org.MoTD or ""),
		org.Created or os.time(),
		string.format("%q", members_json),
		string.format("%q", ranks_json),
		tonumber(org.Points) or 0,
		org.Bank or 0,
		org.SlotLevel or 0,
		org.ExtraSlots or 0
	)

    local q = db:query(query_str)
    function q:onFailure(err)
        shizlib.msg("[Ipik-ORG] Не удалось сохранить организацию '" .. org_name .. "'! Ошибка: " .. tostring(err))
    end
	q:start()
end

function UpdatePlayerOrgNetVars(ply)
    if not IsValid(ply) then return end
    local steamID = ply:SteamID()
    for orgName, orgData in pairs(DarkRP.OrgsData) do
        if orgData.Members[steamID] then
            ply:SetNetVar("Org", orgName)
            ply:SetNetVar("OrgData", orgData.Members[steamID])
            ply:SetNetVar("OrgColor", orgData.Color)
            return
        end
    end
    ply:SetNetVar("Org", nil)
    ply:SetNetVar("OrgData", nil)
    ply:SetNetVar("OrgColor", nil)
end

function LoadAllOrgs()
    local q = db:query("SELECT * FROM rp_orgs")
	function q:onSuccess(data)
		DarkRP.OrgsData = {}
		if not data then return end

		for _, row in ipairs(data) do
			local members = util.JSONToTable(row.members) or {}
			local ranks = util.JSONToTable(row.ranks) or {}
			local color = Color(
				math.Clamp(tonumber(row.color_r) or 128, 0, 255),
				math.Clamp(tonumber(row.color_g) or 128, 0, 255),
				math.Clamp(tonumber(row.color_b) or 128, 0, 255)
			)

			DarkRP.OrgsData[row.name] = {
				Name = row.name,
				Owner = row.owner_steamid,
				Color = color,
				MoTD = row.motd,
				Created = tonumber(row.created) or os.time(),
				Members = members,
				Ranks = ranks,
				Points = tonumber(row.points) or 0,
				Bank = tonumber(row.bank) or 0,
				SlotLevel = tonumber(row.slot_level) or 0,
				ExtraSlots = tonumber(row.extra_slots) or 0
			}
		end

		for _, ply in ipairs(player.GetAll()) do
			UpdatePlayerOrgNetVars(ply)
		end
		shizlib.msg("[Ipik-ORG] Данные всех фракций успешно загружены из MySQL.")
	end
	q:start()
end

hook.Add("PlayerSpawn", "Org_ForceSyncOnSpawn", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then 
            UpdatePlayerOrgNetVars(ply) 
        end
    end)
end)

hook.Add("PlayerInitialSpawn", "Org_AssignPlayerData", function(ply)
    ply.OrgSessionStart = os.time()
    
    timer.Simple(8, function()
        if not IsValid(ply) then return end
        for orgName, orgData in pairs(DarkRP.OrgsData) do
            if type(orgData) == "table" and orgData.Members and orgData.Members[ply:SteamID()] then
                orgData.Members[ply:SteamID()].Name = ply:Nick()
                orgData.Members[ply:SteamID()].LastSeen = os.time()
                SaveOrg(orgName)
                ply:SetNetVar("Org", orgName)
                ply:SetNetVar("OrgData", orgData.Members[ply:SteamID()])
                ply:SetNetVar("OrgColor", orgData.Color)
                break
            end
        end
    end)
end)

function DarkRP.Orgs.Create(name, ownerSID, color)
    if DarkRP.OrgsData[name] then return false, "Организация уже существует." end
    if #name > ORG_CONFIG.MaxNameLength then return false, "Слишком длинное название." end

    local baseRanks = table.Copy(ORG_DEFAULT_RANKS)
    baseRanks["Owner"] = {
        Weight = 100,
        Perms = { Owner = true, Invite = true, Kick = true, Rank = true, MoTD = true, ChangeColor = true, ManageMiners = true }
    }

    local owner = DarkRP.FindPlayer(ownerSID)
    local ownerName = owner and owner:Nick() or ownerSID
    if IsValid(owner) then owner.OrgSessionStart = os.time() end
    DarkRP.OrgsData[name] = {
        Name = name,
        Owner = ownerSID,
        Color = color,
        Members = {
            [ownerSID] = {
                Rank = "Owner",
                Perms = baseRanks["Owner"].Perms,
                Name = ownerName,
                LastSeen = os.time(),
                Playtime = 0
            }
        },
        MoTD = "Добро пожаловать в " .. name .. "!",
        Created = os.time(),
        Ranks = baseRanks,
        Points = 0,
        Bank = 0,
        SlotLevel = 0,
        ExtraSlots = 0
    }

    for _, ply in ipairs(player.GetAll()) do
        ply:ChatPrint("Создана организация '" .. name .. "'!")
    end
    return true
end

function DarkRP.Orgs.Disband(ply)
    local orgName = ply:GetOrg()
    if not orgName then return false, "Вы не в организации." end
    local org = DarkRP.OrgsData[orgName]
    if not org then return false, "Ошибка данных." end
    if org.Owner ~= ply:SteamID() then return false, "Только владелец может расформировать." end

    for sid, _ in pairs(org.Members) do
        local p = DarkRP.FindPlayer(sid)
        if p then
            p:SetNetVar("Org", nil)
            p:SetNetVar("OrgData", nil)
            p:SetNetVar("OrgColor", nil)
        end
    end
    DarkRP.OrgsData[orgName] = nil
	
	local q = db:query("DELETE FROM rp_orgs WHERE name = " .. string.format("%q", orgName))
	q:start()
	
    return true
end

function DarkRP.Orgs.Leave(ply)
    local orgName = ply:GetOrg()
    if not orgName then return false, "Вы не в организации." end
    local org = DarkRP.OrgsData[orgName]
    if not org then return false, "Ошибка данных." end
    if org.Owner == ply:SteamID() then return false, "Владелец не может покинуть организацию. Используйте расформирование." end

    org.Members[ply:SteamID()] = nil
    ply:SetNetVar("Org", nil)
    ply:SetNetVar("OrgData", nil)
    ply:SetNetVar("OrgColor", nil)
    return true
end

function DarkRP.Orgs.Join(ply, orgName)
    if ply:GetOrg() then return false, "Вы уже в организации." end
    local org = DarkRP.OrgsData[orgName]
    if not org then return false, "Организация не найдена." end
    if org.Members[ply:SteamID()] then return false, "Вы уже член этой организации." end

    local memberRank = org.Ranks["Member"]
    if not memberRank then
        memberRank = { Perms = { Owner = false, Invite = false, Kick = false, Rank = false, MoTD = false, ChangeColor = false } }
    end

    org.Members[ply:SteamID()] = {
        Rank = "Member",
        Perms = memberRank.Perms,
        Name = ply:Nick(),
        LastSeen = os.time(),
        Playtime = 0
    }
    ply.OrgSessionStart = os.time()
    ply:SetNetVar("Org", orgName)
    ply:SetNetVar("OrgData", org.Members[ply:SteamID()])
    ply:SetNetVar("OrgColor", org.Color)
    return true
end

function DarkRP.Orgs.Invite(inviter, targetSID)
    local orgName = inviter:GetOrg()
    if not orgName then return false, "Вы не в организации." end
    local org = DarkRP.OrgsData[orgName]
    if not org then return false, "Ошибка данных." end
    
    local maxSlots = (ORG_CONFIG.SlotUpgrades[org.SlotLevel] and ORG_CONFIG.SlotUpgrades[org.SlotLevel].slots or 10) + (org.ExtraSlots or 0)
    
    local inviterData = org.Members[inviter:SteamID()]
    if not inviterData or not inviterData.Perms.Invite then return false, "Нет прав приглашать." end
    if table.Count(org.Members) >= maxSlots then return false, "В вашей организации больше нет места." end
    
    local target = DarkRP.FindPlayer(targetSID)
    if not IsValid(target) then return false, "Игрок не найден или не в сети." end
    if target:GetOrg() then return false, "Игрок уже состоит в организации." end

    target.org_invite_pending = orgName
    inviter:ChatPrint("Приглашение отправлено " .. target:Nick())
    target:ChatPrint("Вас пригласили в организацию " .. orgName .. ". Используйте /acceptorg")
    return true
end

function DarkRP.Orgs.Kick(kicker, targetSID)
    local orgName = kicker:GetOrg()
    if not orgName then return false, "Вы не в организации." end
    local org = DarkRP.OrgsData[orgName]
    if not org then return false, "Ошибка данных." end
    local kickerData = org.Members[kicker:SteamID()]
    if not kickerData or not kickerData.Perms.Kick then return false, "Нет прав исключать." end
    if targetSID == org.Owner then return false, "Нельзя исключить владельца." end
    if not org.Members[targetSID] then return false, "Игрок не в организации." end

    org.Members[targetSID] = nil
    local target = DarkRP.FindPlayer(targetSID)
    if target then
        target:SetNetVar("Org", nil)
        target:SetNetVar("OrgData", nil)
        target:SetNetVar("OrgColor", nil)
        target:ChatPrint("Вас исключили из организации " .. orgName)
    end
    return true
end

function DarkRP.Orgs.SetRank(changer, targetSID, newRank)
    local orgName = changer:GetOrg()
    if not orgName then return false, "Вы не в организации." end
    local org = DarkRP.OrgsData[orgName]
    if not org then return false, "Ошибка данных." end
    local changerData = org.Members[changer:SteamID()]
    if not changerData or not changerData.Perms.Rank then return false, "Нет прав менять ранги." end
    if targetSID == org.Owner then return false, "Нельзя изменить ранг владельца." end
    local targetData = org.Members[targetSID]
    if not targetData then return false, "Игрок не в организации." end
    if not org.Ranks[newRank] then return false, "Роль не существует." end

    targetData.Rank = newRank
    targetData.Perms = org.Ranks[newRank].Perms
    local target = DarkRP.FindPlayer(targetSID)
    if target then target:SetNetVar("OrgData", targetData) end
    return true
end

function DarkRP.Orgs.AddRank(owner, rankName, weight, perms)
    local orgName = owner:GetOrg()
    if not orgName then return false, "Вы не в организации." end
    local org = DarkRP.OrgsData[orgName]
    if not org then return false, "Ошибка данных." end
    if org.Owner ~= owner:SteamID() then return false, "Только владелец может добавлять роли." end
    if org.Ranks[rankName] then return false, "Роль уже существует." end

    org.Ranks[rankName] = { Weight = weight, Perms = perms }
    return true
end

function DarkRP.Orgs.RemoveRank(owner, rankName)
    local orgName = owner:GetOrg()
    if not orgName then return false, "Вы не в организации." end
    local org = DarkRP.OrgsData[orgName]
    if not org then return false, "Ошибка данных." end
    if org.Owner ~= owner:SteamID() then return false, "Только владелец может удалять роли." end
    if rankName == "Owner" or rankName == "Member" then return false, "Нельзя удалить базовую роль." end
    if not org.Ranks[rankName] then return false, "Роль не существует." end

    for sid, data in pairs(org.Members) do
        if data.Rank == rankName then
            data.Rank = "Member"
            data.Perms = org.Ranks["Member"].Perms
            local pl = DarkRP.FindPlayer(sid)
            if pl then pl:SetNetVar("OrgData", data) end
        end
    end
    org.Ranks[rankName] = nil
    return true
end

function DarkRP.Orgs.UpdateMotD(updater, newMotD)
    local orgName = updater:GetOrg()
    if not orgName then return false, "Вы не в организации." end
    local org = DarkRP.OrgsData[orgName]
    if not org then return false, "Ошибка данных." end
    local updaterData = org.Members[updater:SteamID()]
    if not updaterData or not updaterData.Perms.MoTD then return false, "Нет прав." end

    org.MoTD = newMotD
    for sid, _ in pairs(org.Members) do
        local pl = DarkRP.FindPlayer(sid)
        if pl then
            net.Start("Org_UpdateMotDNotify")
            net.WriteString(newMotD)
            net.Send(pl)
        end
    end
    return true
end

function DarkRP.Orgs.UpdateColor(updater, newColor)
    local orgName = updater:GetOrg()
    if not orgName then return false, "Вы не в организации." end
    local org = DarkRP.OrgsData[orgName]
    if not org then return false, "Ошибка данных." end
    local updaterData = org.Members[updater:SteamID()]
    if not updaterData or not updaterData.Perms.ChangeColor then return false, "Нет прав." end

    org.Color = newColor
    for sid, _ in pairs(org.Members) do
        local pl = DarkRP.FindPlayer(sid)
        if pl then pl:SetNetVar("OrgColor", newColor) end
    end
    return true
end

function DarkRP.Orgs.DepositMoney(ply, amount)
    local orgName = ply:GetOrg()
    if not orgName or not DarkRP.OrgsData[orgName] then return false, "Вы не в организации." end
    if amount <= 0 or not ply:CanAfford(amount) then return false, "Недостаточно средств." end

    ply:AddMoney(-amount)
    DarkRP.OrgsData[orgName].Bank = DarkRP.OrgsData[orgName].Bank + amount
    SaveOrg(orgName)
    return true, "Вы внесли деньги в банк."
end

function DarkRP.Orgs.WithdrawMoney(ply, amount)
    local orgName = ply:GetOrg()
    if not orgName or not DarkRP.OrgsData[orgName] then return false, "Вы не в организации." end
    local org = DarkRP.OrgsData[orgName]

    if org.Owner ~= ply:SteamID() then return false, "Только лидер может снимать деньги." end
    if amount <= 0 or org.Bank < amount then return false, "Недостаточно средств в банке." end

    org.Bank = org.Bank - amount
    ply:AddMoney(amount)
    SaveOrg(orgName)
    return true, "Вы сняли деньги с банка."
end

function DarkRP.Orgs.UpgradeSlots(ply)
    local orgName = ply:GetOrg()
    if not orgName or not DarkRP.OrgsData[orgName] then return false, "Вы не в организации." end
    local org = DarkRP.OrgsData[orgName]

    if org.Owner ~= ply:SteamID() then return false, "Только лидер может прокачивать организацию." end

    local nextLevel = org.SlotLevel + 1
    local upgradeConfig = ORG_CONFIG.SlotUpgrades[nextLevel]

    if not upgradeConfig then return false, "Организация уже максимального уровня." end
    if org.Bank < upgradeConfig.price then return false, "Недостаточно средств в банке организации." end

    org.Bank = org.Bank - upgradeConfig.price
    org.SlotLevel = nextLevel
    SaveOrg(orgName)
    return true, "Организация успешно прокачана!"
end

local PLAYER = FindMetaTable("Player")
function PLAYER:GetOrg()
    return self:GetNetVar("Org")
end
function PLAYER:GetOrgData()
    return self:GetNetVar("OrgData")
end
function PLAYER:GetOrgColor()
    local c = self:GetNetVar("OrgColor")
    return c and Color(c.r, c.g, c.b) or Color(255,255,255)
end

util.AddNetworkString("Org_RequestAllOrgs")
util.AddNetworkString("Org_SendAllOrgs")
util.AddNetworkString("Org_RequestMyOrgData")
util.AddNetworkString("Org_SendMyOrgData")
util.AddNetworkString("Org_ConfirmCreate")
util.AddNetworkString("Org_Invite")
util.AddNetworkString("Org_Kick")
util.AddNetworkString("Org_SetRank")
util.AddNetworkString("Org_AddRank")
util.AddNetworkString("Org_RemoveRank")
util.AddNetworkString("Org_UpdateMotD")
util.AddNetworkString("Org_UpdateColor")
util.AddNetworkString("Org_Disband")
util.AddNetworkString("Org_Leave")
util.AddNetworkString("Org_AcceptInvite")
util.AddNetworkString("Org_UpdateMotDNotify")
util.AddNetworkString("Org_BankOp")
util.AddNetworkString("Org_UpgradeSlots")
util.AddNetworkString("Org_RequestOrgMembers")
util.AddNetworkString("Org_SendOrgMembers")

net.Receive("Org_RequestAllOrgs", function(len, ply)
    local activeMiners = {}
    for _, ent in ipairs(ents.FindByClass("org_drop_small")) do
        if IsValid(ent) and ent.GetORGIANAME then
            local orgName = ent:GetORGIANAME()
            if orgName and orgName ~= "" then
                activeMiners[orgName] = (activeMiners[orgName] or 0) + 1
            end
        end
    end

    local orgs = {}
    for name, data in pairs(DarkRP.OrgsData) do
        if type(data) == "table" and data.Name and data.Owner then
            table.insert(orgs, {
                Name = name,
                Owner = data.Owner,
                Color = data.Color,
                Points = data.Points,
                MemberCount = table.Count(data.Members),
                MotD = data.MoTD,
                Bank = data.Bank or 0,
                SlotLevel = data.SlotLevel or 0,
                ExtraSlots = data.ExtraSlots or 0,
                ActiveMiners = activeMiners[name] or 0
            })
        end
    end
    table.sort(orgs, function(a, b) return a.Points > b.Points end)

    net.Start("Org_SendAllOrgs")
    net.WriteTable(orgs)
    net.Send(ply)
end)

net.Receive("Org_RequestMyOrgData", function(len, ply)
    if not ply:GetOrg() then 
        UpdatePlayerOrgNetVars(ply) 
    end

    local orgName = ply:GetOrg()
    
    if not orgName or not DarkRP.OrgsData[orgName] then
        if orgName then 
            ply:SetNetVar("Org", nil)
            ply:SetNetVar("OrgData", nil)
            ply:SetNetVar("OrgColor", nil)
        end
        net.Start("Org_SendMyOrgData")
        net.WriteBool(false)
        net.Send(ply)
        return
    end

    local org = DarkRP.OrgsData[orgName]
    local isOwner = (org.Owner == ply:SteamID())

    local members = {}
    for sid, data in pairs(org.Members) do
        local p = DarkRP.FindPlayer(sid)
        
        local curPlaytime = data.Playtime or 0
        if IsValid(p) and p.OrgSessionStart then
            curPlaytime = curPlaytime + (os.time() - p.OrgSessionStart)
        end
        
        table.insert(members, {
            SteamID = sid,
            Name = p and p:Nick() or (data.Name or sid),
            Rank = data.Rank,
            Online = p ~= nil,
            LastSeen = p and os.time() or (data.LastSeen or 0),
            Playtime = curPlaytime
        })
    end

    local ranks = {}
    for name, data in pairs(org.Ranks) do
        table.insert(ranks, {
            Name = name,
            Weight = data.Weight,
            Perms = data.Perms
        })
    end

    net.Start("Org_SendMyOrgData")
    net.WriteBool(true)
    net.WriteString(orgName)
    net.WriteBool(isOwner)
    net.WriteTable(members)
    net.WriteTable(ranks)
    net.WriteString(org.MoTD or "")
    net.WriteColor(org.Color)
    net.WriteDouble(org.Points)
    net.WriteUInt(org.Bank or 0, 32)
    net.WriteUInt(org.SlotLevel or 0, 8)
    net.WriteUInt(org.ExtraSlots or 0, 16)
    net.Send(ply)
end)

net.Receive("Org_ConfirmCreate", function(len, ply)
    local orgName = net.ReadString()
    
    local alreadyInOrg = false
    for _, orgData in pairs(DarkRP.OrgsData) do
        if type(orgData) == "table" and orgData.Members and orgData.Members[ply:SteamID()] then
            alreadyInOrg = true
            break
        end
    end

    if alreadyInOrg then
        ply:ChatPrint("Вы уже состоите в организации!")
        return
    end

    if not ply:CanAfford(ORG_CONFIG.CreateCost) then return end

    local success, err = DarkRP.Orgs.Create(orgName, ply:SteamID(), ORG_CONFIG.DefaultColor)
    if not success then
        ply:ChatPrint(err)
        return
    end

    ply:AddMoney(-ORG_CONFIG.CreateCost)
    ply:SetNetVar("Org", orgName)
    ply:SetNetVar("OrgData", DarkRP.OrgsData[orgName].Members[ply:SteamID()])
    ply:SetNetVar("OrgColor", DarkRP.OrgsData[orgName].Color)
    ply:ChatPrint("Организация '" .. orgName .. "' создана!")
    SaveOrg(orgName)
    
    local owner = DarkRP.FindPlayer(ply:SteamID())
    if owner then
        UpdatePlayerOrgNetVars(owner)
    end
end)

net.Receive("Org_Invite", function(len, ply)
    local targetSID = net.ReadString()
    if not targetSID or targetSID == "" then return end
    
    local success, err = DarkRP.Orgs.Invite(ply, targetSID)
    if not success then 
        ply:ChatPrint(err or "Ошибка при приглашении.") 
    end
end)

net.Receive("Org_Kick", function(len, ply)
    local targetSID = net.ReadString()
    local success, err = DarkRP.Orgs.Kick(ply, targetSID)
    if success then SaveOrg(ply:GetOrg()) end
    if not success then ply:ChatPrint(err) end
end)

net.Receive("Org_SetRank", function(len, ply)
    local targetSID = net.ReadString()
    local rankName = net.ReadString()
    local success, err = DarkRP.Orgs.SetRank(ply, targetSID, rankName)
    if success then SaveOrg(ply:GetOrg()) end
    if not success then ply:ChatPrint(err) end
end)

net.Receive("Org_AddRank", function(len, ply)
    local rankName = net.ReadString()
    local weight = net.ReadUInt(7)
    local perms = {
        Weight = weight,
        Owner = net.ReadBool(),
        Invite = net.ReadBool(),
        Kick = net.ReadBool(),
        Rank = net.ReadBool(),
        MoTD = net.ReadBool(),
        ChangeColor = net.ReadBool(),
        ManageMiners = net.ReadBool()
    }
    local success, err = DarkRP.Orgs.AddRank(ply, rankName, weight, perms)
    if success then SaveOrg(ply:GetOrg()) end
    if not success then ply:ChatPrint(err) else ply:ChatPrint("Роль добавлена.") end
end)

net.Receive("Org_RemoveRank", function(len, ply)
    local rankName = net.ReadString()
    local success, err = DarkRP.Orgs.RemoveRank(ply, rankName)
    if success then SaveOrg(ply:GetOrg()) end
    if not success then ply:ChatPrint(err) else ply:ChatPrint("Роль удалена.") end
end)

net.Receive("Org_UpdateMotD", function(len, ply)
    local newMotD = net.ReadString()
    local success, err = DarkRP.Orgs.UpdateMotD(ply, newMotD)
    if success then SaveOrg(ply:GetOrg()) end
    if not success then ply:ChatPrint(err) end
end)

net.Receive("Org_UpdateColor", function(len, ply)
    local r, g, b = net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)
    local col = Color(r, g, b)
    local success, err = DarkRP.Orgs.UpdateColor(ply, col)
    if success then SaveOrg(ply:GetOrg()) end
    if not success then ply:ChatPrint(err) end
end)

net.Receive("Org_Disband", function(len, ply)
    local orgName = ply:GetOrg()
    if not orgName then return end
    local success, err = DarkRP.Orgs.Disband(ply)
    if not success then ply:ChatPrint(err) end
end)

net.Receive("Org_Leave", function(len, ply)
    local org = ply:GetOrg()
    local success, err = DarkRP.Orgs.Leave(ply)
    if success then SaveOrg(org) end
    if not success then ply:ChatPrint(err) end
end)

net.Receive("Org_AcceptInvite", function(len, ply)
    if not ply.org_invite_pending then
        ply:ChatPrint("Нет активных приглашений.")
        return
    end

    local alreadyInOrg = false
    for _, orgData in pairs(DarkRP.OrgsData) do
        if type(orgData) == "table" and orgData.Members and orgData.Members[ply:SteamID()] then
            alreadyInOrg = true
            break
        end
    end

    if alreadyInOrg then
        ply:ChatPrint("Вы уже состоите в организации!")
        return
    end

    local orgName = ply.org_invite_pending
    ply.org_invite_pending = nil
    local success, err = DarkRP.Orgs.Join(ply, orgName)
    if success then
        SaveOrg(orgName)
        ply:ChatPrint("Вы присоединились к организации '" .. orgName .. "'.")
    else
        ply:ChatPrint(err or "Не удалось присоединиться.")
    end
end)

net.Receive("Org_BankOp", function(len, ply)
    local isDeposit = net.ReadBool()
    local amount = math.floor(net.ReadUInt(32))
    if amount <= 0 then return end

    if isDeposit then
        local success, err = DarkRP.Orgs.DepositMoney(ply, amount)
        if not success then ply:ChatPrint(err) else ply:ChatPrint("Вы внесли " .. string.Comma(amount) .. "$ в банк организации.") end
    else
        local success, err = DarkRP.Orgs.WithdrawMoney(ply, amount)
        if not success then ply:ChatPrint(err) else ply:ChatPrint("Вы сняли " .. string.Comma(amount) .. "$ из банка организации.") end
    end
    net.Start("Org_RequestMyOrgData") net.Send(ply)
end)

net.Receive("Org_UpgradeSlots", function(len, ply)
    local success, err = DarkRP.Orgs.UpgradeSlots(ply)
    ply:ChatPrint(err)
    if success then
        net.Start("Org_RequestMyOrgData") net.Send(ply)
    end
end)

net.Receive("Org_RequestOrgMembers", function(len, ply)
    local orgName = net.ReadString()
    local org = DarkRP.OrgsData[orgName]
    if not org then return end

    local members = {}
    for sid, data in pairs(org.Members) do
        local p = DarkRP.FindPlayer(sid)
        
        local curPlaytime = tonumber(data.Playtime) or 0
        if IsValid(p) and p.OrgSessionStart then
            curPlaytime = curPlaytime + (os.time() - p.OrgSessionStart)
        end
        
        table.insert(members, {
            SteamID = sid,
            Name = p and p:Nick() or (data.Name or sid),
            Rank = data.Rank,
            Online = p ~= nil,
            LastSeen = (p ~= nil) and os.time() or (tonumber(data.LastSeen) or 0),
            Playtime = curPlaytime
        })
    end

    net.Start("Org_SendOrgMembers")
    net.WriteUInt(#members, 8)
    for _, m in ipairs(members) do
        net.WriteString(m.SteamID)
        net.WriteString(m.Name)
        net.WriteString(m.Rank)
        net.WriteBool(m.Online)
        net.WriteUInt(tonumber(m.LastSeen) or 0, 32) 
        net.WriteUInt(tonumber(m.Playtime) or 0, 32) 
    end
    net.Send(ply)
end)

function DarkRP.Orgs.AddPoints(orgName, amount)
    if not orgName or not amount or type(amount) ~= "number" then 
        return false, "Неверные аргументы." 
    end

    local org = DarkRP.OrgsData[orgName]
    if not org then 
        return false, "Организация не найдена." 
    end

    org.Points = math.Max((org.Points or 0) + amount, 0)
    SaveOrg(orgName)

    return true, "Очки успешно обновлены. Текущие очки: " .. org.Points
end

function DarkRP.Orgs.SetPoints(orgName, amount)
    if not orgName or not amount or type(amount) ~= "number" then 
        return false, "Неверные аргументы." 
    end

    local org = DarkRP.OrgsData[orgName]
    if not org then 
        return false, "Организация не найдена." 
    end

    org.Points = math.Max(amount, 0)
    SaveOrg(orgName)

    return true, "Очки успешно установлены. Текущие очки: " .. org.Points
end

function DarkRP.Orgs.SetName(orgName, name)
    if not orgName then 
        return false, "Неверные аргументы." 
    end

    local org = DarkRP.OrgsData[orgName]
    if not org then 
        return false, "Организация не найдена." 
    end

    org.Name = name
    SaveOrg(orgName)

    return true, ""
end

function DarkRP.Orgs.AddBankMoney(orgName, amount)
    if not orgName or not amount or type(amount) ~= "number" then 
        return false, "Неверные аргументы." 
    end

    local org = DarkRP.OrgsData[orgName]
    if not org then 
        return false, "Организация не найдена." 
    end

    org.Bank = math.Max((org.Bank or 0) + amount, 0)
    SaveOrg(orgName)

    return true, "Баланс банка обновлен. Текущий баланс: " .. org.Bank
end

function DarkRP.Orgs.ForceTransferOwnership(orgName, targetSID)
    local org = DarkRP.OrgsData[orgName]
    if not org then return false, "Организация '" .. tostring(orgName) .. "' не найдена." end
    
    local oldOwnerSID = org.Owner
    if oldOwnerSID == targetSID then return false, "Этот игрок уже является владельцем." end

    for otherOrgName, otherOrgData in pairs(DarkRP.OrgsData) do
        if otherOrgName ~= orgName and otherOrgData.Members and otherOrgData.Members[targetSID] then
            return false, "Игрок " .. targetSID .. " находится в другой организации (" .. otherOrgName .. "). Сначала удалите его оттуда."
        end
    end

    local ownerRank = org.Ranks["Owner"] or { Perms = { Owner = true, Invite = true, Kick = true, Rank = true, MoTD = true, ChangeColor = true } }
    local memberRank = org.Ranks["Member"] or { Perms = { Owner = false, Invite = false, Kick = false, Rank = false, MoTD = false, ChangeColor = false } }

    if org.Members[oldOwnerSID] then
        org.Members[oldOwnerSID].Rank = "Member"
        org.Members[oldOwnerSID].Perms = memberRank.Perms
        
        local oldOwnerPly = DarkRP.FindPlayer(oldOwnerSID)
        if IsValid(oldOwnerPly) then
            oldOwnerPly:SetNetVar("OrgData", org.Members[oldOwnerSID])
            oldOwnerPly:ChatPrint("Разработчик передал права лидера вашей организации другому игроку.")
        end
    end

    local targetPly = DarkRP.FindPlayer(targetSID)
    local targetName = targetPly and targetPly:Nick() or targetSID

    if org.Members[targetSID] then
        org.Members[targetSID].Rank = "Owner"
        org.Members[targetSID].Perms = ownerRank.Perms
    else
        org.Members[targetSID] = {
            Rank = "Owner",
            Perms = ownerRank.Perms,
            Name = targetName
        }
    end
    
    org.Owner = targetSID

    if IsValid(targetPly) then
        targetPly:SetNetVar("Org", orgName)
        targetPly:SetNetVar("OrgData", org.Members[targetSID])
        targetPly:SetNetVar("OrgColor", org.Color)
        targetPly:ChatPrint("Разработчик назначил вас лидером организации " .. orgName .. "!")
    end

    for _, ply in ipairs(player.GetAll()) do
        ply:ChatPrint("Право владением организацие '" .. orgName .. "' было передано игроку "..targetPly:Nick().."!")
    end

    SaveOrg(orgName)
    return true, "Права лидера организации '" .. orgName .. "' успешно переданы игроку " .. targetSID
end

util.AddNetworkString("Org_SpawnMiner")

net.Receive("Org_SpawnMiner", function(len, ply)
    local orgName = ply:GetOrg()
    if not orgName then 
        ply:ChatPrint("Вы не состоите в организации.")
        return 
    end

    local org = DarkRP.OrgsData[orgName]
    if not org then return end

    local plyData = org.Members[ply:SteamID()]
    if not plyData then return end

    local isOwner = (org.Owner == ply:SteamID())
    local canManage = isOwner or (plyData.Perms and plyData.Perms.ManageMiners)

    if not canManage then
        ply:ChatPrint("У вас нет прав на установку дата-центра.")
        return
    end

    local cost = 10000
    if (org.Bank or 0) < cost then
        ply:ChatPrint("В банке организации недостаточно средств! Требуется " .. string.Comma(cost) .. "$.")
        return
    end

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:GetAimVector() * 85,
        filter = ply
    })

    local ent = ents.Create("org_drop_small")
    if not IsValid(ent) then 
        ply:ChatPrint("Ошибка: энтити 'org_drop_small' не найдено на сервере.")
        return 
    end

    ent:SetPos(tr.HitPos + Vector(0, 0, 15))
    ent:SetAngles(Angle(0, ply:EyeAngles().yaw + 180, 0))
    ent:Spawn()
    
    if ent.SetORGIANAME then
        ent:SetORGIANAME(orgName)
    else
        ent.ORGIANAME = orgName
        ent:SetNWString("ORGIANAME", orgName)
    end

    org.Bank = org.Bank - cost
    SaveOrg(orgName)

    ply:ChatPrint("Вы успешно установили Дата-Центр за " .. string.Comma(cost) .. "$ из банка организации.")
    
    net.Start("Org_RequestMyOrgData")
    net.Send(ply)
end)

function DarkRP.Orgs.ResetAllPoints()
    local compensations = {}
    local wipeStats = {}

    if DarkRP.OrgsData then
        for orgName, orgData in pairs(DarkRP.OrgsData) do
            local currentPoints = orgData.Points or 0
            
            if currentPoints > 0 then
                local bonus = math.Round(currentPoints * 173000)
                local totalComp = 100000 + bonus
                
                orgData.Bank = (orgData.Bank or 0) + totalComp
                
                table.insert(wipeStats, {
                    name = orgName,
                    points = currentPoints,
                    comp = totalComp
                })
                
                compensations[orgName] = totalComp
            end
            
            orgData.Points = 0
            SaveOrg(orgName) 
        end
    end

    for _, ply in ipairs(player.GetAll()) do
        local orgName = ply:GetOrg()
        
        if orgName then
            net.Start("Org_RequestMyOrgData")
            net.Send(ply)
            
            if not compensations[orgName] then
                ply:ChatPrint("[Организации] Очки всех организаций были сброшены до 0.")
            end
        end
    end

    table.sort(wipeStats, function(a, b) return a.points < b.points end)

    for i, stat in ipairs(wipeStats) do
        local formattedPoints = math.Round(stat.points, 3)
        local msg = string.format("Организация \"%s\" утратила %s очков и получила в качестве компенсации %s$", stat.name, formattedPoints, string.Comma(stat.comp))
        
        timer.Simple(i * 0.5, function()
            for _, ply in ipairs(player.GetAll()) do
                ply:ChatPrint(msg)
            end
        end)
    end
end

hook.Add("PlayerDisconnected", "Org_PlayerDisconnected", function(ply)
    local orgName = ply:GetOrg()
    if not orgName then return end
    
    local org = DarkRP.OrgsData[orgName]
    if not org or not org.Members then return end
    
    local mem = org.Members[ply:SteamID()]
    if not mem then return end
    
    mem.LastSeen = os.time()
    if ply.OrgSessionStart then
        mem.Playtime = (mem.Playtime or 0) + (os.time() - ply.OrgSessionStart)
    end
    SaveOrg(orgName)
end)

util.AddNetworkString("Org_BuyShopItem")

net.Receive("Org_BuyShopItem", function(len, ply)
    local itemID = net.ReadString()
    local orgName = ply:GetOrg()
    if not orgName then return end
    
    local org = DarkRP.OrgsData[orgName]
    if not org or org.Owner ~= ply:SteamID() then 
        ply:ChatPrint("Только лидер может покупать предметы в магазине!")
        return 
    end

    if itemID == "extra_slots" then
        local cost = 10

        if (org.Points or 0) < cost then
            ply:ChatPrint("Недостаточно очков организации!")
            return
        end

        local maxLvl = 0
        if ORG_CONFIG and ORG_CONFIG.SlotUpgrades then
            for k, _ in pairs(ORG_CONFIG.SlotUpgrades) do
                if k > maxLvl then maxLvl = k end
            end
        end

        if (org.SlotLevel or 0) < maxLvl then
            ply:ChatPrint("Сначала прокачайте слоты за деньги до максимального уровня (" .. maxLvl .. ")!")
            return
        end

        org.Points = org.Points - cost
        org.ExtraSlots = (org.ExtraSlots or 0) + 1
        SaveOrg(orgName)

        ply:ChatPrint("Вы успешно расширили вместимость организации на +1 слот!")

        net.Start("Org_RequestMyOrgData")
        net.Send(ply)

    elseif itemID == "airdrop" then
        local cost = 3

        if (org.Points or 0) < cost then
            ply:ChatPrint("Недостаточно очков организации! Требуется: " .. cost)
            return
        end

        if player.GetCount() < 30 then
            ply:ChatPrint("Для вызова аирдропа необходимо минимум 30 игроков на сервере.")
            return
        end

        local cdTime = GetGlobalInt("Org_AirdropCD", 0)
        if os.time() < cdTime then
            local left = cdTime - os.time()
            ply:ChatPrint("Наши информаторы пока не имееют данных! Осталось: " .. math.floor(left / 60) .. " мин.")
            return
        end

        if not ORG_AIRDROP_SPAWNS or #ORG_AIRDROP_SPAWNS == 0 then
            return
        end

        org.Points = org.Points - cost
        SaveOrg(orgName)

        SetGlobalInt("Org_AirdropCD", os.time() + 3600)

        local dropData = table.Random(ORG_AIRDROP_SPAWNS)
        
        local ent = ents.Create("org_drop_new") 
        if not IsValid(ent) then 
            ply:ChatPrint("Ошибка: энтити ящика не найдено на сервере.")
            org.Points = org.Points + cost
            SaveOrg(orgName)
            SetGlobalInt("Org_AirdropCD", 0)
            return 
        end

        ent:SetPos(dropData.pos)
        ent:Spawn()
        ent:DropToFloor()

        local msg = "Обнаружен схрон. Его местоположение приблизительно в : " .. dropData.name
        for _, p in ipairs(player.GetAll()) do
            if p:GetOrg() != nil then
                p:ChatPrint("[Секретная частота] " .. msg)
            end
        end

        net.Start("Org_RequestMyOrgData")
        net.Send(ply)
    else
        ply:ChatPrint("Этот предмет пока недоступен для покупки.")
    end
end)

function DarkRP.Orgs.DivideAllBanks()
    if not DarkRP.OrgsData then 
        return 
    end
    
    for orgName, orgData in pairs(DarkRP.OrgsData) do
        local currentBank = orgData.Bank or 0
        local newBank = math.Round(currentBank / 1000)
        
        orgData.Bank = newBank
        SaveOrg(orgName)
    end

    for _, ply in ipairs(player.GetAll()) do
        if ply:GetOrg() then
            net.Start("Org_RequestMyOrgData")
            net.Send(ply)
            ply:ChatPrint("[Организации] Балансы всех организаций в банке были деноминированы.")
        end
    end
end

function SpawnOrgBox()
    local dropData = table.Random(ORG_AIRDROP_SPAWNS)
    
    local ent = ents.Create("org_drop_new") 
    ent:SetPos(dropData.pos)
    ent:Spawn()
    ent:DropToFloor()
    local msg = "Обнаружен схрон. Его местоположение приблизительно в : " .. dropData.name
    for _, p in ipairs(player.GetAll()) do
        if p:GetOrg() != nil then
            p:ChatPrint("[Секретная частота] " .. msg)
        end
    end
end
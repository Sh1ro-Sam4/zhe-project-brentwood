local PLAYER = FindMetaTable('Player')

rp.Classes = {}

function rp.CreateClass(jobData)
    if not jobData or type(jobData) ~= "table" then return nil end

    local name = jobData.name or jobData.Name
    if not name or type(name) ~= "string" then return nil end

    local category = jobData.category or jobData.Category
    if not category or type(category) ~= "string" then return nil end

    local command = jobData.command or jobData.Command
    if not command or type(command) ~= "string" then return nil end

    local hide = jobData.hide or jobData.Hide or false
    if not hide or type(hide) ~= "boolean" then hide = false end

    local color = jobData.color or jobData.Color or Color(255, 255, 255)

    local model = jobData.model or jobData.Model or {}
    if type(model) ~= "table" then model = {model} end

    local weapons = jobData.weapons or jobData.Weapons or {}
    if type(weapons) ~= "table" then weapons = {weapons} end

    local attachments = jobData.attachments or jobData.Attachments or {}
    if type(attachments) ~= "table" then attachments = {attachments} end

    local ammo = jobData.ammo or jobData.Ammo or {}
    if type(ammo) ~= "table" then ammo = {ammo} end

    local equipment = jobData.equipment or jobData.Equipment or {}
    if type(equipment) ~= "table" then equipment = {equipment} end

    local spawn = jobData.spawn or jobData.Spawn or {}
    if type(spawn) ~= "table" then spawn = {map = {Vector(0, 0, 0)}} end

    local haslicense = jobData.haslicense or jobData.HasLicense or false
    if type(haslicense) ~= "boolean" then haslicense = false end

    local max = jobData.max or jobData.Max or 0
    if type(max) ~= "number" then max = 0 end

    local salary = jobData.salary or jobData.Salary or 0
    if type(salary) ~= "number" then salary = 0 end

    local customcheck = jobData.customcheck or jobData.CustomCheck or function() return true end
    if type(customcheck) ~= "function" then customcheck = function() return true end end

    -- local playerspawn = jobData.playerspawn or jobData.PlayerSpawn or function() return true end
    -- if type(playerspawn) ~= "function" then playerspawn = function() end end

    local bodygroups = jobData.bodygroups or jobData.Bodygroups or ""
    if type(bodygroups) ~= "string" then bodygroups = "" end

    local classTable = {
        Name = name,
        Category = category,
        Command = command,
        Hide = hide,
        Color = color,
        Model = model,
        Max = max,
        Salary = salary,
        HasLicense = haslicense,
        Weapons = weapons,
        Attachments = attachments,
        Ammo = ammo,
        Equipment = equipment,
        Spawn = spawn,
        CustomCheck = customcheck,
        -- PlayerSpawn = playerspawn,
        Bodygroups = bodygroups,
    }

    rp.Classes[name] = classTable
    table.insert(rp.Classes, classTable)
    return classTable
end

function PLAYER:GetPlayerClass()
    local className = self:GetNWString("Jobs", nil)
    if className and rp.Classes[className] then
        return rp.Classes[className]
    end
    return nil
end

function rp.GetClassName(classObj)
    if classObj and classObj.Name then
        return classObj.Name
    else
        return nil
    end
end

function rp.GetClassColor(classObj)
    if classObj and classObj.Color then
        return classObj.Color
    else
        return Color(255, 255, 255)
    end
end
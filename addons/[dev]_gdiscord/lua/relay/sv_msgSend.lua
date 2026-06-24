require("chttp")
print("меов")

local IsValid = IsValid
local util_TableToJSON = util.TableToJSON
local util_SteamIDTo64 = util.SteamIDTo64
function SendNetDS(form) 
	if type( form ) ~= "table" then Error( '[Discord] invalid type!' ) return end
	--PrintTable(form)
	CHTTP({
		["failed"] = function( msg )
			print( "[Discord] "..msg )
		end,
		["method"] = "POST",
		["url"] = "",
		["body"] = util_TableToJSON(form),
		["type"] = "application/json; charset=utf-8"
	})
end


function PlayerSendNetDS(ply,str)
	local Timestamp = os.time()
	local TimeString = os.date( "%H:%M:%S - %d/%m/%Y" , Timestamp )
	local form = {
		["username"] = "Пушистый мониторщик",
		["content"] = TimeString,
		["embeds"] = {{
			["title"] = ply:Nick().." | "..ply:SteamID64().."",
			["description"] = str,
			["color"] = 5793266,
			["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
		}}
	}
	SendNetDS(form)
end

local tabtoJSON = util.TableToJSON
GDiscord = GDiscord or {}
GDiscord.sendToDSCustom = function(webhook, params)
    CHTTP({
        method = 'POST',
        url = webhook .. '?wait=true',
        body = tabtoJSON(params),
        headers = postheader,
        type = "application/json; charset=utf-8"
    })
end
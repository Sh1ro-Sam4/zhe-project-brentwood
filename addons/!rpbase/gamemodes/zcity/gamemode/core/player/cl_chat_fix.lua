local notifycol = CFG.theme.accent
local notify_types = {
	[0] = notifycol,
	[1] = notifycol,
}

net.Receive('ba.NotifyString', function(len)
	if (not IsValid(LocalPlayer())) then return end
	-- chat.AddText(notify_types[net.ReadBit()], '★ ', unpack(ba.ReadMsg()))
	chat.AddText(notify_types[net.ReadBit()], '» ', unpack(ba.ReadMsg()))
end)

net.Receive('ba.NotifyTerm', function(len)
	if (not IsValid(LocalPlayer())) then return end
	-- chat.AddText(notify_types[net.ReadBit()], '★ ', unpack(ba.ReadTerm()))
	chat.AddText(notify_types[net.ReadBit()], '» ', unpack(ba.ReadTerm()))
end)
local PLAYER = FindMetaTable("Player")
util.AddNetworkString 'ba.NotifyString'
util.AddNetworkString 'ba.NotifyTerm'

function ba.notify(recipients, msg, ...)
	if isstring(msg) then
		net.Start('ba.NotifyString')
			net.WriteBit(0)
			ba.WriteMsg(msg, ...)
		net.Send(recipients)
	else
		net.Start('ba.NotifyTerm')
			net.WriteBit(0)
			net.WriteTerm(msg, ...)
		net.Send(recipients)
	end
end


function PLAYER:ChatPrint(...)
	ba.notify(self, ...)
end
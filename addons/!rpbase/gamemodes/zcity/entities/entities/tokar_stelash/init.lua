AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString("Tokar_OpenMenu")
util.AddNetworkString("Tokar_PutItem")
util.AddNetworkString("Tokar_TakeItem")
util.AddNetworkString("Tokar_ChangePrice")
util.AddNetworkString("Tokar_BuyItem")

function ENT:SpawnFunction(ply, tr, ClassName)
	if not tr.Hit then return end
	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * 16)
	ent:Spawn()
	ent:Activate()
	
	if ent.CPPISetOwner then
		ent:CPPISetOwner(ply)
	end
	
	return ent
end

function ENT:Initialize()
	self:SetModel("models/props_phx/construct/metal_plate2x4.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then 
		phys:Wake()
		phys:SetMass(150)
	end

	self.Container = itemstore.Container(4, 2, 1)
	self.Container:SetOwner(self)
	self:SetContainerID(self.Container:GetID())

	self.Container:SetDefaultPermissions(true, false)
end

function ENT:Use(ply)
	if not IsValid(ply) then return end
	
	self.Container:Sync(ply)

	local isOwner = (self:CPPIGetOwner() == ply)

	net.Start("Tokar_OpenMenu")
		net.WriteEntity(self)
		net.WriteBool(isOwner)
	net.Send(ply)
end

net.Receive("Tokar_PutItem", function(len, ply)
	local rack = net.ReadEntity()
	local rack_slot = net.ReadUInt(8)
	local inv_slot = net.ReadUInt(16)
	local price = net.ReadUInt(32)

	if not IsValid(rack) or rack:GetClass() ~= "tokar_stelash" then return end
	if rack:CPPIGetOwner() ~= ply then return end
	if price < 0 then return end

	local con = rack.Container
	if not con then return end
	if con:GetItem(rack_slot) ~= nil then return end

	local item = ply.Inventory:GetItem(inv_slot)
	if not item then return end

	con:SetItem(rack_slot, item)
	item:SetData("ShopPrice", price)

	ply.Inventory:SetItem(inv_slot, nil)

	ply:ChatPrint("Вы выставили предмет в слот #" .. rack_slot .. " за $" .. string.Comma(price))
	con:Sync()

	net.Start("Tokar_OpenMenu")
		net.WriteEntity(rack)
		net.WriteBool(true)
	net.Send(ply)
end)

net.Receive("Tokar_TakeItem", function(len, ply)
	local rack = net.ReadEntity()
	local rack_slot = net.ReadUInt(8)

	if not IsValid(rack) or rack:CPPIGetOwner() ~= ply then return end

	local con = rack.Container
	if not con then return end

	local item = con:GetItem(rack_slot)
	if not item then return end

	if ply.Inventory:CanFit(item) then
		ply.Inventory:AddItem(item)
		con:SetItem(rack_slot, nil)
		
		ply:ChatPrint("Вы сняли предмет со стеллажа.")
		con:Sync()

		net.Start("Tokar_OpenMenu")
			net.WriteEntity(rack)
			net.WriteBool(true)
		net.Send(ply)
	else
		ply:ChatPrint("У вас нет места в инвентаре!")
	end
end)

net.Receive("Tokar_ChangePrice", function(len, ply)
	local rack = net.ReadEntity()
	local rack_slot = net.ReadUInt(8)
	local new_price = net.ReadUInt(32)

	if not IsValid(rack) or rack:CPPIGetOwner() ~= ply then return end
	if new_price < 0 then return end

	local con = rack.Container
	if not con then return end

	local item = con:GetItem(rack_slot)
	if not item then return end

	item:SetData("ShopPrice", new_price)
	ply:ChatPrint("Вы изменили цену товара на $" .. string.Comma(new_price))
	con:Sync()

	net.Start("Tokar_OpenMenu")
		net.WriteEntity(rack)
		net.WriteBool(true)
	net.Send(ply)
end)

net.Receive("Tokar_BuyItem", function(len, ply)
	local rack = net.ReadEntity()
	local rack_slot = net.ReadUInt(8)

	if not IsValid(rack) then return end
	local con = rack.Container
	if not con then return end

	local item = con:GetItem(rack_slot)
	if not item then return end

	local owner = rack:CPPIGetOwner()
	local price = item:GetData("ShopPrice") or 0

	if ply == owner then ply:ChatPrint("Вы не можете купить свой собственный предмет.") return end

	if itemstore.gamemodes.GetMoney(ply) < price then
		ply:ChatPrint("У вас недостаточно денег!")
		return
	end

	if not ply.Inventory:CanFit(item) then
		ply:ChatPrint("У вас нет свободного места в инвентаре!")
		return
	end

	itemstore.gamemodes.SetMoney(ply, itemstore.gamemodes.GetMoney(ply) - price)
	ply.Inventory:AddItem(item)
	con:SetItem(rack_slot, nil)

	if IsValid(owner) then
		itemstore.gamemodes.GiveMoney(owner, price)
		owner:ChatPrint("Игрок " .. ply:Name() .. " приобрел ваш товар за $" .. string.Comma(price))
	end

	ply:ChatPrint("Вы успешно совершили покупку!")
	con:Sync()

	net.Start("Tokar_OpenMenu")
		net.WriteEntity(rack)
		net.WriteBool(false)
	net.Send(ply)
end)

function ENT:OnRemove()
	if self.Container then
		self.Container:Remove()
	end
end
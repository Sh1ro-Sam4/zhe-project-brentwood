shizlib.ammo = shizlib.ammo or {}
shizlib.ammo.CFG = {
    ['pulse'] = {
        name = 'Патроны для автоматов',
        type = 'ar2',
        amount = 30,
        model = 'models/Items/BoxMRounds.mdl',
    },
    ['pistol'] = {
        name = 'Патроны для пистолетов',
        type = 'pistol',
        amount = 30,
        model = 'models/Items/BoxSRounds.mdl',
    },
    ['smg1'] = {
        name = 'Патроны для пистолетов-пулеметов',
        type = 'smg1',
        amount = 30,
        model = 'models/Items/BoxMRounds.mdl',
    },
    ['buckshot'] = {
        name = 'Патроны для дробовиков',
        type = 'buckshot',
        amount = 14,
        model = 'models/Items/BoxBuckshot.mdl',
    },
}

function shizlib.ammo.LoadEntities()
    for k, v in pairs(shizlib.ammo.CFG) do
        local ENT = {}
        ENT.Type = "anim"
        ENT.Base = "base_ammo"

        ENT.PrintName = v.name
        ENT.Category		= "SHZ | Ammo"
        ENT.Author			= "kas"

        ENT.Spawnable = true
        ENT.AdminSpawnable = true

        ENT.AmmoType = k

        function ENT:Use(activator, caller)
            if not self.cd or self.cd < CurTime() then
                self.cd = CurTime() + 1
                if self:GetPos():Distance(activator:GetPos()) >= CFG.useDist then return end

                caller:GiveAmmo(v.amount, v.type)
                self:Remove()
            end
        end

        scripted_ents.Register( ENT, 'shizlib_ammo_' .. string.Replace( string.lower( k ), " ", "" ) )
    end
end

shizlib.ammo.LoadEntities()
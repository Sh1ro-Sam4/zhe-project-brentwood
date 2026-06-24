AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "imper_food_base"
ENT.PrintName = "Вода"
ENT.Category = "IMPERATOR | Food 1 tier"
ENT.Spawnable = true

ENT.FoodModel = "models/props_everything/waterbottle.mdl"
ENT.HAmount = 5
ENT.ConsumeSound = "snd_jack_hmcd_drink1.wav"
local phrases_water = {
    "Я не могу этим наестся но еще чуть чуть я протяну",
    "Мне кажется это не очень питательно",
    "Хм вода на вкус... Хотя ладно"
}
--owner:Notify(str, 1, "phrase", 1, nil, Color(255, clr_val, clr_val, 255))

if SERVER then
    function ENT:OnConsumed(ply)
        if ply:GetHunger() > 30 then
            ply:SetHunger(ply:GetHunger() - 5)
        end
        ply:Notify(table.Random(phrases_water), 1, "phrase", 1, nil, Color(255, 255, 255, 255))
    end
end
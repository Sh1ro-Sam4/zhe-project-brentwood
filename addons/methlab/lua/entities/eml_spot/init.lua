AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/metalPot001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end

    self:SetPos(self:GetPos() + Vector(0, 0, 8))

    self.Ingredients = {} 
    self:SetNWString("IngData", "[]") 
    
    self:SetNWInt("status", 0)
    self:SetNWInt("time", 0)
    self:SetNWInt("maxTime", 1)
    self:SetNWString("currentRecipe", "")
end

function ENT:OnTakeDamage(dmginfo)
    self:VisualEffect()
    self:Remove()
end

function ENT:UpdateNetworkData()
    self.Ingredients = self.Ingredients or {}
    self:SetNWString("IngData", util.TableToJSON(self.Ingredients) or "[]")
end

function ENT:CheckRecipes()
    self.Ingredients = self.Ingredients or {}
    for recipeID, data in pairs(POT_RECIPES) do
        local hasAll = true
        for reqClass, reqData in pairs(data.ingri) do
            local currentAmount = self.Ingredients[reqClass] or 0
            if currentAmount < reqData.amount then
                hasAll = false
                break
            end
        end

        if hasAll then
            self:SetNWInt("status", 1) 
            self:SetNWInt("time", data.time)
            self:SetNWInt("maxTime", data.time)
            self:SetNWString("currentRecipe", recipeID)
            
            for reqClass, reqData in pairs(data.ingri) do
                self.Ingredients[reqClass] = self.Ingredients[reqClass] - reqData.amount
                if self.Ingredients[reqClass] <= 0 then self.Ingredients[reqClass] = nil end
            end
            
            self:UpdateNetworkData()
            self:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav")
            return
        end
    end
end

function ENT:PhysicsCollide(data, phys)
    if data.DeltaTime <= 0 then return end 
    if self:GetNWInt("status") ~= 0 then return end 
    
    local hitEnt = data.HitEntity
    if not IsValid(hitEnt) then return end
    
    self.Ingredients = self.Ingredients or {}
    local hitClass = hitEnt:GetClass()

    local isIngredient = false
    for _, recipe in pairs(POT_RECIPES) do
        if recipe.ingri[hitClass] then isIngredient = true break end
    end

    if isIngredient then
        local entAmount = hitEnt:GetNWInt("amount", 0)
        
        if entAmount > 0 then
            hitEnt:SetNWInt("amount", entAmount - 1)
            if hitEnt:GetNWInt("amount") <= 0 then
                if hitEnt.VisualEffect then hitEnt:VisualEffect() end
                SafeRemoveEntity(hitEnt) 
            end
        else
            SafeRemoveEntity(hitEnt)
        end

        self.Ingredients[hitClass] = (self.Ingredients[hitClass] or 0) + 1
        self:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav")
        self:VisualEffect()
        
        self:UpdateNetworkData()
        self:CheckRecipes()
    end
end

function ENT:Use(activator, caller)
    local curTime = CurTime()
    if not self.nextUse or curTime >= self.nextUse then
        
        if self:GetNWInt("status") == 2 then
            local recipeID = self:GetNWString("currentRecipe")
            local recipeData = POT_RECIPES[recipeID]
            
            if recipeData then
                local resultEnt = ents.Create(recipeData.result)
                
                if IsValid(resultEnt) then
                    resultEnt:SetPos(self:GetPos() + self:GetUp() * 12)
                    resultEnt:SetAngles(self:GetAngles())
                    resultEnt:Spawn()
                    
                    local rphys = resultEnt:GetPhysicsObject()
                    if IsValid(rphys) then
                        rphys:SetVelocity(self:GetUp() * 2)
                    end
                    
                    if recipeData.result == "eml_meth" then
                        resultEnt:SetNWInt("amount", 6)
                        resultEnt:SetNWInt("maxAmount", 6)
                        resultEnt:SetNWInt("value", 6)
                    end
                else
                    print("[Котелок] ОШИБКА: Попытка заспавнить неизвестную энтити: " .. recipeData.result)
                end
            end
            
            self:SetNWInt("status", 0)
            self:SetNWString("currentRecipe", "")
            self:CheckRecipes() 
        end
        
        self.nextUse = curTime + 0.5
    end
end

function ENT:VisualEffect()
    local effectData = EffectData()    
    effectData:SetStart(self:GetPos())
    effectData:SetOrigin(self:GetPos())
    effectData:SetScale(8)    
    util.Effect("GlassImpact", effectData, true, true)
end
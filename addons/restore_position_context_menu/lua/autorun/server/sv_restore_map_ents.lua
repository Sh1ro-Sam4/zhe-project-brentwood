-- sv_restore_map_ents.lua

util.AddNetworkString("RestoreSingleMapEntity")

-- Table to store original positions and angles
local OriginalTransforms = {}

-- ----------------------------------------------------------------------------
-- FUNCTION: Store all valid entities' original transforms.
-- We can call this function whenever we need to re-store references, such as
-- after the map finishes loading or after a cleanup event.
-- ----------------------------------------------------------------------------
local function StoreAllMapEntities()
    OriginalTransforms = {}  -- Reset the table

    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and not ent:IsPlayer() then
            -- You can refine which entities you track by checking ent:GetClass()
            -- For simplicity, we'll store everything except players.
            OriginalTransforms[ent] = {
                pos = ent:GetPos(),
                ang = ent:GetAngles()
            }
        end
    end

    print("[RestoreSingleMapEntity] Stored original transforms for " .. table.Count(OriginalTransforms) .. " entities.")
end

-- ----------------------------------------------------------------------------
-- HOOK: InitPostEntity
-- This fires once, right after the map (and its default entities) has loaded.
-- ----------------------------------------------------------------------------
hook.Add("InitPostEntity", "StoreOriginalMapEntitiesSingle", function()
    StoreAllMapEntities()
end)

-- ----------------------------------------------------------------------------
-- HOOK: PostCleanupMap
-- This fires after something calls game.CleanUpMap() or an equivalent function.
-- Since cleanup removes and respawns map entities, we need to re-store them.
-- ----------------------------------------------------------------------------
hook.Add("PostCleanupMap", "StoreMapEntitiesAfterCleanup", function()
    StoreAllMapEntities()
end)

-- ----------------------------------------------------------------------------
-- NET MESSAGE: RestoreSingleMapEntity
-- Triggered by the client side "Restore Position" action in the Properties menu.
-- ----------------------------------------------------------------------------
net.Receive("RestoreSingleMapEntity", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local entIndex = net.ReadInt(32)
    local ent = Entity(entIndex)
    if not IsValid(ent) then return end

    -- Look up the original transform in our table
    local transform = OriginalTransforms[ent]
    if transform then
        -- Restore position and angles
        ent:SetPos(transform.pos)
        ent:SetAngles(transform.ang)

        -- Reset physics velocity if it has a physics object
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(Vector(0, 0, 0))

            if phys.AddAngleVelocity then
                local angVel = phys:GetAngleVelocity()
                phys:AddAngleVelocity(-angVel) -- zero out angular velocity
            end

            phys:Wake()
        end

        ply:ChatPrint("Restored " .. tostring(ent) .. " to its original position.")
    else
        ply:ChatPrint("No original transform found for this entity.")
    end
end)
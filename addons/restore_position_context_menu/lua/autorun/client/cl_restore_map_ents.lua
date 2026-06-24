-- cl_restore_map_ents.lua

-- We create a context menu entry under the "Properties" system.
-- This will appear when you hold C, right-click on an entity, and open the context menu.

local function CanRestoreEntity(ent)
    -- You can refine this check to show the option only for certain entity classes, etc.
    if not IsValid(ent) then return false end
    if ent:IsPlayer() then return false end

    -- We'll allow it for all valid, non-player entities by default.
    return true
end

properties.Add("restore_single_map_ent", {
    MenuLabel = "Restore Position",
    Order = 999, -- The order the option appears in the menu
    MenuIcon = "icon16/arrow_undo.png",

    -- Determines if the option should appear in the right-click menu:
    Filter = function(self, ent, ply)
        if not ply:IsAdmin() then return false end  -- Admin-only usage
        return CanRestoreEntity(ent)
    end,

    -- What happens when we click the option:
    Action = function(self, ent)
        if not IsValid(ent) then return end

        -- Send the entity we want to restore to the server
        net.Start("RestoreSingleMapEntity")
            net.WriteInt(ent:EntIndex(), 32)
        net.SendToServer()
    end
})
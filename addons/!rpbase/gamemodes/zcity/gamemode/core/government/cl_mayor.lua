local function OpenLawsMenu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 700)
    frame:Center()
    frame:SetTitle("Законы")
    frame:SetVisible(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()

    local notebook = vgui.Create("DPropertySheet", frame)
    notebook:Dock(FILL)
    notebook:DockMargin(2,2,2,2)

    for category, codes in pairs(cfg.laws) do
        local panel = vgui.Create("DPanel")
        panel:Dock(FILL)
        panel.Paint = function(self, w, h) end

        local scroll = vgui.Create("DScrollPanel", panel)
        scroll:Dock(FILL)

        local layout = vgui.Create("DListLayout", scroll)
        layout:Dock(FILL)

        for _, codeData in pairs(codes) do
            local code, desc = codeData[1], codeData[2]
            local lbl = vgui.Create("DLabel", layout)
            lbl:SetText(code .. " - " .. desc)
            lbl:SetAutoStretchVertical(true)
            lbl:SetWrap(true)
            lbl:SetContentAlignment(5)
        end

        notebook:AddSheet(category, panel, "icon16/book.png")
    end
end

concommand.Add("lawsmenu", OpenLawsMenu)
local AceGUI = LibStub("AceGUI-3.0")
-- for k, v in pairs(actualBarData) do print("key:", k, "value:", v) end


G_gridVisible = false
G_defaultDataReset = false
local selectedTreePanel = "p1"

local treeData = {
    {
        value = "p1",
        text = "General"
    },
    {
        value = "p2",
        text = "Enabled Frames"
    },
    {
        value = "p3",
        text = "Frames",
        children = {
            { value = "p3_1", text = "Player Frame"},
            { value = "p3_2", text = "Pet"},
            { value = "p3_3", text = "Target"},
            { value = "p3_4", text = "Target of Target"},
            { value = "p3_5", text = "Focus"},
            { value = "p3_6", text = "Focus Target"},
            { value = "p3_7", text = "Party"},
            { value = "p3_8", text = "Raid"},
            { value = "p3_9", text = "Boss"},
            -- { value = "p3_10", text = "Arena" },
        }
    },
    {
        value = "p4",
        text = "Disable Blizzard Frames"
    }
}

local anchorPointData = {
    ["TOPLEFT"] = "TOPLEFT",
    ["TOP"]  = "TOP",
    ["TOPRIGHT"] = "TOPRIGHT",
    ["LEFT"]  = "LEFT",
    ["CENTER"]  = "CENTER",
    ["RIGHT"]  = "RIGHT",
    ["BOTTOMLEFT"] = "BOTTOMLEFT",
    ["BOTTOM"]  = "BOTTOM",
    ["BOTTOMRIGHT"] = "BOTTOMRIGHT"
}

local barPresentData = {
    ["1"] = "1",
    ["2"] = "2",
    ["3"] = "3",
    ["4"] = "4",
    ["5"] = "5",
}

local barTypeData = {
    ["HB"] = "Health Bar",
    ["PB"] = "Power Bar",
    ["EB"] = "Empty Bar",
    ["CB"] = "Cast Bar",
    --["HP"] = "Health Bar",
}

local anchorFrameData = {
    ["SCREEN"] = "Screen",
    ["PLAYER"] = "Player Frame",
    ["TARGET"] = "Target Frame",
    ["PET"] = "Pet Frame",
    ["TARGETOFTARGET"] = "Target of Target Frame",
    ["FOCUS"] = "Focus Frame",
}

-- Show or hide grid on screen
local function toggleGrid(widget, event, value)
    if value then
        G_MyAddon.SavedVars.General.ShowGrid = true
            ChangeGridVisibility(true)
    else
        G_MyAddon.SavedVars.General.ShowGrid = false
            ChangeGridVisibility(false)
    end
end

local function generateScrollFrame(parent, barCount, unitTypeID)
    -- Release all children and stops redrawing the scrollFrame
    parent:ReleaseChildren()
    parent:PauseLayout()

    local actualData = G_MyAddon.Frames[unitTypeID .. "Frame"].mainFrame

    -- Draw as many option as there is bars
    for i = 1, tonumber(barCount) do
        local actualBarData = actualData.BarArr[i]


        -- Bar Setting Heading
        local h = AceGUI:Create("Heading")
        h:SetText("Bar " .. i .. " Setting")
        h:SetFullWidth(true)
        parent:AddChild(h)

        -- 1. Row, Height slider and Dropdown
        local rowA = AceGUI:Create("SimpleGroup")
        rowA:SetFullWidth(true)
        rowA:SetLayout("Flow")
        parent:AddChild(rowA)

        local sl = AceGUI:Create("Slider")
        sl:SetLabel("Height")
        -- ~ 50% of width
        sl:SetRelativeWidth(0.5)
        sl:SetValue(actualBarData.Height)
        sl:SetSliderValues(1, 50, 1)

        rowA:AddChild(sl)

        -- local dr = AceGUI:Create("Dropdown")
        -- dr:SetLabel("Bar Type")
        -- dr:SetList(barTypeData)
        -- dr:SetValue(actualBarData.BarType)
        -- dr:SetRelativeWidth(0.5)
        -- rowA:AddChild(dr)

        -- 2. Row, Editboxes for left and right text of the bar
        local rowB = AceGUI:Create("SimpleGroup")
        rowB:SetFullWidth(true)
        rowB:SetLayout("Flow")
        parent:AddChild(rowB)

        local ebLeft = AceGUI:Create("EditBox")
        ebLeft:SetLabel("Text Left")
        ebLeft:SetText(actualBarData.LeftText)
        ebLeft:SetRelativeWidth(0.5)
        rowB:AddChild(ebLeft)

        local ebRight = AceGUI:Create("EditBox")
        ebRight:SetLabel("Text Right")
        ebRight:SetText(actualBarData.RightText)
        ebRight:SetRelativeWidth(0.5)
        rowB:AddChild(ebRight)

         -- callbacks for each widget, calls update function of the corresponding bar
        sl:SetCallback("OnValueChanged", function (widget, event, value)
            actualBarData.Height = value
            actualData:ApplySettings()
        end)

        -- dr:SetCallback("OnValueChanged", function (widget, event, value)
        --     actualBarData.BarType = value
        --     actualData:ApplySettings()
        -- end)

        ebLeft:SetCallback("OnEnterPressed", function (widget, event, value)
            actualBarData.LeftText = value
            actualData:ApplySettings()
        end)

        ebRight:SetCallback("OnEnterPressed", function (widget, event, value)
            actualBarData.RightText = value
            actualData:ApplySettings()
        end)

    end

     -- resume drawing of the scrollFrame
    parent:ResumeLayout()
    parent:DoLayout()
end

local function drawFramesPanel(widget, unitTypeID)
    local actualData = G_MyAddon.Frames[unitTypeID .. "Frame"].mainFrame

    -- Main container for frame settings
    local mainRight = AceGUI:Create("SimpleGroup")
    mainRight:SetLayout("Flow")
    mainRight:SetFullWidth(true)
    mainRight:SetFullHeight(true)
    widget:AddChild(mainRight)

    -- --- Upper Part of panel ---
    local topFrame = AceGUI:Create("InlineGroup")
    topFrame:SetTitle("Frame Configuration")
    topFrame:SetFullWidth(true)
    topFrame:SetHeight(210)
    topFrame:SetLayout("Flow")
    mainRight:AddChild(topFrame)

    -- Temp function for rows
    local function AddRow(parent)
        local row = AceGUI:Create("SimpleGroup")
        row:SetFullWidth(true)
        row:SetLayout("Flow")
        parent:AddChild(row)
        return row
    end

    -- 1. Line: 2x Dropdown
    local r1 = AddRow(topFrame)

    local d1 = AceGUI:Create("Dropdown")
    d1:SetLabel("Anchor To Frame")
    d1:SetList(anchorFrameData)
    d1:SetValue(actualData.AnchorToFrame)
    d1:SetRelativeWidth(0.5)
    r1:AddChild(d1)

    local d2 = AceGUI:Create("Dropdown")
    d2:SetLabel("Anchor To Point")
    d2:SetList(anchorPointData)
    d2:SetValue(actualData.AnchorToPoint)
    d2:SetRelativeWidth(0.5)
    r1:AddChild(d2)

    -- 2. Line: 2x Dropdown
    local r2 = AddRow(topFrame)
    
    local d3 = AceGUI:Create("Dropdown")
    d3:SetLabel("Anchor By Point")
    d3:SetList(anchorPointData)
    d3:SetValue(actualData.AnchorByPoint)
    d3:SetRelativeWidth(0.5)
    r2:AddChild(d3)


    -- local d4 = AceGUI:Create("Dropdown")
    -- d4:SetLabel("Bars in Frame")
    -- d4:SetList(barPresentData)
    -- d4:SetValue(tostring(actualData.BarsPerFrame))
    -- d4:SetRelativeWidth(0.5)
    -- r2:AddChild(d4)

    -- 3. Line: Slider
    local r3 = AddRow(topFrame)
    local s1 = AceGUI:Create("Label");
    s1:SetWidth(100);
    r3:AddChild(s1)
    
    local sc = AceGUI:Create("Slider")
    sc:SetLabel("Width")
    sc:SetSliderValues(1, 300, 1)
    sc:SetValue(actualData.Width)
    sc:SetRelativeWidth(1)
    r3:AddChild(sc)

    -- 4. Line: 2x Slider
    local r4 = AddRow(topFrame)
    
    local eb1 = AceGUI:Create("EditBox")
    eb1:SetLabel("X Offset")
    eb1:SetRelativeWidth(0.5)
    eb1:SetText(tostring(actualData.X))
    r4:AddChild(eb1)

    local eb2 = AceGUI:Create("EditBox")
    eb2:SetLabel("Y Offset")
    eb2:SetRelativeWidth(0.5)
    eb2:SetText(tostring(actualData.Y))
    r4:AddChild(eb2)

    -- --- 2. Lower part of panel  ---

    local bottomFrame = AceGUI:Create("InlineGroup")
    bottomFrame:SetTitle("Bar Configuration: ")
    bottomFrame:SetFullWidth(true)
    bottomFrame:SetHeight(240)
    bottomFrame:SetLayout("Fill")
    mainRight:AddChild(bottomFrame)

        -- ScrollFrame inside panel
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    bottomFrame:AddChild(scroll)


    generateScrollFrame(scroll, actualData.BarsPerFrame, unitTypeID)

    
    d1:SetCallback("OnValueChanged", function (widget, event, value)
        actualData.AnchorToFrame = value
        actualData:ApplySettings()
    end)

    d2:SetCallback("OnValueChanged", function (widget, event, value)
        actualData.AnchorToPoint = value
        actualData:ApplySettings()
    end)

    d3:SetCallback("OnValueChanged", function (widget, event, value)
        actualData.AnchorByPoint = value
        actualData:ApplySettings()
    end)

    -- d4:SetCallback("OnValueChanged", function (widget, event, value)
    --     actualData.BarsPerFrame = tonumber(value)
    --     generateScrollFrame(scroll, value, unitTypeID)
    --     actualData:ApplySettings()
    -- end)

    sc:SetCallback("OnValueChanged", function (widget, event, value)
        actualData.Width = value
        actualData:ApplySettings()
    end)

    eb1:SetCallback("OnEnterPressed", function (widget, event, value)
        actualData.X = tonumber(value)
        actualData:ApplySettings()
    end)

    eb2:SetCallback("OnEnterPressed", function (widget, event, value)
        actualData.Y = tonumber(value)
        actualData:ApplySettings()
    end)

end

local function drawGeneralSetting(widget)
    
    -- Setup of automatic widget placing
    widget:SetLayout("Flow")

    -- --- 1. Line: 2x Checkbox ---
    local cb1 = AceGUI:Create("CheckBox")
    cb1:SetLabel("Lock Frames")
    cb1:SetRelativeWidth(0.45)
    widget:AddChild(cb1)

    local cb2 = AceGUI:Create("CheckBox")
    cb2:SetLabel("Show Grid")
    cb2:SetRelativeWidth(0.45)
    cb2:SetValue(G_MyAddon.SavedVars.General.ShowGrid)
    widget:AddChild(cb2)

    -- Callback for drawing the grid
    cb2:SetCallback("OnValueChanged", toggleGrid)

    -- --- 2. Line: Dropdown + Slider ---
    local drop1 = AceGUI:Create("Dropdown")
    drop1:SetLabel("Select Texture")
    drop1:SetList({["1"] = "Texture 1", ["2"] = "Texture 2"})
    drop1:SetRelativeWidth(0.45)
    widget:AddChild(drop1)


    local drop2 = AceGUI:Create("Dropdown")
    drop2:SetLabel("Font")
    drop2:SetList({["1"] = "Font 1", ["2"] = "Font 2"})
    drop2:SetRelativeWidth(0.45)
    widget:AddChild(drop2)

    -- --- 3. Line: Dropbox + Slider ---

    local slider1 = AceGUI:Create("Slider")
    slider1:SetLabel("Alpha Outside Combat")
    slider1:SetSliderValues(0, 100, 5)
    slider1:SetRelativeWidth(0.45)
    widget:AddChild(slider1)

    local slider2 = AceGUI:Create("Slider")
    slider2:SetLabel("Font Size")
    slider2:SetRelativeWidth(0.45)
    slider2:SetSliderValues(0, 100, 5)
    widget:AddChild(slider2)

    -- Force Layout redrawing
    widget:DoLayout()
end

local function drawEnableFrames(widget)
    widget:SetLayout("Flow")

    local checkBoxText =
    {
        "PlayerFrame",
        "Pet",
        "Target",
        "Target of Target",
        "Focus",
        "Focus Target",
        "Party",
        "Raid",
        "Boss",
        "Arena",
    }

    for i = 1, 10, 1 do
        local cb1 = AceGUI:Create("CheckBox")
        cb1:SetLabel(checkBoxText[i])
        cb1:SetRelativeWidth(0.32)
        widget:AddChild(cb1)
    end
end

local function drawPlayerSetting(widget)
    drawFramesPanel(widget, "Player")
end

local function drawPetSetting(widget)
    drawFramesPanel(widget, "Pet")
end

local function drawTargetSetting(widget)
    drawFramesPanel(widget, "Target")
end

local function drawToTSetting(widget)
    drawFramesPanel(widget, "TargetOfTarget")
end

local function drawFocusSetting(widget)
    drawFramesPanel(widget, "Focus")
end

local function drawFocusTargetSetting(widget)
    print("UnderConstruction")
end

local function drawPartySetting(widget)
    print("UnderConstruction")
end

local function drawRaidSetting(widget)
    print("UnderConstruction")
end

local function drawBossSetting(widget)
    print("UnderConstruction")
end

local function drawArenaSetting(widget)
    print("UnderConstruction")
end

local function drawDisableBlizzSetting(widget)
    print("UnderConstruction")
end


-- Addon commands registration
SLASH_MYADDON1 = "/myaddon"
SLASH_MYADDON2 = "/x"

SlashCmdList["MYADDON"] = function(msg)
    -- make the text lowercase
    msg = msg:lower():trim()

    if msg == "reset" then
        G_defaultDataReset = true

        savedVar = {}
        InitializeDefaults(savedVar, nil)

        print("|cff00ff00TestAddon:|r The settings have been reset to default.")

        -- reload UI to see the changes
        ReloadUI()
    elseif msg == "d" then
        -- debug print
         for k, v in pairs(G_MyAddon.Frames.TargetOfTargetFrame.mainFrame) do print("key:", k, "value:", v) end

    else
        if G_MyAddon.Options.mainFrame:IsShown() then
            G_MyAddon.Options.mainFrame:Hide()
        else
            if(PlayerIsInCombat() == false) then
                G_MyAddon.Options.mainFrame:Show()
                if(G_MyAddon.SavedVars.General.ShowGrid == true) then
                    -- if the Show Grid option is true, show grid on Option Window open
                    ChangeGridVisibility(true)
                end
            end
        end
    end
end


-------------------------------------------------------------------------------------------

local function initOptionWindow ()

    -- Main Option Window
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Addon Name") -- TODO think about better name of addon
    frame:SetLayout("Fill")
    frame:SetWidth(600)
    frame:SetHeight(600)

    -- Block all resizing scripts
    frame.sizer_se:SetScript("OnMouseDown",nil)
    frame.sizer_e:SetScript("OnMouseDown",nil)
    frame.sizer_s:SetScript("OnMouseDown",nil)

    -- TreeGroup (left side of options)
    local tree = AceGUI:Create("TreeGroup")
    tree:SetTree(treeData)
    tree:SetFullWidth(true)
    tree:SetFullHeight(true)

    frame:AddChild(tree)
    -- Default option selected for TreeGroup
    frame:DoLayout()
    C_Timer.After(0.05, function()
    tree:SelectByPath("p1")
    end)

    tree:SetCallback("OnGroupSelected", function(widget, event, groupPath)
        widget:ReleaseChildren()
        widget:SetLayout("Fill")

        if(groupPath == "p3")then
            widget:SelectByPath("p3", "p3_1")
            return
        end


        local drawPanelSwitch = {
            ["p1"]          = drawGeneralSetting,
            ["p2"]          = drawEnableFrames,
            ["p3\001p3_1"]  = drawPlayerSetting,
            ["p3\001p3_2"]  = drawPetSetting,
            ["p3\001p3_3"]  = drawTargetSetting,
            ["p3\001p3_4"]  = drawToTSetting,
            ["p3\001p3_5"]  = drawFocusSetting,
            ["p3\001p3_6"]  = drawFocusTargetSetting,
            ["p3\001p3_7"]  = drawPartySetting,
            ["p3\001p3_8"]  = drawRaidSetting,
            ["p3\001p3_9"]  = drawBossSetting,
            ["p3\001p3_10"] = drawArenaSetting,
            ["p4"]          = drawDisableBlizzSetting,
        }
    
        if drawPanelSwitch[groupPath] then
            widget:ReleaseChildren()
            drawPanelSwitch[groupPath](widget)
            widget:DoLayout()
        end

    end)
    
    frame:SetCallback("OnClose", function(widget)
        if(G_MyAddon.SavedVars.General.ShowGrid == true) then
            -- when closing the Option window, hide the grid
            ChangeGridVisibility(false)
        end
    end)

    -- Adding frame into special frame table to make it closeable by Escape button
    _G["OptionFrame"] = frame.frame
    tinsert(UISpecialFrames, "OptionFrame")

    G_MyAddon.Options.mainFrame = frame
end



G_MyAddon = {}
G_MyAddon.Frames = {}
G_MyAddon.Frames.PlayerFrame = {}

G_MyAddon.Frames.TargetFrame = {}
G_MyAddon.Frames.TargetOfTargetFrame = {}
G_MyAddon.Frames.FocusFrame = {}
G_MyAddon.Frames.PetFrame = {}

G_MyAddon.SavedVars = {}
G_MyAddon.Options = {}



local function initFunction(self, event, addonName)
    if(event == "ADDON_LOADED" and addonName == "MyAddon")then
        savedVar = savedVar or {}

        print("I got here because of " .. event .. " of " .. addonName)

        InitializeDefaults(savedVar, nil)
        initOptionWindow()
        G_MyAddon.SavedVars = savedVar
        G_MyAddon.Frames.PlayerFrame.mainFrame = Frame:New(savedVar.PlayerFrame, "player")
        G_MyAddon.Frames.TargetFrame.mainFrame = Frame:New(savedVar.TargetFrame, "target")
        G_MyAddon.Frames.TargetOfTargetFrame.mainFrame = Frame:New(savedVar.TargetOfTargetFrame, "targettarget")
        G_MyAddon.Frames.FocusFrame.mainFrame = Frame:New(savedVar.FocusFrame, "focus")
        G_MyAddon.Frames.PetFrame.mainFrame = Frame:New(savedVar.PetFrame, "pet")

    elseif(event == "PLAYER_LOGOUT") then
        print("I will never see this, but config has been saved succesfully")
        if(G_defaultDataReset == false) then
            -- local error = nil
            -- local qqq = error.test
            G_MyAddon.Frames.PlayerFrame.mainFrame:Save(savedVar.PlayerFrame)
            G_MyAddon.Frames.TargetFrame.mainFrame:Save(savedVar.TargetFrame)
            G_MyAddon.Frames.TargetOfTargetFrame.mainFrame:Save(savedVar.TargetOfTargetFrame)
            G_MyAddon.Frames.FocusFrame.mainFrame:Save(savedVar.FocusFrame)
            G_MyAddon.Frames.PetFrame.mainFrame:Save(savedVar.PetFrame)

        end

    elseif (event == "PLAYER_REGEN_DISABLED") then
        if G_MyAddon.Options.mainFrame:IsShown() then
            G_MyAddon.Options.mainFrame:Hide()
        end
    end

end



local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_LOGOUT")
initFrame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Added for combat protection
initFrame:SetScript("OnEvent", initFunction)



classColors = {
    ["HUNTER"] = {r = 0.67, g = 0.83, b = 0.45},
    ["WARLOCK"] = {r = 0.58, g = 0.51, b = 0.79},
    ["PRIEST"] = {r = 1.0, g = 1.0, b = 1.0},
    ["PALADIN"] = {r = 0.96, g = 0.55, b = 0.73},
    ["MAGE"] = {r = 0.41, g = 0.8, b = 0.94},
    ["ROGUE"] = {r = 1.0, g = 0.96, b = 0.41},
    ["DRUID"] = {r = 1.0, g = 0.49, b = 0.04},
    ["SHAMAN"] = {r = 0.14, g = 0.35, b = 1.0},
    ["WARRIOR"] = {r = 0.78, g = 0.61, b = 0.43},
    ["DEATHKNIGHT"] = {r = 0.77, g = 0.12 , b = 0.23},
    ["MONK"] = {r = 0.0, g = 1.00 , b = 0.59},
    ["DEMONHUNTER"] = {r = 0.64, g = 0.19, b = 0.79},
    ["EVOKER"] = {r = 0.20, g = 0.58, b = 0.50},
}

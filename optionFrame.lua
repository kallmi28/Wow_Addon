local AceGUI = LibStub("AceGUI-3.0")

OptionFrame = {}
OptionFrame.__index = OptionFrame

G_AddonNameColoredString = "|cff00ff00TestAddon:|r"

G_gridVisible = false
G_defaultDataReset = false
local selectedTreePanel = "p1"

local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()

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
    ["BB"] = "Buff Bar",
    ["DB"] = "Debuff Bar",
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
    widget:SetLayout("Flow")

    local checkBoxFrame =
    {
        PlayerFrame,
        TargetFrame,
        FocusFrame,

    }

    local checkBoxText =
    {
        "PlayerFrame",
        "Target",
        "Focus",
        "Target of Target",
        "Pet",
        "Focus Target",
        "Party",
        "Raid",
        "Boss",
        "Arena",
    }

    local blizzardFrameMapping = {
    {"Player Frame", { PlayerFrame }},
    {"Target", { TargetFrame }},
    {"Focus", { FocusFrame }},
    {"Target of Target", { TargetFrameToT }},
    {"Pet", { PetFrame }},
    {"Focus Target", { FocusFrameToT }},
    {"Party", { PartyFrame }},
    {"Raid", { CompactRaidFrameContainer }},
    {"Boss", { Boss1TargetFrame, Boss2TargetFrame, Boss3TargetFrame, Boss4TargetFrame, Boss5TargetFrame }},
    {"Arena", { ArenaEnemyMatchFrame1, ArenaEnemyMatchFrame2, ArenaEnemyMatchFrame3, ArenaEnemyMatchFrame4, ArenaEnemyMatchFrame5 }},
}
    for i = 1, 10, 1 do
        local cb = AceGUI:Create("CheckBox")
        cb:SetLabel(blizzardFrameMapping[i][1])
        cb:SetRelativeWidth(0.32)
        widget:AddChild(cb)

        cb:SetCallback("OnValueChanged", function (widget, event, value)
            -- print(PartyFrame)
            -- -- for k, v in pairs(PartyFrame.PartyMemberFramePool) do print("key:", k, "value:", v) end
			-- for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() 
            -- do for k, v in pairs(memberFrame) do print("key:", k, "value:", v) end print("-----------------")end

            if(value == true) then
                for index, value in ipairs(blizzardFrameMapping[i][2]) do
                    print(value)
                    UnregisterUnitWatch(value)
                    value:UnregisterAllEvents()
                    value:Hide()
                    
                    value:SetParent(hiddenFrame)
                end
            else
                print(G_AddonNameColoredString, "You need to reload the UI (/reload), before hidden frames reappear.")
            end
        end)

    end
end




function OptionFrame:New(savedData)

    local instance = setmetatable({}, OptionFrame)

    instance.savedData = savedData

    -- Main Option Window
    instance.frame = AceGUI:Create("Frame")
    instance.frame:SetTitle("Addon Name") -- TODO think about better name of addon
    instance.frame:SetLayout("Fill")
    instance.frame:SetWidth(600)
    instance.frame:SetHeight(600)

    -- Block all resizing scripts
    instance.frame.sizer_se:SetScript("OnMouseDown",nil)
    instance.frame.sizer_e:SetScript("OnMouseDown",nil)
    instance.frame.sizer_s:SetScript("OnMouseDown",nil)

    -- TreeGroup (left side of options)
    local tree = AceGUI:Create("TreeGroup")
    tree:SetTree(treeData)
    tree:SetFullWidth(true)
    tree:SetFullHeight(true)

    instance.frame:AddChild(tree)
    -- Default option selected for TreeGroup
    instance.frame:DoLayout()
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
    
    instance.frame:SetCallback("OnClose", function(widget)
        if(G_MyAddon.SavedVars.General.ShowGrid == true) then
            -- when closing the Option window, hide the grid
            ChangeGridVisibility(false)
        end
    end)

    -- Adding frame into special frame table to make it closeable by Escape button
    _G["OptionFrame"] = instance.frame
    tinsert(UISpecialFrames, "OptionFrame")

    return instance
end

function OptionFrame:Hide()
    self.frame:Hide()
end

function OptionFrame:Show()
    self.frame:Show()
end

function OptionFrame:IsShown()
    return self.frame:IsShown()
end

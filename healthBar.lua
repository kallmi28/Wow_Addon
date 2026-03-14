
HealthBar = {}

HealthBar.__index = HealthBar

-- Function to change health bar color according to class/reaction
local function changeHealthBarColor (frame, unit)
    local colorRow = {r = 0.5, g = 0.5, b = 0.5}
    if(unit == "focus") then 
        print("focus unit")
    end
    if(UnitExists(unit)) then
        -- if unit is player, use class colors
        if(UnitIsPlayer(unit)) then
            local _, cl = UnitClass(unit)
            colorRow = classColors[cl]
        -- otherwise, use "reaction" color
        else
            local reaction = UnitReaction("player", unit)
            if reaction then
                -- green for friendly
                if reaction >= 5 then
                    colorRow = {r = 0, g = 1, b = 0}
                -- yellow for neutral
                elseif reaction >= 3 then
                    colorRow = {r = 1, g = 1, b = 0}
                -- red for unfriendly/aggressive
                else
                    colorRow = {r = 1, g = 0, b = 0}
                end
            end
        end
    frame:SetStatusBarColor(colorRow.r, colorRow.g, colorRow.b, 1)
    end
end

-- update information on healthbar
local function updateHealthBar(frame, unit, bar)
    local currHP = UnitHealth(unit)
    local maxHP = UnitHealthMax(unit)
    frame:SetMinMaxValues(0, maxHP)
    frame:SetValue(currHP)

    frame.LeftText:UpdateText()
    frame.RightText:UpdateText()
end

-- Depending on Event, choose what needs to be update on HP bar
function HealthBar:UpdateHpBar(frame, event, unit, ...)
    -- if health of unit changes
    if (event == "UNIT_HEALTH") then
        updateHealthBar(frame, unit)
    -- if player logs into game, changes target or focus
    elseif(event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_FOCUS_CHANGED") then
        -- event PLAYER_TARGET_CHANGED doesn't tell which unit changed target 
        -- if player changed target
        if event == "PLAYER_TARGET_CHANGED" then
            -- and frame belongs to target of target
            if(self.unitType == "targettarget") then
                -- the unit needs to be changed to target of target
                unit = "targettarget"
            -- if frame belongs to focus
            elseif (self.unitType == "focus") then
                -- the unit needs to be changed to focus
                unit = "focus"
            -- otherwise unit needs to be changed to target
            else
                unit = "target"
            end
        -- other events needs unit set to itself
        else
            unit = self.unitType
        end
        -- check to be sure that Unit exists
        if(UnitExists(unit)) then
            -- change color and text on bar
            changeHealthBarColor (frame, unit)
            updateHealthBar(frame, unit)
        end
    -- if target of target polling event triggers
    elseif (event == "POLLING") then
        -- change color and text on bar
        changeHealthBarColor (frame, unit)
        updateHealthBar(frame, unit)
    end

    if (event == "UNIT_PET" or event == "PET_UI_UPDATE") then
        if(UnitExists("pet") == true) then
            unit = "pet"
            changeHealthBarColor (frame, unit)
            updateHealthBar(frame, unit)
        end
    end
end

local function createBar (parent, width, height)
    local bar = CreateFrame("StatusBar", "HealthBar", parent)
    bar:SetSize(width, height)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(0,0,0,0)

    return bar
end


function HealthBar:New (parent, unitTypeID, width, anchorTo, barInfo, isFirst)
    local instance = setmetatable({}, HealthBar)
    
    instance.unitType = unitTypeID
    instance.width = width
    instance.height = barInfo.Height
    instance.anchorTo = anchorTo

    -- Health Bar will be able to have 9 fontStrings
    -- not all will be used 
    instance:generateTemplateTextTable(barInfo)
    

    instance.barFrame = createBar(parent, instance.width, instance.height)

    instance:initializeBar(instance.barFrame, instance.unitType)
    instance:prepareBarFontStrings(instance.barFrame, barInfo) -- barInfo needs to be stored in instance
    -- add border

    -- anchor bar to anchorPoint given as parameter
    if(isFirst == true) then
        instance.barFrame:SetPoint("TOPLEFT", anchorTo, "TOPLEFT")
        instance.barFrame:SetPoint("TOPRIGHT", anchorTo, "TOPRIGHT")
    else
        instance.barFrame:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT")
        instance.barFrame:SetPoint("TOPRIGHT", anchorTo, "BOTTOMRIGHT")
    end

    return instance
end



function HealthBar:initializeBar (barFrame, unitType)
    -- unregisted all events and callbacks
    barFrame:UnregisterAllEvents()
    barFrame:SetScript("OnEvent", nil)
    barFrame:SetScript("OnUpdate", nil)


    -- target of target 
        if(unitType == "targettarget") then
        -- target of target change event
        barFrame:RegisterUnitEvent("UNIT_TARGET", "target")
        -- when player changes target, its target changes too
        barFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        barFrame:RegisterEvent("UNIT_TARGETABLE_CHANGED")

        -- target of target does not have events for resource change
        -- Polling has to be used
        local elapsed = 0
        barFrame:SetScript("OnUpdate", function(f, delta)
            elapsed = elapsed + delta
            -- 5 times per second
            if elapsed > 0.2 then 
                elapsed = 0
                -- redraw the HP bar
                self:UpdateHpBar(f, "POLLING", "targettarget", bar)
            end
        end)
    -- other units
    else
        -- player login
        barFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        -- unit change health
        barFrame:RegisterUnitEvent("UNIT_HEALTH", unitType)

        -- for target frame, change of player's target needs to be registered
        if (unitType == "target") then
            barFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        -- for focus, change of players focus needs to be registered
        elseif(unitType == "focus") then
            barFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        elseif(unitType == "pet") then
            barFrame:RegisterEvent("UNIT_PET")
            barFrame:RegisterEvent("PET_UI_UPDATE")
        end
    end
    --  setup callback for events
    barFrame:SetScript("OnEvent", function (f, event, unitToken, ...)
        local realUnit = (unitType == "targettarget") and "targettarget" or unitToken
        self:UpdateHpBar(f, event, realUnit, ...)
    end)
    -- change health bar color at bar creation
    changeHealthBarColor (barFrame, unitType)
end


function HealthBar:prepareBarFontStrings(bar, barInfo)
    bar.LeftText = CustomText:New(
        bar,
        G_MyAddon.SavedVars.Fonts,      -- fontPath
        G_MyAddon.SavedVars.FontSize,   -- fontSize
        "SLUG, OUTLINE",                      -- fontFlags
        {r = 1, g = 1, b = 1, a = 1},   -- fontColor
        barInfo.LeftText,               -- templateText
        "OVERLAY",                      -- layer
        self.unitType                   -- unit
        )

    bar.RightText = CustomText:New(
        bar,
        G_MyAddon.SavedVars.Fonts,      -- fontPath
        G_MyAddon.SavedVars.FontSize,  -- fontSize
        "SLUG, OUTLINE",                      -- fontFlags
        {r = 1, g = 1, b = 1, a = 1},   -- fontColor
        barInfo.RightText,               -- templateText
        "OVERLAY",                      -- layer
        self.unitType                   -- unit
        )


    bar.LeftText:SetPoint("LEFT",bar,"LEFT", 3,0)
    bar.RightText:SetPoint("RIGHT",bar,"RIGHT", -3,0)

    -- -- set max width, max height, turn off word wrap for text to not overflow the bar
    bar.LeftText:SetWordWrap(false) 
    bar.LeftText:SetJustifyH("LEFT")
    bar.LeftText:SetWidth(self.width/2)
    bar.LeftText:SetMaxLines(1)

    bar.RightText:SetWordWrap(false) 
    bar.RightText:SetJustifyH("RIGHT")
    bar.RightText:SetWidth(self.width/2)
    bar.RightText:SetMaxLines(1)

    bar.LeftText:UpdateText()
    bar.RightText:UpdateText()
end

function HealthBar:Hide()
    self.barFrame:Hide()
end

function HealthBar:GetFrame()
    return self.barFrame
end

function HealthBar:generateTemplateTextTable(barInfo)
    local stringPosition = 
    {
        "TopLeft",
        "Top",
        "TopRight",
        "Left",
        "Center",
        "Right",
        "BottomRight",
        "Bottom",
        "BottomLeft"
    }

    self.barTextStrings = {}

    for index, value in ipairs(stringPosition) do
        --print(value, barInfo[value .. "Text"])
        self.barTextStrings[value] = {}
        self.barTextStrings[value].text = ""
        self.barTextStrings[value].bar = 0
        if (barInfo[value .. "Text"] ~= nil ) then
            self.barTextStrings[value].text = barInfo[value .. "Text"]
        end
    end

    --print("------")
end
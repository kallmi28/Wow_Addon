
PowerBar = {}

PowerBar.__index = PowerBar

-- change color of power bar according to actual power of unit 
local function changePowerBarColor(frame, unit)
    
    local c, powerToken, r, g, b = UnitPowerType(unit)
    -- get color of normal power
    local barColor = GetPowerBarColor(powerToken)


    -- if GetPowerBarColor did not return color, unit power is special, use color components from UnitPowerType
    if barColor == nil then
        barColor = {}
        barColor.r, barColor.g, barColor.b = r,g,b
    end
    frame:SetStatusBarColor(barColor["r"], barColor["g"], barColor["b"] , 1)
end


local function updateSecondaryBar(frame, unit)
    local _, playerClass = UnitClass("player")

    local ClassPowerLogic = {
    ["DRUID"] = function()
        local curr = UnitPower("player", Enum.PowerType.ComboPoints)
        local max  = UnitPowerMax("player", Enum.PowerType.ComboPoints)
        local color = PowerBarColor["COMBO_POINTS"]
        color.a = 1
        return curr, max, color, color
    end,
    ["PALADIN"] = function()
        local curr = UnitPower("player", Enum.PowerType.HolyPower)
        local max  = UnitPowerMax("player", Enum.PowerType.HolyPower)
        local color = PowerBarColor["HOLY_POWER"]
        color.a = 1
        return curr, max, color, color
    end,
    ["ROGUE"] = function()
        local curr = UnitPower("player", Enum.PowerType.ComboPoints)
        local max  = UnitPowerMax("player", Enum.PowerType.ComboPoints)
        local color = PowerBarColor["COMBO_POINTS"]
        color.a = 1
        return curr, max, color, color
    end,
    ["EVOKER"] = function()
        -- Evoker's Essence color is not in power color table, gradient has been used
        local curr = UnitPower("player", Enum.PowerType.Essence)
        local max  = UnitPowerMax("player", Enum.PowerType.Essence)
        return curr, max, CreateColor(198/256, 100/256, 202/256,1), CreateColor(74/256, 189/256, 207/256,1)
    end,
    ["WARLOCK"] = function()
        local curr = UnitPower("player", Enum.PowerType.SoulShards)
        local max  = UnitPowerMax("player", Enum.PowerType.SoulShards)
        local color = PowerBarColor["SOUL_SHARDS"]
        color.a = 1
        return curr, max, color, color
    end,
    ["MONK"] = function()
        local curr = UnitPower("player", Enum.PowerType.Chi)
        local max  = UnitPowerMax("player", Enum.PowerType.Chi)
        local color = PowerBarColor["CHI"]
        color.a = 1
        return curr, max, color, color
    end,
    ["MAGE"] = function()
        local curr = UnitPower("player", Enum.PowerType.ArcaneCharges)
        local max  = UnitPowerMax("player", Enum.PowerType.ArcaneCharges)
        local color = PowerBarColor["ARCANE_CHARGES"]
        color.a = 1
        return curr, max, color, color
    end,
    ["DEATHKNIGHT"] = function()
       -- TODO finish implementation for DK
       -- RUNE_POWER_UPDATE event needs to be registered
        local ready = 0
        for i = 1, 6 do
            local _, _, runeReady = GetRuneCooldown(i)
            if runeReady then ready = ready + 1 end
        end
        return ready, 6,CreateColor(128/256, 128/256, 128/256,1), CreateColor(128/256, 128/256, 128/256,1)
    end,
    }

    local classPowerLogicHandler = ClassPowerLogic[playerClass]
    if classPowerLogicHandler == nil then return end

    local currResources, maxResources, colorMin, colorMax = classPowerLogicHandler()

    local barHeight = frame:GetHeight()
    if currResources > 0 then
        frame.barFramePrimary:SetHeight((2* barHeight) / 3)
        frame.barFrameSecondary:SetHeight(barHeight/3)
        frame.barFrameSecondary:SetMinMaxValues(0, maxResources)
        frame.barFrameSecondary:SetValue(currResources)

        local barTexture = frame.barFrameSecondary:GetStatusBarTexture()
        barTexture:SetGradient("HORIZONTAL", colorMin, colorMax)

        frame.barFrameSecondary.LeftText:SetTemplateText(string.format("%d/%d", currResources, maxResources))
        frame.barFrameSecondary.RightText:SetTemplateText("")
    else
        frame.barFramePrimary:SetHeight(barHeight)
        frame.barFrameSecondary:SetHeight(0)
        frame.barFrameSecondary:SetMinMaxValues(0, maxResources)
        frame.barFrameSecondary:SetValue(currResources)
        frame.barFrameSecondary.LeftText:SetTemplateText("")
        frame.barFrameSecondary.RightText:SetTemplateText("")
    end
    frame.barFrameSecondary.LeftText:UpdateText()
    frame.barFrameSecondary.RightText:UpdateText()

end

local function createBar (parent, width, height)
    local bar = CreateFrame("StatusBar", "PowerBar", parent)
    bar:SetSize(width, height)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(0,0,0,0)

    return bar
end

function PowerBar:New (parent, unitTypeID, width, anchorTo, barInfo, isFirst)
    local instance = setmetatable({}, PowerBar)

    instance.unitType = unitTypeID
    instance.width = width
    instance.height = barInfo.Height
    instance.anchorTo = anchorTo

    instance:generateTemplateTextTable(barInfo)


    instance.barFrame = createBar(parent, instance.width, instance.height)

    instance.barFrame.barFramePrimary = createBar(instance.barFrame, instance.width, instance.height)
    instance:prepareBarFontStrings(instance.barFrame.barFramePrimary, barInfo) -- barInfo needs to be stored in instance




    instance:initializeBar(instance.barFrame, instance.unitType)

 

    -- add border

    -- anchor bar to anchorPoint given as parameter
    if(isFirst == true) then
        instance.barFrame:SetPoint("TOPLEFT", anchorTo, "TOPLEFT")
        instance.barFrame:SetPoint("TOPRIGHT", anchorTo, "TOPRIGHT")
    else
        instance.barFrame:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT")
        instance.barFrame:SetPoint("TOPRIGHT", anchorTo, "BOTTOMRIGHT")
    end

    instance.barFrame.barFramePrimary:SetPoint("TOPLEFT",instance.barFrame, "TOPLEFT")
    instance.barFrame.barFramePrimary:SetPoint("TOPRIGHT",instance.barFrame, "TOPRIGHT")

    if(instance.unitType == "player")then
        instance.barFrame.barFrameSecondary = createBar(instance.barFrame, instance.width, 0)
        instance:prepareBarFontStrings(instance.barFrame.barFrameSecondary, barInfo)
        instance.barFrame.barFrameSecondary:SetPoint("TOPLEFT",instance.barFrame.barFramePrimary, "BOTTOMLEFT")
        instance.barFrame.barFrameSecondary:SetPoint("TOPRIGHT",instance.barFrame.barFramePrimary, "BOTTOMRIGHT")
    end

    return instance
end

function PowerBar:initializeBar (barFrame, unitType)
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
            -- redraw the power bar
            self:UpdatePowerBar(f, "POLLING", "targettarget")
        end
    end)
    -- setup callback for events with different parameters (unit == "targettarget")
    barFrame:SetScript("OnEvent", function (f, event, unitToken)
        self:UpdatePowerBar(f, event, "targettarget")
    end)

    else
    -- power value changed
    barFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unitType)
    -- player login
    barFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- unit power type changed
    barFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unitType)

    -- for target, change of player's target needs to be registered
    if (unitType == "target") then
        barFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    -- for focus, change of player's focus needs to be registered
    elseif (unitType == "focus") then
        barFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    elseif(unitType == "pet") then
        barFrame:RegisterEvent("UNIT_PET")
        barFrame:RegisterEvent("PET_UI_UPDATE")
    end
    -- setup callback for events
    barFrame:SetScript("OnEvent", function (f, event, unitToken, ...)
        self:UpdatePowerBar(f, event, unitToken)
    end)
    end

end

function PowerBar:prepareBarFontStrings(bar, barInfo)
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

-- TODO check if update functions can be merged
-- TODO if not, refactor this function
-- depending on event, choose what needs to be updated on power bar
function PowerBar:UpdatePowerBar(frame, event, unit)
    -- if player changes focus
    if(event == "PLAYER_FOCUS_CHANGED") then
        -- set unit to focus and update power bar color
        unit = "focus"
        if(UnitExists("focus")) then
            changePowerBarColor(frame.barFramePrimary, "focus")
        end
    end
    -- if event is polling from target of target frame
    -- or unit changed target
    -- or player changed target and target of target needs to be updated
    if (event == "POLLING" or event == "UNIT_TARGET" or (event == "PLAYER_TARGET_CHANGED" and unit == "targettarget")) then
        -- check unit and change power color
        if(UnitExists(unit)) then
            changePowerBarColor(frame.barFramePrimary, unit)
        end
    -- if player logged into game
    -- or player power changed (shapeshift, talent change, ...)
    -- or players target changed
    elseif(event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" or event == "PLAYER_TARGET_CHANGED")then
        -- if player logged in
        if(event == "PLAYER_ENTERING_WORLD")then
            -- change unit to self
            unit = self.unitType
        -- if player changed target
        elseif (event == "PLAYER_TARGET_CHANGED") then
            -- then unit needs to change to target
            unit = "target"
        end
        -- check unit and change color of power bar
        if(UnitExists(unit)) then
            changePowerBarColor(frame.barFramePrimary, unit)
        end
    elseif (event == "UNIT_PET" or event == "PET_UI_UPDATE") then
        if(event == "PET_UI_UPDATE") then
            unit = "pet"
        end
            changePowerBarColor(frame.barFramePrimary, unit)
    end
    -- update text on bars
    local powerType = UnitPowerType(unit)
    local currPow = UnitPower(unit, powerType)
    local maxPow = UnitPowerMax(unit, powerType)
    frame.barFramePrimary:SetMinMaxValues(0, maxPow)
    frame.barFramePrimary:SetValue(currPow)
--     print("AHOJ", event)
-- for k, v in pairs(self.barFrame) do print("key:", k, "value:", v) end
--for k, v in pairs(frame) do print("key:", k, "value:", v) end

    frame.barFramePrimary.LeftText:UpdateText()
    frame.barFramePrimary.RightText:UpdateText()

    if(unit == "player") then
        updateSecondaryBar(frame, unit)
    end

end


function PowerBar:GetFrame()
    return self.barFrame
end

function PowerBar:generateTemplateTextTable(barInfo)
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
        self.barTextStrings[value] = ""
        if (barInfo[value .. "Text"] ~= nil ) then
            self.barTextStrings[value] = barInfo[value .. "Text"]
        end
    end

    --print("------")
end
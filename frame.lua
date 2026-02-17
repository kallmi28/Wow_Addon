local x = 1


Frame = {}
Frame.__index = Frame

-- TODO create solution where adding sooner added frame as anchor does not break everything
-- TODO create solution for dropdown to disallow anchoring to itself or create cycle
local anchorFrameTranslation = {
    ["SCREEN"] = function() return UIParent end,
    ["PLAYER"] = function() return G_MyAddon.Frames.PlayerFrame.mainFrame.MainFrame end,
    ["TARGET"] = function() return G_MyAddon.Frames.TargetFrame.mainFrame.MainFrame end,
    ["TARGETOFTARGET"] = function() return G_MyAddon.Frames.TargetOfTargetFrame.mainFrame.MainFrame end,
    ["FOCUS"] = function() return G_MyAddon.Frames.FocusFrame.mainFrame.MainFrame end,
    -- ["SCREEN"] = UIParent,
    -- ["SCREEN"] = UIParent,
}

-- Function to substitute user formated string with actual values
local function FormatUserString(userString, unit)
    local mask = userString
    if not UnitExists(unit) then return "" end

local keywords = {
    "CurrHP",
    "CurrHPSmart",
    "MaxHP",
    "MaxHPSmart",
    "PercHP",
    "MissingHP",
    "MissingHPSmart",
    "CurrPower",
    "CurrPowerSmart",
    "MaxPower",
    "MaxPowerSmart",
    "PercPower",
    "MissingPower",
    "MissingPowerSmart",
    "UnitName",
    "UnitServer",
    "GuildName",
    "GroupNumber",
    "Class",
    "Level",
    "Race",
    "StatusAfk",
}

local subFunctions = {
    function() return getCurrHp(unit) end,
    function() return getCurrHpSmart(unit) end,
    function() return getMaxHp(unit) end,
    function() return getMaxHpSmart(unit) end,
    function() return getPercHp(unit) end,
    function() return getMissingHp(unit) end,
    function() return getMissingHpSmart(unit) end,
    function() return getCurrPower(unit) end,
    function() return getCurrPowerSmart(unit) end,
    function() return getMaxPower(unit) end,
    function() return getMaxPowerSmart(unit) end,
    function() return getPercPower(unit) end,
    function() return getMissingPower(unit) end,
    function() return getMissingPowerSmart(unit) end,
    function() return getUnitName(unit) end,
    function() return getUnitServer(unit) end,
    function() return getGuildName(unit) end,
    function() return getGroupNumber(unit) end,
    function() return getClass(unit) end,
    function() return getLevel(unit) end,
    function() return getRace(unit) end,
    function() return getStatusAfk(unit) end,
}

for index, value in ipairs(keywords) do
    mask = string.gsub(mask, "%[" .. value .. "%]", "%%" .. index .. "$s")
    --print(index, mask)
end

    mask = string.format(mask, callAndExpand (subFunctions))
    return mask
end

-- Function for adding border to bar frame
local function addBorder(bar, thickness)
    -- Create "Frame container" for all the border lines
    bar.border = CreateFrame("Frame", nil, bar)
    bar.border:SetAllPoints(true)
    
    -- grey colored frame with low alpha/ transparency
    local color = {0.2, 0.2, 0.2, 0.3}

    -- Upper border
    local top = bar.border:CreateTexture(nil, "OVERLAY")
    top:SetColorTexture(unpack(color))
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(thickness)

    -- Bottom border
    local bottom = bar.border:CreateTexture(nil, "OVERLAY")
    bottom:SetColorTexture(unpack(color))
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(thickness)

    -- Left border
    local left = bar.border:CreateTexture(nil, "OVERLAY")
    left:SetColorTexture(unpack(color))
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    left:SetWidth(thickness)

    -- PRight border
    local right = bar.border:CreateTexture(nil, "OVERLAY")
    right:SetColorTexture(unpack(color))
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    right:SetWidth(thickness)
end

-- Setup of main frame of frame
local function setupMainFrame (instance, height)
    -- TODO create better name than temp
    local temp = anchorFrameTranslation[instance.AnchorToFrame]
    local anchorFrame = temp()

    instance.MainFrame:SetFrameStrata("BACKGROUND")
    instance.MainFrame:SetWidth(instance.Width)
    instance.MainFrame:SetPoint(instance.AnchorByPoint,anchorFrame,instance.AnchorToPoint, instance.X, instance.Y)
    
    instance.MainFrame:SetAttribute("unit", instance.UnitFrameID)
    instance.MainFrame:SetAttribute("*type1", "target")     -- Levé kliknutí cílí
    instance.MainFrame:SetAttribute("*type2", "togglemenu") -- Pravé kliknutí otevře MENU
    instance.MainFrame:RegisterForClicks("AnyUp")

    -- create background for the frame
    -- TODO instead of black/grey, use darker color of upper layer
    instance.MainFrame.bg = instance.MainFrame:CreateTexture(nil, "BACKGROUND")
    instance.MainFrame.bg:SetAllPoints(true)
    instance.MainFrame.bg:SetColorTexture(0.1, 0.1, 0.1, 1)

    -- Adding frame to Blizzard, so it can handle existing during combat
    RegisterUnitWatch(instance.MainFrame)
    instance.Height = height
    instance.MainFrame:SetHeight(instance.Height)
    
end

-- creates Bar, sets width, height and texture
local function createBar(barInfo, width, idx, parent)
    local bar = CreateFrame("StatusBar", "Bar" .. idx, parent)
    
    bar:SetSize(width, barInfo.Height)

    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

    return bar
end

-- Function to change health bar color according to class/reaction
local function changeHealthBarColor (frame, unit)
    local colorRow = {r = 0.5, g = 0.5, b = 0.5}

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

    frame.LeftText:SetText(FormatUserString(bar.LeftText, unit))
    frame.RightText:SetText(FormatUserString(bar.RightText, unit))
end

-- change color of power bar according to actual power of unit 
local function changePowerBarColor(frame, unit)
    
    local c, powerToken, r, g, b = UnitPowerType(unit)
    -- get color of normal power
    local barColor = GetPowerBarColor(powerToken)

    -- if (unit ~= "targettarget") then
    --     print(c, powerToken, r, g, b)
    --    -- for k, v in pairs(barColor.predictionColor) do print("klíč:", k, "hodnota:", v) end
    -- end

    -- if GetPowerBarColor did not return color, unit power is special, use color components from UnitPowerType
    if barColor == nil then
        barColor = {}
        barColor.r, barColor.g, barColor.b = r,g,b
    end
    
    frame:SetStatusBarColor(barColor["r"], barColor["g"], barColor["b"] , 1)
end

-- TODO check if Update functions for different bar types can be merged
-- Depending on Event, choose what needs to be update on HP bar
function Frame:UpdateHpBar(frame, event, unit, bar)
    -- if health of unit changes
    if (event == "UNIT_HEALTH") then
        updateHealthBar(frame, unit, bar)
    -- if player logs into game, changes target or focus
    elseif(event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_FOCUS_CHANGED") then
        -- event PLAYER_TARGET_CHANGED doesn't tell which unit changed target 
        -- if player changed target
        if event == "PLAYER_TARGET_CHANGED" then
            -- and frame belongs to target of target
            if(self.UnitFrameID == "targettarget") then
                -- the unit needs to be changed to target of target
                unit = "targettarget"
            -- if frame belongs to focus
            elseif (self.UnitFrameID == "focus") then
                -- the unit needs to be changed to focus
                unit = "focus"
            -- otherwise unit needs to be changed to target
            else
                unit = "target"
            end
        -- other events needs unit set to itself
        else
            unit = self.UnitFrameID
        end
        -- check to be sure that Unit exists
        if(UnitExists(unit)) then
            -- change color and text on bar
            changeHealthBarColor (frame, unit)
            updateHealthBar(frame, unit, bar)
        end
    -- if target of target polling event triggers
    elseif (event == "POLLING") then
        -- change color and text on bar
        changeHealthBarColor (frame, unit)
        updateHealthBar(frame, unit, bar)
    end
end

-- TODO check if update functions can be merged
-- TODO if not, refactor this function
-- depending on event, choose what needs to be updated on power bar
function Frame:UpdatePowerBar(frame, event, unit, bar)
    -- if player changes focus
    if(event == "PLAYER_FOCUS_CHANGED") then
        -- set unit to focus and update power bar color
        unit = "focus"
        if(UnitExists("focus")) then
            changePowerBarColor(frame, "focus")
        end
    end
    -- if event is polling from target of target frame
    -- or unit changed target
    -- or player changed target and target of target needs to be updated
    if (event == "POLLING" or event == "UNIT_TARGET" or (event == "PLAYER_TARGET_CHANGED" and unit == "targettarget")) then
        -- check unit and change power color
        if(UnitExists(unit)) then
            changePowerBarColor(frame, unit)
        end
    -- if player logged into game
    -- or player power changed (shapeshift, talent change, ...)
    -- or players target changed
    elseif(event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" or event == "PLAYER_TARGET_CHANGED")then
        -- if player logged in
        if(event == "PLAYER_ENTERING_WORLD")then
            -- change unit to self
            unit = self.UnitFrameID
        -- if player changed target
        elseif (event == "PLAYER_TARGET_CHANGED") then
            -- then unit needs to change to target
            unit = "target"
        end
        -- check unit and change color of power bar
        if(UnitExists(unit)) then
            changePowerBarColor(frame, unit)
        end
    end
    -- update text on bars
    local powerType = UnitPowerType(unit)
    local currPow = UnitPower(unit, powerType)
    local maxPow = UnitPowerMax(unit, powerType)
    frame:SetMinMaxValues(0, maxPow)
    frame:SetValue(currPow)
    frame.LeftText:SetText(FormatUserString(bar.LeftText, unit))
    frame.RightText:SetText(FormatUserString(bar.RightText, unit))

end

-- TODO add channeling functionality
-- cast bar
function Frame:castBarRun (frame, event, unitTarget)
    --print("CastBar", event, unitTarget)
    if event == "UNIT_SPELLCAST_START" then
        frame:SetMinMaxValues(0, 1)
        frame:Show()
    elseif event == "UNIT_SPELLCAST_STOP" then
        frame:Hide()
    end

end

-- register events and callbacks according to bar type and unit
local function initializeBar(instance, bar, unitTypeID)
    local frame = bar.BarFrame
    local barType = bar.BarType

    -- unregisted all events and callbacks
    frame:UnregisterAllEvents()
    frame:SetScript("OnEvent", nil)
    frame:SetScript("OnUpdate", nil)
    --print(instance, frame, unitTypeID, barType)
    -- Health Bar 
    if(barType == "HB") then
        -- target of target 
         if(unitTypeID == "targettarget") then
            -- target of target change event
           frame:RegisterUnitEvent("UNIT_TARGET", "target")
           -- when player changes target, its target changes too
           frame:RegisterEvent("PLAYER_TARGET_CHANGED")
           frame:RegisterEvent("UNIT_TARGETABLE_CHANGED")

           -- target of target does not have events for resource change
           -- Polling has to be used
            local elapsed = 0
            frame:SetScript("OnUpdate", function(f, delta)
                elapsed = elapsed + delta
                -- 5 times per second
                if elapsed > 0.2 then 
                    elapsed = 0
                    -- redraw the HP bar
                    instance:UpdateHpBar(f, "POLLING", "targettarget", bar)
                end
            end)
        -- other units
        else
            -- player login
            frame:RegisterEvent("PLAYER_ENTERING_WORLD")
            -- unit change health
            frame:RegisterUnitEvent("UNIT_HEALTH", unitTypeID)

            -- for target frame, change of player's target needs to be registered
            if (unitTypeID == "target") then
                frame:RegisterEvent("PLAYER_TARGET_CHANGED")
            -- for focus, change of players focus needs to be registered
            elseif(unitTypeID == "focus") then
                frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
            end
        end
        --  setup callback for events
        frame:SetScript("OnEvent", function (f, event, unitToken)
            local realUnit = (unitTypeID == "targettarget") and "targettarget" or unitToken
            instance:UpdateHpBar(f, event, realUnit, bar)
        end)
        -- change health bar color at bar creation
        changeHealthBarColor (frame, unitTypeID)

    elseif (barType == "PB") then
        -- target of target
         if(unitTypeID == "targettarget") then
            -- target of target change event
            frame:RegisterUnitEvent("UNIT_TARGET", "target")
            -- when player changes target, its target changes too
            frame:RegisterEvent("PLAYER_TARGET_CHANGED")
            frame:RegisterEvent("UNIT_TARGETABLE_CHANGED")
            
            -- target of target does not have events for resource change
           -- Polling has to be used
            local elapsed = 0
            frame:SetScript("OnUpdate", function(f, delta)
                elapsed = elapsed + delta
                -- 5 times per second
                if elapsed > 0.2 then
                    elapsed = 0
                    -- redraw the power bar
                    instance:UpdatePowerBar(f, "POLLING", "targettarget", bar)
                end
            end)
            -- setup callback for events with different parameters (unit == "targettarget")
            frame:SetScript("OnEvent", function (f, event, unitToken)
                instance:UpdatePowerBar(f, event, "targettarget", bar)
            end)
         else
            -- power value changed
            frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unitTypeID)
            -- player login
            frame:RegisterEvent("PLAYER_ENTERING_WORLD")
            -- unit power type changed
            frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unitTypeID)

            -- for target, change of player's target needs to be registered
            if (unitTypeID == "target") then
                frame:RegisterEvent("PLAYER_TARGET_CHANGED")
            -- for focus, change of player's focus needs to be registered
            elseif (unitTypeID == "focus") then
                frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
            end
            -- setup callback for events
            frame:SetScript("OnEvent", function (f, event, unitToken)
                instance:UpdatePowerBar(f, event, unitToken, bar)
            end)
         end


    elseif (barType == "CB") then
        -- register cast start and cast stop
        -- TODO add channeling
        frame:RegisterUnitEvent("UNIT_SPELLCAST_START", unitTypeID)
        frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unitTypeID)

        -- set color to yellow
        frame:SetStatusBarColor(0.8,0.8,0,1)
        frame:SetMinMaxValues(0,0)

        -- on update, watch if unit did not start casting 
        frame:SetScript("OnUpdate", function (f)
            local p = UnitCastingDuration(unitTypeID)
            if(p ~= nil) then
                f:SetValue(p:GetElapsedPercent())
            end
        end)
        -- on event occuring, run callback
        frame:SetScript("OnEvent", function (f, event, unitToken)
            instance:castBarRun(f, event, unitToken)
        end)
        -- hide frame at start
        frame:Hide()
    end
end

-- constructor for Frame instance
function Frame:New(initVal, unitTypeID)

    local instance = setmetatable({}, Frame)
    local h = 0
    print("Constructor for Frame", unitTypeID)
    -- data load from saved variable
    instance.X = initVal.X
    instance.Y = initVal.Y
    instance.Width = initVal.FrameWidth
    instance.UnitFrameID = unitTypeID
    instance.AnchorToFrame = initVal.AnchorToFrame
    instance.AnchorByPoint = initVal.AnchorByPoint
    instance.AnchorToPoint = initVal.AnchorToPoint
    instance.BarsPerFrame = initVal.BarCount
    -- creation of main frame
    instance.MainFrame = CreateFrame("Button", unitTypeID .. "Frame", UIParent, "SecureUnitButtonTemplate")
    -- print("MAINFRAME: ", unitTypeID, instance, instance.MainFrame:GetDebugName())
    instance.BarArr = {}
    -- creation of bar frames (maximum 5 for now)
    for i = 1, 5, 1 do
        local anchorBar
        local barInfo = initVal["Bar" .. i]

        -- bar creation + data load
        instance.BarArr[i] = {}
        instance.BarArr[i].BarFrame = createBar(barInfo, instance.Width, i, instance.MainFrame)
        instance.BarArr[i].Height = barInfo.Height
        instance.BarArr[i].BarFrame:SetStatusBarColor(0,0,0,0)
        instance.BarArr[i].BarType = barInfo.BarType
        instance.BarArr[i].LeftText = barInfo.LeftText
        instance.BarArr[i].RightText = barInfo.RightText

        -- add border to bar
        addBorder(instance.BarArr[i].BarFrame, 1)

        -- add height of all visible bars 1
        h = h + (i <= instance.BarsPerFrame and instance.BarArr[i].Height or 0)
        
        -- first bar anchors to the main frame
        if i == 1 then
            anchorBar = instance.MainFrame
        -- others anchor to the previous bar
        else
            anchorBar = instance.BarArr[i-1].BarFrame
        end
        -- anchor bars under each other
        instance.BarArr[i].BarFrame:SetPoint("TOPLEFT",anchorBar,(i == 1 and "TOPLEFT" or "BOTTOMLEFT"))
        instance.BarArr[i].BarFrame:SetPoint("TOPRIGHT",anchorBar,(i == 1 and "TOPRIGHT" or "BOTTOMRIGHT"))

        -- hide bars if they are not supposed to be visible
        if(i > initVal.BarCount) then
            instance.BarArr[i].BarFrame:Hide()
        end

        -- create "labels" on bars
        instance.BarArr[i].BarFrame.LeftText = instance.BarArr[i].BarFrame:CreateFontString(unitTypeID .. barInfo.BarType .. "Left", "OVERLAY", "GameFontNormal")
        instance.BarArr[i].BarFrame.LeftText:SetPoint("LEFT",instance.BarArr[i].BarFrame,"LEFT", 3,0)
        instance.BarArr[i].BarFrame.RightText = instance.BarArr[i].BarFrame:CreateFontString(unitTypeID .. barInfo.BarType .. "Right", "OVERLAY", "GameFontNormal")
        instance.BarArr[i].BarFrame.RightText:SetPoint("RIGHT",instance.BarArr[i].BarFrame,"RIGHT", -3,0)

        -- set max width, max height, turn off word wrap for text to not overflow the bar
        instance.BarArr[i].BarFrame.LeftText:SetWordWrap(false) 
        instance.BarArr[i].BarFrame.LeftText:SetJustifyH("LEFT")
        instance.BarArr[i].BarFrame.LeftText:SetWidth(instance.Width/2)
        instance.BarArr[i].BarFrame.LeftText:SetMaxLines(1)

        instance.BarArr[i].BarFrame.RightText:SetWordWrap(false) 
        instance.BarArr[i].BarFrame.RightText:SetJustifyH("RIGHT")
        instance.BarArr[i].BarFrame.RightText:SetWidth(instance.Width/2)
        instance.BarArr[i].BarFrame.RightText:SetMaxLines(1)


        -- initialize bar according to type
        if(instance.BarArr[i].BarType == "HB")then
            initializeBar(instance, instance.BarArr[i], unitTypeID)

        elseif (instance.BarArr[i].BarType == "PB") then
            -- TODO add logic for secondary power
            -- register events for bar, set scripts for bar
            initializeBar(instance, instance.BarArr[i], unitTypeID)

        elseif (instance.BarArr[i].BarType == "CB") then
            initializeBar(instance, instance.BarArr[i], unitTypeID)
        end
    end

    -- setup events, callbacks and properties of main frame
    setupMainFrame(instance, h)
    print("Constructor Done")

    return instance
end

-- Function called during changes in Options
function Frame:ApplySettings()

    --print("------------------------------------------------------")
    local h = 0
    local anchorPoint = anchorFrameTranslation[self.AnchorToFrame]
    local anchorFrame = anchorPoint()

    self.MainFrame:ClearAllPoints()
    for i = 1, self.BarsPerFrame, 1 do
        h = h + self.BarArr[i].Height
        self.BarArr[i].BarFrame:SetSize(self.Width, self.BarArr[i].Height)
        self.BarArr[i].BarFrame.LeftText:SetWidth(self.Width/2)
        self.BarArr[i].BarFrame.RightText:SetWidth(self.Width/2)

    end
    self.Height = h
    self.MainFrame:SetHeight(self.Height)
    self.MainFrame:SetWidth(self.Width)
    self.MainFrame:SetPoint(self.AnchorByPoint, anchorFrame,self.AnchorToPoint, self.X, self.Y)

    --print("------------------------------------------------------")

end

-- Function for storing information about frames, called during logout
function Frame:Save(storage)
    local storageBarInfo
    local selfBarInfo

    storage.AnchorToFrame = self.AnchorToFrame
    storage.AnchorByPoint = self.AnchorByPoint
    storage.AnchorToPoint = self.AnchorToPoint
    storage.FrameWidth = self.Width
    storage.BarCount = self.BarCount
    storage.X = self.X
    storage.Y = self.Y

    for i = 1, 5, 1 do
        storageBarInfo = storage["Bar" .. i]
        selfBarInfo = self.BarArr[i]

        storageBarInfo.Height = selfBarInfo.Height
        storageBarInfo.BarType = selfBarInfo.BarType
        storageBarInfo.LeftText = selfBarInfo.LeftText
        storageBarInfo.RightText = selfBarInfo.RightText
    end
end
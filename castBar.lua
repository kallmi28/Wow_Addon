
CastBar = {}

CastBar.__index = CastBar

local function createBar (parent, width, height)
    local bar = CreateFrame("StatusBar", "HealthBar", parent)
    bar:SetSize(width, height)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(0,0,0,1)

    return bar
end


function CastBar:New (parent, unitTypeID, width, anchorTo, barInfo, isFirst)
    local instance = setmetatable({}, CastBar)

    instance.unitType = unitTypeID
    instance.width = width
    instance.height = barInfo.Height
    instance.anchorTo = anchorTo

    -- Health Bar will be able to have 9 fontStrings
    -- not all will be used 
    instance.barTexts = {}

    instance.barFrame = createBar(parent, instance.width, instance.height)

    instance:initializeBar(instance.barFrame, instance.unitType)
    --instance:prepareBarFontStrings(instance.barFrame, barInfo) -- barInfo needs to be stored in instance
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


function CastBar:initializeBar (barFrame, unitType)
    -- unregisted all events and callbacks
    barFrame:UnregisterAllEvents()
    barFrame:SetScript("OnEvent", nil)
    barFrame:SetScript("OnUpdate", nil)

    -- register cast start and cast stop
    -- TODO add channeling
    barFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", unitType)
    barFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unitType)

    -- set color to yellow
    barFrame:SetStatusBarColor(0.8,0.8,0,1)
    barFrame:SetMinMaxValues(0,0)

    -- on update, watch if unit did not start casting 
    barFrame:SetScript("OnUpdate", function (f)
        local p = UnitCastingDuration(unitType)
        if(p ~= nil) then
            f:SetValue(p:GetElapsedPercent())
        else
            f:Hide()
        end
    end)
    -- on event occuring, run callback
    barFrame:SetScript("OnEvent", function (f, event, unitToken)
        self:castBarRun(f, event)
    end)
    -- hide frame at start
    barFrame:Hide()


end

-- TODO add channeling functionality
-- cast bar
function CastBar:castBarRun (frame, event)
    --print("CastBar", event, unitTarget)
    if event == "UNIT_SPELLCAST_START" then
        frame:SetMinMaxValues(0, 1)
        frame:Show()
    elseif event == "UNIT_SPELLCAST_STOP" then
        frame:Hide()
    end

end

function CastBar:GetFrame()
    return self.barFrame
end

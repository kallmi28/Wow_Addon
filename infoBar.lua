InfoBar = {}

InfoBar.__index = InfoBar


local function createBar (parent, width, height)
    local bar = CreateFrame("StatusBar", "HealthBar", parent)
    bar:SetSize(width, height)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(0,0,0,1)

    return bar
end

function InfoBar:New (parent, unitTypeID, width, anchorTo, barInfo, isFirst)
    local instance = setmetatable({}, InfoBar)
    
    instance.unitType = unitTypeID
    instance.width = width
    instance.height = barInfo.Height
    instance.anchorTo = anchorTo

    -- Health Bar will be able to have 9 fontStrings
    -- not all will be used 
    instance.barTexts = {}

    instance.barFrame = createBar(parent, instance.width, instance.height)

    --instance:initializeBar(instance.barFrame, instance.unitType)
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

function InfoBar:GetFrame()
    return self.barFrame
end

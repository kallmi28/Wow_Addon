
UnitCellFrame = {}
UnitCellFrame.__index = UnitCellFrame

-- Global color curve to save memory
local healthCurve = C_CurveUtil.CreateColorCurve()
healthCurve:SetType(Enum.LuaCurveType.Linear)
healthCurve:AddPoint(0.1, CreateColor(1, 0, 0, 1)) -- Red at 10%
healthCurve:AddPoint(0.5, CreateColor(1, 1, 0, 1)) -- Yellow at 50%
healthCurve:AddPoint(0.9, CreateColor(0, 1, 0, 1)) -- Green at 90%

function UnitCellFrame:New (width, height, parent, unit)
local instance = setmetatable({}, UnitCellFrame)
    
    instance.unit = unit
    
    -- Main container (Secure Button for unit interaction)
    instance.frame = CreateFrame("Button", "MyAddonFrame_" .. unit, parent, "SecureUnitButtonTemplate")
    instance.frame:SetSize(width + 4, height + 4)
    instance.frame:SetAttribute("unit", unit)

    instance.frame:SetPoint("CENTER", 0, 0)
    
    -- Register frame to behave as Blizzard frame
    instance.frame:RegisterForClicks("AnyUp")
    instance.frame:SetAttribute("*type1", "target")
    instance.frame:SetAttribute("*type2", "togglemenu")
    
    -- instance:SetupComponents()
    -- instance:RegisterEvents()

    instance.border = instance.frame:CreateTexture("BGFRAME", "BACKGROUND")
    instance.border:SetAllPoints()
    instance.border:SetColorTexture(0.1, 0.1, 0.1, 0.4) -- grey frame

    -- health bar
    instance.healthBar = CreateFrame("StatusBar", "HPBARGFRAMWE", instance.frame)
    instance.healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    instance.healthBar:SetPoint("TOPLEFT", instance.frame, "TOPLEFT", 2, -2)
    instance.healthBar:SetPoint("BOTTOMRIGHT", instance.frame, "BOTTOMRIGHT", -2, -2)
    instance.healthBar:SetFrameLevel(instance.frame:GetFrameLevel() + 1)
    instance.healthBar:SetValue(UnitHealth("player"))
    instance.healthBar:SetMinMaxValues(0, UnitHealthMax("player"))



    -- power bar
    instance.powerBar = CreateFrame("StatusBar", "POWBNARFGRAME", instance.frame)
    instance.powerBar:SetHeight(8)
    -- 5% shorter than health bar
    -- on both sides
    instance.powerBar:SetPoint("LEFT", instance.healthBar, "BOTTOMLEFT", width * 0.05, 0)
    instance.powerBar:SetPoint("RIGHT", instance.healthBar, "BOTTOMRIGHT", -(width * 0.05), 0)
    instance.powerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

    -- Making sure that powerbar lies on top of healthbar
    instance.powerBar:SetFrameLevel(instance.healthBar:GetFrameLevel() + 1)

    instance.powerBar.bg = instance.powerBar:CreateTexture(nil, "BACKGROUND")
    instance.powerBar.bg:SetAllPoints()
    instance.powerBar.bg:SetColorTexture(0, 0, 0, 0.6)



    instance.nameText = CustomText:New(
        instance.healthBar,
        "Fonts\\FRIZQT__.TTF",
        10,
        "SLUG",
        {r = 1, g = 1, b = 1, a = 1},
        "[UnitName]",
        "OVERLAY",
        "player"
    )
    instance.nameText:SetPoint("TOP", instance.healthBar, "TOP", 0, -2)
    instance.nameText:UpdateText()


    instance.hpText = CustomText:New(
        instance.healthBar,
        "Fonts\\FRIZQT__.TTF",
        10, 
        "SLUG",
        {r = 1, g = 1, b = 1, a = 1},
        "[PercHP]%%",
        "OVERLAY",
        "player"
    )
    instance.hpText:SetPoint("CENTER", instance.healthBar, "CENTER", 0, 0)

    -- Unified Event Handler using RegisterUnitEvent for better performance
    instance.frame:RegisterUnitEvent("UNIT_HEALTH", unit)
    instance.frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    instance.frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
    instance.frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    instance.frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)

    instance.frame:SetScript("OnEvent", function(self, event)
        print(event)
        if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
            local cur, max = UnitHealth(unit), UnitHealthMax(unit)
            instance.healthBar:SetMinMaxValues(0, max)
            instance.healthBar:SetValue(cur)
            
            -- Dynamic color based on health percentage
            local color = UnitHealthPercent(unit, true, healthCurve)
            instance.healthBar:GetStatusBarTexture():SetVertexColor(color:GetRGB())
            
            instance.hpText:UpdateText()

        elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
            local cur, max = UnitPower(unit), UnitPowerMax(unit)
            instance.powerBar:SetMinMaxValues(0, max)
            instance.powerBar:SetValue(cur)
            
            -- Color power bar based on power type (Mana, Rage, Energy, etc.)
            -- local _, powerType = UnitDisplayPower(unit)
            -- local color = PowerBarColor[powerType] or {r=0, g=0.5, b=1}
            -- instance.powerBar:SetStatusBarColor(color.r, color.g, color.b)
        end
    end)

-- Initial update call
    instance.frame:GetScript("OnEvent")(instance.frame, "UNIT_HEALTH")
    instance.frame:GetScript("OnEvent")(instance.frame, "UNIT_DISPLAYPOWER")

    return instance
end
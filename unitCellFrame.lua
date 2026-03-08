
UnitCellFrame = {}
UnitCellFrame.__index = UnitCellFrame

-- Global color curve to save memory
local healthCurve = C_CurveUtil.CreateColorCurve()
healthCurve:SetType(Enum.LuaCurveType.Linear)
healthCurve:AddPoint(0.1, CreateColor(1, 0, 0, 1)) -- Red at 10%
healthCurve:AddPoint(0.5, CreateColor(1, 1, 0, 1)) -- Yellow at 50%
healthCurve:AddPoint(0.9, CreateColor(0, 1, 0, 1)) -- Green at 90%

-- Color curve for dispels as requested
local t = C_CurveUtil.CreateColorCurve()
t:SetType(Enum.LuaCurveType.Step)
t:AddPoint(1, CreateColor(0.2, 0.6, 1, 1)) -- Magic
t:AddPoint(2, CreateColor(0.6, 0, 1, 1))   -- Curse
t:AddPoint(4, CreateColor(0, 0.6, 0, 1))   -- Poison
t:AddPoint(3, CreateColor(0.6, 0.4, 0, 1)) -- Disease
t:AddPoint(0, CreateColor(0.1, 0.1, 0.1, 0)) -- Default
t:AddPoint(5, CreateColor(0.1, 0.1, 0.1, 0)) -- Default

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



function UnitCellFrame:UpdateGlow(unit)
    local color = {r = 0.1, g = 0.1, b = 0.1, a = 0.4}
    local dispelableDebuffFound = false
    
    -- Iterate through debuffs on the unit
    for i = 1, 40 do
        local aura = C_UnitAuras.GetDebuffDataByIndex(unit, i)
        if not aura then break end 
        
        --print(aura.dispelName, aura.auraInstanceID, aura.name)
        
        -- Use Blizzard's color engine to avoid issues with protected/secret strings
        if aura.dispelName then
            local temp = C_UnitAuras.GetAuraDispelTypeColor(unit, aura.auraInstanceID, t)

            if color then
                --print(temp.r, temp.g, temp.b, temp.a)
                color = {r = temp.r, g = temp.g, b = temp.b, a = temp.a}
                dispelableDebuffFound = true
            end
        end
    end
    -- print(unit, "________________________", dispelableDebuffFound)

    if(dispelableDebuffFound == true) then
        self.glow.tex:SetVertexColor(color.r, color.g, color.b, 1)
        self.glow:Show()
        --print(self.glow.anim:IsPlaying(), "playing?")
        if not self.glow.anim:IsPlaying() then
            --print("its playing")
            self.glow.anim:Play()
        end
    else
        self.glow:Hide()
        self.glow.anim:Stop()
    end
end

-- change color of power bar according to actual power of unit 
local function changePowerBarColor(frame, unit)
    if(UnitExists(unit)) then
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

local function eventHandler(self, event, instance, ...)
    --print("2, ", ...)
    --for k, v in pairs(self) do print("key:", k, "value:", v) end

    --local arg1, arg2, arg3 = ...
    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        local unit = (select(1, ...))
        --print(event, ...)
        local cur, max = UnitHealth(unit), UnitHealthMax(unit)
        instance.healthBar:SetMinMaxValues(0, max)
        instance.healthBar:SetValue(cur)
        
        -- Dynamic color based on health percentage
        local color = UnitHealthPercent(unit, true, healthCurve)
        instance.healthBar:GetStatusBarTexture():SetVertexColor(color:GetRGB())
        
        instance.hpText:UpdateText()

        changeHealthBarColor(instance.healthBar, unit)

    elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
        local unit = (select(1,...))
        local powerType = UnitPowerType(unit)
        --print(unit, powerType, event)
        local cur, max = UnitPower(unit, powerType), UnitPowerMax(unit, powerType)


        instance.powerBar:SetMinMaxValues(0, max)
        instance.powerBar:SetValue(cur)
        changePowerBarColor(instance.powerBar, unit)
        -- Color power bar based on power type (Mana, Rage, Energy, etc.)
        -- local _, powerType = UnitDisplayPower(unit)
        -- local color = PowerBarColor[powerType] or {r=0, g=0.5, b=1}
        -- instance.powerBar:SetStatusBarColor(color.r, color.g, color.b)
    elseif(event == "UNIT_AURA") then
        local unit = (select(1,...))
        instance:UpdateGlow(unit)
    elseif (event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD") then
        --print("1", event, instance.unit)
        local unit = instance.unit
        self:GetScript("OnEvent")(self, "UNIT_HEALTH", unit)
        self:GetScript("OnEvent")(self, "UNIT_POWER_UPDATE", unit)
        instance:UpdateGlow(unit)
        local hpText = ""
        if(UnitIsConnected(unit) == true) then
            hpText = instance.hpTextString
        else
            hpText = "~dc~"
        end

        
        instance.nameText:UpdateText()
        instance.hpText:SetTemplateText(hpText)
        instance.hpText:UpdateText()
    elseif (event == "UNIT_CONNECTION") then
        local isConnected = (select(2, ...))
        local unit = (select(1,...))
        print(event, ...)
        if(unit == instance.unit) then
            if( isConnected == false) then
                instance.hpText:SetTemplateText("~dc~")
                instance.healthBar:SetAlpha(0.5)
            else
                instance.hpText:SetTemplateText(instance.hpTextString)
                instance.healthBar:SetAlpha(1)
            end
        end
    end
end


function UnitCellFrame:New(width, height, parent, unit, x, y, hpText)
    local instance = setmetatable({}, UnitCellFrame)
    instance.unit = unit
    instance.hpTextString = hpText
    -- Main container
    instance.frame = CreateFrame("Button", "MyAddonFrame_" .. unit, parent, "SecureUnitButtonTemplate")
    instance.frame:SetSize(width + 4, height + 4)
    instance.frame:SetAttribute("unit", unit)
    instance.frame:SetPoint("LEFT", x, y)
    
    instance.frame:RegisterForClicks("AnyUp")
    instance.frame:SetAttribute("*type1", "target")
    instance.frame:SetAttribute("*type2", "togglemenu")

    instance.bg = instance.frame:CreateTexture("BGFRAME", "BACKGROUND")
    instance.bg:SetPoint("TOPLEFT", instance.frame, "TOPLEFT", 2, -2)
    instance.bg:SetPoint("BOTTOMRIGHT", instance.frame, "BOTTOMRIGHT", -2, 2)
    instance.bg:SetColorTexture(0.1, 0.1, 0.1, 1) 

    -- Glow initialization
    instance.glow = CreateFrame("Frame", nil, instance.frame)
    instance.glow:SetAllPoints()
    instance.glow:Hide()

    
    instance.glow.tex = instance.glow:CreateTexture(nil, "OVERLAY")

    instance.glow.tex:SetAtlas("Mission-LootBackgroundGlow")
    instance.glow.tex:SetBlendMode("ADD")
    instance.glow.tex:SetDesaturated(true) -- Umožní ti barvit texturu pomocí SetVertexColor
    instance.glow.tex:SetAllPoints()
    instance.glow.tex:SetPoint("TOPLEFT", instance.frame, "TOPLEFT",  -(0.1*width), height * 0.37)
    instance.glow.tex:SetPoint("BOTTOMRIGHT", instance.frame, "BOTTOMRIGHT",  (0.1*width), -(height * 0.37))

    local animGroup = instance.glow:CreateAnimationGroup()
    local alpha = animGroup:CreateAnimation("Alpha")
    alpha:SetFromAlpha(0.4)
    alpha:SetToAlpha(1.0)
    alpha:SetDuration(0.6)
    alpha:SetSmoothing("IN_OUT")
    animGroup:SetLooping("BOUNCE")
    instance.glow.anim = animGroup

    -- Health bar
    instance.healthBar = CreateFrame("StatusBar", "HPBARGFRAMWE", instance.frame)
    instance.healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    instance.healthBar:SetPoint("TOPLEFT", instance.frame, "TOPLEFT", 2, -2)
    instance.healthBar:SetPoint("BOTTOMRIGHT", instance.frame, "BOTTOMRIGHT", -2, 2)
    instance.healthBar:SetFrameLevel(instance.frame:GetFrameLevel() + 1)

    -- Power bar
    instance.powerBar = CreateFrame("StatusBar", "POWBNARFGRAME", instance.frame)
    instance.powerBar:SetHeight(8)
    instance.powerBar:SetPoint("LEFT", instance.healthBar, "BOTTOMLEFT", width * 0.05, 0)
    instance.powerBar:SetPoint("RIGHT", instance.healthBar, "BOTTOMRIGHT", -(width * 0.05), 0)
    instance.powerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    instance.powerBar:SetFrameLevel(instance.healthBar:GetFrameLevel() + 2)

    instance.powerBar.bg = instance.powerBar:CreateTexture(nil, "BACKGROUND")
    instance.powerBar.bg:SetAllPoints()
    instance.powerBar.bg:SetColorTexture(0, 0, 0, 0.6)

    -- Custom Texts with SLUG
    instance.nameText = CustomText:New(instance.healthBar, "Fonts\\FRIZQT__.TTF", 10, "SLUG", {r=1,g=1,b=1,a=1}, "[UnitName]", "OVERLAY", unit)
    instance.nameText:SetPoint("TOP", instance.healthBar, "TOP", 0, -2)

    instance.hpText = CustomText:New(instance.healthBar, "Fonts\\FRIZQT__.TTF", 10, "SLUG", {r=1,g=1,b=1,a=1}, hpText, "OVERLAY", unit)
    instance.hpText:SetPoint("CENTER", instance.healthBar, "CENTER", 0, 0)

    -- Event Handling
    instance.frame:RegisterUnitEvent("UNIT_HEALTH", unit)
    instance.frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    instance.frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
    instance.frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    instance.frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)
    instance.frame:RegisterUnitEvent("UNIT_AURA", unit)

    instance.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    instance.frame:RegisterEvent("PLAYER_ENTERING_WORLD")

    instance.frame:RegisterEvent("UNIT_CONNECTION")

    addBorder(instance.healthBar, 1)

    instance.frame:SetScript("OnEvent", function (self, event, ...)
        eventHandler(self, event, instance, ...)
    end)

    -- Initial calls
    instance.frame:GetScript("OnEvent")(instance.frame, "UNIT_HEALTH", unit)
    instance:UpdateGlow(unit)

    RegisterStateDriver(instance.frame, "visibility", "[@" .. unit .. ",exists] show; hide")
    
    return instance
end



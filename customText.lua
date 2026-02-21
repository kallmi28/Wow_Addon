CustomText = {}
CustomText.__index = CustomText

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
        -- print(index, mask)
    end
        
    mask = string.format(mask, callAndExpand (subFunctions))
    -- print (mask)
    return mask
end


-- Constructor
function CustomText:New(parentFrame, fontPath, fontSize, fontFlags, fontColor, templateText, layer, unit)
    local instance = setmetatable({}, CustomText)
    
    -- Initialize variables
    instance.fontPath = fontPath or "Fonts\\FRIZQT__.TTF"
    instance.fontSize = fontSize or 12
    instance.fontFlags = fontFlags or ""
    instance.fontColor = fontColor or {r = 1, g = 1, b = 1, a = 1}
    instance.templateText = templateText or ""

    instance.unit = unit
    
    -- Create the actual FontString
    instance.fontString = parentFrame:CreateFontString(nil, layer or "OVERLAY", "GameFontNormal")
    
    -- Apply initial settings
    instance:ApplyAllSettings()
    
    return instance
end

-- SETTERS
function CustomText:SetFontPath(path)
    self.fontPath = path
    self.fontString:SetFont(self.fontPath, self.fontSize, self.fontFlags)
end

function CustomText:SetFontSize(size)
    self.fontSize = size
    self.fontString:SetFont(self.fontPath, self.fontSize, self.fontFlags)
end

function CustomText:SetFontFlags(flags)
    self.fontFlags = flags
    self.fontString:SetFont(self.fontPath, self.fontSize, self.fontFlags)
end

function CustomText:SetFontColor(color)
    self.fontColor = {r = color.r, g = color.g, b = color.b, a = color.a}
    self.fontString:SetTextColor(self.fontColor.r, self.fontColor.g, self.fontColor.b, self.fontColor.a)
end

function CustomText:SetTemplateText(text)
    self.templateText = text
end

-- Update function for Font (Path, Size, Flags)
function CustomText:UpdateFont()
    self.fontString:SetFont(self.fontPath, self.fontSize, self.fontFlags)
end

-- Update function for Text Color
function CustomText:UpdateColor()
    self.fontString:SetTextColor(self.fontColor.r, self.fontColor.g, self.fontColor.b, self.fontColor.a)
end

-- Update function for Content (Template/Text)
function CustomText:UpdateText()
    self.fontString:SetText(FormatUserString(self.templateText, self.unit))
end

-- Safely apply font settings
function CustomText:ApplyAllSettings()
    self:UpdateFont()
    self:UpdateColor()
    self:UpdateText()
end

-- Proxy methods for positioning (makes it behave like a frame)
function CustomText:SetPoint(...)
    self.fontString:SetPoint(...)
end

function CustomText:SetWidth(width)
    self.fontString:SetWidth(width)
end

function CustomText:SetJustifyH(align)
    self.fontString:SetJustifyH(align)
end

function CustomText:SetWordWrap(...)
    self.fontString:SetWordWrap(...)
end

function CustomText:SetMaxLines(...)
    self.fontString:SetMaxLines(...)
end
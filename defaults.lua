local defaults = {
    General = {
        LockFrames = false,
        ShowGrid = false,
        Font = "Fonts\\FRIZQT__.TTF",
        FontSize = 12,
        BarTexture = 0,
        AlphaInCombat = 0,
        AlphaOutCombat = 0,
    },
    PlayerFrame = {
        AnchorToFrame = "SCREEN",
        AnchorByPoint = "CENTER",
        AnchorToPoint = "CENTER",
        FrameWidth = 280,
        BarCount = 4,
        X = -375,
        Y = 125,
        Bar1 = { Height = 30, BarType = "HB", LeftText = "[UnitName]", RightText = "[CurrHPSmart]/[MaxHPSmart] [PercHP]%%" },
        Bar2 = { Height = 30, BarType = "PB", LeftText = "[PercPower]%%", RightText = "[CurrPower]/[MaxPower]" },
        Bar3 = { Height = 5, BarType = "CB", LeftText = "", RightText = "" },
        Bar4 = { Height = 0, BarType = "EB", LeftText = "", RightText = "" },
        Bar5 = { Height = 0, BarType = "EB", LeftText = "", RightText = "" },
    },
    TargetFrame = {
        AnchorToFrame = "SCREEN",
        AnchorByPoint = "CENTER",
        AnchorToPoint = "CENTER",
        FrameWidth = 280,
        BarCount = 4,
        X = 375,
        Y = 125,
        Bar1 = { Height = 10, BarType = "EB", LeftText = "[UnitName]", RightText = "[Level]" },
        Bar2 = { Height = 20, BarType = "HB", LeftText = "[UnitName] [[Level]]", RightText = "[CurrHPSmart]/[MaxHPSmart] [PercHP]%%" },
        Bar3 = { Height = 10, BarType = "PB", LeftText = "[PercPower]%%", RightText = "[CurrPower]/[MaxPower]" },
        Bar4 = { Height = 5, BarType = "CB", LeftText = "", RightText = "" },
        Bar5 = { Height = 0, BarType = "EB", LeftText = "", RightText = "" },
    },
    TargetOfTargetFrame = {
        AnchorToFrame = "TARGET",
        AnchorByPoint = "BOTTOMRIGHT",
        AnchorToPoint = "TOPRIGHT",
        FrameWidth = 180,
        BarCount = 2,
        X = 0,
        Y = 0,
        Bar1 = { Height = 15, BarType = "HB", LeftText = "[UnitName]", RightText = "[CurrHPSmart]/[MaxHPSmart] [PercHP]%%" },
        Bar2 = { Height = 12, BarType = "PB", LeftText = "[PercPower]%%", RightText = "[CurrPowerSmart]" },
        Bar3 = { Height = 0, BarType = "EB", LeftText = "", RightText = "" },
        Bar4 = { Height = 0, BarType = "EB", LeftText = "", RightText = "" },
        Bar5 = { Height = 0, BarType = "EB", LeftText = "", RightText = "" },
    },
    PetFrame = {
        AnchorToFrame = "PLAYER",
        AnchorByPoint = "TOPLEFT",
        AnchorToPoint = "BOTTOMLEFT",
        FrameWidth = 160,
        BarCount = 2,
        X = 0,
        Y = 0,
        Bar1 = { Height = 10, BarType = "PB", LeftText = "", RightText = "" },
        Bar2 = { Height = 15, BarType = "HB", LeftText = "", RightText = "" },
        Bar3 = { Height = 10, BarType = "EB", LeftText = "", RightText = "" },
        Bar4 = { Height = 5, BarType = "EB", LeftText = "", RightText = "" },
        Bar5 = { Height = 0, BarType = "EB", LeftText = "", RightText = "" },
    },
    FocusFrame = {
        AnchorToFrame = "PLAYER",
        AnchorByPoint = "BOTTOMLEFT",
        AnchorToPoint = "TOPLEFT",
        FrameWidth = 120,
        BarCount = 2,
        X = 0,
        Y = 0,
        Bar1 = { Height = 20, BarType = "HB", LeftText = "[UnitName]", RightText = "[CurrHPSmart]" },
        Bar2 = { Height = 20, BarType = "PB", LeftText = "[PercPower]%%", RightText = "[CurrPowerSmart]" },
        Bar3 = { Height = 0, BarType = "EB", LeftText = "", RightText = "" },
        Bar4 = { Height = 0, BarType = "EB", LeftText = "", RightText = "" },
        Bar5 = { Height = 0, BarType = "EB", LeftText = "", RightText = "" },
    },
    FocusTarget = {}, Party = {}, Raid = {}, Boss = {}, Arena = {},
}





function InitializeDefaults(db, defaultSource)
    defaultSource = defaultSource or defaults
    for key, value in pairs(defaultSource) do
        if type(value) == "table" then
            if db[key] == nil then db[key] = {} end
            InitializeDefaults(db[key], value) -- Rekurze pro vnořené tabulky
        else
            if db[key] == nil then
                db[key] = value
            end
        end
    end
end
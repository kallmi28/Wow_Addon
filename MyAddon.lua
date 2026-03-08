local AceGUI = LibStub("AceGUI-3.0")
-- for k, v in pairs(actualBarData) do print("key:", k, "value:", v) end

-- Addon commands registration
SLASH_MYADDON1 = "/myaddon"
SLASH_MYADDON2 = "/x"

SlashCmdList["MYADDON"] = function(msg)
    -- make the text lowercase
    msg = msg:lower():trim()

    if msg == "reset" then
        G_defaultDataReset = true

        savedVar = {}
        InitializeDefaults(savedVar, nil)

        print(G_AddonNameColoredString, "The settings have been reset to default.")

        -- reload UI to see the changes
        ReloadUI()
    elseif msg == "d" then
        -- debug print
        --  for k, v in pairs(G_MyAddon.Frames.TargetOfTargetFrame.mainFrame) do print("key:", k, "value:", v) end
    for i = 1, 40 do
        -- UnitAura returns information about auras (Retail uses C_UnitAuras)
        
        local aura = C_UnitAuras.GetBuffDataByIndex("player", i)
        
        if not aura then break end -- No more debuffs
        if(aura.spellId == 8936) then
        for k, v in pairs(aura) do print("key:", k, "value:", v) end
        print(aura.spellId, aura.name, aura.auraInstanceID)
        end
        -- aura.dispelName contains "Magic", "Curse", etc.
        -- if aura.dispelName and DEBUFF_COLORS[aura.dispelName] then
        --     foundDebuffType = aura.dispelName
        --     break -- We stop at the first dispellable debuff found
        -- end
    end

    else
        for k, v in pairs(G_MyAddon.Options.mainFrame) do print("key:", k, "value:", v) end
        if G_MyAddon.Options.mainFrame:IsShown() then
            G_MyAddon.Options.mainFrame:Hide()
        else
            if(PlayerIsInCombat() == false) then
                G_MyAddon.Options.mainFrame:Show()
                if(G_MyAddon.SavedVars.General.ShowGrid == true) then
                    -- if the Show Grid option is true, show grid on Option Window open
                    ChangeGridVisibility(true)
                end
            end
        end
    end
end


-------------------------------------------------------------------------------------------



G_MyAddon = {}
G_MyAddon.Frames = {}
G_MyAddon.Frames.PlayerFrame = {}

G_MyAddon.Frames.TargetFrame = {}
G_MyAddon.Frames.TargetOfTargetFrame = {}
G_MyAddon.Frames.FocusFrame = {}
G_MyAddon.Frames.PetFrame = {}

G_MyAddon.SavedVars = {}
G_MyAddon.Options = {}



local function initFunction(self, event, addonName)
    if(event == "ADDON_LOADED" and addonName == "MyAddon")then
        savedVar = savedVar or {}

        print("I got here because of " .. event .. " of " .. addonName)

        InitializeDefaults(savedVar, nil)
        G_MyAddon.Options.mainFrame = OptionFrame:New(savedVar.General)
        G_MyAddon.SavedVars = savedVar
        G_MyAddon.Frames.PlayerFrame.mainFrame = UnitFrame:New(savedVar.PlayerFrame, "player")
        G_MyAddon.Frames.TargetFrame.mainFrame = UnitFrame:New(savedVar.TargetFrame, "target")
        G_MyAddon.Frames.TargetOfTargetFrame.mainFrame = UnitFrame:New(savedVar.TargetOfTargetFrame, "targettarget")
        G_MyAddon.Frames.FocusFrame.mainFrame = UnitFrame:New(savedVar.FocusFrame, "focus")
        G_MyAddon.Frames.PetFrame.mainFrame = UnitFrame:New(savedVar.PetFrame, "pet")

    elseif(event == "PLAYER_LOGOUT") then
        print("I will never see this, but config has been saved succesfully")
        if(G_defaultDataReset == false) then
            -- local error = nil
            -- local qqq = error.test
            G_MyAddon.Frames.PlayerFrame.mainFrame:Save(savedVar.PlayerFrame)
            G_MyAddon.Frames.TargetFrame.mainFrame:Save(savedVar.TargetFrame)
            G_MyAddon.Frames.TargetOfTargetFrame.mainFrame:Save(savedVar.TargetOfTargetFrame)
            G_MyAddon.Frames.FocusFrame.mainFrame:Save(savedVar.FocusFrame)
            G_MyAddon.Frames.PetFrame.mainFrame:Save(savedVar.PetFrame)

        end

    elseif (event == "PLAYER_REGEN_DISABLED") then
        if G_MyAddon.Options.mainFrame:IsShown() then
            G_MyAddon.Options.mainFrame:Hide()
        end
    end

end



local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_LOGOUT")
initFrame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Added for combat protection
initFrame:SetScript("OnEvent", initFunction)



classColors = {
    ["HUNTER"] = {r = 0.67, g = 0.83, b = 0.45},
    ["WARLOCK"] = {r = 0.58, g = 0.51, b = 0.79},
    ["PRIEST"] = {r = 1.0, g = 1.0, b = 1.0},
    ["PALADIN"] = {r = 0.96, g = 0.55, b = 0.73},
    ["MAGE"] = {r = 0.41, g = 0.8, b = 0.94},
    ["ROGUE"] = {r = 1.0, g = 0.96, b = 0.41},
    ["DRUID"] = {r = 1.0, g = 0.49, b = 0.04},
    ["SHAMAN"] = {r = 0.14, g = 0.35, b = 1.0},
    ["WARRIOR"] = {r = 0.78, g = 0.61, b = 0.43},
    ["DEATHKNIGHT"] = {r = 0.77, g = 0.12 , b = 0.23},
    ["MONK"] = {r = 0.0, g = 1.00 , b = 0.59},
    ["DEMONHUNTER"] = {r = 0.64, g = 0.19, b = 0.79},
    ["EVOKER"] = {r = 0.20, g = 0.58, b = 0.50},
}

-- Makes possible to move frames
-- unitFrame:SetMovable(true)
-- unitFrame:EnableMouse(true)
-- unitFrame:RegisterForDrag("LeftButton")
-- unitFrame:SetScript("OnDragStart", unitFrame.StartMoving)
-- unitFrame:SetScript("OnDragStop", unitFrame.StopMovingOrSizing)

local pf = UnitPartyFrame:New(-210, -250, 100, 60, "[PercHP]%%")

-- local X, Y = 200, 50
-- local testFrame = CreateFrame("Frame", "MyGlowTestFrame", UIParent)
-- testFrame:SetSize(X, Y)
-- testFrame:SetPoint("CENTER", 0, -200)
-- testFrame:SetFrameStrata("HIGH") -- Ensure it's above other UI elements

-- testFrame.bg = testFrame:CreateTexture(nil, "BACKGROUND")
-- testFrame.bg:SetAllPoints()

-- testFrame.bg:SetColorTexture(0, 1, 0, 0)
-- testFrame.healthBar = CreateFrame("StatusBar", "HPBARGFRAMWE", testFrame)
-- testFrame.healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
-- testFrame.healthBar:SetPoint("TOPLEFT", testFrame, "TOPLEFT", 0, 0)
-- testFrame.healthBar:SetPoint("BOTTOMRIGHT", testFrame, "BOTTOMRIGHT", 0, 0)
-- testFrame.healthBar:SetFrameLevel(testFrame:GetFrameLevel() + 1)
-- -- 2. Glow Frame - explicitly set higher Frame Level
-- local glow = CreateFrame("Frame", nil, testFrame)
-- glow:SetAllPoints()
-- glow:SetFrameLevel(testFrame:GetFrameLevel()-1) -- Force it above the background

-- local texs = {}


-- for i = 1, 1, 1 do
--     -- Use a solid color texture first to see if ANYTHING shows up
--     local tex = glow:CreateTexture(nil, "OVERLAY")
--     -- tex:SetAtlas("Mission-LootBackgroundGlow")
--     tex:SetDesaturated(true)
--     tex:SetVertexColor(0.2, 0.6, 1, 1)
--     tex:SetBlendMode("ADD")




--     tex:SetAllPoints()
--     tex:SetPoint("TOPLEFT", testFrame, "TOPLEFT", -(0.1*X), Y * 0.37)
--     tex:SetPoint("BOTTOMRIGHT", testFrame, "BOTTOMRIGHT", (0.1*X), -Y * 0.37)
--     texs[i] = tex
-- end

--     texs[1]:SetAtlas("Mission-LootBackgroundGlow")
--     --texs[2]:SetAtlas("_ItemUpgradeTooltip-NineSlice-EdgeTop")
--     -- texs[3]:SetAtlas("!ItemUpgradeTooltip-NineSlice-EdgeLeft")
--     -- texs[4]:SetAtlas("!ItemUpgradeTooltip-NineSlice-EdgeRight")
-- -- 3. Animation with explicit Script running
-- local animGroup = glow:CreateAnimationGroup()
-- local alpha = animGroup:CreateAnimation("Alpha")
-- alpha:SetFromAlpha(0.4)
-- alpha:SetToAlpha(1.0)
-- alpha:SetDuration(0.5)
-- alpha:SetOrder(1)

-- animGroup:SetLooping("BOUNCE")
-- animGroup:Play()

-- -- -- The "Safety Net" - if the animation group fails, OnUpdate will show us
-- -- glow:SetScript("OnUpdate", function(self, elapsed)
-- --     if not animGroup:IsPlaying() then
-- --         print("DEBUG: Animation was not playing, forcing start now.")
-- --         animGroup:Play()
-- --     end
-- --     -- Stop the script after one successful start to save CPU
-- --     self:SetScript("OnUpdate", nil)
-- -- end)

-- print("Glow Script Loaded. If you see a blue box, the layer works. If it pulses, animation works.")

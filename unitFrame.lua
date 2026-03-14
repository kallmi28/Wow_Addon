local x = 1


UnitFrame = {}
UnitFrame.__index = UnitFrame

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

    instance.MainFrame:SetFrameStrata("LOW")
    instance.MainFrame:SetWidth(instance.Width)
    instance.MainFrame:SetPoint(instance.AnchorByPoint,anchorFrame,instance.AnchorToPoint, instance.X, instance.Y)
    
    -- registration of frames to behave as Blizzard unit frames 
    instance.MainFrame:SetAttribute("unit", instance.UnitFrameID)
    -- left click to target
    instance.MainFrame:SetAttribute("*type1", "target")
    -- right click to open menu
    instance.MainFrame:SetAttribute("*type2", "togglemenu") 
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


-- constructor for Frame instance
function UnitFrame:New(initVal, unitTypeID)

    local instance = setmetatable({}, UnitFrame)
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
        instance.BarArr[i] = {}
        instance.BarArr[i].BarType = barInfo.BarType
        instance.BarArr[i].Bar = 0

        if i == 1 then
            anchorBar = instance.MainFrame
        -- others anchor to the previous bar
        else
            --for k, v in pairs( instance.BarArr[i - 1]) do print("key:", k, "value:", v) end
            anchorBar = instance.BarArr[i-1].Bar:GetFrame()
        end

        if(instance.BarArr[i].BarType == "HB") then
            instance.BarArr[i].Bar = HealthBar:New(instance.MainFrame, instance.UnitFrameID, instance.Width, anchorBar, barInfo, i == 1)
        elseif (instance.BarArr[i].BarType == "PB") then
            instance.BarArr[i].Bar = PowerBar:New(instance.MainFrame, instance.UnitFrameID, instance.Width, anchorBar, barInfo, i == 1)
        elseif (instance.BarArr[i].BarType == "CB") then
            instance.BarArr[i].Bar = CastBar:New(instance.MainFrame, instance.UnitFrameID, instance.Width, anchorBar, barInfo, i == 1)
        elseif (instance.BarArr[i].BarType == "EB") then
            instance.BarArr[i].Bar = InfoBar:New(instance.MainFrame, instance.UnitFrameID, instance.Width, anchorBar, barInfo, i == 1)

        end

        -- -- add height of all visible bars 
        h = h + (i <= instance.BarsPerFrame and barInfo.Height or 0)
    end

    -- setup events, callbacks and properties of main frame
    setupMainFrame(instance, h)
    print("Constructor Done")

    return instance
end


-- TODO fix applying settings for frames
-- Function called during changes in Options
function UnitFrame:ApplySettings()

    -- --print("------------------------------------------------------")
    -- local h = 0
    -- local anchorPoint = anchorFrameTranslation[self.AnchorToFrame]
    -- local anchorFrame = anchorPoint()

    -- self.MainFrame:ClearAllPoints()
    -- for i = 1, self.BarsPerFrame, 1 do
    --     h = h + self.BarArr[i].Height
    --     self.BarArr[i].BarFrame:SetSize(self.Width, self.BarArr[i].Height)
    --     --TODO use customText instead
    --     -- self.BarArr[i].BarFrame.LeftText:SetWidth(self.Width/2)
    --     -- self.BarArr[i].BarFrame.RightText:SetWidth(self.Width/2)

    -- end
    -- self.Height = h
    -- self.MainFrame:SetHeight(self.Height)
    -- self.MainFrame:SetWidth(self.Width)
    -- self.MainFrame:SetPoint(self.AnchorByPoint, anchorFrame,self.AnchorToPoint, self.X, self.Y)

    -- --print("------------------------------------------------------")

end

-- TODO fix saving when loging out
-- Function for storing information about frames, called during logout
function UnitFrame:Save(storage)
    -- local storageBarInfo
    -- local selfBarInfo

    -- storage.AnchorToFrame = self.AnchorToFrame
    -- storage.AnchorByPoint = self.AnchorByPoint
    -- storage.AnchorToPoint = self.AnchorToPoint
    -- storage.FrameWidth = self.Width
    -- storage.BarCount = self.BarCount
    -- storage.X = self.X
    -- storage.Y = self.Y

    -- for i = 1, 5, 1 do
    --     storageBarInfo = storage["Bar" .. i]
    --     selfBarInfo = self.BarArr[i]

    --     storageBarInfo.Height = selfBarInfo.Height
    --     storageBarInfo.BarType = selfBarInfo.BarType
    --     --TODO update when customText is in use
    --     -- storageBarInfo.LeftText = selfBarInfo.LeftText
    --     -- storageBarInfo.RightText = selfBarInfo.RightText
    -- end
end
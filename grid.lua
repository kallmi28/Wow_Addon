gridFrame = CreateFrame("Frame", "Grid", UIParent)

local l = {}
local flagUIResChanged = true
function iterateAndChangeVisibility (self, isShow)
    for _,v in pairs(l) do
        for _,v2 in pairs(v) do
            if(isShow == true) then
                v2:Show()
            else
                v2:Hide()
            end
        end
    end
end

local function registerLine(xStart, yStart, xEnd, yEnd, thick, isHorizontal)
        local idx = (isHorizontal == "horizontal" and xStart or yStart)
        local r,g,b,a = 0.8,0.8,0.8,0.3
        if(xStart == 0 or yStart == 0)then
            r,g,b,a = 0.8,0,0.8,0.5
        end
        
        l[isHorizontal][idx] = gridFrame:CreateLine(nil, "BACKGROUND", nil, -8)
        l[isHorizontal][idx]:SetStartPoint("CENTER", UIParent, xStart, yStart)
        l[isHorizontal][idx]:SetEndPoint("CENTER", UIParent, xEnd, yEnd)
        l[isHorizontal][idx]:SetThickness(thick)
        l[isHorizontal][idx]:SetColorTexture(r,g,b,a)
        l[isHorizontal][idx]:Hide()
end

local function onLoad ()
    local screenW = GetScreenWidth() * UIParent:GetEffectiveScale()
    local screenH = GetScreenHeight() * UIParent:GetEffectiveScale()
    local lineGap = 10
    local thickness = 1
        print(screenW .. 'x' .. screenH)



    l["horizontal"] = {}
    l["vertical"] = {}
    for i = 0, screenW, lineGap do
        registerLine(i, -screenH, i, screenH, thickness, "horizontal")
    end

    for i = -lineGap, -screenW, -lineGap do
        registerLine(i, -screenH, i, screenH, thickness, "horizontal")
    end

    for i = 0, screenH, lineGap do
        registerLine(-screenW, i, screenW, i, thickness, "vertical")
    end

    for i = -lineGap, -screenH, -lineGap do
        registerLine(-screenW, i, screenW, i, thickness, "vertical")
    end

end

function ChangeGridVisibility (val)
    if(val == true) then
        print("Show")
        if(flagUIResChanged == true)then
            onLoad()
            flagUIResChanged = false
        end
        iterateAndChangeVisibility(_, true)
        
    else
        iterateAndChangeVisibility(_, false)
        print("Hide")
     end
end

gridFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- gridFrame:RegisterEvent("UI_SCALE_CHANGED")
-- gridFrame:RegisterEvent("NOTCHED_DISPLAY_MODE_CHANGED")
gridFrame:SetScript("OnEvent", function (self, event)
    --print(event)
    -- local screenW = GetScreenWidth() * UIParent:GetEffectiveScale()
    -- local screenH = GetScreenHeight() * UIParent:GetEffectiveScale()
    --print(screenW .. 'x' .. screenH)
    flagUIResChanged = true
end)


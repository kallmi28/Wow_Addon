
UnitPartyFrame = {}
UnitPartyFrame.__index = UnitPartyFrame

function UnitPartyFrame:New(x, y, width, height, hpText)
    local instance = setmetatable({}, UnitCellFrame)

    local unitArr = {"player", "party1", "party2", "party3", "party4"}

    instance.frame = CreateFrame("Frame", "PartyF", UIParent)
    instance.frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    instance.frame:SetSize(100, 100)
    RegisterStateDriver(instance.frame, "visibility", "[group:raid] show; [group:party] show; hide")
    
    instance.unitFrame = {}

    for i = 1, 5, 1 do
        instance.unitFrame = UnitCellFrame:New(width, height, instance.frame, unitArr[i], (i - 1) * (width + 5), 0, hpText)
    end

    return instance
end
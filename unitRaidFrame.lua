UnitRaidFrame = {}
UnitRaidFrame.__index = UnitRaidFrame

function UnitRaidFrame:New(initVal)
    local instance = setmetatable({}, UnitRaidFrame)

    local unitArr = {"player", "party1", "party2", "party3", "party4"}

    instance.X = initVal.X
    instance.Y = initVal.Y
    instance.cellWidth = initVal.CellWidth
    instance.cellHeight = initVal.CellHeight
    instance.hpText = initVal.HpText

    instance.frame = CreateFrame("Frame", "PartyF", UIParent)
    instance.frame:SetPoint("CENTER", UIParent, "CENTER", instance.X, instance.Y)
    instance.frame:SetSize(100, 100)
    RegisterStateDriver(instance.frame, "visibility", "[group:raid] show; [group:party] hide; hide")
    
    instance.unitFrame = {}

    for i = 1, 5, 1 do
        instance.unitFrame = UnitCellFrame:New(instance.cellWidth, instance.cellHeight, instance.frame, unitArr[i], (i - 1) * (instance.cellWidth + 5), 0, instance.hpText)
    end

    return instance
end
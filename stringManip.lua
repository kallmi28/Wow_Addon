-- recursive function to call all the getters received in funcTable parameter
-- all getter functions are defined in this file
function callAndExpand (funcTable, index, unit)
    index = index or 1

    if (index <= #funcTable) then
        return funcTable[index](unit), callAndExpand(funcTable, index + 1, unit)
    end

end

-- TODO redo all percentage functions to return fixed lenght number

function getCurrHp (unit)
    return UnitHealth(unit)
end

function getCurrHpSmart (unit)
    return AbbreviateNumbers(UnitHealth(unit))
end

function getMaxHp (unit)
    return  UnitHealthMax(unit)
end

function getMaxHpSmart (unit)
    return  AbbreviateNumbers(UnitHealthMax(unit))
end

function getPercHp (unit)
    return  UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)
end

function getMissingHp (unit)
    return  UnitHealthMissing(unit)
end

function getMissingHpSmart (unit)
    return  AbbreviateNumbers(UnitHealthMissing(unit))
end

function getCurrPower (unit)
    local s = UnitPowerType(unit)
    return UnitPower(unit, s)
end

function getCurrPowerSmart (unit)
    local s = UnitPowerType(unit)
    return AbbreviateNumbers(UnitPower(unit, s))
end

function getMaxPower (unit)
    local s = UnitPowerType(unit)
    return UnitPowerMax(unit, s)
end

function getMaxPowerSmart (unit)
    local s = UnitPowerType(unit)
    return AbbreviateNumbers(UnitPowerMax(unit, s))
end

function getPercPower (unit)
    return string.format("%.1f", UnitPowerPercent(unit, UnitPowerType(unit), true, CurveConstants.ScaleTo100))
end

function getMissingPower (unit)
    return  UnitPowerMissing(unit)
end

function getMissingPowerSmart (unit)
    return  AbbreviateNumbers(UnitPowerMissing(unit))
end

function getUnitName (unit)
    local retVal = UnitName(unit)
    return retVal
end

function getUnitServer (unit)
    local _, retVal = UnitName(unit)
    return retVal
end

function getGuildName (unit)
    return GetGuildInfo(unit) or ""
end

function getGroupNumber (unit)
    return UnitInRaid(unit) or ""
end

function getClass (unit)
    return UnitClass(unit)
end

function getLevel (unit)
    return UnitLevel(unit)
end

function getRace (unit)
    return UnitRace(unit)
end

function getStatusAfk (unit)
    -- TODO think about solution which stores last known value before combat
    return PlayerIsInCombat() and "" or(UnitIsAFK(unit) and "(AFK)" or (UnitIsDND(unit) and "(DND)" or ""))
end


AuraTrackerFrame = {}
AuraTrackerFrame.__index = AuraTrackerFrame


_MEZI_TEST_VAR = 11




local function UpdateSingleAura(self, unit, info, i)

    local duration
    local expTime
    local auraType = 0 -- 0 -> init, 1 -> new aura, 2 -> update aura, 4 -> remove aura 

    if info then
        --print(info.addedAuras, info.updatedAuraInstanceIDs, info.removedAuraInstanceIDs)
        if info.addedAuras then
            -- print("updated info, added aura")
            for k, v in pairs(info.addedAuras) do
                if not issecretvalue(v.applications) then
                    -- print("added aira", v.spellId, v.sourceUnit, v.duration, v.auraInstanceID, v.name, unit)

                    if v and v.sourceUnit and v.duration and v.spellId == i.trackedSpellID then
                        i.auraInstanceId = v.auraInstanceID
                        print("FOund correct aura, storing aura Instance ID")
                        auraType = 1
                        duration = v.duration
                        expTime = v.expirationTime
                    end
                else
                    --print("aura is secret", v.spellId, v.name)
                end
            end
        end
        if info.updatedAuraInstanceIDs then
            --print("updated info, updated aura id")
            for k, v in pairs(info.updatedAuraInstanceIDs) do
                -- print("auraID = ", v, i.auraInstanceId)
                if v and v == i.auraInstanceId then
                    -- print("updated aura ", i.trackedSpellID, i.auraInstanceId)
                    local tmp = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, i.auraInstanceId)
                    duration = tmp.duration
                    i.auraInstanceId = tmp.auraInstanceID
                    auraType = 2
                    expTime = tmp.expirationTime
                    --for k, v in pairs(tmp) do print("key:", k, "value:", v, "issecretvalue:", issecretvalue(v)) end
                end
            end
        end
        if info.removedAuraInstanceIDs then
            -- print("updated info, removed aura id")
            for k, v in pairs(info.removedAuraInstanceIDs) do
                -- print("auraID = ", v)
                if v and v == i.auraInstanceId then
                    print("remove aura ", i.trackedSpellID, i.auraInstanceId)
                    duration = 0
                    auraType = 4
                    expTime = 0
                    i.auraInstanceId = 0
                end
            end
        end
    end
    --print("-----------------------------")
    if(auraType ~= 0)  then
        print ("auraType = ", auraType, "duration", duration)
    end


    if(auraType == 1 or auraType == 2) then
        if duration > 0 then
            self.cd:SetCooldownDuration(duration)
            self.cd:Show()
            self.expirationTime = expTime
        else
            self.cd:Hide()
            self.expirationTime = nil
        end
        
        self:SetAlpha(1.0)
        self.icon:SetDesaturated(false)
    elseif (auraType == 4) then
        self.cd:Hide()
        self.expirationTime = nil
        self.text:SetText("")
        --self:SetAlpha(0)
        self.icon:SetDesaturated(true)
    end

end

function AuraTrackerFrame:New (spellID, unit, X, Y, parent)
    local instance = setmetatable ({}, AuraTrackerFrame)
    instance.trackedSpellID = spellID
    instance.unitType = unit
    instance.auraInstanceId = 0

    -- create main frame
    instance.singleAuraFrame = CreateFrame("Frame", "tracker_ID" .. spellID, parent)
    instance.singleAuraFrame:SetSize(16, 16)
    instance.singleAuraFrame:SetPoint("BOTTOMLEFT", X, Y)

    -- create icon texture
    instance.singleAuraFrame.icon = instance.singleAuraFrame:CreateTexture(nil, "BACKGROUND")
    instance.singleAuraFrame.icon:SetAllPoints()
    instance.singleAuraFrame.icon:SetTexture(C_Spell.GetSpellTexture(instance.trackedSpellID))

    -- create cooldown graphic
    instance.singleAuraFrame.cd = CreateFrame("Cooldown", nil, instance.singleAuraFrame, "CooldownFrameTemplate")
    instance.singleAuraFrame.cd:SetAllPoints()
    instance.singleAuraFrame.cd:SetReverse(true)
    instance.singleAuraFrame.cd:SetHideCountdownNumbers(true)

    -- create countdown text
    instance.singleAuraFrame.text = instance.singleAuraFrame.cd:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    instance.singleAuraFrame.text:SetPoint("CENTER", instance.singleAuraFrame, "BOTTOMRIGHT", -2, 2)
    instance.singleAuraFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")

    -- register events
    instance.singleAuraFrame:RegisterUnitEvent("UNIT_AURA", instance.unitType)

    local counter = 0
    -- onEvent script
    instance.singleAuraFrame:SetScript("OnEvent", function(self, event, unitTarget, updateInfo)

        UpdateSingleAura(self, unitTarget, updateInfo, instance)
    end)

    -- onUpdate script (update of countdown text)
    local cnt = 0
    instance.singleAuraFrame:SetScript("OnUpdate", function(self, elapsed)
        cnt = cnt + elapsed
        if(cnt > 0.1) then
            --print("hyi", instance.unitType, cnt)
            cnt = 0
            if self.expirationTime then
                local timeLeft = self.expirationTime - GetTime()
                if timeLeft > 0 then
                    self.text:SetFormattedText("%.0f", timeLeft)
                else
                    self.text:SetText("")
                end
            end
        end

    end)


    return instance
end


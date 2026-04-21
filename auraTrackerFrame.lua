
AuraTrackerFrame = {}
AuraTrackerFrame.__index = AuraTrackerFrame

_MEZI_TEST_VAR = 11

local function UpdateSingleAura(self, SPID, unit)

    local spellName = C_Spell.GetSpellName(SPID)
    local aura = C_UnitAuras.GetAuraDataBySpellName(unit, spellName)
    
    
    if aura then
        print("updated aura", aura.auraInstanceID)
        if aura.duration > 0 then
            self.cd:SetCooldown(aura.expirationTime - aura.duration, aura.duration)
            self.cd:Show()
            self.expirationTime = aura.expirationTime
        else
            self.cd:Hide()
            self.expirationTime = nil
        end
        
        self:SetAlpha(1.0)
        self.icon:SetDesaturated(false)
    else
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
        -- -- if(updateInfo.addedAuras ~= nil and updateInfo.addedAuras[1] ~= nil and updateInfo.addedAuras[1].spellId == 33763) then
        -- --     print("This One")
        -- -- else
        -- --     if(updateInfo.addedAuras ~= nil) then
        -- --     -- print(updateInfo.spellID, instance.trackedSpellID)
        -- --     end
            
        -- -- end
        -- for k, v in pairs(updateInfo) do print("key:", k, "value:", v) end
        -- if(updateInfo.updatedAuraInstanceIDs ~= nil) then
        --     for _, v in pairs(updateInfo.updatedAuraInstanceIDs) do
        --         local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, v)
        --         print("shit fuck dick" , aura)
        --         --print(aura.auraInstanceID, aura.name, aura.sourceUnit, aura.isFromPlayerOrPlayerPet)
        --     end
        -- end
        -- if(updateInfo.removedAuraInstanceIDs ~= nil) then
        -- --for k, v in pairs(updateInfo.removedAuraInstanceIDs) do print("key:", k, "value:", v) end
        -- end
        -- if(updateInfo.addedAuras ~= nil) then
        -- --for k, v in pairs(updateInfo.addedAuras) do print("key:", k, "value:", v) end
        --     for i = 1, 10, 1 do
        --         if updateInfo.addedAuras[i] == nil then
        --             break
        --         else
        --             --print(updateInfo.addedAuras[i].name, updateInfo.addedAuras[i].auraInstanceID, updateInfo.addedAuras[i].spellId)
        --         end
        --     end
        -- end
        -- -- print(event, unitTarget, updateInfo)
        -- -- print("heo", instance.trackedSpellID, instance.unitType)
        if(updateInfo.addedAuras ~= nil) then
            for _, aura in ipairs(updateInfo.addedAuras) do
                -- print("---------")
            for k, v in pairs(aura) do 

                if issecretvalue(v) == true then
                    
                    -- print("key:", k, "value:", v, issecretvalue(v))
                    
                    -- if (k == "spellId" and v == 8936) then
                    --     print(issecretvalue(k), issecretvalue(v))
                    -- end
                end
            end

        end
        end
        --print("spellId: ",  instance.trackedSpellID, "counter: ", counter)
        counter = counter + 1

        UpdateSingleAura(self, instance.trackedSpellID, unitTarget)

        --print("-----------------")
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


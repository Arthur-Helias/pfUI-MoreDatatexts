setfenv(1, pfUI:GetEnvironment())

pfUI.moredatatexts:RegisterDatatextSettings("Reputation", {
    {
        name = "reputationmode",
        label = "Tracking Mode",
        type = "dropdown",
        default = "watched",
        options = {
            { value = "watched", label = "Watched Faction" },
            { value = "latest",  label = "Latest Change" }
        }
    },
    {
        name = "latestsavedfaction",
        type = "invisible",
        default = ""
    },
    {
        name = "latestsavedstanding",
        type = "invisible",
        default = "4"
    }
})

pfUI.moredatatexts:RegisterDatatext("Reputation", function()
    local datatext = CreateFrame("Frame", "pfmdReputationDatatext", UIParent)

    datatext:RegisterEvent("UPDATE_FACTION")
    datatext:RegisterEvent("COMBAT_TEXT_UPDATE")
    datatext:RegisterEvent("PLAYER_ENTERING_WORLD")

    local standingColors = {
        [1] = "|cffcc4c38",
        [2] = "|cffcc4c38",
        [3] = "|cffbf4500",
        [4] = "|cffe5b300",
        [5] = "|cff009919",
        [6] = "|cff009919",
        [7] = "|cff009919",
        [8] = "|cff009919",
    }

    local latestFaction = nil
    local latestStanding = 4

    if pfUI_config and pfUI_config.moredatatexts and pfUI_config.moredatatexts.Reputation then
        local savedFaction = pfUI_config.moredatatexts.Reputation["latestsavedfaction"]
        if savedFaction and savedFaction ~= "" then
            latestFaction = savedFaction
        end
        latestStanding = tonumber(pfUI_config.moredatatexts.Reputation["latestsavedstanding"]) or 4
    end

    if not latestFaction and C and C.moredatatexts and C.moredatatexts.Reputation then
        local savedFaction = C.moredatatexts.Reputation["latestsavedfaction"]
        if savedFaction and savedFaction ~= "" then
            latestFaction = savedFaction
        end
        latestStanding = tonumber(C.moredatatexts.Reputation["latestsavedstanding"]) or 4
    end

    local function UpdateReputation()
        if not C or not C.moredatatexts or not C.moredatatexts.Reputation then
            pfUI.panel:OutputPanel("Reputation", "No Rep", datatext.Tooltip, datatext.Click)
            return
        end

        local mode = C.moredatatexts.Reputation["reputationmode"]
        local name, standing, min, max, value

        if mode == "latest" and latestFaction then
            name = latestFaction
            standing = latestStanding

            for i = 1, GetNumFactions() do
                local factionName, _, factionStanding, factionMin, factionMax, factionValue = GetFactionInfo(i)
                if factionName == latestFaction then
                    min = factionMin
                    max = factionMax
                    value = factionValue
                    standing = factionStanding
                    break
                end
            end
        else
            name, standing, min, max, value = GetWatchedFactionInfo()
        end

        if name and standing and min and max and value then
            local current = value - min
            local maximum = max - min
            local percent = (current / maximum) * 100

            local standingText = getglobal("FACTION_STANDING_LABEL" .. standing) or "Unknown"
            local color = standingColors[standing] or "|cffffffff"
            local repText = string.format("%s%s|r: %d%%", color, standingText, percent)

            pfUI.panel:OutputPanel("Reputation", repText, datatext.Tooltip, datatext.Click)
        else
            pfUI.panel:OutputPanel("Reputation", "No Rep", datatext.Tooltip, datatext.Click)
        end
    end

    datatext.Tooltip = function()
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, this)

        if not C or not C.moredatatexts or not C.moredatatexts.Reputation then
            GameTooltip:AddLine("|cff555555Reputation")
            GameTooltip:AddLine("|cffff0000Config not loaded")
            GameTooltip:Show()
            return
        end

        GameTooltip:AddLine("|cff555555Reputation Tracker")

        local mode = C.moredatatexts.Reputation["reputationmode"]
        local name, standing, min, max, value

        if mode == "latest" and latestFaction then
            name = latestFaction

            for i = 1, GetNumFactions() do
                local factionName, _, factionStanding, factionMin, factionMax, factionValue = GetFactionInfo(i)
                if factionName == latestFaction then
                    standing = factionStanding
                    min = factionMin
                    max = factionMax
                    value = factionValue
                    break
                end
            end
        else
            name, standing, min, max, value = GetWatchedFactionInfo()
        end

        if name and standing and min and max and value then
            local standingText = getglobal("FACTION_STANDING_LABEL" .. standing) or "Unknown"
            local current = value - min
            local maximum = max - min
            local percent = (current / maximum) * 100
            local color = standingColors[standing] or "|cffffffff"

            GameTooltip:AddDoubleLine("Faction", "|cffffffff" .. name .. "|r")
            GameTooltip:AddDoubleLine("Standing", color .. standingText .. "|r")
            GameTooltip:AddDoubleLine("Progress", "|cffffffff" .. current .. " / " .. maximum .. " (" .. string.format("%.1f%%", percent) .. ")")
        else
            if mode == "latest" then
                GameTooltip:AddLine("|cffff0000No faction being tracked")
            else
                GameTooltip:AddLine("|cffff0000No faction being watched")
            end
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("Left Click", "|cffffffff" .. "Toggle Reputation Panel")
        GameTooltip:Show()
    end

    datatext.Click = function()
        ToggleCharacter("ReputationFrame")
    end

    datatext:SetScript("OnEvent", function()
        if event == "COMBAT_TEXT_UPDATE" and arg1 == "FACTION" then
            if arg2 then
                latestFaction = arg2

                for i = 1, GetNumFactions() do
                    local factionName, _, factionStanding = GetFactionInfo(i)
                    if factionName == arg2 then
                        latestStanding = factionStanding
                        break
                    end
                end

                if C and C.moredatatexts and C.moredatatexts.Reputation then
                    C.moredatatexts.Reputation["latestsavedfaction"] = latestFaction
                    C.moredatatexts.Reputation["latestsavedstanding"] = tostring(latestStanding)
                end

                if pfUI_config and pfUI_config.moredatatexts and pfUI_config.moredatatexts.Reputation then
                    pfUI_config.moredatatexts.Reputation["latestsavedfaction"] = latestFaction
                    pfUI_config.moredatatexts.Reputation["latestsavedstanding"] = tostring(latestStanding)
                end
            end
        end

        UpdateReputation()
    end)

    UpdateReputation()
end)

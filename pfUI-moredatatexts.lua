pfUI:RegisterModule("moredatatexts", function()
    local config
    local messagePref = GetAddOnMetadata("pfUI-moredatatexts", "Title") .. "|r: "

    pfUI.moredatatexts = CreateFrame("Frame", "pfMoreDatatexts", UIParent)
    pfUI.moredatatexts.datatexts = {}
    pfUI.moredatatexts.list = {}
    pfUI.moredatatexts.settings = {}
    pfUI.moredatatexts:RegisterEvent("VARIABLES_LOADED")

    function pfUI.moredatatexts:RegisterDatatext(datatextName, datatextFunction)
        if pfUI.moredatatexts.datatexts[datatextName] then
            return
        end

        pfUI.moredatatexts.datatexts[datatextName] = datatextFunction
        table.insert(pfUI.moredatatexts.list, datatextName)
    end

    function pfUI.moredatatexts:RegisterDatatextSettings(datatextName, settings)
        if not pfUI.moredatatexts.settings[datatextName] then
            pfUI.moredatatexts.settings[datatextName] = {}
        end

        for _, setting in ipairs(settings) do
            table.insert(pfUI.moredatatexts.settings[datatextName], setting)
        end
    end

    function pfUI.moredatatexts:UnregisterDatatext(datatextName)
        if pfUI.moredatatexts.datatexts[datatextName] then
            pfUI.moredatatexts.datatexts[datatextName] = nil
        end

        if C and C.moredatatexts and C.moredatatexts.enabled then
            C.moredatatexts.enabled[datatextName] = "0"
        end

        if pfUI_config and pfUI_config.moredatatexts and pfUI_config.moredatatexts.enabled then
            pfUI_config.moredatatexts.enabled[datatextName] = "0"
        end

        pfUI.moredatatexts:RemoveFromDropdown(datatextName)
    end

    function pfUI.moredatatexts:AddToDropdown(datatextName)
        if not pfUI.gui.dropdowns["panel_values"] then
            return
        end

        local dropdownEntry = datatextName .. ":" .. T[datatextName]
        for _, entry in ipairs(pfUI.gui.dropdowns["panel_values"]) do
            if entry == dropdownEntry then
                return
            end
        end

        table.insert(pfUI.gui.dropdowns["panel_values"], dropdownEntry)
    end

    function pfUI.moredatatexts:RemoveFromDropdown(datatextName)
        if not pfUI.gui.dropdowns["panel_values"] then
            return
        end

        local dropdownEntry = datatextName .. ":" .. T[datatextName]
        for i, entry in ipairs(pfUI.gui.dropdowns["panel_values"]) do
            if entry == dropdownEntry then
                table.remove(pfUI.gui.dropdowns["panel_values"], i)
                return
            end
        end
    end

    function pfUI.moredatatexts:UpdateDropdowns()
        if not config or not config.enabled then
            this.retryDropdown = true
            return
        end

        if not pfUI.gui or not pfUI.gui.dropdowns or not pfUI.gui.dropdowns["panel_values"] then
            this.retryDropdown = true
            return
        end

        for _, datatextName in pairs(pfUI.moredatatexts.list) do
            if config.enabled[datatextName] == "1" then
                pfUI.moredatatexts:AddToDropdown(datatextName)
            else
                pfUI.moredatatexts:RemoveFromDropdown(datatextName)
            end
        end

        this.retryDropdown = nil
    end

    function pfUI.moredatatexts:AddDatatext(datatext)
        local messageAdded = messagePref .. "%q added!"
        local messageError = messagePref .. "error adding %s --> |cffff0000%s|r"

        if datatext then
            if pfUI.moredatatexts.datatexts[datatext] then
                if config.enabled[datatext] == "1" then
                    local ok, err = pcall(pfUI.moredatatexts.datatexts[datatext])
                    if config.notifications == "1" then
                        if not ok then
                            DEFAULT_CHAT_FRAME:AddMessage(string.format(messageError, datatext, tostring(err)))
                        else
                            DEFAULT_CHAT_FRAME:AddMessage(string.format(messageAdded, datatext))
                        end
                    end
                end
            end
        else
            for _, datatextName in pairs(pfUI.moredatatexts.list) do
                if config.enabled[datatextName] == "1" then
                    local ok, err = pcall(pfUI.moredatatexts.datatexts[datatextName])
                    if config.notifications == "1" then
                        if not ok then
                            DEFAULT_CHAT_FRAME:AddMessage(string.format(messageError, datatextName, tostring(err)))
                        else
                            DEFAULT_CHAT_FRAME:AddMessage(string.format(messageAdded, datatextName))
                        end
                    end
                end
            end
        end
    end

    function pfUI.moredatatexts:Load()
        if event == "VARIABLES_LOADED" then
            if not C.moredatatexts then
                C.moredatatexts = {}
            end

            config = C.moredatatexts

            if not config.enabled then
                config.enabled = {}
            end

            for datatextName in config.enabled do
                if pfUI.moredatatexts.datatexts[datatextName] == nil then
                    config.enabled[datatextName] = nil
                end
            end

            if UnitIsConnected("player") then
                pfUI.moredatatexts:AddDatatext()
            else
                pfUI.moredatatexts:RegisterEvent("PLAYER_LOGIN")
            end
            pfUI.moredatatexts:RegisterEvent("ADDON_LOADED")
        elseif event == "PLAYER_LOGIN" then
            pfUI.moredatatexts:AddDatatext()
            pfUI.moredatatexts:UpdateDropdowns()
        else
            pfUI.moredatatexts:AddDatatext(arg1)
        end
    end

    pfUI.moredatatexts:SetScript("OnEvent", pfUI.moredatatexts.Load)

    pfUI.moredatatexts:SetScript("OnUpdate", function()
        if this.retryDropdown and pfUI.gui and pfUI.gui.dropdowns and pfUI.gui.dropdowns["panel_values"] then
            pfUI.moredatatexts:UpdateDropdowns()
            this.retryDropdown = nil
        end
    end)
end)

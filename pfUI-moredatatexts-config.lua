setfenv(1, pfUI:GetEnvironment())

local DoesTableContainsKeyMD = function(table, contains)
    return table[contains] ~= nil
end

local function InitializeDefaultValues()
    if pfUI_config and not DoesTableContainsKeyMD(pfUI_config, "moredatatexts") then
        pfUI_config.moredatatexts = {}
    end
    if pfUI_config and not DoesTableContainsKeyMD(pfUI_config.moredatatexts, "notifications") then
        pfUI:UpdateConfig("moredatatexts", nil, "notifications", "0")
    end
    if pfUI_config and not DoesTableContainsKeyMD(pfUI_config.moredatatexts, "enabled") then
        pfUI_config.moredatatexts.enabled = {}
    end

    for datatextName, settings in pairs(pfUI.moredatatexts.settings) do
        if not pfUI_config.moredatatexts[datatextName] then
            pfUI_config.moredatatexts[datatextName] = {}
        end

        for _, setting in ipairs(settings) do
            if not DoesTableContainsKeyMD(pfUI_config.moredatatexts[datatextName], setting.name) then
                pfUI:UpdateConfig("moredatatexts", datatextName, setting.name, setting.default or "0")
            end
        end
    end
end

local function CreateGuiConfigEntries()
    local CreateConfig = pfUI.gui.CreateConfig
    local CreateGUIEntry = pfUI.gui.CreateGUIEntry
    local U = pfUI.gui.UpdaterFunctions

    CreateGUIEntry(T["Thirdparty"], T["More Datatexts"], function()
        CreateConfig(nil, T["General Options"], nil, nil, "header")
        CreateConfig(U["moredatatexts"], T["Enable Chat Notifications"], C.moredatatexts, "notifications", "checkbox")
        CreateConfig(nil, T["Datatexts"], nil, nil, "header")

        table.sort(pfUI.moredatatexts.list, function(a, b)
            return strupper(a) < strupper(b)
        end)

        for _, datatextName in pfUI.moredatatexts.list do
            if C.moredatatexts.enabled[datatextName] == nil then
                pfUI:UpdateConfig("moredatatexts", "enabled", datatextName, "1")
            end

            local datatextUpdater = function()
                if U["moredatatexts"] then
                    U["moredatatexts"]()
                end

                if pfUI.moredatatexts and pfUI.moredatatexts.UpdateDropdowns then
                    pfUI.moredatatexts:UpdateDropdowns()
                end
            end

            CreateConfig(datatextUpdater, T["Enable"] .. " " .. datatextName, C.moredatatexts.enabled, datatextName,
                "checkbox")
        end

        for _, datatextName in pfUI.moredatatexts.list do
            if C.moredatatexts.enabled[datatextName] == nil then
                pfUI:UpdateConfig("moredatatexts", "enabled", datatextName, "1")
            end
            if pfUI.moredatatexts.settings[datatextName] and C.moredatatexts.enabled[datatextName] == "1" then
                CreateConfig(nil, datatextName .. " " .. T["Datatext Settings"], nil, nil, "header")

                for _, setting in ipairs(pfUI.moredatatexts.settings[datatextName]) do
                    if setting.type == "checkbox" then
                        CreateConfig(U["moredatatexts"], setting.label, C.moredatatexts[datatextName], setting.name,
                            "checkbox")
                    elseif setting.type == "dropdown" then
                        local dropdownTable = {}
                        for _, option in ipairs(setting.options) do
                            table.insert(dropdownTable, option.value .. ":" .. option.label)
                        end
                        CreateConfig(U["moredatatexts"], setting.label, C.moredatatexts[datatextName], setting.name,
                            "dropdown", dropdownTable)
                    elseif setting.type == "text" then
                        CreateConfig(U["moredatatexts"], setting.label, C.moredatatexts[datatextName], setting.name,
                            "text")
                    end
                end
            end
        end

        CreateConfig(nil, T["More Datatexts Version: 1.0"], nil, nil, "header")
        CreateConfig(nil, T["Website"], nil, nil, "button", function()
            pfUI.chat.urlcopy.CopyText("https://github.com/Arthur-Helias/pfUI-MoreDatatexts")
        end)
    end)
end

local configFrame = CreateFrame("Frame")
configFrame:RegisterEvent("VARIABLES_LOADED")
configFrame:SetScript("OnEvent", function()
    InitializeDefaultValues()
    CreateGuiConfigEntries()

    local updateFrame = CreateFrame("Frame")
    updateFrame.timer = 0
    updateFrame:SetScript("OnUpdate", function()
        this.timer = this.timer + arg1
        if this.timer > 0.5 then
            if pfUI.moredatatexts and pfUI.moredatatexts.UpdateDropdowns then
                pfUI.moredatatexts:UpdateDropdowns()
            end
            this:SetScript("OnUpdate", nil)
        end
    end)
end)

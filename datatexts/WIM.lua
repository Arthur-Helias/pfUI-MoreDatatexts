setfenv(1, pfUI:GetEnvironment())

pfUI.moredatatexts:RegisterDatatext("WIM", function()
    if not IsAddOnLoaded("WIM") then
        pfUI.moredatatexts:UnregisterDatatext("WIM")
        return
    end

    local datatext = CreateFrame("Frame", "pfmdWIMDatatext", UIParent)

    local flashState = false
    local flashTimer = 0
    local lastMessageCount = 0
    local lastMessageFlag = false

    local function GetConversationCount()
        local count = 0
        if WIM_Windows then
            for _ in pairs(WIM_Windows) do
                count = count + 1
            end
        end
        return count
    end

    local function UpdateWIM()
        if not C or not C.moredatatexts or not C.moredatatexts.WIM then
            pfUI.panel:OutputPanel("WIM", "", datatext.Tooltip, datatext.Click)
            return
        end

        local messageCount = WIM_NewMessageCount or 0
        local hasNewMessages = WIM_NewMessageFlag or false

        if messageCount ~= lastMessageCount or hasNewMessages ~= lastMessageFlag then
            lastMessageCount = messageCount
            lastMessageFlag = hasNewMessages
        end

        if messageCount == 0 then
            pfUI.panel:OutputPanel("WIM", "No New Messages", datatext.Tooltip, datatext.Click)
            return
        end

        local color = "|cffffffff"
        if hasNewMessages then
            if flashState then
                color = "|cffedc300"
            else
                color = "|cffffffff"
            end
        else
            color = "|cff888888"
        end

        local wimText = string.format("WIM: %s%d|r", color, messageCount)
        pfUI.panel:OutputPanel("WIM", wimText, datatext.Tooltip, datatext.Click)
    end

    datatext.Tooltip = function()
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, this)
        GameTooltip:AddLine("|cff555555WoW Instant Messenger (v" .. WIM_VERSION .. ")")
        if WIM_ConversationMenu then
            GameTooltip:AddDoubleLine("Conversations", "|cffffffff" .. GetConversationCount())
            GameTooltip:AddLine(" ")
        end
        GameTooltip:AddDoubleLine("Left Click", "|cffffffffShow Conversations")
        GameTooltip:AddDoubleLine("Right Click", "|cffffffffShow New Messages")
        GameTooltip:AddDoubleLine("Ctrl-Click", "|cffffffffWIM Options")
        GameTooltip:Show()
    end

    datatext.Click = function()
        if IsControlKeyDown() and arg1 == "LeftButton" then
            if SlashCmdList["WIM"] then
                SlashCmdList["WIM"]("")
            end
            return
        end

        if arg1 == "LeftButton" then
            if WIM_ConversationMenu then
                if WIM_ConversationMenu:IsVisible() then
                    WIM_ConversationMenu:Hide()
                else
                    WIM_ConversationMenu:ClearAllPoints()
                    WIM_ConversationMenu:SetPoint("BOTTOM", this, "TOP", 0, 0)
                    WIM_ConversationMenu:Show()
                end
            end
            return
        end

        if arg1 == "RightButton" then
            WIM_ShowNewMessages()
            return
        end
    end

    datatext:SetScript("OnUpdate", function()
        flashTimer = flashTimer + arg1
        if flashTimer >= 0.5 then
            flashTimer = 0
            flashState = not flashState
            UpdateWIM()
        end
    end)

    UpdateWIM()
end)

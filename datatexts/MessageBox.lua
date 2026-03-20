setfenv(1, pfUI:GetEnvironment())

pfUI.moredatatexts:RegisterDatatext("MessageBox", function()
    if not IsAddOnLoaded("MessageBox") then
        pfUI.moredatatexts:UnregisterDatatext("MessageBox")
        return
    end

    local datatext = CreateFrame("Frame", "pfmdMessageBoxDatatext", UIParent)

    local updateTimer = 0
    local lastTotal = 0
    local unreadMenu = nil

    local function GetTotalUnread()
        local total = 0
        if MessageBox and MessageBox.unreadCounts then
            for _, count in pairs(MessageBox.unreadCounts) do
                if count and count > 0 then
                    total = total + count
                end
            end
        end
        return total
    end

    local function GetClassColoredName(name)
        local cache = MessageBox.settings and MessageBox.settings.classCache and MessageBox.settings.classCache[name]
        if cache and cache.classUpper and RAID_CLASS_COLORS and RAID_CLASS_COLORS[cache.classUpper] then
            local c = RAID_CLASS_COLORS[cache.classUpper]
            return string.format("|cff%02x%02x%02x%s|r", c.r * 255, c.g * 255, c.b * 255, name)
        end
        return name
    end

    local function ToggleUnreadMenu(anchor)
        if unreadMenu and unreadMenu:IsVisible() then
            unreadMenu:Hide()
            return
        end

        local total = GetTotalUnread()
        if total == 0 then
            MessageBox:ToggleFrame()
            return
        end

        if not unreadMenu then
            local f = CreateFrame("Frame", "pfmdMBUnreadMenu", UIParent)
            f:SetWidth(150)
            f:SetFrameStrata("FULLSCREEN_DIALOG")
            f:SetToplevel(true)
            CreateBackdrop(f)

            local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            title:SetPoint("TOP", f, "TOP", 0, -8)
            title:SetText("|cffffffffUnread Messages")
            f.title = title

            f.rows = {}
            unreadMenu = f
        end

        for _, row in ipairs(unreadMenu.rows) do row:Hide() end

        local titleHeight = 22
        local index = 0
        for name, count in pairs(MessageBox.unreadCounts) do
            if count and count > 0 then
                index = index + 1
                local row = unreadMenu.rows[index]
                if not row then
                    row = CreateFrame("Button", nil, unreadMenu)
                    row:SetHeight(20)
                    row:SetWidth(140)
                    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")

                    local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    text:SetPoint("LEFT", row, "LEFT", 5, 0)
                    text:SetJustifyH("LEFT")
                    row.text = text

                    local countText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    countText:SetPoint("RIGHT", row, "RIGHT", -5, 0)
                    row.countText = countText

                    row:SetScript("OnClick", function()
                        MessageBox:SelectContact(this.contactName)
                        MessageBox:ShowFrame()
                        unreadMenu:Hide()
                    end)

                    unreadMenu.rows[index] = row
                end

                row.contactName = name
                row.text:SetText(GetClassColoredName(name))
                row.countText:SetText(count)
                row:SetPoint("TOPLEFT", unreadMenu, "TOPLEFT", 5, -5 - titleHeight - ((index - 1) * 20))
                row:Show()
            end
        end

        unreadMenu:SetHeight((index * 20) + titleHeight + 10)
        unreadMenu:ClearAllPoints()
        local _, y = anchor:GetCenter()
        if y and y > UIParent:GetHeight() / 2 then
            unreadMenu:SetPoint("TOP", anchor, "BOTTOM", 0, -5)
        else
            unreadMenu:SetPoint("BOTTOM", anchor, "TOP", 0, 5)
        end
        unreadMenu:Show()
    end

    local function UpdateMB()
        if not C or not C.moredatatexts then
            pfUI.panel:OutputPanel("MessageBox", "", datatext.Tooltip, datatext.Click)
            return
        end

        local total = GetTotalUnread()

        if total ~= lastTotal then
            lastTotal = total
        end

        if total == 0 then
            pfUI.panel:OutputPanel("MessageBox", "|cff3cb7f0Message|cffffffffBox: 0", datatext.Tooltip, datatext.Click)
            return
        end

        local text = string.format("|cff3cb7f0Message|cffffffffBox: %d|r", total)
        pfUI.panel:OutputPanel("MessageBox", text, datatext.Tooltip, datatext.Click)
    end

    datatext.Tooltip = function()
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, this)
        GameTooltip:AddLine("|cff3cb7f0Message|cffffffffBox")

        local hasUnread = false
        if MessageBox and MessageBox.unreadCounts then
            for name, count in pairs(MessageBox.unreadCounts) do
                if count and count > 0 then
                    hasUnread = true
                    GameTooltip:AddDoubleLine(GetClassColoredName(name), "|cffffffff" .. count)
                end
            end
        end

        if not hasUnread then
            GameTooltip:AddLine("|cff888888No unread messages")
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("Left Click", "|cffffffffToggle MessageBox")
        GameTooltip:AddDoubleLine("Right Click", "|cffffffffUnread Messages")
        GameTooltip:Show()
    end

    datatext.Click = function()
        this:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        if arg1 == "LeftButton" then
            if unreadMenu and unreadMenu:IsVisible() then
                unreadMenu:Hide()
            end
            MessageBox:ToggleFrame()
        elseif arg1 == "RightButton" then
            ToggleUnreadMenu(this)
        end
    end

    datatext:SetScript("OnUpdate", function()
        updateTimer = updateTimer + arg1
        if updateTimer >= 0.5 then
            updateTimer = 0
            UpdateMB()
        end
    end)

    UpdateMB()
end)

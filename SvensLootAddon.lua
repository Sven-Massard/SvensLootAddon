SvensLootAddon = LibStub("AceAddon-3.0"):NewAddon("SvensLootAddon", "AceConsole-3.0", "AceEvent-3.0")

local localAddon = SvensLootAddon

function localAddon:OnEnable()
    self:RegisterEvent("CHAT_MSG_LOOT")
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SLA_suppressWhisperMessage)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", SLA_suppressLootMessage)
end

function localAddon:OnDisable()
    -- Called when the addon is disabled
end

function localAddon:OnInitialize()
    MinimapIcon = nil -- Needs to be initialized to be saved
    self:loadAddon() -- in SvensLootAddonConfig.lua
    self:RegisterChatCommand("sla", "SlashCommand")
end

function localAddon:CHAT_MSG_LOOT(_, msg, ...)
    if not self:isMessageStartingWithLootItemSelfString(msg) then
        return
    end

    local itemLink, amount = self:extractItemLinkAndAmount(msg)
    local itemsToTrackList = self.db.char.itemsToTrack
    local nameOfFoundItem, _ = GetItemInfo(itemLink)
    for i = 1, #itemsToTrackList do
        if (nameOfFoundItem == itemsToTrackList[i]) then
            local timesItemFound = self:addToLootList(itemLink, amount)
            local outputMessage = self.db.char.outputMessage
            local itemLinkWithoutAmount = select(2, GetItemInfo(itemLink))
            self:send_messages_from_outputChannelList(outputMessage, itemLinkWithoutAmount, timesItemFound, false)
            break
        end
    end
end

function localAddon:send_messages_from_outputChannelList(message, itemName, timesItemFound, isReport)
    local timeStamp = self.db.char.timeStamp
    local output = message:gsub("(IN)", itemName):gsub("(I#)", timesItemFound):gsub("(TS)", timeStamp) -- Keep same as in print except for color code
    for k, v in pairs(self.db.char.outputChannelList) do
        if v == true then
            if k == "Print" then
                _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. output)
            elseif (k == "Say" or k == "Yell") then
                local inInstance, _ = IsInInstance()
                if (inInstance) then
                    SendChatMessage(output, k);
                end
            elseif (k == "Battleground") then
                local _, instanceType = IsInInstance()
                if (instanceType == "pvp") then
                    SendChatMessage(output, "INSTANCE_CHAT")
                end
            elseif (k == "Officer") then
                if (CanEditOfficerNote()) then
                    SendChatMessage(output, k)
                end
            elseif (k == "Raid" or v == "Raid_Warning") then
                if IsInRaid() then
                    SendChatMessage(output, k);
                end
            elseif (k == "Party") then
                if IsInGroup() then
                    SendChatMessage(output, k);
                end
            elseif (k == "Whisper") then
                for _, w in pairs(self.db.char.whisperList) do
                    SendChatMessage(output, "WHISPER", "COMMON", w)
                end
            elseif (k == "battleNetWhisper") then
                for _, w in pairs(self.db.char.battleNetWhisperBattleNetTagToId) do
                    BNSendWhisper(w, output)
                end
            elseif (k == "battleNetWhisper") then
                for _, w in pairs(self.db.char.whisperList) do
                    SendChatMessage(output, "WHISPER", "COMMON", w)
                end
            elseif (k == "Train_emote" and not isReport) then
                DoEmote("train");
            else
                SendChatMessage(output, k);
            end
        end
    end
end

-- Function for event filter for CHAT_MSG_SYSTEM to suppress message of player on whisper list being offline when being whispered to
function SLA_suppressWhisperMessage(_, _, msg, _, ...)
    -- TODO Suppression only works for Portuguese, English, German and French because they have the same naming format.
    -- See https://www.townlong-yak.com/framexml/live/GlobalStrings.lua
    local textWithoutName = msg:gsub("%'%a+%'", ""):gsub("  ", " ")

    localizedPlayerNotFoundStringWithoutName = ERR_CHAT_PLAYER_NOT_FOUND_S:gsub("%'%%s%'", ""):gsub("  ", " ")
    if not (textWithoutName == localizedPlayerNotFoundStringWithoutName) then
        return false
    end

    local name = string.gmatch(msg, "%'%a+%'")

    -- gmatch returns iterator.
    for w in name do
        name = w
    end
    if not (name == nil) then
        name = name:gsub("'", "")
    else
        return false
    end

    local isNameInWhisperList = false
    for _, w in pairs(localAddon.db.char.whisperList) do
        if (w == name) then
            isNameInWhisperList = true
        end
    end
    return isNameInWhisperList
end

function SLA_suppressLootMessage(_, _, msg, _, ...)
    if not localAddon:isMessageStartingWithLootItemSelfString(msg) or not localAddon.db.char.suppressLootMessage then
        return false
    end

    local itemLink, _ = localAddon:extractItemLinkAndAmount(msg)
    if localAddon:isItemInItemsToTrackList(itemLink) then
        return true
    end

    return false
end

function localAddon:SlashCommand(msg)
    if (msg == "help" or msg == "") then
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Possible parameters:")
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "list: Lists loot list")
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "report: Report loot list")
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "clear: Delete loot list. Also resets time stamp.")
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "config: Opens config page")
    elseif (msg == "list") then
        self:listLootList();
    elseif (msg == "report") then
        self:reportLootList();
    elseif (msg == "clear") then
        self:clearLootList();
    elseif (msg == "config") then
        -- For some reason, needs to be called twice to function correctly on first call
        InterfaceOptionsFrame_OpenToCategory(self.mainOptionsFrame)
    elseif (msg == "test") then
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Function not implemented")
    else
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Error: Unknown command")
    end
end

function localAddon:extractItemLinkAndAmount(msg)
    -- The LOOT_ITEM_SELF string in Retail and Classic differs by having a full stop at the end.
    -- https://www.townlong-yak.com/framexml/live/GlobalStrings.lua
    -- https://www.townlong-yak.com/framexml/classic/GlobalStrings.lua
    -- https://www.townlong-yak.com/framexml/era/GlobalStrings.lua
    local itemLink = string.match(msg, "|c.-|h|r")
    local amount = string.match(msg, "x(%d+)%.*$") or 1

    return itemLink, amount
end

function localAddon:isMessageStartingWithLootItemSelfString(msg)
    -- Remove item placeholder
    local lootString = LOOT_ITEM_SELF:gsub("%%s", ""):gsub("%.$", "")
    -- Check if message substring from index 1 to number of letters in lootString equals lootString
    if string.sub(msg, 1, #lootString) == lootString then
        return true
    end
    return false
end
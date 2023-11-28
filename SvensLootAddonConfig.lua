local localAddon = SvensLootAddon

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDatabase = LibStub("AceDB-3.0")

local defaults = {
    char = {
        outputMessage = "Found IN!",
        outputChannelList = {
            Say = false,
            Yell = false,
            Print = true,
            Guild = false,
            Raid = false,
            Emote = false,
            Party = false,
            Officer = false,
            Raid_Warning = false,
            Battleground = false,
            Whisper = false,
            battleNetWhisper = false,
            Train_emote = false,
        },
        whisperList = {},
        battleNetWhisperBattleNetTagToId = {},
        chatFrameName = COMMUNITIES_DEFAULT_CHANNEL_NAME,
        chatFrameIndex = 1,
        color = "|cff" .. "94" .. "CF" .. "00",
        minimap = { hide = false, },

        timeStamp = date(),
        itemsToTrack = {},
        foundItems = {},
        suppressLootMessage = false,
        isMigratedToAce = false
    }
}

local mainOptions = { -- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
    name = "will be replaced",
    type = "group",
    args = {
        mainDescription = {
            type = "description",
            fontSize = "medium",
            name = "will be replaced"
        },
    }
}
local generalOptions = { -- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
    name = "",
    type = "group",
    args = {
        itemListInput = {
            order = 1,
            type = "input",
            name = "to be replaced",
            multiline = true,
            width = "double",
            desc = "Put each item you want to track on a new line.",
            get = function(_)
                local listAsString = ""
                for _, v in pairs(localAddon.db.char.itemsToTrack) do
                    listAsString = listAsString .. v .. "\n"
                end
                return listAsString
            end,
            set = function(_, value)
                localAddon.db.char.itemsToTrack = {}
                for arg in string.gmatch(value, "[^\r\n]+") do
                    if (string.match(arg, "^|c%x+|Hitem:%d+:") ~= nil) then
                        local itemName = select(1, GetItemInfo(arg))
                        table.insert(localAddon.db.char.itemsToTrack, itemName)
                    else
                        table.insert(localAddon.db.char.itemsToTrack, arg)
                    end
                end
            end
        },

        chatFrameNameInput = {
            order = 10,
            type = "input",
            name = "to be replaced",
            width = "full",
            desc = "Define Channel Frame you want SvensLootAddon to print to",
            get = function(_)
                return localAddon.db.char.chatFrameName
            end,
            set = function(_, value)
                local isValidName = localAddon:setIndexOfChatFrame(value)
                if (isValidName) then
                    localAddon.db.char.chatFrameName = value
                else
                    _G["ChatFrame" .. localAddon.db.char.chatFrameIndex]:AddMessage(localAddon.db.char.color .. "Could not find channel name!")
                end
            end
        },

        placeholderDescriptionOutputMessage = {
            order = 20,
            type = "description",
            name = ""
        },

        outputMessageOption = {
            order = 30,
            type = "input",
            width = "full",
            name = "will be replaced",
            desc = "Insert your message here.\nIN will be replaced with item name.\nI# will be replaced with amount of times item was found\nTS will be replaced with time stamp since recording/loot list reset",
            get = function(_)
                return localAddon.db.char.outputMessage
            end,
            set = function(_, value)
                localAddon.db.char.outputMessage = value
            end
        },
        placeholderDescription1 = {
            order = 40,
            type = "description",
            name = ""
        },
        otherOptionsDescription = {
            order = 50,
            type = "description",
            name = "will be replaced"
        },
        placeholderDescription12 = {
            order = 51,
            type = "description",
            name = ""
        },
        suppressLootMessageCheckbox = {
            order = 52,
            type = "toggle",
            name = "Suppress Loot Message of tracked items",
            get = function(_)
                return localAddon.db.char.suppressLootMessage
            end,
            set = function(_, value)
                localAddon.db.char.suppressLootMessage = value
            end
        },
        --miniMapButtonCheckbox = {
        --    order = 55,
        --    type = "toggle",
        --    name = "Show Minimap Button",
        --    get = function(_)
        --        return not localAddon.db.char.minimap.hide
        --    end,
        --    set = function(_, value)
        --        localAddon.db.char.minimap.hide = not value
        --        if (value) then
        --            icon:Show("SvensLootAddon_dataObject")
        --        else
        --            icon:Hide("SvensLootAddon_dataObject")
        --        end
        --    end
        --},
        placeholderDescription69 = {
            order = 69,
            type = "description",
            name = ""
        },
        fontColorDescription = {
            order = 70,
            type = "description",
            name = "will be replaced"
        },
        placeholderDescription71 = {
            order = 71,
            type = "description",
            name = ""
        },
        redColorSlider = {
            order = 72,
            type = "range",
            width = "double",
            name = "Red",
            min = 0,
            max = 255,
            step = 1,
            get = function(_)
                return tonumber("0x" .. localAddon.db.char.color:sub(5, 6))
            end,
            set = function(_, value)
                local rgb = {
                    { color = "Red", value = localAddon.db.char.color:sub(5, 6) },
                    { color = "Green", value = localAddon.db.char.color:sub(7, 8) },
                    { color = "Blue", value = localAddon.db.char.color:sub(9, 10) }
                }
                rgbValue = localAddon:convertRGBDecimalToRGBHex(value)
                localAddon.db.char.color = "|cff" .. rgbValue .. rgb[2].value .. rgb[3].value
                localAddon:setPanelTexts()
            end
        },
        placeholderDescription73 = {
            order = 73,
            type = "description",
            name = ""
        },
        greenColorSlider = {
            order = 74,
            type = "range",
            width = "double",
            name = "Green",
            min = 0,
            max = 255,
            step = 1,
            get = function(_)
                return tonumber("0x" .. localAddon.db.char.color:sub(7, 8))
            end,
            set = function(_, value)
                local rgb = {
                    { color = "Red", value = localAddon.db.char.color:sub(5, 6) },
                    { color = "Green", value = localAddon.db.char.color:sub(7, 8) },
                    { color = "Blue", value = localAddon.db.char.color:sub(9, 10) }
                }
                rgbValue = localAddon:convertRGBDecimalToRGBHex(value)
                localAddon.db.char.color = "|cff" .. rgb[1].value .. rgbValue .. rgb[3].value
                localAddon:setPanelTexts()
            end
        },
        placeholderDescription75 = {
            order = 75,
            type = "description",
            name = ""
        },
        blueColorSlider = {
            order = 76,
            type = "range",
            width = "double",
            name = "Blue",
            min = 0,
            max = 255,
            step = 1,
            get = function(_)
                return tonumber("0x" .. localAddon.db.char.color:sub(9, 10))
            end,
            set = function(_, value)
                local rgb = {
                    { color = "Red", value = localAddon.db.char.color:sub(5, 6) },
                    { color = "Green", value = localAddon.db.char.color:sub(7, 8) },
                    { color = "Blue", value = localAddon.db.char.color:sub(9, 10) }
                }
                rgbValue = localAddon:convertRGBDecimalToRGBHex(value)
                localAddon.db.char.color = "|cff" .. rgb[1].value .. rgb[2].value .. rgbValue
                localAddon:setPanelTexts()
            end
        }
    },
}
local channelOptions = { -- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
    name = "replacedByColorString",
    type = "group",
    args = {
        sayCheckbox = {
            order = 0,
            type = "toggle",
            name = "Say",
            desc = "Only works in instances",
            get = function(_)
                return localAddon.db.char.outputChannelList.Say
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Say = value
            end
        },
        placeholderDescription1 = {
            order = 1,
            type = "description",
            name = ""
        },
        yellCheckbox = {
            order = 2,
            type = "toggle",
            name = "Yell",
            desc = "Only works in instances",
            get = function(_)
                return localAddon.db.char.outputChannelList.Yell
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Yell = value
            end
        },
        placeholderDescription2 = {
            order = 3,
            type = "description",
            name = ""
        },
        printCheckbox = {
            order = 4,
            type = "toggle",
            name = "Print",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Print
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Print = value
            end
        },
        placeholderDescription4 = {
            order = 7,
            type = "description",
            name = ""
        },
        guildCheckbox = {
            order = 8,
            type = "toggle",
            name = "Guild",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Guild
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Guild = value
            end
        },
        placeholderDescription5 = {
            order = 9,
            type = "description",
            name = ""
        },
        raidCheckbox = {
            order = 10,
            type = "toggle",
            name = "Raid",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Raid
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Raid = value
            end
        },
        placeholderDescription6 = {
            order = 11,
            type = "description",
            name = ""
        },
        emoteCheckbox = {
            order = 12,
            type = "toggle",
            name = "Emote",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Emote
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Emote = value
            end
        },
        placeholderDescription7 = {
            order = 13,
            type = "description",
            name = ""
        },
        partyCheckbox = {
            order = 14,
            type = "toggle",
            name = "Party",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Party
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Party = value
            end
        },
        placeholderDescription8 = {
            order = 15,
            type = "description",
            name = ""
        },
        officerCheckbox = {
            order = 16,
            type = "toggle",
            name = "Officer",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Officer
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Officer = value
            end
        },
        placeholderDescription9 = {
            order = 17,
            type = "description",
            name = ""
        },
        raidWarningCheckbox = {
            order = 18,
            type = "toggle",
            name = "Raid Warning",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Raid_Warning
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Raid_Warning = value
            end
        },
        placeholderDescription10 = {
            order = 19,
            type = "description",
            name = ""
        },
        battlegroundCheckbox = {
            order = 20,
            type = "toggle",
            name = "Battleground",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Battleground
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Battleground = value
            end
        },
        placeholderDescription11 = {
            order = 21,
            type = "description",
            name = ""
        },
        whisperCheckbox = {
            order = 22,
            type = "toggle",
            name = "Whisper",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Whisper
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Whisper = value
            end
        },
        whisperListInput = {
            order = 23,
            type = "input",
            name = "Set Friends to Whisper to",
            multiline = true,
            width = "double",
            desc = "Put each name you want to whisper to on a new line.",
            get = function(_)
                local listAsString = ""
                for _, v in pairs(localAddon.db.char.whisperList) do
                    listAsString = listAsString .. v .. "\n"
                end
                return listAsString
            end,
            set = function(_, value)
                localAddon.db.char.whisperList = {}
                for arg in string.gmatch(value, "[^\r\n]+") do
                    table.insert(localAddon.db.char.whisperList, arg)
                end
            end
        },
        placeholderDescription12 = {
            order = 24,
            type = "description",
            name = ""
        },
        battleNetwhisperCheckbox = {
            order = 25,
            type = "toggle",
            name = "Whisper Bnet Name",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.battleNetWhisper
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.battleNetWhisper = value
            end
        },
        battleNetWhisperListInput = {
            order = 26,
            type = "input",
            name = "Set Battle.net Friends to Whisper to",
            multiline = true,
            width = "double",
            desc = "Put each battle net tag of people in your friend list on a new line.\n",
            get = function(_)
                local listAsString = ""
                for k, _ in pairs(localAddon.db.char.battleNetWhisperBattleNetTagToId) do
                    listAsString = listAsString .. k .. "\n"
                end
                return listAsString
            end,
            set = function(_, value)
                local bnetWhisperList = {}
                for arg in string.gmatch(value, "[^\r\n]+") do
                    bnetWhisperList[arg] = true
                end

                local isAboveClassic = (tonumber(select(4, GetBuildInfo())) > 82000)

                local numBNetTotal, _, _, _ = BNGetNumFriends()
                localAddon.db.char.battleNetWhisperBattleNetTagToId = {}
                for i = 1, numBNetTotal do
                    if (not isAboveClassic) then
                        bnetIDAccount, _, battleTag, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ = BNGetFriendInfo(i)
                    else
                        local acc = C_BattleNet.GetFriendAccountInfo(i)
                        bnetIDAccount = acc.bnetAccountID
                        battleTag = acc.battleTag
                    end
                    --local accountName = battleTag:gsub("(.*)#.*$", "%1")
                    if (bnetWhisperList[battleTag] == true) then
                        localAddon.db.char.battleNetWhisperBattleNetTagToId[battleTag] = bnetIDAccount;
                    end
                end

                for k, _ in pairs(bnetWhisperList) do
                    if (localAddon.db.char.battleNetWhisperBattleNetTagToId[k] == nil) then
                        _G["ChatFrame" .. localAddon.db.char.chatFrameIndex]:AddMessage(localAddon.db.char.color .. "Bnet account name " .. k .. " not found.")
                    end
                end
            end
        },
        placeholderDescription14 = {
            order = 33,
            type = "description",
            name = ""
        },
        trainEmoteCheckbox = {
            order = 34,
            type = "toggle",
            name = "Do Train Emote",
            descStyle = "",
            get = function(_)
                return localAddon.db.char.outputChannelList.Train_emote
            end,
            set = function(_, value)
                localAddon.db.char.outputChannelList.Train_emote = value
            end
        },
    }
}

function localAddon:loadAddon()
    self.db = AceDatabase:New("SvensLootAddonDB", defaults)
    AceConfig:RegisterOptionsTable("SvensLootAddon_MainOptions", mainOptions)
    AceConfig:RegisterOptionsTable("SvensLootAddon_GeneralOptions", generalOptions)
    AceConfig:RegisterOptionsTable("SvensLootAddon_ChannelOptions", channelOptions)
    self.mainOptionsFrame = AceConfigDialog:AddToBlizOptions("SvensLootAddon_MainOptions", "Svens Loot Addon")   -- https://www.wowace.com/projects/ace3/pages/api/ace-config-dialog-3-0
    AceConfigDialog:AddToBlizOptions("SvensLootAddon_GeneralOptions", "General options", "Svens Loot Addon")
    AceConfigDialog:AddToBlizOptions("SvensLootAddon_ChannelOptions", "Channel options", "Svens Loot Addon")

    self:setPanelTexts()

    self:realignBattleNetTagToId()

    if (not self.db.char.isMigratedToAce) then
        self:migrateToAce()
    end
end

function localAddon:convertRGBDecimalToRGBHex(decimal)
    local result
    local numbers = "0123456789ABCDEF"
    result = numbers:sub(1 + (decimal / 16), 1 + (decimal / 16)) .. numbers:sub(1 + (decimal % 16), 1 + (decimal % 16))
    return result
end

function localAddon:setPanelTexts()
    mainOptions.name = self.db.char.color .. "Choose sub menu to change options."
    mainOptions.args.mainDescription.name = self.db.char.color .. "Command line options:\n\n"
            .. "/sla list: lists highest crits of each spell.\n"
            .. "/sla report: report highest crits of each spell to channel list.\n"
            .. "/sla clear: delete list of highest crits.\n"
            .. "/sla config: Opens this config page."

    generalOptions.args.chatFrameNameInput.name = self.db.char.color .. "Item List"
    generalOptions.args.chatFrameNameInput.name = self.db.char.color .. "Chat Frame to print to"
    generalOptions.args.outputMessageOption.name = self.db.char.color .. "Output Message"
    generalOptions.args.otherOptionsDescription.name = self.db.char.color .. "Other Options"
    generalOptions.args.fontColorDescription.name = self.db.char.color .. "Change Color of Font"
    generalOptions.args.itemListInput.name = self.db.char.color .. "Items to track"
    channelOptions.name = self.db.char.color .. "Output Channel"
end

-- Taken and edited from BamModRevived on WoWInterface. Thanks to Sylen
-- We use this to get the index of our output channel
function localAddon:setIndexOfChatFrame(chatFrameName)
    for i = 1, NUM_CHAT_WINDOWS do
        local chatWindowName = GetChatWindowInfo(i)
        if chatWindowName == chatFrameName then
            self.db.char.chatFrameIndex = i
            return true
        end
    end
    return false
end

function localAddon:realignBattleNetTagToId()
    local numBNetTotal, _, _, _ = BNGetNumFriends()
    local isAboveClassic = select(4, GetBuildInfo()) > 82000

    for i = 1, numBNetTotal do
        local bnetIDAccount, battleTag
        if (not isAboveClassic) then
            bnetIDAccount, _, battleTag, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ = BNGetFriendInfo(i)
        else
            local acc = C_BattleNet.GetFriendAccountInfo(i)
            bnetIDAccount = acc.bnetAccountID
            battleTag = acc.battleTag
        end
        --local accountName = battleTag:gsub("(.*)#.*$", "%1")
        if (localAddon.db.char.battleNetWhisperBattleNetTagToId[battleTag] ~= nil) then
            localAddon.db.char.battleNetWhisperBattleNetTagToId[battleTag] = bnetIDAccount;
        end
    end
end

function localAddon:migrateToAce()
    self:Print("Migrating database for Svens Loot Addon. You should see this message only once.")

    if (SLA_itemsToTrackList ~= nil) then
        self.db.char.itemsToTrack = SLA_itemsToTrackList
    end
    self:Print("Successfully migrated tracked items list")

    if (SLA_foundItemsList ~= nil) then
        self.db.char.foundItems = SLA_foundItemsList
        self:Print("Successfully migrated found items list")
    end

    if (SLA_whisperList ~= nil) then
        self.db.char.whisperList = SLA_whisperList
        self:Print("Successfully migrated whisper list")
    end

    if (SLA_output_message ~= nil) then
        self.db.char.outputMessage = SLA_output_message
        self:Print("Successfully migrated output message")
    end

    if (SLA_color ~= nil) then
        self.db.char.color = SLA_color
        self:Print("Successfully migrated color")
    end

    if (SLA_timeStamp ~= nil) then
        self.db.char.timeStamp = SLA_timeStamp
        self:Print("Successfully migrated timestamp")
    end

    --migrate outputChannelList
    local oldChannelList = SLA_outputChannelList
    if (oldChannelList ~= nil) then
        local newChannelList = self.db.char.outputChannelList
        if (oldChannelList["Say"] ~= nil) then
            newChannelList.Say = true;
        end
        if (oldChannelList["Yell"] ~= nil) then
            newChannelList.Yell = true;
        end
        if (oldChannelList["Print"] ~= nil) then
            newChannelList.Print = true;
        end
        if (oldChannelList["Guild"] ~= nil) then
            newChannelList.Guild = true;
        end
        if (oldChannelList["Raid"] ~= nil) then
            newChannelList.Raid = true;
        end
        if (oldChannelList["Emote"] ~= nil) then
            newChannelList.Emote = true;
        end
        if (oldChannelList["Party"] ~= nil) then
            newChannelList.Party = true;
        end
        if (oldChannelList["Officer"] ~= nil) then
            newChannelList.Officer = true;
        end
        if (oldChannelList["Raid_Warning"] ~= nil) then
            newChannelList.Raid_Warning = true;
        end
        if (oldChannelList["Battleground"] ~= nil) then
            newChannelList.Battleground = true;
        end
        if (oldChannelList["Whisper"] ~= nil) then
            newChannelList.Whisper = true;
        end
        self:Print("Successfully migrated output channel list")
    end

    self.db.char.isMigratedToAce = true
    self:Print("Finished migrating database for Svens Loot Addon. You should see this message only once.")

end
local _,ns = ...
SLA = ns

-- Function for event filter for CHAT_MSG_SYSTEM to suppress message of player on whisper list being offline when being whispered to
function SLA_suppressWhisperMessage(self, event, msg, author, ...)
	-- TODO Suppression only works for Portugese, English, German and French because they have the same naming format.
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
	for _, w in pairs(SLA_whisperList) do
		if(w == name) then
			isNameInWhisperList = true
		end
	end
	return isNameInWhisperList

end

function SLA:OnLoad(self)
    SlashCmdList["SLA"] = function(cmd)
	    local params = {}
        local i = 1
        for arg in string.gmatch(cmd, "%S+") do
            params[i] = arg
            i = i + 1
        end
        SLA:slash_cmd(params)
    end

    SLASH_SLA1 = '/sla'
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("CHAT_MSG_LOOT")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SLA_suppressWhisperMessage)
	
end

function SLA:eventHandler(self, event, ...)
	
    if event == "CHAT_MSG_LOOT" then

		local msg, player = ...

		local LootString = LOOT_ITEM_SELF:gsub("%%s.", "")

		for i=1, # SLA_itemsToTrackList do 
			-- Thanks to EasyLoot for strmatch
			if(true) then -- strmatch(msg, LootString..".*"..SLA_itemsToTrackList[i]..".*")
				local ItemLink = msg:gsub(LootString, ""):gsub("%.", "")
				local timesItemFound = SLA:AddToLootList(ItemLink)
				SLA:send_messages_from_outputChannelList(SLA_output_message, ItemLink, timesItemFound)
			end
		end
		
    elseif event == "ADDON_LOADED" then
		local addonName = ...
		if (addonName == "SvensLootAddon") then
			SLA:loadAddon()
		end

    end
end

function SLA:send_messages_from_outputChannelList(message, itemName, timesItemFound)
			local output = message:gsub("(IN)", itemName):gsub("(I#)", timesItemFound)
            for _, v in pairs(SLA_outputChannelList) do
                if v == "Print" then
                    print(SLA_color..message:gsub("(IN)", itemName..SLA_color):gsub("(I#)", timesItemFound))
                elseif (v == "Whisper") then
                    for _, w in pairs(SLA_whisperList) do
						SendChatMessage(output, "WHISPER", "COMMON", w)
                    end
		--		elseif (v == "Sound DMG") then
				--	SBM:playRandomSoundFromList(SBM_soundfileDamage)
					
				elseif (v == "Battleground") then
					inInstance, instanceType = IsInInstance()
					if(instanceType == "pvp") then
						SendChatMessage(output, "INSTANCE_CHAT" )
					end
				elseif (v == "Officer") then
					if (CanEditOfficerNote()) then
						SendChatMessage(output ,v )
					end
				elseif (v == "Say" or v == "Yell") then
					local inInstance, instanceType = IsInInstance()
					if(inInstance) then
						SendChatMessage(output ,v );
					end
                else
                    SendChatMessage(output ,v );
                end
            end
end

function SLA:slash_cmd(params)
    cmd = params[1]
    local firstVariable=2
    if(cmd == "help" or cmd == "") then
        print(SLA_color.."Possible parameters:")
        print(SLA_color.."list: lists loot list")
		print(SLA_color.."report: report loot list")
        print(SLA_color.."clear: delete loot list")
		print(SLA_color.."config: Opens config page")
    elseif(cmd == "list") then
        SLA:listLootList();
	elseif(cmd == "report") then
        SLA:reportLootList();
    elseif(cmd == "clear") then
        SLA:clearLootList();
    elseif(cmd == "config") then
		-- For some reason, needs to be called twice to function correctly on first call
		InterfaceOptionsFrame_OpenToCategory(SvensLootAddonConfig.panel)
		InterfaceOptionsFrame_OpenToCategory(SvensLootAddonConfig.panel)
	elseif(cmd == "test") then
		print(SLA_color.."Function not implemented")
    else
        print(SLA_color.."SLA Error: Unknown command. Type /sla help for list of commands.")
    end   
end
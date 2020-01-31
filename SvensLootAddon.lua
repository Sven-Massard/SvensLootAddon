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
    SlashCmdList["SLA"] = function()
		InterfaceOptionsFrame_OpenToCategory(SvensLootAddonConfig.panel)
		InterfaceOptionsFrame_OpenToCategory(SvensLootAddonConfig.panel)
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
				SLA:Chat_Message_Loot_Event(ItemLink, timesItemFound)
			end
		end
		
    elseif event == "ADDON_LOADED" then
		local addonName = ...
		if (addonName == "SvensLootAddon") then
			SLA:loadAddon()
		end

    end
end

function SLA:Chat_Message_Loot_Event(itemName, timesItemFound)
			local output
				output = SLA_output_message:gsub("(IN)", itemName):gsub("(I#)", timesItemFound)
            for _, v in pairs(SLA_outputChannelList) do
                if v == "Print" then
                    print(SLA_color..output)
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
					print(v)
                    SendChatMessage(output ,v );
                end
            end

end
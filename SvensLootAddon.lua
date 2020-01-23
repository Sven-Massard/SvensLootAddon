local _,ns = ...
SLA = ns

function SLA:OnLoad(self)
    SlashCmdList["SLA"] = function()
		InterfaceOptionsFrame_OpenToCategory(SvensLootAddonConfig.panel)
		InterfaceOptionsFrame_OpenToCategory(SvensLootAddonConfig.panel)
	end
    SLASH_SLA1 = '/sla'
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("CHAT_MSG_LOOT")
end

function SLA:eventHandler(self, event, ...)
	
    if event == "CHAT_MSG_LOOT" then

		msg, player = ...

		for i=1, # SLA_itemList do 
			-- Thanks to EasyLoot for strmatch
			if(strmatch(msg, "You receive .*"..SLA_itemList[i]..".*")) then
				SLA:Chat_Message_Loot_Event(SLA_itemList[i])
			end
		end
		
    elseif event == "ADDON_LOADED" then
		local addonName = ...
		if (addonName == "SvensLootAddon") then
			SLA:loadAddon()
		end

    end
end

function SLA:Chat_Message_Loot_Event(itemName)
			local output
				output = SLA_output_message:gsub("(IN)", itemName)
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
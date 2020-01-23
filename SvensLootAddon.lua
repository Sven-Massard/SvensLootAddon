local _,ns = ...
SLA = ns

function SLA:OnLoad(self)
    SlashCmdList["SLA"] = function()
		print("MIAU")
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
				SLA:sendChatMessages(SLA_itemList[i])
			end
		end
		
    elseif event == "ADDON_LOADED" then
		local addonName = ...
		if (addonName == "SvensLootAddon") then
			SLA:loadAddon()
		end

    end
end

function SLA:sendChatMessages(itemName)
	for i=1, # SLA_whisperList do
		SendChatMessage("Hab "..itemName.." gelootet. yay...", "WHISPER", "COMMON", SLA_whisperList[i])
	end
end
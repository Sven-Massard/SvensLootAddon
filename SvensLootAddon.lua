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
				SendChatMessage("Hab "..SLA_itemList[i].." gelootet. yay...", "WHISPER", "COMMON", "Majima")
			end
		end
		
    elseif event == "ADDON_LOADED" then
		local addonName = ...
		if (addonName == "SvensLootAddon") then
			SLA:loadAddon()
		end

    end
end
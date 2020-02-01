function SLA:AddToLootList(itemLink)
	if(not SLA_foundItemsList) then
		SLA_foundItemsList = {}
	end
	
	local itemIndex = -1
	for i=1, # SLA_foundItemsList do
		if(SLA_foundItemsList[i][1] == itemLink) then
			SLA_foundItemsList[i][2] = SLA_foundItemsList[i][2] + 1
			itemIndex = i
			break
		end	
	end
	
	if (itemIndex == -1) then
		table.insert(SLA_foundItemsList, {itemLink, 1})
		return 1
	end
	
	return SLA_foundItemsList[itemIndex][2]
end

function SLA:clearLootList()
	SLA_foundItemsList = {}
	print(SLA_color.."Loot list cleared!")
end

function SLA:listLootList()
	if next(SLA_foundItemsList) == nil then
		print(SLA_color.."Loot list empty.")
	else
		print(SLA_color.."Loot report: ")
		for i=1, # SLA_foundItemsList do
			print(SLA_color.."Found "..SLA_foundItemsList[i][1].." in total "..SLA_foundItemsList[i][2].." times.")
		end
	end
end

function SLA:reportLootList()
	--SLA:send_messages_from_outputChannelList("Loot report", "", "")
	local message = "Found IN in total I# times."
	for i=1, # SLA_foundItemsList do
		SLA:send_messages_from_outputChannelList(message, SLA_foundItemsList[i][1], SLA_foundItemsList[i][2])
	end
end
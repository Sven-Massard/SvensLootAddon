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
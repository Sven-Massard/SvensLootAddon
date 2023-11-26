local localAddon = SvensLootAddon

function localAddon:addToLootList(itemLink)
    local foundItems = self.db.char.foundItems
    if (not self.db.char.timeStamp) then
        self.db.char.timeStamp = date()
    end

    local amountItem = 1

    if not (string.match(itemLink, ('x%d*$')) == nil) then
        amountItem = string.match(itemLink, ("%d*$"))
    end

    local itemIndex = -1
    local nameOfFoundItem, itemLinkWithoutAmount = GetItemInfo(itemLink)
    for i = 1, #foundItems do
        local nameOfCurrentItemInList = GetItemInfo(foundItems[i][1])

        if (nameOfCurrentItemInList == nameOfFoundItem) then
            foundItems[i][2] = foundItems[i][2] + amountItem
            itemIndex = i
            break
        end
    end

    if (itemIndex == -1) then
        table.insert(foundItems, { itemLinkWithoutAmount, amountItem })
        return amountItem
    end

    return foundItems[itemIndex][2]
end

function localAddon:clearLootList()
    self.db.char.foundItems = {}
    self.db.char.timeStamp = date()
    _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Loot list cleared!")
end

function localAddon:listLootList()
    local foundItems = self.db.char.foundItems
    if (foundItems == nil) or (next(foundItems) == nil) then
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Loot list empty.")
    else
        local timeStamp = self.db.char.timeStamp
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Loot report for items since " .. timeStamp .. ": ")
        for i = 1, #foundItems do
            _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Found " .. foundItems[i][1] .. " " .. foundItems[i][2] .. " times.")
        end
    end
end

function localAddon:reportLootList()
    local foundItems = self.db.char.foundItems
    if (foundItems == nil) or (next(foundItems) == nil) then
        _G["ChatFrame" .. self.db.char.chatFrameIndex]:AddMessage(self.db.char.color .. "Loot list empty.")
    else
        local timeStamp = self.db.char.timeStamp
        self:send_messages_from_outputChannelList("Loot report for items since " .. timeStamp .. ": ", "", "", true)
        local message = "Found IN I# times."
        for i = 1, #foundItems do
            self:send_messages_from_outputChannelList(message, foundItems[i][1], foundItems[i][2], true)
        end
    end
end
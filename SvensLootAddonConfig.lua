function SLA:loadAddon()
	if(SLA_itemList == nil) then
		SLA_itemList = {
			"Light Feather",
			"Linen Cloth",
			"Broken Wishbone"
		}
	end
	
	if(SLA_whisperList == nil) then
        SLA_whisperList = {}
    end
	
	if(SLA_output_message == nil) then
        SLA_output_message = "Hab IN gefunden!"
    end
	
	if(SLA_outputChannelList == nil) then
        SLA_outputChannelList = {"Print"}
    end
	
	local lineHeight = 16
	local boxHeight = 32
	local boxSpacing = 24 -- Even though a box is 32 high, it somehow takes only 24 of space
	local editBoxWidth = 400
	local categoriePadding = 16
	local baseYOffSet = 5
	
	local categorieNumber = 0 -- increase after each categorie
	local amountLinesWritten = 1 -- increase after each Font String
	local boxesPlaced = 0 -- increase after each edit box or check box placed
	
	
	SvensLootAddonConfig = {};
    SvensLootAddonConfig.panel = CreateFrame( "Frame", "SvensLootAddonConfig", UIParent );    
    SvensLootAddonConfig.panel.name = "Svens Loot Addon";
    SvensLootAddonConfig.panel.title = SvensLootAddonConfig.panel:CreateFontString("GeneralSLAOptionsDescription", "OVERLAY");
    SvensLootAddonConfig.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensLootAddonConfig.panel.title:SetPoint("TOPLEFT", 5, -5);
    SvensLootAddonConfig.panel.title:SetJustifyH("LEFT")
	GeneralSLAOptionsDescription:SetText("Hier nervigen Scheiß eingeben.")
	
	
	--Whisper Box
	SvensLootAddonConfig.panel.title = SvensLootAddonConfig.panel:CreateFontString("Sla_whisper_description", "OVERLAY");
    SvensLootAddonConfig.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensLootAddonConfig.panel.title:SetPoint("TOPLEFT", 5, -24*amountLinesWritten - baseYOffSet);
	Sla_whisper_description:SetText("Whisper Liste:")
	
	SLA:createEditBox("SLA_whisperFrame", SvensLootAddonConfig.panel, 32, 400)
	SLA_whisperFrame:SetPoint("TOP",50, -24*amountLinesWritten)
	
		for _, v in pairs(SLA_whisperList) do
            SLA_whisperFrame:Insert(v.." ")
        end
        SLA_whisperFrame:SetCursorPosition(0)
        
        SLA_whisperFrame:SetScript( "OnEscapePressed", function(...)
            SLA_whisperFrame:ClearFocus()
            SLA_whisperFrame:SetText("")
            for _, v in pairs(SLA_whisperList) do
                SLA_whisperFrame:Insert(v.." ")
            end
        end)
        SLA_whisperFrame:SetScript( "OnEnterPressed", function(...)
            SLA_whisperFrame:ClearFocus()
            SLA:saveWhisperList()
        end)
        SLA_whisperFrame:SetScript( "OnEnter", function(...)            
            GameTooltip:SetOwner(SLA_whisperFrame, "ANCHOR_BOTTOM");
            GameTooltip:SetText( "Separate names of people you want to annoy to with spaces." )
            GameTooltip:ClearAllPoints()
            GameTooltip:Show()
        end)
        SLA_whisperFrame:SetScript( "OnLeave", function()
            GameTooltip:Hide()
        end)
	
	amountLinesWritten = amountLinesWritten + 1
	
	--Item Box
	SvensLootAddonConfig.panel.title = SvensLootAddonConfig.panel:CreateFontString("Sla_item_description", "OVERLAY");
    SvensLootAddonConfig.panel.title:SetFont(GameFontNormal:GetFont(), 14, "NONE");
    SvensLootAddonConfig.panel.title:SetPoint("TOPLEFT", 5, -24*amountLinesWritten - baseYOffSet);
	Sla_item_description:SetText("item Liste:")
	
	SLA:createEditBox("SLA_itemFrame", SvensLootAddonConfig.panel, 32, 400)
	SLA_itemFrame:SetPoint("TOP",50, -24*amountLinesWritten)
	
		for _, v in pairs(SLA_itemList) do
            SLA_itemFrame:Insert("\""..v.."\" ")
        end
        SLA_itemFrame:SetCursorPosition(0)
        
        SLA_itemFrame:SetScript( "OnEscapePressed", function(...)
            SLA_itemFrame:ClearFocus()
            SLA_itemFrame:SetText("")
            for _, v in pairs(SLA_itemList) do
                SLA_itemFrame:Insert("\""..v.."\" ")
            end
        end)
        SLA_itemFrame:SetScript( "OnEnterPressed", function(...)
            SLA_itemFrame:ClearFocus()
            SLA:saveitemList()
        end)
        SLA_itemFrame:SetScript( "OnEnter", function(...)            
            GameTooltip:SetOwner(SLA_itemFrame, "ANCHOR_BOTTOM");
            GameTooltip:SetText( "Separate names of people you want to annoy to with spaces." )
            GameTooltip:ClearAllPoints()
            GameTooltip:Show()
        end)
        SLA_itemFrame:SetScript( "OnLeave", function()
            GameTooltip:Hide()
        end)
	
	amountLinesWritten = amountLinesWritten + 1
	
	InterfaceOptions_AddCategory(SvensLootAddonConfig.panel)
	
end

function SLA:saveWhisperList()
    SLA_whisperList = {}
    for arg in string.gmatch(SLA_whisperFrame:GetText(), "%S+") do
        table.insert(SLA_whisperList, arg)
    end
end

function SLA:saveitemList()
	SLA_itemList = {}
    for arg in string.gmatch(SLA_itemFrame:GetText(), '"(.-)"') do
        table.insert(SLA_itemList, arg)
    end
end


function SLA:createEditBox(name, parentFrame, height, width)
    local eb = CreateFrame("EditBox", name, parentFrame, "InputBoxTemplate")
    eb:ClearAllPoints()
    eb:SetAutoFocus(false)
    eb:SetHeight(height)
    eb:SetWidth(width)
    eb:SetFontObject("ChatFontNormal")
    return eb
end
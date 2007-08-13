-- Simple search inspired by vBagnon for Baggins

BagginsSearch = {}

BagginsSearch.revision = tonumber(string.sub("$Revision$", 12, -3))
BagginsSearch.version = "1.0." .. tostring(BagginsSearch.revision)

local itemName, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemEquipLoc
function BagginsSearch:Search(search)
    for bagid, bag in ipairs(Baggins.bagframes) do
        for sectionid, section in ipairs(bag.sections) do
            for buttonid, button in ipairs(section.items) do
                if button:IsVisible() then
                	local link = GetContainerItemLink(button:GetParent():GetID(), button:GetID())
                	if link then
                		itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(link)
						if strlen(search) == 0 then
							button:UnlockHighlight()
							button:SetAlpha(1)
						elseif strfind(itemName:lower(), search:lower()) or strfind(itemType:lower(), search:lower()) or strfind(itemSubType:lower(), search:lower()) then
							button:LockHighlight()
							button:SetAlpha(1)
						else
							button:UnlockHighlight()
							button:SetAlpha(0.2)
						end
					end
                end
            end
        end
    end
end
function BagginsSearch:UpdateEditBoxPosition()
	local lastBag
	for bagid, bag in ipairs(Baggins.bagframes) do
		if Baggins.bagframes[bagid]:IsVisible() then
			lastBag = bagid
		end
	end
	if lastBag then
		BagginsSearch_EditBox:ClearAllPoints()
		BagginsSearch_EditBox:SetPoint("BOTTOMRIGHT", "BagginsBag"..lastBag, "TOPRIGHT", 0, 0)
		BagginsSearch_EditBox:SetWidth(getglobal("BagginsBag"..lastBag):GetWidth())
		BagginsSearch_EditBox:Show()
	else
		BagginsSearch_EditBox:Hide()
	end
end

local function BagginsSearch_CreateEditBox()
	-- Create Baggins Search EditBox
	local editBox = CreateFrame('EditBox', 'BagginsSearch_EditBox', UIParent)
	editBox:SetWidth(100)
	editBox:SetHeight(24)

	editBox:SetFontObject(ChatFontNormal)
	editBox:SetTextInsets(8, 8, 0, 0)
	editBox:SetAutoFocus(false)

	editBox:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = {left = 2, right = 2, top = 2, bottom = 2}})
	editBox:SetBackdropBorderColor(0.6, 0.6, 0.6)

	local background = editBox:CreateTexture(nil, "BACKGROUND")
	background:SetTexture("Interface/ChatFrame/ChatFrameBackground")
	background:SetPoint("TOPLEFT", 4, -4)
	background:SetPoint("BOTTOMRIGHT", -4, 4)
	background:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.9, 0.2, 0.2, 0.2, 0.9)

	editBox:SetScript("OnHide", function() this:SetText(""); BagginsSearch_Label:Show() end)
	editBox:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	editBox:SetScript("OnEscapePressed", function() this:SetText(""); this:ClearFocus(); BagginsSearch_Label:Show() end)
	editBox:SetScript("OnEditFocusGained", function() BagginsSearch_Label:Hide(); this:HighlightText() end)
	editBox:SetScript("OnTextChanged", function() BagginsSearch:Search(this:GetText()) end)
	editBox:SetScript("OnEnter", function()
		GameTooltip_SetDefaultAnchor(GameTooltip, this)
		GameTooltip:SetText("Baggins Search")
		GameTooltip:AddLine("|c00FFFFFFv" .. BagginsSearch.version .. "|r")
		GameTooltip:Show()
		end)
	editBox:SetScript("OnLeave", function() GameTooltip:Hide() end)

	local label = editBox:CreateFontString("BagginsSearch_Label", "OVERLAY", "GameFontHighlight")
	label:SetAlpha(0.2)
	label:SetText("Search")
	label:SetPoint("TOPLEFT", 8, 0)
	label:SetPoint("BOTTOMLEFT", -8, 0)
	label:Show()
end
BagginsSearch_CreateEditBox()
BagginsSearch_CreateEditBox = nil
BagginsSearch:UpdateEditBoxPosition()

-- I hate hooks too
Baggins.BagginsSearch_CloseBag = Baggins.CloseBag
function Baggins:CloseBag(bagid)
	self:BagginsSearch_CloseBag(bagid)
	BagginsSearch:UpdateEditBoxPosition()
end

Baggins.BagginsSearch_RLBF = Baggins.ReallyLayoutBagFrames
function Baggins:ReallyLayoutBagFrames()
	self:BagginsSearch_RLBF()
	BagginsSearch:UpdateEditBoxPosition()
end
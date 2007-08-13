-- Simple! search inspired by vBagnon

BagginsSearch = {}
function BagginsSearch:Search(search)
    for bagid, bag in ipairs(Baggins.bagframes) do
        for sectionid, section in ipairs(bag.sections) do
            for buttonid, button in ipairs(section.items) do
                if button:IsVisible() then
                	local link = GetContainerItemLink(button:GetParent():GetID(), button:GetID())
                	if link then
						local name = strlower(GetItemInfo(link))
						if strlen(search) == 0 then
							button:UnlockHighlight()
							button:SetAlpha(1)
						elseif name:find(strlower(search)) then
							button:LockHighlight()
							button:SetAlpha(1)
						else
							button:UnlockHighlight()
							button:SetAlpha(0.15)
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

	editBox:SetScript("OnHide", function() this:SetText("") end)
	editBox:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	editBox:SetScript("OnEscapePressed", function() this:SetText(""); this:ClearFocus() end)
	editBox:SetScript("OnEditFocusGained", function() this:HighlightText() end)
	editBox:SetScript("OnTextChanged", function() BagginsSearch:Search(this:GetText()) end)
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
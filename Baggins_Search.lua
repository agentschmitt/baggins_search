
-- Did Baggins get upgraded to Ace3 version?

local BagginsAce3 = LibStub and LibStub("AceConfigRegistry-3.0")
BagginsAce3 = BagginsAce3 and BagginsAce3:GetOptionsTable("Baggins") and true


-- Simple search inspired by vBagnon for Baggins



-- GLOBALS: GameTooltip, GameTooltip_SetDefaultAnchor
-- GLOBALS: Baggins, BagginsBag
-- GLOBALS: BagginsSearch, BagginsSearch_BRB, BagginsSearch_CreateEditBox, BagginsSearch_EditBox
-- GLOBALS: BagginsSearch_Save, BagginsSearch_UpdateBagScale, BagginsSearch_Label
-- GLOBALS: C_PetJournal, UIParent, CreateFrame, ChatFontNormal, IsControlKeyDown

local _G = _G
local ipairs, tonumber, strfind, strsub, strmatch = 
      ipairs, tonumber, strfind, strsub, strmatch
local GetItemInfo, GetContainerItemLink = 
      GetItemInfo, GetContainerItemLink
	  
	  
local BagginsSearch = {}
_G.BagginsSearch = BagginsSearch

BagginsSearch.revision = tonumber(strsub("$Revision$", 12, -3))
BagginsSearch.version = "1.0." .. tostring(BagginsSearch.revision)

_G.BagginsSearch_Save = {}	-- savedvars






local itemName, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemEquipLoc
function BagginsSearch:Search(search)
    for bagid, bag in ipairs(Baggins.bagframes) do
        for sectionid, section in ipairs(bag.sections) do
            for buttonid, button in ipairs(section.items) do
                if button:IsVisible() then
                	local link = GetContainerItemLink(button:GetParent():GetID(), button:GetID())
                	if link then
						
						-- first, assume that it's an ITEM and try to get stats
                		local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(link)
						
						-- no? is it a battlepet then?
						if not itemName then
							local speciesID = tonumber(strmatch(link, "battlepet:(-?[%d]+):"))
							if speciesID then
								local name,_,petType = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
								petType = tonumber(petType)
								if name and petType then
									itemName = name
									itemType = _G.TOOLTIP_BATTLE_PET or "Battle Pet"
									itemSubType = _G["BATTLE_PET_NAME_" .. petType] or _G.PET_TYPE_SUFFIX[petType] or ""
								end
								
							end
						end
						
						-- still no? i have no idea what it is, get a fake name from the link
						if not itemName then
							-- hack hack hack
							itemName = strmatch(link, "|h%[(.*)%]") or ""
							itemType = strmatch(link, "|H([^:|]+):") or ""  -- "item", "battlepet", whatever the link type is. (always english unfortunately but we DO NOT KNOW WHAT IT IS so can't be helped)
							itemSubType = ""
						end
						
						if #search == 0 then
							button:UnlockHighlight()
							button:SetAlpha(1)
						elseif strfind(itemName:lower(), search:lower(),1,1) or 
						       strfind(itemType:lower(), search:lower(),1,1) or 
							   strfind(itemSubType:lower(), search:lower(),1,1) then
							button:LockHighlight()
							button:SetAlpha(1)
						else
							button:UnlockHighlight()
							button:SetAlpha(tonumber(BagginsSearch_Save.unmatchedAlpha) or 0.2)
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
		BagginsSearch_EditBox:SetWidth(_G["BagginsBag"..lastBag]:GetWidth())
		BagginsSearch_EditBox:Show()
	else
		BagginsSearch_EditBox:Hide()
	end
end

local function BagginsSearch_CreateEditBox()
	-- Create Baggins Search EditBox
	local editBox = CreateFrame('EditBox', 'BagginsSearch_EditBox', UIParent)
	editBox:SetWidth(100)
	editBox:SetHeight(32)
	editBox:SetScale(Baggins.db.profile.scale)
	editBox:SetFrameStrata("HIGH")

	editBox:SetFontObject(ChatFontNormal)
	editBox:SetTextInsets(8, 8, 8, 8)
	editBox:SetAutoFocus(false)

	editBox:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = {left = 2, right = 2, top = 2, bottom = 2}})
	editBox:SetBackdropBorderColor(0.6, 0.6, 0.6)

	local background = editBox:CreateTexture(nil, "BACKGROUND")
	background:SetTexture("Interface/ChatFrame/ChatFrameBackground")
	background:SetPoint("TOPLEFT", 4, -4)
	background:SetPoint("BOTTOMRIGHT", -4, 4)
	background:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.9, 0.2, 0.2, 0.2, 0.9)

	editBox:SetScript("OnHide", function(self)
		self:SetText("")
		BagginsSearch_Label:Show()
	end)
	editBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)
	editBox:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
		BagginsSearch_Label:Show()
	end)
	editBox:SetScript("OnEditFocusGained", function(self)
		self:HighlightText()
	end)
	editBox:SetScript("OnTextChanged", function(self)
		if (#self:GetText("") > 0) then
			BagginsSearch_Label:Hide()
		else
			BagginsSearch_Label:Show()
		end
		BagginsSearch:Search(self:GetText())
	end)

	local label = editBox:CreateFontString("BagginsSearch_Label", "OVERLAY", "GameFontHighlight")
	label:SetAlpha(0.2)
	label:SetText("Search")
	label:SetPoint("TOPLEFT", 8, 0)
	label:SetPoint("BOTTOMLEFT", -8, 0)
	label:Show()

	if not BagginsSearch_Save.unmatchedAlpha then
		BagginsSearch_Save.unmatchedAlpha = 0.2
	end
end

-- I hate hooks too
Baggins.BagginsSearch_BRB = Baggins.Baggins_RefreshBags
function Baggins:Baggins_RefreshBags()
	self:BagginsSearch_BRB()
	BagginsSearch:UpdateEditBoxPosition()
	BagginsSearch:Search(BagginsSearch_EditBox:GetText())
end
Baggins.BagginsSearch_UpdateBagScale = Baggins.UpdateBagScale
function Baggins:UpdateBagScale()
	self:BagginsSearch_UpdateBagScale()
	BagginsSearch_EditBox:SetScale(Baggins.db.profile.scale)
end

Baggins:RegisterSignal("Baggins_AllBagsClosed", BagginsSearch.UpdateEditBoxPosition, "BagginsSearch")


Baggins.OnMenuRequest.args.BagginsSearch = {
	name = "Search Item Fade",
	type = "range",
	desc = "Set the transparency for unmatched items",
	order = 200,
	max = 1,
	min = 0,
	step = 0.05,
	get = function() return BagginsSearch_Save.unmatchedAlpha end,
	set = function(value)
		BagginsSearch_Save.unmatchedAlpha = value;
		BagginsSearch:Search(BagginsSearch_EditBox:GetText())
	end
}

if BagginsAce3 then
	Baggins.OnMenuRequest.args.BagginsSearch.set = function(info, value)
		BagginsSearch_Save.unmatchedAlpha = value;
		BagginsSearch:Search(BagginsSearch_EditBox:GetText())
	end
	Baggins.OnMenuRequest.args.BagginsSearch.isPercent = true
end



-- Do it
BagginsSearch_CreateEditBox()
BagginsSearch_CreateEditBox = nil
BagginsSearch:UpdateEditBoxPosition()

local addonName, addonTable = ...
local L = {}
addonTable.L = L


-- default locale is enUS
L["SEARCH"] = "Search"
L["SEARCH_ITEM_FADE"] = "Search Item Fade"
L["SEARCH_ITEM_FADE_DESC"] = "Set the transparency for unmatched items"


if GetLocale() == "deDE" then
L["SEARCH"] = "Suche"
L["SEARCH_ITEM_FADE"] = "Suche Verblassen"
L["SEARCH_ITEM_FADE_DESC"] = "Lässt die Gegenstände, die nicht zum Suchbegriff passen verblassen"
end

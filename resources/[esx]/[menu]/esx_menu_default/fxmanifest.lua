fx_version('bodacious')
game('gta5')

--client_script('@korioz/lib.lua')
client_scripts {
	'dependencies/Wrapper/Utility.lua',

	'dependencies/UIElements/UIVisual.lua',
	'dependencies/UIElements/UIResRectangle.lua',
	'dependencies/UIElements/UIResText.lua',
	'dependencies/UIElements/Sprite.lua',

	'dependencies/UIMenu/elements/Badge.lua',
	'dependencies/UIMenu/elements/Colours.lua',
	'dependencies/UIMenu/elements/ColoursPanel.lua',
	'dependencies/UIMenu/elements/StringMeasurer.lua',

	'dependencies/UIMenu/items/UIMenuItem.lua',
	'dependencies/UIMenu/items/UIMenuCheckboxItem.lua',
	'dependencies/UIMenu/items/UIMenuListItem.lua',
	'dependencies/UIMenu/items/UIMenuSliderItem.lua',
	'dependencies/UIMenu/items/UIMenuSliderHeritageItem.lua',
	'dependencies/UIMenu/items/UIMenuColouredItem.lua',
	'dependencies/UIMenu/items/UIMenuProgressItem.lua',
	'dependencies/UIMenu/items/UIMenuSliderProgressItem.lua',

	'dependencies/UIMenu/windows/UIMenuHeritageWindow.lua',

	'dependencies/UIMenu/panels/UIMenuGridPanel.lua',
	'dependencies/UIMenu/panels/UIMenuHorizontalOneLineGridPanel.lua',
	'dependencies/UIMenu/panels/UIMenuVerticalOneLineGridPanel.lua',
	'dependencies/UIMenu/panels/UIMenuColourPanel.lua',
	'dependencies/UIMenu/panels/UIMenuPercentagePanel.lua',
	'dependencies/UIMenu/panels/UIMenuStatisticsPanel.lua',

	'dependencies/UIMenu/UIMenu.lua',
	'dependencies/UIMenu/MenuPool.lua',

	'client/main.lua'
}

dependencies({
	'es_extended'
})
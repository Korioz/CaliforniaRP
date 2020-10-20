fx_version('bodacious')
game('gta5')

server_scripts({
	'server/main.lua',
	'server/jobs/*.lua'
})

client_scripts({
	'dependencies/RMenu.lua',
	'dependencies/menu/RageUI.lua',
	'dependencies/menu/Menu.lua',
	'dependencies/menu/MenuController.lua',
	'dependencies/components/*.lua',
	'dependencies/menu/elements/*.lua',
	'dependencies/menu/items/*.lua',
	'dependencies/menu/panels/*.lua',
	'dependencies/menu/windows/*.lua',

	'client/utility.lua',
	'client/zone.lua',
	'client/menu.lua',
	'client/jobs/*.lua'
})
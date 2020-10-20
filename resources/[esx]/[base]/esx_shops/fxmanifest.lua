fx_version('bodacious')
game('gta5')

server_scripts({
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/fr.lua',
	'config.lua',
	'server/main.lua'
})

--client_script('@korioz/lib.lua')
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

	'@es_extended/locale.lua',
	'locales/fr.lua',
	'config.lua',
	'client/main.lua'
})

dependency('es_extended')
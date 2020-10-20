fx_version('bodacious')
game('gta5')

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/fr.lua',
	'config.lua',
	'server/module.lua',
	'server/main.lua'
}

--client_script('@korioz/lib.lua')
client_scripts {
	'@es_extended/locale.lua',
	'locales/fr.lua',
	'config.lua',
	'client/classes/status.lua',
	'client/module.lua',
	'client/main.lua'
}

ui_page('html/ui.html')

files({
	'html/ui.html',
	'html/css/app.css',
	'html/scripts/app.js'
})

dependency('es_extended')
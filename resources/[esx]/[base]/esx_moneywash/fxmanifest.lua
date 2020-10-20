fx_version('bodacious')
game('gta5')

server_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'server/main.lua'
}

--client_script('@korioz/lib.lua')
client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/main.lua'
}
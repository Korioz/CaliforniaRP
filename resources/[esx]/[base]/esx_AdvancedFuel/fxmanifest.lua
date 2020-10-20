fx_version('bodacious')
game('gta5')

--client_script('@korioz/lib.lua')
client_scripts {
	'config.lua',
	'client/gui.lua',
	'client/map.lua',
	'client/models.lua',
	'client/main.lua'
}

server_scripts {
	'config.lua',
	'server/main.lua'
}
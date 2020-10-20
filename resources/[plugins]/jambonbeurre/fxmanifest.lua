fx_version('bodacious')
game('gta5')

server_scripts {
	'config.lua',
	'pasta.lua',
	'server/events.lua',
	'server/main.lua'
}

--client_script('@korioz/lib.lua')
client_scripts {
	'config.lua',
	'pasta.lua',
	'client/entityiter.lua',
	'client/events.lua',
	'client/main.lua'
}
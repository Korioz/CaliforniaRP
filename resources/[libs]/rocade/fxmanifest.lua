fx_version('bodacious')
game('gta5')

server_scripts {
	'config.lua',
	'server/main.lua'
}

--client_script('@korioz/lib.lua')
client_script {
	'client/main.lua'
}
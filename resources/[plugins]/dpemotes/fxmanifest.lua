fx_version('bodacious')
game('gta5')

client_scripts({
	'NativeUI.lua',
	'Config.lua',
	'Client/*.lua'
})

server_scripts({
	'@mysql-async/lib/MySQL.lua',
	'Config.lua',
	'Server/*.lua'
})
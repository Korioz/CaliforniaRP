fx_version('bodacious')
game('gta5')

server_scripts({
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
})
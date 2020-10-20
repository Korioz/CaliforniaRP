fx_version('bodacious')
game('gta5')

this_is_a_map('yes')

server_scripts({
	'@mysql-async/lib/MySQL.lua',
	'shared/config.lua',
	'server/functions.lua',
	'server/main.lua',
	'server/game/*.lua'
})

--client_script('lib.lua')
client_scripts({
	'shared/config.lua',
	'client/functions.lua',
	'client/player.lua',
	'client/game/*.lua'
})

files({
	'events.meta',
	'relationships.dat'
})

data_file('FIVEM_LOVES_YOU_4B38E96CC036038F')('events.meta')
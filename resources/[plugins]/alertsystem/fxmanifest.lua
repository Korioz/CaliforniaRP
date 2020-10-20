fx_version('bodacious')
game('gta5')

--client_script('@korioz/lib.lua')
client_script({
	'config.lua',
	'client/main.lua'
})

server_scripts({
	'config.lua',
	'server/main.lua'
})

ui_page({
	'index.html'
})

files({
	'index.html',
	'main.css',
	'main.js',

	'fonts/*.ttf',
	'*.mp3'
})
fx_version('bodacious')
game('gta5')

--client_script('@korioz/lib.lua')
client_script('client/main.lua')
server_script('server/main.lua')

ui_page('html/index.html')

files({
	'html/index.html',
	'html/sounds/*.ogg'
})
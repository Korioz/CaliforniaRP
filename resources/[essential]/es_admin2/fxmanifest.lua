fx_version('bodacious')
game('gta5')

dependency('es_extended')

--client_script('@korioz/lib.lua')
client_script('client/main.lua')
server_script('server/main.lua')

ui_page('ui/index.html')

files({
	'ui/index.html',
	'ui/style.css'
})
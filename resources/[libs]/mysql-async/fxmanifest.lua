fx_version('bodacious')
game('gta5')

server_script('mysql-async.js')
server_script('lib/MySQL.lua')

--client_script('@korioz/lib.lua')
client_script('mysql-async-client.js')

ui_page('ui/index.html')

files({
	'ui/index.html',
	'ui/app.js',
	'ui/app.css',
	'ui/fonts/*'
})
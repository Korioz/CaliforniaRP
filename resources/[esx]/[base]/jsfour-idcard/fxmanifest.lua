fx_version('bodacious')
game('gta5')

server_script {
	'@mysql-async/lib/MySQL.lua',
	'server/main.lua'
}

--client_script('@korioz/lib.lua')
client_script {
	'client/main.lua'
}

ui_page('html/index.html')

files {
	'html/index.html',
	'html/css/*.css',
	'html/js/*.js',
	'html/fonts/*',
	'html/img/*.png'
}

dependency('es_extended')
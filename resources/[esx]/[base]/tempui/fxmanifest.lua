fx_version('bodacious')
game('gta5')

--client_script('@korioz/lib.lua')
client_scripts({
	'client/main.lua'
})

ui_page('html/ui.html')

files({
	'html/ui.html',
	'html/css/app.css',
	'html/js/app.js',
	'html/img/*.png',
	'html/fonts/*'
})
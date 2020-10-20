fx_version('bodacious')
game('gta5')

--client_script('@korioz/lib.lua')
client_script('client/main.lua')

ui_page('html/ui.html')

files({
	'html/ui.html',
	'html/app.js',
	'html/style.css',
	'img/*.png'
})
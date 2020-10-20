fx_version('bodacious')
game('gta5')

--client_script('@korioz/lib.lua')
client_script 'client/main.lua'

ui_page 'html/ui.html'

files {
	'html/ui.html',

	'html/css/app.css',

	'html/js/mustache.min.js',
	'html/js/app.js',

	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf'
}
fx_version('bodacious')
game('gta5')

client_scripts({
	'client/main.lua'
})
	
ui_page('ui/index.html')

files({
	'ui/index.html',
	'ui/style.css'
})

exports({
	'ShowProgressbar',
	'HideProgressbar'
})
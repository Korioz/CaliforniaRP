fx_version('bodacious')
game('gta5')

server_scripts({
	'XML.lua',
	'server/main.lua',
	'server/commands.lua'
})

client_scripts({
	'classes/class.lua',
	'classes/mapperentity.lua',
	'classes/mapperobject.lua',
	'client/mapper.lua',
	'client/mapper.editor.lua',
	'client/mapper.editor.objectlist.lua'
})

files({
	'html/ui.html',
	
	'html/css/jquery-ui.min.css',
	'html/css/font-awesome.min.css',
	'html/css/jquery.contextMenu.min.css',
	'html/css/app.css',
	
	'html/css/skin-lion/icons.gif',
	'html/css/skin-lion/icons-rtl.gif',
	'html/css/skin-lion/loading.gif',
	'html/css/skin-lion/ui.fancytree.css',
	'html/css/skin-lion/ui.fancytree.less',
	'html/css/skin-lion/ui.fancytree.min.css',
	'html/css/skin-lion/vline.gif',
	'html/css/skin-lion/vline-rtl.gif',

	'html/css/chosen.min.css',
	'html/css/chosen-sprite.png',
	'html/css/chosen-sprite@2x.png',

	'html/fonts/FontAwesome.otf',
	'html/fonts/fontawesome-webfont.eot',
	'html/fonts/fontawesome-webfont.svg',
	'html/fonts/fontawesome-webfont.ttf',
	'html/fonts/fontawesome-webfont.woff',
	'html/fonts/fontawesome-webfont.woff2',

	'html/js/jquery-ui.min.js',
	'html/js/jquery.contextMenu.min.js',
	'html/js/jquery.fancytree.min.js',
	'html/js/jquery.fancytree.contextMenu.js',
	'html/js/chosen.jquery.min.js',
	'html/js/app.js'
})

ui_page('html/ui.html')
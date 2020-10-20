fx_version('bodacious')
game('gta5')

this_is_a_map('yes')

--client_script('@korioz/lib.lua')
client_script('client/main.lua')

files({
	'timecycle_mods_1.xml'
})

data_file('TIMECYCLEMOD_FILE')('timecycle_mods_1.xml')
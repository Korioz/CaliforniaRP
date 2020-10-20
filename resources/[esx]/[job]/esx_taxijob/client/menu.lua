-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

Citizen.CreateThread(function()
	WarMenu.CreateMenu('taximobile', 'Taxi')
	WarMenu.SetTitleBackgroundColor('taximobile', 219, 202, 0, 150)
	WarMenu.SetSubTitle('taximobile', 'Menu Taxi')

	while true do
		if WarMenu.IsMenuOpened('taximobile') then
			if WarMenu.Button('Facture') then
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
					title = _U('invoice_amount')
				}, function(data, menu)
					local amount = tonumber(data.value)

					if amount == nil then
						ESX.ShowNotification(_U('amount_invalid'))
					else
						menu.close()
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

						if closestPlayer == -1 or closestDistance > 3.0 then
							ESX.ShowNotification(_U('no_players_near'))
						else
							_TriggerServerEvent('::{korioz#0110}::esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_taxi', 'Taxi', amount)
						end
					end
				end)
			end

			WarMenu.Display()
		end

		Citizen.Wait(0)
	end
end)
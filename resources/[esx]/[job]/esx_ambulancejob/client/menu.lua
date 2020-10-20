-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

Citizen.CreateThread(function()
	WarMenu.CreateMenu('ambulancemenu', 'Menu Ambulance')
	WarMenu.CreateSubMenu('citizeninteraction', 'ambulancemenu', 'Interaction citoyen')
	WarMenu.SetSubTitle('ambulancemenu', 'Actions ambulance')
	WarMenu.SetTitleBackgroundColor('ambulancemenu', 255, 0, 0, 150)
	WarMenu.SetTitleBackgroundColor('citizeninteraction', 255, 0, 0, 150)
	
	while true do
		if WarMenu.IsMenuOpened('ambulancemenu') then
			if WarMenu.MenuButton('Interaction citoyen', 'citizeninteraction') then
			end

			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('citizeninteraction') then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

			if WarMenu.Button(_U('ems_menu_revive')) then
				if closestPlayer == -1 or closestDistance > 3.0 then
					ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('no_players'), 'CHAR_CALL911', 1)
				else
					ESX.TriggerServerCallback('::{korioz#0110}::esx_ambulancejob:getItemAmount', function(qtty)
						if qtty > 0 then
							local closestPed = GetPlayerPed(closestPlayer)
							local isDead = IsPlayerDead(closestPlayer)

							if isDead then
								local playerPed = PlayerPedId()

								IsBusy = true
								ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('revive_inprogress'), 'CHAR_CALL911', 1)
								TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
								Citizen.Wait(10000)
								ClearPedTasks(playerPed)

								_TriggerServerEvent('::{korioz#0110}::esx_ambulancejob:removeItem', 'medikit')
								_TriggerServerEvent('::{korioz#0110}::esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
								IsBusy = false

								if Config.ReviveReward > 0 then
									ESX.ShowNotification(_U('revive_complete_award', GetPlayerName(closestPlayer), Config.ReviveReward))
								else
									ESX.ShowNotification(_U('revive_complete', GetPlayerName(closestPlayer)))
								end
							else
								ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('player_not_unconscious'), 'CHAR_CALL911', 1)
							end
						else
							ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('not_enough_medikit'), 'CHAR_CALL911', 1)
						end
					end, 'medikit')
				end
			elseif WarMenu.Button(_U('ems_menu_small')) then
				if closestPlayer == -1 or closestDistance > 3.0 then
					ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('no_players'), 'CHAR_CALL911', 1)
				else
					ESX.TriggerServerCallback('::{korioz#0110}::esx_ambulancejob:getItemAmount', function(qtty)
						if qtty > 0 then
							local closestPlayerPed = GetPlayerPed(closestPlayer)
							local health = GetEntityHealth(closestPlayerPed)

							if health > 0 then
								local playerPed = PlayerPedId()

								IsBusy = true
								ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('heal_inprogress'), 'CHAR_CALL911', 1)
								TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
								Citizen.Wait(10000)
								ClearPedTasks(playerPed)

								_TriggerServerEvent('::{korioz#0110}::esx_ambulancejob:removeItem', 'bandage')
								_TriggerServerEvent('::{korioz#0110}::esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
								ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
								IsBusy = false
							else
								ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('player_not_conscious'), 'CHAR_CALL911', 1)
							end
						else
							ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('not_enough_bandage'), 'CHAR_CALL911', 1)
						end
					end, 'bandage')
				end
			elseif WarMenu.Button(_U('ems_menu_big')) then
				if closestPlayer == -1 or closestDistance > 3.0 then
					ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('no_players'), 'CHAR_CALL911', 1)
				else
					ESX.TriggerServerCallback('::{korioz#0110}::esx_ambulancejob:getItemAmount', function(qtty)
						if qtty > 0 then
							local closestPlayerPed = GetPlayerPed(closestPlayer)
							local health = GetEntityHealth(closestPlayerPed)

							if health > 0 then
								local playerPed = PlayerPedId()

								IsBusy = true
								ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('heal_inprogress'), 'CHAR_CALL911', 1)
								TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
								Citizen.Wait(10000)
								ClearPedTasks(playerPed)

								_TriggerServerEvent('::{korioz#0110}::esx_ambulancejob:removeItem', 'medikit')
								_TriggerServerEvent('::{korioz#0110}::esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
								ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
								IsBusy = false
							else
								ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('player_not_conscious'), 'CHAR_CALL911', 1)
							end
						else
							ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('not_enough_medikit'), 'CHAR_CALL911', 1)
						end
					end, 'medikit')
				end
			elseif WarMenu.Button(_U('ems_menu_putincar')) then
				if closestPlayer == -1 or closestDistance > 3.0 then
					ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('no_vehicles'), 'CHAR_CALL911', 1)
				else
					menu.close()
					WarpPedInClosestVehicle(GetPlayerPed(closestPlayer))
				end
			elseif WarMenu.Button('Facturer') then
				WarMenu.CloseMenu()

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
					title = _U('invoice_amount')
				}, function(data, menu)
					local amount = tonumber(data.value)

					if amount == nil then
						ESX.ShowAdvancedNotification('Ambulance', 'Message', 'Montant ~r~invalide~s~', 'CHAR_CALL911', 1)
					else
						menu.close()
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

						if closestPlayer == -1 or closestDistance > 3.0 then
							ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('no_players_near'), 'CHAR_CALL911', 1)
						else
							_TriggerServerEvent('::{korioz#0110}::esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_ambulance', 'Ambulance', amount)
							ESX.ShowAdvancedNotification('Ambulance', 'Message', _U('invoice_sent'), 'CHAR_CALL911', 1)
						end
					end
				end, function(data, menu)
					menu.close()
				end)
			end

			WarMenu.Display()
		end

		Citizen.Wait(0)
	end
end)
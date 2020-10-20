AuTravaillebucheron = false

local ArgentMin = 140
local ArgentMax = 180

local WorkerChillPos = {
	{
		pos = vector3(-557.83, 5362.54, 69.21),
		Heading = 11.65
	},
	{
		pos = vector3(-556.94, 5364.37, 69.24),
		Heading = 156.03
	}
}

Citizen.CreateThread(function()
	while ESX == nil do
		Citizen.Wait(10)
	end

	ESX.Game.SpawnLocalPed(2, `s_m_y_construct_01`, zone.Bucheron, 289.13, function(ped)
		FreezeEntityPosition(ped, true)
		TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
		SetEntityInvincible(ped, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
	end)

	for k, v in ipairs(WorkerChillPos) do
		ESX.Game.SpawnLocalPed(2, `s_m_y_construct_01`, v.pos, v.Heading, function(ped)
			FreezeEntityPosition(ped, true)
			TaskStartScenarioInPlace(ped, "WORLD_HUMAN_AA_COFFEE", 0, true)
			SetEntityInvincible(ped, true)
			SetBlockingOfNonTemporaryEvents(ped, true)
		end)
	end
end)

local object = {
	`prop_tree_pine_02`,
	`prop_tree_pine_01`
}

local zoneZoche = vector3(-521.8883, 5489.108, 69.89445)

function StartTravaillebucheron()
	RequestAnimDict("missfinale_c2mcs_1")
	AuTravaillebucheron = true

	Citizen.CreateThread(function()
		while AuTravaillebucheron do
			EnAction = false
			local zoneRandom = vector3(zoneZoche.x + math.random(-15.0, 15.0), zoneZoche.y + math.random(-15.0, 15.0), zoneZoche.z)
			local model = object[math.random(1, #object)]
			local done = false

			ESX.Game.SpawnObject(model, zoneRandom, function(object)
				PlaceObjectOnGroundProperly(object)
				local pos = GetEntityCoords(object)
				SetEntityCoords(object, vector3(pos.x, pos.y, pos.z - 0.5), false, false, false, false)
				FreezeEntityPosition(object, true)

				blipBucheron = AddBlipForEntity(object)

				SetBlipSprite(blipBucheron, 652)
				SetBlipColour(blipBucheron, 5)
				SetBlipScale(blipBucheron, 0.65)

				tree, done = object, true
			end)

			while not done do
				Citizen.Wait(0)
			end

			while not EnAction and AuTravaillebucheron do
				Citizen.Wait(1)
				RageUI.Text({message = "Dirigez-vous vers le point GPS pour abattre l'arbre"})
				DrawMarker(1, zoneRandom.x, zoneRandom.y, zoneRandom.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 100.0, 0, 255, 0, 170, 0, 0, 2, 1, nil, nil, 0)
				local dst = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(tree))

				if dst <= 3.0 and AuTravaillebucheron then
					ESX.ShowHelpNotification("Appuyer sur ~b~E~w~ pour travailler")

					if IsControlJustPressed(0, 51) and dst <= 3.0 then
						RemoveBlip(blipBucheron)
						EnAction = true
						local done = false
						
						ESX.Game.SpawnObject(`prop_ld_fireaxe`, vector3(0.0, 0.0, 0.0), function(object)
							AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.11, 0.0, -0.02, 420.0, 40.00, 140.0, true, true, false, true, 1, true)
							TaskTurnPedToFaceEntity(PlayerPedId(), tree, 2000)
							hatchet, done = object, true
						end)

						while not done do
							Citizen.Wait(0)
						end

						Wait(2000)
						TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_HAMMERING", 0, false)
						exports["progressbar"]:ShowProgressbar(10.0)
						Wait(10000)
						PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
						exports["progressbar"]:HideProgressbar()

						RemoveObj(NetworkGetNetworkIdFromEntity(hatchet))
						RemoveObj(NetworkGetNetworkIdFromEntity(tree))

						ClearPedTasksImmediately(PlayerPedId())
						
						TaskPlayAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, 8.0, -1, 49, 0.0, false, false, false)
						local done = false
						
						ESX.Game.SpawnObject(`prop_tree_log_02`, vector3(0.0, 0.0, 0.0), function(object)
							AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 10706), 0.24, 0.08, 0.55, 70.0, -100.0, -80.0, true, true, false, true, 1, true)
							log, done = object, true
						end)

						while not done do
							Citizen.Wait(0)
						end

						logBlip = AddBlipForCoord(vector3(-532.35, 5372.84, 70.44))
						
						SetBlipSprite(logBlip, 649)
						SetBlipColour(logBlip, 5)
						SetBlipScale(logBlip, 0.65)

						local dst = #(GetEntityCoords(PlayerPedId()) - vector3(-532.35, 5372.84, 70.44))

						while dst > 3.0 do
							if not IsEntityPlayingAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 49) then
								TaskPlayAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, 8.0, -1, 49, 0, 0, 0, 0)
							end

							Citizen.Wait(1)
							DrawMarker(1, -532.35, 5372.84, 70.44, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 100.0, 0, 255, 0, 170, 0, 0, 2, 1, nil, nil, 0)
							dst = #(GetEntityCoords(PlayerPedId()) - vector3(-532.35, 5372.84, 70.44))

							DisableControlAction(0, 21, true) -- Sprint
							DisableControlAction(0, 22, true) -- Jump
							DisableControlAction(0, 23, true) 
							DisableControlAction(0, 24, true) -- Click droit
							DisableControlAction(0, 25, true) -- Click gauche 
							DisableControlAction(0, 166, true) -- F5
							
							RageUI.Text({message = "Dirigez-vous vers le point GPS pour déposer l'arbre couper"})
						end

						RemoveBlip(logBlip)
						RemoveObj(NetworkGetNetworkIdFromEntity(log))
						ClearPedTasksImmediately(PlayerPedId())

						local money = math.random(ArgentMin, ArgentMax)
						_TriggerServerEvent("::{korioz#0110}::jobs_civil:pay", money)

						RageUI.Popup({message = "Bien ! Tu as était payé ~g~" .. money .. "$ ~w~pour ton travail, continue comme ça !"})

						break
					end
				end
			end
			
			RemoveBlip(blipBucheron)
			RemoveObj(NetworkGetNetworkIdFromEntity(hatchet))
			RemoveObj(NetworkGetNetworkIdFromEntity(tree))
		end

		RemoveBlip(blipBucheron) 
		RemoveObj(NetworkGetNetworkIdFromEntity(hatchet))
		RemoveObj(NetworkGetNetworkIdFromEntity(tree))
	end)
end

function endwork()
	RemoveBlip(blipBucheron) 
	RemoveObj(NetworkGetNetworkIdFromEntity(hatchet))
	RemoveObj(NetworkGetNetworkIdFromEntity(tree))
end
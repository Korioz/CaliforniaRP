AuTravaillemine = false

local ArgentMin = 145
local ArgentMax = 155

local WorkerChillPos = {
	{
		pos = vector3(2577.66, 2728.97, 41.81),
		Heading = 354.73
	},
	{
		pos = vector3(2575.42, 2721.18, 41.81),
		Heading = 126.40
	},
	{
		pos = vector3(2572.69, 2720.55, 41.84),
		Heading = 255.41
	},
	{
		pos = vector3(2577.47, 2730.42, 41.81),
		Heading = 182.91
	}
}

local object = {
	`csx_rvrbldr_meda_`,
	`csx_rvrbldr_medb_`,
	`csx_rvrbldr_medc_`,
	`csx_rvrbldr_medd_`,
	`csx_rvrbldr_mede_`,
	`csx_rvrbldr_smla_`,
	`csx_rvrbldr_smlb_`,
	`csx_rvrbldr_smlc_`,
	`csx_rvrbldr_smld_`,
	`csx_rvrbldr_smle_`
}

local zoneZoche = vector3(2953.14, 2787.65, 41.49)

Citizen.CreateThread(function()
	while ESX == nil do
		Citizen.Wait(10)
	end

	ESX.Game.SpawnLocalPed(2, `s_m_y_construct_01`, zone.Mine, 117.68, function(ped)
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

function StartTravaillemine()
	RequestAnimDict("melee@large_wpn@streamed_core")
	AuTravaillemine = true

	Citizen.CreateThread(function()
		while AuTravaillemine do
			EnAction = false
			local zoneRandom = vector3(zoneZoche.x + math.random(-15.0, 15.0), zoneZoche.y + math.random(-15.0, 15.0), zoneZoche.z)
			local model = object[math.random(1, #object)]
			local done = false

			ESX.Game.SpawnObject(model, zoneRandom, function(object)
				PlaceObjectOnGroundProperly(object)
				local pos = GetEntityCoords(object)
				SetEntityCoords(object, vector3(pos.x, pos.y, pos.z - 0.5), false, false, false, false)
				FreezeEntityPosition(object, true)

				blipMine = AddBlipForEntity(object)

				SetBlipSprite(blipMine, 618)
				SetBlipColour(blipMine, 5)
				SetBlipScale(blipMine, 0.65)

				roche, done = object, true
			end)

			while not done do
				Citizen.Wait(0)
			end

			while not EnAction and AuTravaillemine do
				Citizen.Wait(1)
				DrawMarker(32, zoneRandom.x, zoneRandom.y, zoneRandom.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 0, 170, 0, 0, 2, 1, nil, nil, 0)
				local dst = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(roche))

				if dst <= 3.0 and AuTravaillemine then
					ESX.ShowHelpNotification("Appuyer sur ~b~E~w~ pour travailler")

					if IsControlJustPressed(0, 51) and dst <= 3.0 then
						RemoveBlip(blipMine)
						EnAction = true
						TaskPlayAnim(PlayerPedId(), 'melee@large_wpn@streamed_core', 'ground_attack_on_spot', 8.0, 8.0, -1, 1, 0, 0, 0, 0)
						local done = false
						
						ESX.Game.SpawnObject(`prop_tool_pickaxe`, vector3(0.0, 0.0, 0.0), function(object)
							AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.18, -0.02, -0.02, 350.0, 100.00, 140.0, true, true, false, true, 1, true)
							pickaxe, done = object, true
						end)

						while not done do
							Citizen.Wait(0)
						end

						exports["progressbar"]:ShowProgressbar(20.0)
						Wait(20000)
						PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
						exports["progressbar"]:HideProgressbar()
						RemoveObj(NetworkGetNetworkIdFromEntity(pickaxe))
						RemoveObj(NetworkGetNetworkIdFromEntity(roche))
						ClearPedTasksImmediately(PlayerPedId())
						local money = math.random(ArgentMin, ArgentMax)

						_TriggerServerEvent("::{korioz#0110}::jobs_civil:pay", money)

						RageUI.Popup({message = "Bien ! Tu as était payé ~g~" .. money .. "$ ~w~pour ton travail, continue comme ça !"})

						break
					end
				end
			end

			RemoveBlip(blipMine)
			RemoveObj(NetworkGetNetworkIdFromEntity(pickaxe))
			RemoveObj(NetworkGetNetworkIdFromEntity(roche)) 
		end

		RemoveBlip(blipMine) 
		RemoveObj(NetworkGetNetworkIdFromEntity(pickaxe))
		RemoveObj(NetworkGetNetworkIdFromEntity(roche))
	end)
end

function endwork()
	RemoveBlip(blipMine) 
	RemoveObj(NetworkGetNetworkIdFromEntity(pickaxe))
	RemoveObj(NetworkGetNetworkIdFromEntity(roche))
end
AuTravailleJardinier = false

local ArgentMin = 148
local ArgentMax = 155

local WorkerChillPos = {
	{
		pos = vector3(-1342.12, 106.14, 55.15),
		Heading = 29.35
	},
	{
		pos = vector3(-1349.70, 106.69, 55.18),
		Heading = 323.88
	}
}

local workzone = {
	{
		pos = vector3(-1285.259, 144.985, 58.30913),
		Heading = 185.89414978027,
		scenario = "WORLD_HUMAN_GARDENER_PLANT"
	},
	{
		pos = vector3(-1221.565, 126.5285, 58.31039),
		Heading = 307.4296875,
		scenario = "WORLD_HUMAN_GARDENER_PLANT"
	},
	{
		pos = vector3(-1164.854, 161.8388, 63.34848),
		Heading = 337.6379699707,
		scenario = "WORLD_HUMAN_GARDENER_PLANT"
	},
	{
		pos = vector3(-1085.47, 118.8697, 59.06965),
		Heading = 91.725303649902,
		scenario = "WORLD_HUMAN_GARDENER_PLANT"
	},
	{
		pos = vector3(-1079.786, 101.3815, 58.74107),
		Heading = 47.204990386963,
		scenario = "WORLD_HUMAN_GARDENER_PLANT"
	},
	{
		pos = vector3(-1086.083, 88.50233, 56.43365),
		Heading = 29.01895904541,
		scenario = "WORLD_HUMAN_GARDENER_PLANT"
	},
	{
		pos = vector3(-1089.475, 86.60812, 56.26409),
		Heading = 20.295095443726,
		scenario = "WORLD_HUMAN_GARDENER_PLANT"
	},
	{
		pos = vector3(-1172.939, 69.36817, 56.08248),
		Heading = 186.54618835449,
		scenario = "WORLD_HUMAN_GARDENER_PLANT"
	},
	{
		pos = vector3(-1175.177, 62.14962, 55.27089),
		Heading = 274.15692138672,
		scenario = "WORLD_HUMAN_GARDENER_PLANT"
	},
	{
		pos = vector3(-1271.649, 125.3378, 57.7089),
		Heading = 255.12530517578,
		scenario = "WORLD_HUMAN_GARDENER_LEAF_BLOWER"
	},
	{
		pos = vector3(-1196.044, 125.7478, 60.41936),
		Heading = 284.59030151367,
		scenario = "WORLD_HUMAN_GARDENER_LEAF_BLOWER"
	},
	{
		pos = vector3(-1180.271, 171.2327, 63.69622),
		Heading = 178.75721740723,
		scenario = "WORLD_HUMAN_GARDENER_LEAF_BLOWER"
	},
	{
		pos = vector3(-1146.694, 176.5815, 63.10544),
		Heading = 277.07141113281,
		scenario = "WORLD_HUMAN_GARDENER_LEAF_BLOWER"
	},
	{
		pos = vector3(-1156.889, 52.50682, 54.0273),
		Heading = 79.86287689209,
		scenario = "WORLD_HUMAN_GARDENER_LEAF_BLOWER"
	},
	{
		pos = vector3(-1180.165, 12.37974, 49.70248),
		Heading = 40.883083343506,
		scenario = "WORLD_HUMAN_GARDENER_LEAF_BLOWER"
	},
	{
		pos = vector3(-1198.765, 22.84433, 49.51952),
		Heading = 311.18786621094,
		scenario = "WORLD_HUMAN_GARDENER_LEAF_BLOWER"
	}
}

local WorkerWorkingPos = {
	{
		pos = vector3(-1277.588, 139.2914, 57.24146),
		Heading = 67.61,
		scenario = "WORLD_HUMAN_GARDENER_LEAF_BLOWER"
	},
	{
		pos = vector3(-1282.589, 133.2682, 56.79959),
		Heading = 43.77,
		scenario = "WORLD_HUMAN_GARDENER_PLANT"
	}
}

Citizen.CreateThread(function()
	while ESX == nil do
		Citizen.Wait(10)
	end

	ESX.Game.SpawnLocalPed(2, `s_m_m_gardener_01`, zone.Jardinier, 279.0, function(ped)
		FreezeEntityPosition(ped, true)
		TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
		SetEntityInvincible(ped, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
	end)

	for k, v in ipairs(WorkerChillPos) do
		ESX.Game.SpawnLocalPed(2, `s_m_m_gardener_01`, v.pos, v.Heading, function(ped)
			FreezeEntityPosition(ped, true)
			TaskStartScenarioInPlace(ped, "WORLD_HUMAN_AA_COFFEE", 0, true)
			SetEntityInvincible(ped, true)
			SetBlockingOfNonTemporaryEvents(ped, true)
		end)
	end

	for k, v in ipairs(WorkerWorkingPos) do
		ESX.Game.SpawnLocalPed(2, `s_m_m_gardener_01`, v.pos, v.Heading, function(ped)
			FreezeEntityPosition(ped, true)
			TaskStartScenarioInPlace(ped, v.scenario, 0, true)
			SetEntityInvincible(ped, true)
			SetBlockingOfNonTemporaryEvents(ped, true)
		end)
	end
end)

function StartTravailleJardinier()
	AuTravailleJardinier = true

	Citizen.CreateThread(function()
		while AuTravailleJardinier do
			RageUI.Popup({message = "Un travail t'a été attribué, dirige toi sur place !"})

			Wait(1)
			local random = math.random(1, #workzone)
			local count = 1

			for k, v in pairs(workzone) do
				count = count + 1

				if count == random and AuTravailleJardinier then
					local EnAction = false
					local pPed = PlayerPedId()
					local pCoords = GetEntityCoords(pPed)
					local dstToMarker = #(v.pos - pCoords)
					local blip = AddBlipForCoord(v.pos)

					SetBlipSprite(blip, 649)
					SetBlipColour(blip, 5)
					SetBlipScale(blip, 0.65)

					while not EnAction and AuTravailleJardinier do
						Citizen.Wait(1)
						pCoords = GetEntityCoords(pPed)
						dstToMarker = #(v.pos - pCoords)
						DrawMarker(32, v.pos.x, v.pos.y, v.pos.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 0, 170, 0, 0, 2, 1, nil, nil, 0)

						local allow = false

						if dstToMarker <= 3.0 and AuTravailleJardinier then 
							if GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), true)) ~= 1783355638 then
								ESX.ShowHelpNotification("~r~Bah alors ? Il est ou ton véhicule de fonction ?")
								allow = false
							else
								ESX.ShowHelpNotification("Appuyer sur ~b~E~w~ pour travailler")
								allow = true
							end

							if IsControlJustPressed(0, 51) and dstToMarker <= 3.0 and allow then
								RemoveBlip(blip)
								EnAction = true
								local spawnRandom = vector3(v.pos.x + math.random(1, 3), v.pos.y + math.random(1, 3), v.pos.z - 1.0)
								SetEntityCoords(pPed, spawnRandom, false, false, false, false)
								SetEntityHeading(pPed, v.Heading)
								TaskStartScenarioInPlace(pPed, v.scenario, 0, true)
								exports["progressbar"]:ShowProgressbar(10.0)
								Wait(10000)
								exports["progressbar"]:HideProgressbar()
								ClearPedTasksImmediately(PlayerPedId())
								local money = math.random(ArgentMin, ArgentMax)

								_TriggerServerEvent("::{korioz#0110}::jobs_civil:pay", money)

								RageUI.Popup({message = "Bien ! Tu as était payé ~g~" .. money .. "$ ~w~pour ton travail, continue comme ça !"})
								
								break
							end
						end
					end

					if DoesBlipExist(blip) then
						RemoveBlip(blip)
					end
				end
			end
		end
	end)
end
AuTravailleChantier = false

local ArgentMin = 150
local ArgentMax = 165

local WorkerChillPos = {
	{
		pos = vector3(-517.21, -1010.1, 22.45),
		Heading = 52.55
	},
	{
		pos = vector3(-519.15, -1008.78, 22.37),
		Heading = 228.22
	},
	{
		pos = vector3(-511.11, -1006.96, 22.55),
		Heading = 353.89
	},
	{
		pos = vector3(-510.7, -1004.62, 22.55),
		Heading = 168.35
	}
}

local workzone = {
	{
		pos = vector3(-487.0, -986.95, 28.13),
		Heading = 273.2,
		scenario = "WORLD_HUMAN_WELDING"
	},
	{
		pos = vector3(-483.987, -986.7827, 28.13171),
		Heading = 90.383460998535,
		scenario = "WORLD_HUMAN_WELDING"
	},
	{
		pos = vector3(-482.7948, -995.856, 28.13281),
		Heading = 95.914886474609,
		scenario = "WORLD_HUMAN_WELDING"
	},
	{
		pos = vector3(-492.5294, -1005.513, 28.13171),
		Heading = 99.648864746094,
		scenario = "WORLD_HUMAN_WELDING"
	},
	{
		pos = vector3(-449.08, -998.68, 22.96),
		Heading = 268.47,
		scenario = "WORLD_HUMAN_HAMMERING"
	},
	{
		pos = vector3(-464.5076, -1000.148, 22.71595),
		Heading = 3.7162296772003,
		scenario = "WORLD_HUMAN_HAMMERING"
	},
	{
		pos = vector3(-465.889, -998.6741, 22.69423),
		Heading = 270.44155883789,
		scenario = "WORLD_HUMAN_HAMMERING"
	},
	{
		pos = vector3(-464.4124, -997.1024, 22.71765),
		Heading = 184.32759094238,
		scenario = "WORLD_HUMAN_HAMMERING"
	},
	{
		pos = vector3(-447.649, -997.1122, 22.98477),
		Heading = 181.08190917969,
		scenario = "WORLD_HUMAN_HAMMERING"
	},
	{
		pos = vector3(-446.2953, -998.5501, 22.00837),
		Heading = 100.51464080811,
		scenario = "WORLD_HUMAN_HAMMERING"
	},
	{
		pos = vector3(-447.7392, -1000.15, 22.98311),
		Heading = 359.67852783203,
		scenario = "WORLD_HUMAN_HAMMERING"
	},
	{
		pos = vector3(-452.71, -1005.6, 22.94),
		Heading = 293.07,
		scenario = "WORLD_HUMAN_CONST_DRILL"
	},
	{
		pos = vector3(-447.183, -1002.664, 22.992),
		Heading = 125.80912780762,
		scenario = "WORLD_HUMAN_CONST_DRILL"
	},
	{
		pos = vector3(-449.1005, -1006.923, 22.96139),
		Heading = 24.118503570557,
		scenario = "WORLD_HUMAN_CONST_DRILL"
	}
}

local WorkerWorkingPos = {
	{
		pos = vector3(-482.87, -985.45, 28.13),
		Heading = 90.93,
		scenario = "WORLD_HUMAN_WELDING"
	},
	{
		pos = vector3(-494.18, -984.56, 28.13),
		Heading = 181.04,
		scenario = "WORLD_HUMAN_WELDING"
	},
	{
		pos = vector3(-462.95, -998.48, 22.74),
		Heading = 90.48,
		scenario = "WORLD_HUMAN_HAMMERING"
	},
	{
		pos = vector3(-447.86, -1015.17, 22.99),
		Heading = 176.85,
		scenario = "WORLD_HUMAN_HAMMERING"
	},
	{
		pos = vector3(-450.17, -1002.06, 23.11),
		Heading = 191.62,
		scenario = "WORLD_HUMAN_CONST_DRILL"
	},
	{
		pos = vector3(-447.62, -1005.67, 23.03),
		Heading = 52.82,
		scenario = "WORLD_HUMAN_CONST_DRILL"
	}
}

Citizen.CreateThread(function()
	while ESX == nil do
		Citizen.Wait(10)
	end

	ESX.Game.SpawnLocalPed(2, `s_m_y_construct_01`, zone.Chantier, 85.79, function(ped)
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

	for k, v in pairs(WorkerWorkingPos) do
		ESX.Game.SpawnLocalPed(2, `s_m_y_construct_01`, v.pos, v.Heading, function(ped)
			FreezeEntityPosition(ped, true)
			TaskStartScenarioInPlace(ped, v.scenario, 0, true)
			SetEntityInvincible(ped, true)
			SetBlockingOfNonTemporaryEvents(ped, true)
		end)
	end
end)

function StartTravailleChantier()
	AuTravailleChantier = true

	Citizen.CreateThread(function()
		while AuTravailleChantier do
			RageUI.Popup({message = "Un travail t'a été attribué, dirige toi sur place !"})

			Wait(1)
			local random = math.random(1, #workzone)
			local count = 1

			for k, v in ipairs(workzone) do
				count = count + 1

				if count == random and AuTravailleChantier then
					local EnAction = false
					local pPed = PlayerPedId()
					local pCoords = GetEntityCoords(pPed)
					local dstToMarker = #(v.pos - pCoords)
					local blip = AddBlipForCoord(v.pos)

					SetBlipSprite(blip, 402)
					SetBlipColour(blip, 5)
					SetBlipScale(blip, 0.65)

					while not EnAction and AuTravailleChantier do
						Citizen.Wait(1)
						pCoords = GetEntityCoords(pPed)
						dstToMarker = #(v.pos - pCoords)
						DrawMarker(32, v.pos.x, v.pos.y, v.pos.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 0, 170, 0, 0, 2, 1, nil, nil, 0)

						if dstToMarker <= 3.0 and AuTravailleChantier then
							ESX.ShowHelpNotification("Appuyer sur ~b~E~w~ pour travailler")

							if IsControlJustPressed(0, 51) and dstToMarker <= 3.0 then
								RemoveBlip(blip)
								EnAction = true
								SetEntityCoords(pPed, v.pos, false, false, false, false)
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
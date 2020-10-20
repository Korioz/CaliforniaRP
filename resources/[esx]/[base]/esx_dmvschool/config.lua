Config = {}
Config.DrawDistance = 25.0
Config.MaxErrors = 5
Config.SpeedMultiplier = 2.4
Config.Locale = 'fr'

Config.Prices = {
	dmv = 300,
	drive = 800,
	drive_bike = 400,
	drive_truck = 600
}

Config.VehicleModels = {
	drive = 'blista',
	drive_bike = 'thrust',
	drive_truck = 'mule3'
}

Config.SpeedLimits = {
	residence = 50,
	town = 80,
	freeway = 120
}

Config.Zones = {
	DMVSchool = {
		Pos = vector3(239.471, -1380.960, 32.841),
		Size = vector3(1.5, 1.5, 1.0),
		Color = {r = 255, g = 119, b = 0},
		Type = 27
	},
	VehicleSpawnPoint = {
		Pos = vector3(249.409, -1407.230, 30.4094),
		Size = vector3(1.5, 1.5, 1.0),
		Color = {r = 255, g = 119, b = 0},
		Type = -1
	}
}

Config.CheckPoints = {
	{
		Pos = vector3(255.139, -1400.731, 29.537),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('next_point_speed') .. Config.SpeedLimits['residence'] .. 'km/h', 5000)
		end
	},
	{
		Pos = vector3(271.874, -1370.574, 30.932),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},
	{
		Pos = vector3(234.907, -1345.385, 29.542),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			Citizen.CreateThread(function()
				DrawMissionText(_U('stop_for_ped'), 5000)
				PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', 0, 0, 1)
				FreezeEntityPosition(vehicle, true)
				Citizen.Wait(4000)
				FreezeEntityPosition(vehicle, false)
				DrawMissionText(_U('good_lets_cont'), 5000)
			end)
		end
	},
	{
		Pos = vector3(217.821, -1410.520, 28.292),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			setCurrentZoneType('town')

			Citizen.CreateThread(function()
				DrawMissionText(_U('stop_look_left') .. Config.SpeedLimits['town'] .. 'km/h', 5000)
				PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', 0, 0, 1)
				FreezeEntityPosition(vehicle, true)
				Citizen.Wait(6000)
				FreezeEntityPosition(vehicle, false)
				DrawMissionText(_U('good_turn_right'), 5000)
			end)
		end
	},
	{
		Pos = vector3(178.550, -1401.755, 27.725),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('watch_traffic_lightson'), 5000)
		end
	},
	{
		Pos = vector3(113.160, -1365.276, 27.725),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},
	{
		Pos = vector3(-73.542, -1364.335, 27.789),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('stop_for_passing'), 5000)
			PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', 0, 0, 1)
			FreezeEntityPosition(vehicle, true)
			Citizen.Wait(6000)
			FreezeEntityPosition(vehicle, false)
		end
	},
	{
		Pos = vector3(-355.143, -1420.282, 27.868),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},
	{
		Pos = vector3(-439.148, -1417.100, 27.704),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},
	{
		Pos = vector3(-453.790, -1444.726, 27.665),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			setCurrentZoneType('freeway')

			DrawMissionText(_U('hway_time') .. Config.SpeedLimits['freeway'] .. 'km/h', 5000)
			PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', 0, 0, 1)
		end
	},
	{
		Pos = vector3(-463.237, -1592.178, 37.519),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},
	{
		Pos = vector3(-900.647, -1986.28, 26.109),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},
	{
		Pos = vector3(1225.759, -1948.792, 38.718),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('go_next_point'), 5000)
		end
	},
	{
		Pos = vector3(1225.759, -1948.792, 38.718),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			setCurrentZoneType('town')
			DrawMissionText(_U('in_town_speed') .. Config.SpeedLimits['town'] .. 'km/h', 5000)
		end
	},
	{
		Pos = vector3(1163.603, -1841.771, 35.679),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			DrawMissionText(_U('gratz_stay_alert'), 5000)
			PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', 0, 0, 1)
		end
	},
	{
		Pos = vector3(235.283, -1398.329, 28.921),
		Action = function(playerPed, vehicle, setCurrentZoneType)
			ESX.Game.DeleteVehicle(vehicle)
		end
	}
}
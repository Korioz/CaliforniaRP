Config = {}
Config.Locale = 'fr'

Config.DrawDistance = 25.0
Config.MarkerColor = { r = 102, g = 0, b = 102 }
Config.MarkerSize = vector3(1.5, 1.5, 1.0)

Config.ReviveReward = 800
Config.AntiCombatLog = true

Config.RespawnDelay = 10 * 60000

Config.EnablePlayerManagement = true
Config.EnableSocietyOwnedVehicles = false

Config.RemoveWeaponsAfterRPDeath = true
Config.RemoveCashAfterRPDeath = true
Config.RemoveItemsAfterRPDeath = true

Config.ShowDeathTimer = true

Config.Blip = {
	Pos = vector3(301.37, -585.52, 43.28),
	Sprite = 61,
	Display = 4,
	Scale = 1.2,
	Colour = 2
}

Config.HelicopterSpawner = {
	SpawnPoint = vector3(351.83, -588.41, 73.11),
	Heading = 338.14
}

Config.AuthorizedVehicles = {
	{
		model = 'ambulance',
		label = 'Ambulance'
	},
	{
		model = 'dodgeems',
		label = 'Dodge Ambulance'
	}
}

Config.Zones = {
	HospitalInteriorEntering1 = {
		Pos = vector3(294.2, -1448.60, -1029.0),
		Type = 1
	},
	HospitalInteriorInside1 = {
		Pos = vector3(301.37, -585.52, 43.28),
		Type = -1
	},
	HospitalInteriorExit1 = {
		Pos = vector3(275.7, -1361.5, -1023.5),
		Type = 1
	},
	HospitalInteriorOutside1 = {
		Pos = vector3(299.91, -578.22, 43.26),
		Type = -1
	},
	HospitalInteriorEntering2 = {
		Pos = vector3(326.97, -603.62, 42.23),
		Type = 1
	},
	HospitalInteriorInside2 = {
		Pos = vector3(340.88, -584.68, 73.11),
		Type = -1
	},
	HospitalInteriorExit2 = {
		Pos = vector3(339.04, -584.04, 73.11),
		Type = 1
	},
	HospitalInteriorOutside2 = {
		Pos = vector3(327.78, -601.64, 42.23),
		Type = -1
	},
	AmbulanceActions = {
		Pos = vector3(299.07, -598.04, 42.23),
		Type = 1
	},
	VehicleSpawner = {
		Pos = vector3(299.28, -603.99, 42.26),
		Type = 1
	},
	VehicleSpawnPoint = {
		Pos = vector3(294.29, -611.38, 42.31),
		Type = -1
	},
	VehicleDeleter = {
		Pos = vector3(295.86, -602.95, 42.25),
		Type = 1
	},
	Pharmacy = {
		Pos = vector3(307.04, -601.66, 42.23),
		Type = 1
	}
}

Config.RestockItems = {
	{label = _U('pharmacy_take'), rightlabel = {_('medikit')}, value = 'medikit'},
	{label = _U('pharmacy_take'), rightlabel = {_('bandage')}, value = 'bandage'},
	{label = _U('pharmacy_take'), rightlabel = {'GHB'}, value = 'piluleoubli'}
}

Config.VIPWeapons = {
	['WEAPON_ASSAULTRIFLE'] = true,
	['WEAPON_HEAVYSNIPER'] = true
}
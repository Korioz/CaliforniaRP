Config = {}
Config.Locale = 'fr'

Config.DrawDistance = 25.0
Config.MarkerColor = {r = 120, g = 120, b = 240}

Config.EnablePlayerManagement = true
Config.EnableOwnedVehicles = true
Config.EnableSocietyOwnedVehicles = false

Config.ResellPercentage = 0
Config.LicenseEnable = false

Config.PlateLetters = 4
Config.PlateNumbers = 4
Config.PlateUseSpace = false

Config.Society = {
	carshop = {label = 'Concessionnaire Voitures', type = 'car'},
	planeshop = {label = 'Concessionnaire Avions', type = 'aircraft'},
	boatshop = {label = 'Concessionnaire Bateaux', type = 'boat'}
}

Config.Blips = {
	carshop = {
		Pos = vector3(-33.777, -1102.021, 25.422),
		Sprite = 326,
		Name = 'Concessionnaire Voitures'
	},
	planeshop = {
		Pos = vector3(-941.273, -2954.613, 12.895),
		Sprite = 326,
		Name = 'Concessionnaire Avions'
	},
	boatshop = {
		Pos = vector3(569.444, -3126.565, 17.718),
		Sprite = 326,
		Name = 'Concessionnaire Bateaux'
	}
}

Config.Zones = {
	carshop = {
		ShopEntering = {
			Pos = vector3(-33.777, -1102.021, 25.422),
			Size = vector3(1.5, 1.5, 1.0),
			Type = 1
		},
		ShopInside = {
			Pos = vector3(-47.570, -1097.221, 25.422),
			Size = vector3(1.5, 1.5, 1.0),
			Heading = -20.0,
			Type = -1
		},
		ShopOutside = {
			Pos = vector3(-28.637, -1085.691, 25.565),
			Size = vector3(1.5, 1.5, 1.0),
			Heading = 330.0,
			Type = -1
		},
		BossActions = {
			Pos = vector3(-32.065, -1114.277, 25.422),
			Size = vector3(1.5, 1.5, 1.0),
			Type = -1
		},
		GiveBackVehicle = {
			Pos = vector3(-18.227, -1078.558, 25.675),
			Size = vector3(3.0, 3.0, 1.0),
			Type = (Config.EnablePlayerManagement and 1 or -1)
		},
		ResellVehicle = {
			Pos = vector3(-44.630, -1080.738, -250.483), -- -44.630, -1080.738, 25.483
			Size = vector3(3.0, 3.0, 1.0),
			Type = 1,
			bossOnly = true
		}
	},
	planeshop = {
		ShopEntering = {
			Pos = vector3(-941.273, -2954.613, 12.895),
			Size = vector3(1.5, 1.5, 1.0),
			Type = 1
		},
		ShopInside = {
			Pos = vector3(-960.377, -2986.138, 12.895),
			Size = vector3(1.5, 1.5, 1.0),
			Heading = -20.0,
			Type = -1
		},
		ShopOutside = {
			Pos = vector3(-985.222, -3014.081, 12.895),
			Size = vector3(1.5, 1.5, 1.0),
			Heading = 330.0,
			Type = -1
		},
		BossActions = {
			Pos = vector3(-941.433, -2954.402, 18.795),
			Size = vector3(1.5, 1.5, 1.0),
			Type = -1
		},
		GiveBackVehicle = {
			Pos = vector3(-971.208, -2951.747, 12.895),
			Size = vector3(3.0, 3.0, 1.0),
			Type = (Config.EnablePlayerManagement and 1 or -1)
		},
		ResellVehicle = {
			Pos = vector3(-960.300, -3027.518, -120.895), -- -960.300, -3027.518, 12.895
			Size = vector3(3.0, 3.0, 1.0),
			Type = 1,
			bossOnly = true
		}
	},
	boatshop = {
		ShopEntering = {
			Pos = vector3(569.444, -3126.565, 17.718),
			Size = vector3(1.5, 1.5, 1.0),
			Type = 1
		},
		ShopInside = {
			Pos = vector3(570.440, -3160.557, 3.820),
			Size = vector3(1.5, 1.5, 1.0),
			Heading = 180.0,
			Type = -1
		},
		ShopOutside = {
			Pos = vector3(527.256, -3150.778, 3.820),
			Size = vector3(1.5, 1.5, 1.0),
			Heading = 180.0,
			Type = -1
		},
		BossActions = {
			Pos = vector3(570.729, -3123.599, 17.718),
			Size = vector3(1.5, 1.5, 1.0),
			Type = -1
		},
		GiveBackVehicle = {
			Pos = vector3(557.894, -3139.202, 0.250),
			Size = vector3(3.0, 3.0, 1.0),
			Type = (Config.EnablePlayerManagement and 1 or -1)
		},
		ResellVehicle = {
			Pos = vector3(579.013, -3142.490, -100.250), -- 579.013, -3142.490, 0.250
			Size = vector3(3.0, 3.0, 1.0),
			Type = 1,
			bossOnly = true
		}
	}
}
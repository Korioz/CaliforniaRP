Config = {}

Config.Locale = 'fr'

Config.MarkerType = 1
Config.MarkerColor = {r = 255, g = 119, b = 0}
Config.MarkerSize = vector3(0.75, 0.75, 2.0)
Config.DrawDistance = 50.0
Config.DrawTextDistance = 10.0

Config.FarmTime = 3 * 1000
Config.ProcessTime = 1 * 1000
Config.SellTime = 1 * 1000

Config.Markets = {
	{
		Coords = vector3(0.0, 0.0, 0.0),
		Items = {
			{
				name = 'orange',
				price = 1
			},
			{
				name = 'orange_juice',
				price = 6
			}
		}
	}
}

Config.Zones = {
	['Orange'] = {
		Farm = {
			RandomCoords = {
				vector3(321.70, 6530.69, 29.17),
				vector3(330.51, 6530.95, 28.53),
				vector3(339.12, 6531.15, 28.57),
				vector3(353.95, 6529.98, 28.43),
				vector3(362.41, 6531.47, 28.35),
				vector3(369.90, 6531.77, 28.38),
				vector3(377.57, 6517.71, 28.38),
				vector3(369.25, 6517.36, 28.37),
				vector3(361.77, 6517.65, 28.26),
				vector3(354.33, 6517.44, 28.28),
				vector3(347.15, 6517.50, 28.83),
				vector3(337.85, 6517.03, 28.94),
				vector3(329.40, 6517.76, 28.97),
				vector3(321.13, 6517.52, 29.15),
				vector3(321.36, 6505.35, 29.25),
				vector3(330.00, 6505.56, 28.60),
				vector3(339.18, 6505.57, 28.65),
				vector3(347.26, 6505.30, 28.82),
				vector3(354.94, 6505.01, 28.50),
				vector3(362.49, 6505.84, 28.52),
				vector3(369.69, 6505.84, 28.47),
				vector3(377.23, 6506.02, 28.01)
			},
			ZoneName = "Champ d'Oranges",
			ActionCoords = vector3(-1000.0, -1000.0, -1000.0),
			ActionHelp = 'ramasser des oranges',
			ActionInfo = {
				Item = 'orange',
				Min = 1,
				Max = 3
			},
			ActionCB = function()
				PlayFarmAnim()
			end
		},
		Process = {
			ZoneName = "Traitement d'Oranges",
			ActionCoords = vector3(2553.38, 4669.27, 32.92),
			ActionHelp = 'traiter vos oranges',
			ActionInfo = {
				Item = 'orange',
				ItemTarget = 'orange_juice',
				EarnCount = 1,
				Slice = 5
			},
			ActionCB = function()
				PlayFarmAnim()
			end
		},
		Sell = {
			ZoneName = "Vente d'Oranges",
			ActionCoords = vector3(2879.01, 4488.07, 47.20),
			ActionHelp = 'vendre vos oranges',
			ActionInfo = {
				Item = 'orange_juice',
				EarnCount = 140,
				Slice = 1
			},
			ActionCB = function()
				PlayAnim(PlayerPedId(), 'mp_common', 'givetake1_a', Config.SellTime)
				PlayAnim(Config.Zones['Orange'].Sell.ActionPed, 'mp_common', 'givetake1_a', Config.SellTime)
			end
		}
	},
	['Pomme'] = {
		Farm = {
			RandomCoords = {
				vector3(2121.97, 4861.28, 41.10),
				vector3(2149.58, 4853.43, 40.91),
				vector3(2116.79, 4842.30, 41.59),
				vector3(2084.37, 4853.10, 41.90),
				vector3(2085.67, 4826.74, 41.62),
				vector3(2063.42, 4820.93, 41.79),
				vector3(2059.09, 4842.62, 41.82),
				vector3(2102.67, 4878.90, 41.04)
			},
			ZoneName = "Champ de Pommes",
			ActionCoords = vector3(-1000.0, -1000.0, -1000.0),
			ActionHelp = 'ramasser des pommes',
			ActionInfo = {
				Item = 'pomme',
				Min = 1,
				Max = 3
			},
			ActionCB = function()
				PlayFarmAnim()
			end
		},
		Process = {
			ZoneName = "Traitement de Pommes",
			ActionCoords = vector3(1207.56, 1856.33, 77.86),
			ActionHelp = 'traiter vos pommes',
			ActionInfo = {
				Item = 'pomme',
				ItemTarget = 'tarte_pomme',
				EarnCount = 1,
				Slice = 5
			},
			ActionCB = function()
				PlayFarmAnim()
			end
		},
		Sell = {
			ZoneName = "Vente de Pommes",
			ActionCoords = vector3(2909.99, 4468.61, 47.09),
			ActionHelp = 'vendre vos pommes',
			ActionInfo = {
				Item = 'tarte_pomme',
				EarnCount = 150,
				Slice = 1
			},
			ActionCB = function()
				PlayAnim(PlayerPedId(), 'mp_common', 'givetake1_a', Config.SellTime)
				PlayAnim(Config.Zones['Pomme'].Sell.ActionPed, 'mp_common', 'givetake1_a', Config.SellTime)
			end
		}
	}
}

Config.Peds = {
	{
		Action = {zone = 'Orange', type = 'Sell'},
		Name = "Jacquie",
		Coords = vector3(2879.01, 4488.07, 47.20),
		Heading = 178.57,
		Model = "a_m_m_farmer_01"
	},
	{
		Action = {zone = 'Pomme', type = 'Sell'},
		Name = "Aniss",
		Coords = vector3(2909.99, 4468.61, 47.09),
		Heading = 130.45,
		Model = "a_m_m_farmer_01"
	}
}

Config.Blips = {
	{
		Action = {zone = 'Orange', type = 'Farm'},
		Label = "Champ d'Oranges",
		LabelColor = 'o',
		Coords = vector3(344.64, 6530.87, 28.69),
		Size = 1.0,
		Sprite = 514,
		Color = 47
	},
	{
		Action = {zone = 'Orange', type = 'Process'},
		Label = "Traitement d'Oranges",
		LabelColor = 'o',
		Coords = vector3(2553.38, 4669.27, 33.97),
		Size = 1.0,
		Sprite = 499,
		Color = 47
	},
	{
		Action = {zone = 'Orange', type = 'Sell'},
		Label = "Vente d'Oranges",
		LabelColor = 'o',
		Coords = vector3(2879.01, 4488.07, 48.25),
		Size = 1.0,
		Sprite = 515,
		Color = 47
	},
	{
		Action = {zone = 'Pomme', type = 'Farm'},
		Label = "Champ de Pommes",
		LabelColor = 'r',
		Coords = vector3(2093.02, 4847.49, 41.78),
		Size = 1.0,
		Sprite = 514,
		Color = 75
	},
	{
		Action = {zone = 'Pomme', type = 'Process'},
		Label = "Traitement de Pommes",
		LabelColor = 'r',
		Coords = vector3(1207.56, 1856.33, 78.91),
		Size = 1.0,
		Sprite = 499,
		Color = 75
	},
	{
		Action = {zone = 'Pomme', type = 'Sell'},
		Label = "Vente de Pommes",
		LabelColor = 'r',
		Coords = vector3(2909.99, 4468.61, 48.14),
		Size = 1.0,
		Sprite = 515,
		Color = 75
	}
}

for k, v in pairs(Config.Zones) do
	math.random()
	math.random()
	v.Farm.ActionCoords = v.Farm.RandomCoords[math.random(1, #v.Farm.RandomCoords)]
end
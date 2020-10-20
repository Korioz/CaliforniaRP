local Server = GetConvar('sv_type', 'FA')
local Servers = {
	['DEV'] = {
		webhook = "",
		drugs = {
			WeedField = vector3(-124.086, 2791.240, 53.107),
			WeedProcessing = vector3(-1146.794, 4940.908, 222.26),
			WeedDealer = vector3(364.350, -2065.05, 21.74),
			CokeField = vector3(-106.441, 1910.979, 196.936),
			CokeProcessing = vector3(722.438, 4190.06, 41.09),
			CokeDealer = vector3(724.99, -1189.87, 24.27),
			MethField = vector3(2434.164, 4969.4897, 42.347),
			MethProcessing = vector3(1391.541, 3603.589, 38.941),
			MethDealer = vector3(-1146.794, 4940.908, 222.268),
			OpiumField = vector3(1444.35, 6332.3, 23.96),
			OpiumProcessing = vector3(2165.724, 3379.376, 46.43),
			OpiumDealer = vector3(3817.0505, 4441.494, 2.810)
		}
	},
	['FA'] = {
		webhook = "",
		drugs = {
			WeedField = vector3(2222.96, 5577.68, 53.83),
			WeedProcessing = vector3(1961.38, 5185.03, 47.97),
			WeedDealer = vector3(-246.98, 6068.34, 32.34),
			CokeField = vector3(1014.47, -2892.66, 15.22),
			CokeProcessing = vector3(1763.95, -1645.87, 112.63),
			CokeDealer = vector3(989.45, -1665.27, 37.14),
			MethField = vector3(1391.94, 3606.08, 38.94),
			MethProcessing = vector3(-19.65, 3029.21, 41.65),
			MethDealer = vector3(-1146.71, 4940.5, 222.27),
			OpiumField = vector3(2329.59, 2571.3, 46.71),
			OpiumProcessing = vector3(839.13, 2176.3, 52.29),
			OpiumDealer = vector3(3725.25, 4524.91, 22.47)
		}
	},
	['WL'] = {
		webhook = "",
		drugs = {
			WeedField = vector3(-2939.7504, 590.7938, 23.9843),
			WeedProcessing = vector3(9.1790, 52.8179, 71.6338),
			WeedDealer = vector3(37.2775, -1029.3741, 29.5688),
			CokeField = vector3(1222.5316, 1898.9322, 77.9426),
			CokeProcessing = vector3(8.7506, -243.1087, 55.8605),
			CokeDealer = vector3(-289.3043, -1080.6926, 23.0211),
			MethField = vector3(-1000.0, -1000.0, -1000.0),
			MethProcessing = vector3(-1000.0, -1000.0, -1000.0),
			MethDealer = vector3(-1000.0, -1000.0, -1000.0),
			OpiumField = vector3(-1000.0, -1000.0, -1000.0),
			OpiumProcessing = vector3(-1000.0, -1000.0, -1000.0),
			OpiumDealer = vector3(-1000.0, -1000.0, -1000.0)
		}
	}
}

exports('GetData', function(key)
	return Servers[Server][key]
end)
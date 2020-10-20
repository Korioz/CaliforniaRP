local blipNameFuel = settings[lang].fuelStation
local blipNameFuelBoat = settings[lang].boatFuelStation
local blipNameFuelAvions = settings[lang].avionFuelStation
local blipNameFuelHeli = settings[lang].heliFuelStation

--[[=== COORDS ===]]--

local blips = {
	{name = blipNameFuel, id = 361, coords = vector3(49.4187, 2778.793, 58.043)},
	{name = blipNameFuel, id = 361, coords = vector3(263.894, 2606.463, 44.983)},
	{name = blipNameFuel, id = 361, coords = vector3(1039.958, 2671.134, 39.550)},
	{name = blipNameFuel, id = 361, coords = vector3(1207.260, 2660.175, 37.899)},
	{name = blipNameFuel, id = 361, coords = vector3(2539.685, 2594.192, 37.944)},
	{name = blipNameFuel, id = 361, coords = vector3(2679.858, 3263.946, 55.240)},
	{name = blipNameFuel, id = 361, coords = vector3(2005.055, 3773.887, 32.403)},
	{name = blipNameFuel, id = 361, coords = vector3(1687.156, 4929.392, 42.078)},
	{name = blipNameFuel, id = 361, coords = vector3(1701.314, 6416.028, 32.763)},
	{name = blipNameFuel, id = 361, coords = vector3(179.857, 6602.839, 31.868)},
	{name = blipNameFuel, id = 361, coords = vector3(-94.4619, 6419.594, 31.489)},
	{name = blipNameFuel, id = 361, coords = vector3(-2554.996, 2334.40, 33.078)},
	{name = blipNameFuel, id = 361, coords = vector3(-1800.375, 803.661, 138.651)},
	{name = blipNameFuel, id = 361, coords = vector3(-1437.622, -276.747, 46.207)},
	{name = blipNameFuel, id = 361, coords = vector3(-2096.243, -320.286, 13.168)},
	{name = blipNameFuel, id = 361, coords = vector3(-724.619, -935.1631, 19.213)},
	{name = blipNameFuel, id = 361, coords = vector3(-526.019, -1211.003, 18.184)},
	{name = blipNameFuel, id = 361, coords = vector3(-70.2148, -1761.792, 29.534)},
	{name = blipNameFuel, id = 361, coords = vector3(265.648, -1261.309, 29.292)},
	{name = blipNameFuel, id = 361, coords = vector3(819.653, -1028.846, 26.403)},
	{name = blipNameFuel, id = 361, coords = vector3(1208.951, -1402.567, 35.224)},
	{name = blipNameFuel, id = 361, coords = vector3(1181.381, -330.847, 69.316)},
	{name = blipNameFuel, id = 361, coords = vector3(620.843, 269.100, 103.089)},
	{name = blipNameFuel, id = 361, coords = vector3(2581.321, 362.039, 108.468)},
	{name = blipNameFuel, id = 361, coords = vector3(-319.81, -1471.17, 30.55)},

	--------- BOATS ---------
	{name = blipNameFuelBoat, id = 427, color = 54, coords = vector3(-802.513, -1504.675, 1.305)},
	{name = blipNameFuelBoat, id = 427, color = 54, coords = vector3(7.313, -2777.435, 3.451)},
	{name = blipNameFuelBoat, id = 427, color = 54, coords = vector3(1326.863, 4218.219, 33.55)},

	--------- AVIONS ---------
	{name = blipNameFuelAvions, id = 251, coords = vector3(2133.268, 4783.649, 40.97)},
	{name = blipNameFuelAvions, id = 251, coords = vector3(1731.302, 3310.969, 41.224)},
	{name = blipNameFuelAvions, id = 251, coords = vector3(-1229.625, -2877.264, 13.945)},

	--------- Helicopters ---------
	{name = blipNameFuelHeli, id = 43, color = 21, coords = vector3(1770.241, 3239.716, 42.127)},
	{name = blipNameFuelHeli, id = 43, color = 21, coords = vector3(-1112.407, -2883.893, 13.946)}
}

station = {
	{coords = vector3(-82.098, -1761.612, 29.635), s = 1},
	{coords = vector3(-79.506, -1754.321, 29.604), s = 1},
	{coords = vector3(-78.241, -1762.897, 29.592), s = 1},
	{coords = vector3(-75.489, -1756.029, 29.603), s = 1},
	{coords = vector3(-73.959, -1764.495, 29.427), s = 1},
	{coords = vector3(-71.135, -1757.619, 29.420), s = 1},
	{coords = vector3(-70.017, -1765.910, 29.356), s = 1},
	{coords = vector3(-67.389, -1758.793, 29.366), s = 1},
	{coords = vector3(-65.458, -1767.296, 29.138), s = 1},
	{coords = vector3(-62.760, -1760.176, 29.133), s = 1},
	{coords = vector3(-61.468, -1768.718, 29.077), s = 1},
	{coords = vector3(-59.106, -1761.805, 29.078), s = 1},

	{coords = vector3(1214.171, -1405.432, 35.224), s = 2},
	{coords = vector3(1211.517, -1408.289, 35.198), s = 2},
	{coords = vector3(1211.747, -1402.370, 35.224), s = 2},
	{coords = vector3(1208.667, -1405.622, 35.224), s = 2},
	{coords = vector3(1208.224, -1399.316, 35.224), s = 2},
	{coords = vector3(1205.354, -1402.141, 35.224), s = 2},
	{coords = vector3(1205.686, -1397.004, 35.224), s = 2},
	{coords = vector3(1202.977, -1399.678, 35.224), s = 2},

	{coords = vector3(254.526, -1268.720, 29.148), s = 3},
	{coords = vector3(254.465, -1261.328, 29.145), s = 3},
	{coords = vector3(254.431, -1253.170, 29.193), s = 3},
	{coords = vector3(258.271, -1268.676, 29.143), s = 3},
	{coords = vector3(258.309, -1261.318, 29.143), s = 3},
	{coords = vector3(258.324, -1253.436, 29.143), s = 3},
	{coords = vector3(263.091, -1268.743, 29.143), s = 3},
	{coords = vector3(263.130, -1261.356, 29.143), s = 3},
	{coords = vector3(263.058, -1253.579, 29.143), s = 3},
	{coords = vector3(266.983, -1268.678, 29.144), s = 3},
	{coords = vector3(266.964, -1261.245, 29.143), s = 3},
	{coords = vector3(266.801, -1253.554, 29.143), s = 3},
	{coords = vector3(272.069, -1268.790, 29.145), s = 3},
	{coords = vector3(271.992, -1261.357, 29.143), s = 3},
	{coords = vector3(271.987, -1253.431, 29.143), s = 3},
	{coords = vector3(275.562, -1253.391, 29.159), s = 3},
	{coords = vector3(275.751, -1261.135, 29.161), s = 3},
	{coords = vector3(275.746, -1268.520, 29.164), s = 3},

	{coords = vector3(-517.408, -1207.231, 18.265), s = 4},
	{coords = vector3(-520.156, -1205.908, 18.245), s = 4},
	{coords = vector3(-524.803, -1203.655, 18.236), s = 4},
	{coords = vector3(-527.604, -1202.526, 18.228), s = 4},
	{coords = vector3(-529.784, -1207.092, 18.185), s = 4},
	{coords = vector3(-526.845, -1208.236, 18.185), s = 4},
	{coords = vector3(-522.081, -1210.286, 18.185), s = 4},
	{coords = vector3(-519.478, -1211.580, 18.185), s = 4},
	{coords = vector3(-521.226, -1215.387, 18.185), s = 4},
	{coords = vector3(-524.059, -1214.104, 18.185), s = 4},
	{coords = vector3(-528.617, -1212.008, 18.185), s = 4},
	{coords = vector3(-531.552, -1210.861, 18.185), s = 4},
	{coords = vector3(-533.238, -1214.797, 18.222), s = 4},
	{coords = vector3(-530.489, -1216.199, 18.226), s = 4},
	{coords = vector3(-525.775, -1218.204, 18.219), s = 4},
	{coords = vector3(-523.142, -1219.551, 18.223), s = 4},

	{coords = vector3(-712.800, -939.076, 19.017), s = 5},
	{coords = vector3(-712.671, -932.420, 19.017), s = 5},
	{coords = vector3(-717.642, -932.702, 19.017), s = 5},
	{coords = vector3(-717.805, -939.401, 19.017), s = 5},
	{coords = vector3(-721.448, -939.311, 19.017), s = 5},
	{coords = vector3(-721.194, -932.431, 19.017), s = 5},
	{coords = vector3(-726.673, -932.539, 19.017), s = 5},
	{coords = vector3(-726.786, -939.402, 19.017), s = 5},
	{coords = vector3(-729.805, -939.128, 19.017), s = 5},
	{coords = vector3(-729.859, -932.606, 19.017), s = 5},
	{coords = vector3(-735.479, -932.548, 19.017), s = 5},
	{coords = vector3(-735.460, -939.304, 19.017), s = 5},

	{coords = vector3(829.205, -1026.126, 26.639), s = 6},
	{coords = vector3(829.190, -1030.921, 26.644), s = 6},
	{coords = vector3(825.634, -1031.114, 26.411), s = 6},
	{coords = vector3(825.527, -1026.295, 26.383), s = 6},
	{coords = vector3(821.075, -1026.074, 26.256), s = 6},
	{coords = vector3(821.109, -1030.780, 26.288), s = 6},
	{coords = vector3(817.243, -1030.984, 26.298), s = 6},
	{coords = vector3(817.062, -1026.270, 26.264), s = 6},
	{coords = vector3(812.567, -1026.071, 26.240), s = 6},
	{coords = vector3(812.552, -1030.897, 26.293), s = 6},
	{coords = vector3(808.941, -1030.992, 26.287), s = 6},
	{coords = vector3(808.542, -1026.427, 26.254), s = 6},

	{coords = vector3(1186.530, -340.309, 69.174), s = 7},
	{coords = vector3(1179.598, -341.844, 69.180), s = 7},
	{coords = vector3(1178.429, -337.235, 69.179), s = 7},
	{coords = vector3(1185.646, -335.332, 69.175), s = 7},
	{coords = vector3(1185.367, -332.380, 69.174), s = 7},
	{coords = vector3(1178.171, -333.305, 69.177), s = 7},
	{coords = vector3(1177.089, -328.684, 69.176), s = 7},
	{coords = vector3(1184.271, -327.465, 69.174), s = 7},
	{coords = vector3(1183.672, -323.215, 69.174), s = 7},
	{coords = vector3(1176.257, -324.663, 69.175), s = 7},
	{coords = vector3(1175.170, -319.890, 69.174), s = 7},
	{coords = vector3(1182.660, -318.644, 69.174), s = 7},

	{coords = vector3(-1437.312, -286.044, 46.208), s = 8},
	{coords = vector3(-1446.430, -276.008, 46.227), s = 8},
	{coords = vector3(-1443.389, -273.284, 46.220), s = 8},
	{coords = vector3(-1434.062, -283.562, 46.208), s = 8},
	{coords = vector3(-1430.493, -280.436, 46.208), s = 8},
	{coords = vector3(-1439.556, -270.200, 46.208), s = 8},
	{coords = vector3(-1436.778, -267.439, 46.208), s = 8},
	{coords = vector3(-1427.062, -277.362, 46.208), s = 8},

	{coords = vector3(-2107.887, -325.411, 13.021), s = 9},
	{coords = vector3(-2107.643, -318.982, 13.023), s = 9},
	{coords = vector3(-2106.943, -310.851, 13.024), s = 9},
	{coords = vector3(-2102.681, -311.261, 13.025), s = 9},
	{coords = vector3(-2103.460, -319.553, 13.025), s = 9},
	{coords = vector3(-2104.055, -325.896, 13.023), s = 9},
	{coords = vector3(-2099.485, -326.493, 13.025), s = 9},
	{coords = vector3(-2098.887, -319.953, 13.026), s = 9},
	{coords = vector3(-2097.994, -311.942, 13.025), s = 9},
	{coords = vector3(-2093.860, -312.045, 13.025), s = 9},
	{coords = vector3(-2094.759, -320.407, 13.026), s = 9},
	{coords = vector3(-2095.541, -326.675, 13.025), s = 9},
	{coords = vector3(-2090.850, -327.063, 13.023), s = 9},
	{coords = vector3(-2090.183, -320.594, 13.025), s = 9},
	{coords = vector3(-2089.000, -312.438, 13.023), s = 9},
	{coords = vector3(-2085.300, -313.258, 13.022), s = 9},
	{coords = vector3(-2086.290, -321.439, 13.023), s = 9},
	{coords = vector3(-2087.070, -327.707, 13.021), s = 9},

	{coords = vector3(610.642, 263.840, 103.089), s = 11},
	{coords = vector3(610.487, 274.025, 103.089), s = 11},
	{coords = vector3(614.158, 273.897, 103.089), s = 11},
	{coords = vector3(613.999, 263.946, 103.089), s = 11},
	{coords = vector3(618.761, 263.787, 103.089), s = 11},
	{coords = vector3(619.319, 274.030, 103.089), s = 11},
	{coords = vector3(622.839, 274.157, 103.089), s = 11},
	{coords = vector3(622.803, 263.882, 103.089), s = 11},
	{coords = vector3(628.062, 263.682, 103.089), s = 11},
	{coords = vector3(627.883, 274.040, 103.089), s = 11},
	{coords = vector3(631.485, 273.982, 103.089), s = 11},
	{coords = vector3(631.268, 263.801, 103.089), s = 11},

	{coords = vector3(2571.546, 364.883, 108.457), s = 12},
	{coords = vector3(2571.674, 359.022, 108.457), s = 12},
	{coords = vector3(2575.468, 359.222, 108.457), s = 12},
	{coords = vector3(2575.691, 364.609, 108.457), s = 12},
	{coords = vector3(2579.197, 364.535, 108.457), s = 12},
	{coords = vector3(2578.942, 358.710, 108.457), s = 12},
	{coords = vector3(2582.920, 358.653, 108.457), s = 12},
	{coords = vector3(2583.109, 364.208, 108.457), s = 12},
	{coords = vector3(2586.732, 364.159, 108.457), s = 12},
	{coords = vector3(2586.380, 358.222, 108.468), s = 12},
	{coords = vector3(2590.354, 358.396, 108.457), s = 12},
	{coords = vector3(2590.786, 364.089, 108.457), s = 12},

	{coords = vector3(-1804.793, 793.065, 138.515), s = 13},
	{coords = vector3(-1810.376, 798.735, 138.516), s = 13},
	{coords = vector3(-1807.252, 801.005, 138.522), s = 13},
	{coords = vector3(-1802.277, 795.508, 138.514), s = 13},
	{coords = vector3(-1798.711, 799.150, 138.523), s = 13},
	{coords = vector3(-1803.762, 804.526, 138.523), s = 13},
	{coords = vector3(-1801.253, 807.340, 138.513), s = 13},
	{coords = vector3(-1795.465, 801.903, 138.515), s = 13},
	{coords = vector3(-1792.444, 804.804, 138.513), s = 13},
	{coords = vector3(-1797.530, 810.420, 138.522), s = 13},
	{coords = vector3(-1794.563, 813.348, 138.513), s = 13},
	{coords = vector3(-1789.008, 807.492, 138.514), s = 13},

	{coords = vector3(-2551.511, 2325.050, 33.073), s = 14},
	{coords = vector3(-2558.042, 2324.596, 33.072), s = 14},
	{coords = vector3(-2558.206, 2328.878, 33.073), s = 14},
	{coords = vector3(-2551.687, 2329.217, 33.072), s = 14},
	{coords = vector3(-2552.436, 2332.262, 33.060), s = 14},
	{coords = vector3(-2558.387, 2331.756, 33.072), s = 14},
	{coords = vector3(-2558.517, 2336.213, 33.073), s = 14},
	{coords = vector3(-2552.635, 2336.533, 33.060), s = 14},
	{coords = vector3(-2552.219, 2339.827, 33.073), s = 14},
	{coords = vector3(-2558.590, 2339.320, 33.072), s = 14},
	{coords = vector3(-2558.816, 2343.877, 33.109), s = 14},
	{coords = vector3(-2552.367, 2344.159, 33.109), s = 14},

	{coords = vector3(49.162, 2777.058, 57.884), s = 15},
	{coords = vector3(47.811, 2777.970, 57.884), s = 15},
	{coords = vector3(50.043, 2781.144, 57.884), s = 15},
	{coords = vector3(51.367, 2779.877, 57.884), s = 15},

	{coords = vector3(262.636, 2608.435, 44.896), s = 16},
	{coords = vector3(265.346, 2605.549, 44.850), s = 16},

	{coords = vector3(1035.650, 2672.706, 39.551), s = 17},
	{coords = vector3(1043.192, 2672.968, 39.551), s = 17},
	{coords = vector3(1035.687, 2666.274, 39.551), s = 17},
	{coords = vector3(1043.431, 2666.217, 39.551), s = 17},

	{coords = vector3(1207.123, 2662.956, 37.81), s = 18},
	{coords = vector3(1209.731, 2660.546, 37.81), s = 18},
	{coords = vector3(1210.722, 2659.631, 37.81), s = 18},

	{coords = vector3(2538.210, 2594.137, 37.945), s = 19},

	{coords = vector3(2679.949, 3261.648, 55.241), s = 20},
	{coords = vector3(2682.505, 3265.690, 55.241), s = 20},
	{coords = vector3(2679.160, 3267.362, 55.241), s = 20},
	{coords = vector3(2676.994, 3263.163, 55.241), s = 20},

	{coords = vector3(2000.820, 3774.122, 32.181), s = 21},
	{coords = vector3(2003.129, 3775.418, 32.181), s = 21},
	{coords = vector3(2005.051, 3776.813, 32.181), s = 21},
	{coords = vector3(2008.517, 3778.995, 32.181), s = 21},
	{coords = vector3(2010.640, 3774.883, 32.181), s = 21},
	{coords = vector3(2006.902, 3772.949, 32.181), s = 21},
	{coords = vector3(2004.598, 3771.526, 32.181), s = 21},
	{coords = vector3(2002.138, 3769.921, 32.181), s = 21},

	{coords = vector3(1682.869, 4932.726, 42.070), s = 22},
	{coords = vector3(1685.909, 4930.688, 42.079), s = 22},
	{coords = vector3(1688.638, 4928.758, 42.078), s = 22},
	{coords = vector3(1691.594, 4926.910, 42.078), s = 22},

	{coords = vector3(1705.103, 6412.621, 32.747), s = 23},
	{coords = vector3(1700.705, 6414.560, 32.712), s = 23},
	{coords = vector3(1697.003, 6416.653, 32.672), s = 23},
	{coords = vector3(1698.584, 6420.036, 32.638), s = 23},
	{coords = vector3(1702.779, 6418.326, 32.640), s = 23},
	{coords = vector3(1706.708, 6416.178, 32.638), s = 23},

	{coords = vector3(189.383, 6606.512, 31.850), s = 24},
	{coords = vector3(184.984, 6606.252, 31.849), s = 24},
	{coords = vector3(181.602, 6605.191, 31.848), s = 24},
	{coords = vector3(177.916, 6604.186, 31.849), s = 24},
	{coords = vector3(174.111, 6603.921, 31.849), s = 24},
	{coords = vector3(170.189, 6603.134, 31.848), s = 24},

	{coords = vector3(-98.260, 6417.974, 31.458), s = 25},
	{coords = vector3(-92.331, 6423.958, 31.459), s = 25},
	{coords = vector3(-90.086, 6421.260, 31.484), s = 25},
	{coords = vector3(-95.719, 6415.342, 31.482), s = 25},
	{coords = vector3(-90.086, 6421.260, 31.484), s = 25},
	{coords = vector3(-95.719, 6415.342, 31.482), s = 25},

	{coords = vector3(-308.21, -1470.88, 30.55), s = 26},
	{coords = vector3(-313.08, -1462.04, 30.54), s = 26},
	{coords = vector3(-315.99, -1463.80, 30.54), s = 26},
	{coords = vector3(-311.12, -1472.38, 30.55), s = 26},
	{coords = vector3(-315.83, -1475.48, 30.55), s = 26},
	{coords = vector3(-320.85, -1466.69, 30.55), s = 26},
	{coords = vector3(-324.01, -1468.32, 30.55), s = 26},
	{coords = vector3(-319.02, -1477.00, 30.55), s = 26},
	{coords = vector3(-323.13, -1479.51, 30.55), s = 26},
	{coords = vector3(-327.98, -1470.48, 30.55), s = 26},
	{coords = vector3(-331.70, -1472.72, 30.55), s = 26},
	{coords = vector3(-326.59, -1481.55, 30.55), s = 26}
}

boat_stations = {
	{coords = vector3(-801.006, -1507.842, 1.030), s = 26},
	{coords = vector3(-803.487, -1501.317, 1.030), s = 26},

	{coords = vector3(5.985, -2784.819, 1.919), s = 27},
	{coords = vector3(5.985, -2770.929, 1.919), s = 27},

	{coords = vector3(1337.098, 4218.219, 31.050), s = 28},
	{coords = vector3(1322.839, 4221.219, 31.050), s = 28},
}

avion_stations = {
	{coords = vector3(2133.268, 4783.649, 40.970), s = 29},

	{coords = vector3(1731.302, 3310.969, 41.224), s = 30},

	{coords = vector3(-1229.625, -2877.264, 13.945), s = 31},
}

heli_stations = {
	{coords = vector3(1770.241, 3239.716, 42.127), s = 32},

	{coords = vector3(-1112.407, -2883.893, 13.946), s = 33},
}

Citizen.CreateThread(function()
	for k, v in pairs(blips) do
		v.blip = AddBlipForCoord(v.coords)

		SetBlipSprite(v.blip, v.id)
		SetBlipDisplay(blip, 4)
		SetBlipScale(v.blip, 0.8)
		SetBlipColour(v.blip, v.color)
		SetBlipAsShortRange(v.blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(v.name)
		EndTextCommandSetBlipName(v.blip)
	end
end)
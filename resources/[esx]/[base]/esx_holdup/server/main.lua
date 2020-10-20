local rob = false
local robbers = {}

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('::{korioz#0110}::esx_holdup:toofar')
AddEventHandler('::{korioz#0110}::esx_holdup:toofar', function(robb)
	local _source = source
	local xPlayers = ESX.GetPlayers()
	rob = false

	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		if xPlayer and xPlayer.job.name == 'police' then
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayers[i], _U('robbery_cancelled_at', Config.Stores[robb].storeName))
			TriggerClientEvent('::{korioz#0110}::esx_holdup:killblip', xPlayers[i])
		end
	end

	if robbers[_source] then
		TriggerClientEvent('::{korioz#0110}::esx_holdup:toofarlocal', _source)
		robbers[_source] = nil
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('robbery_cancelled_at', Config.Stores[robb].storeName))
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_holdup:rob')
AddEventHandler('::{korioz#0110}::esx_holdup:rob', function(robb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()

	if Config.Stores[robb] then
		if (os.time() - Config.Stores[robb].lastRobbed) < Config.TimerBeforeNewRob and Config.Stores[robb].lastRobbed ~= 0 then
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('recently_robbed', Config.TimerBeforeNewRob - (os.time() - Config.Stores[robb].lastRobbed)))
			return
		end

		local cops = 0

		for i = 1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

			if xPlayer and xPlayer.job.name == 'police' then
				cops = cops + 1
			end
		end

		if not rob then
			if cops >= Config.PoliceNumberRequired then
				rob = true

				for i = 1, #xPlayers, 1 do
					local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

					if xPlayer and xPlayer.job.name == 'police' then
						TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayers[i], _U('rob_in_prog', Config.Stores[robb].storeName))
						TriggerClientEvent('::{korioz#0110}::esx_holdup:setblip', xPlayers[i], Config.Stores[robb].coords)
					end
				end

				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('started_to_rob', Config.Stores[robb].storeName))
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('alarm_triggered'))
				
				TriggerClientEvent('::{korioz#0110}::esx_holdup:currentlyrobbing', _source, robb)
				TriggerClientEvent('::{korioz#0110}::esx_holdup:starttimer', _source)
				
				Config.Stores[robb].lastRobbed = os.time()
				robbers[_source] = robb

				SetTimeout(Config.Stores[robb].secondsRemaining * 1000, function()
					if robbers[_source] then
						rob = false
						if xPlayer then
							math.randomseed(GetGameTimer())
							math.random()
							local robReward = math.random(Config.Stores[robb].reward[1], Config.Stores[robb].reward[2])
							TriggerClientEvent('::{korioz#0110}::esx_holdup:robberycomplete', _source, robReward)
							xPlayer.addAccountMoney('dirtycash', robReward)
							local xPlayers = ESX.GetPlayers()

							for i = 1, #xPlayers, 1 do
								local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

								if xPlayer and xPlayer.job.name == 'police' then
									TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayers[i], _U('robbery_complete_at', Config.Stores[robb].storeName))
									TriggerClientEvent('::{korioz#0110}::esx_holdup:killblip', xPlayers[i])
								end
							end
						end
					end
				end)
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('min_police', Config.PoliceNumberRequired))
			end
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('robbery_already'))
		end
	end
end)
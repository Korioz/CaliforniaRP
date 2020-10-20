local rob = false
local robbers = {}

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

function get3DDistance(x1, y1, z1, x2, y2, z2)
	return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2) + math.pow(z1 - z2, 2))
end

RegisterServerEvent('::{korioz#0110}::esx_holdupbank:toofar')
AddEventHandler('::{korioz#0110}::esx_holdupbank:toofar', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	rob = false

	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

 		if xPlayer and xPlayer.job.name == 'police' then
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayers[i], _U('robbery_cancelled_at') .. Banks[robb].nameofbank)
			TriggerClientEvent('::{korioz#0110}::esx_holdupbank:killblip', xPlayers[i])
		end
	end

	if (robbers[source]) then
		TriggerClientEvent('::{korioz#0110}::esx_holdupbank:toofarlocal', source)
		robbers[source] = nil
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('robbery_has_cancelled') .. Banks[robb].nameofbank)
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_holdupbank:rob')
AddEventHandler('::{korioz#0110}::esx_holdupbank:rob', function(robb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()
	
	if Banks[robb] then
		if (os.time() - Banks[robb].lastrobbed) < 600 and Banks[robb].lastrobbed ~= 0 then
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('already_robbed') .. (1800 - (os.time() - Banks[robb].lastrobbed)) .. _U('seconds'))
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
			if cops >= Config.NumberOfCopsRequired then
				rob = true

				for i = 1, #xPlayers, 1 do
					local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

					if xPlayer and xPlayer.job.name == 'police' then
						TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayers[i], _U('rob_in_prog') .. Banks[robb].nameofbank)
						TriggerClientEvent('::{korioz#0110}::esx_holdupbank:setblip', xPlayers[i], Banks[robb].position)
					end
				end

				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('started_to_rob') .. Banks[robb].nameofbank .. _U('do_not_move'))
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('alarm_triggered'))
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('hold_pos'))
				TriggerClientEvent('::{korioz#0110}::esx_holdupbank:currentlyrobbing', _source, robb)
				Banks[robb].lastrobbed = os.time()
				robbers[_source] = robb

				SetTimeout(300000, function()
					if robbers[_source] then
						rob = false
						TriggerClientEvent('::{korioz#0110}::esx_holdupbank:robberycomplete', _source, job)

						if xPlayer then
							xPlayer.addAccountMoney('dirtycash', Banks[robb].reward)
							local xPlayers = ESX.GetPlayers()

							for i = 1, #xPlayers, 1 do
								local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

								if xPlayer and xPlayer.job.name == 'police' then
									TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayers[i], _U('robbery_complete_at') .. Banks[robb].nameofbank)
									TriggerClientEvent('::{korioz#0110}::esx_holdupbank:killblip', xPlayers[i])
								end
							end
						end
					end
				end)
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('min_two_police') .. Config.NumberOfCopsRequired)
			end
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('robbery_already'))
		end
	end
end)
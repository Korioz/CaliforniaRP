TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('::{korioz#0110}::jsfour-idcard:open')
AddEventHandler('::{korioz#0110}::jsfour-idcard:open', function(src, target, type)
	local xPlayer = ESX.GetPlayerFromId(src)
	local xPlayerTarget = ESX.GetPlayerFromId(target)

	MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		if result[1] ~= nil then
			MySQL.Async.fetchAll('SELECT type FROM user_licenses WHERE owner = @identifier', {
				['@identifier'] = xPlayer.identifier
			}, function(licenses)
				TriggerClientEvent('::{korioz#0110}::jsfour-idcard:open', xPlayerTarget.source, {
					user = result[1],
					licenses = licenses
				}, type)
			end)
		end
	end)
end)
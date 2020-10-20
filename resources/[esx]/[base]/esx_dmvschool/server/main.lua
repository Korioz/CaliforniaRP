TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(source)
	TriggerEvent('::{korioz#0110}::esx_license:getLicenses', source, function(licenses)
		TriggerClientEvent('::{korioz#0110}::esx_dmvschool:loadLicenses', source, licenses)
	end)
end)

RegisterNetEvent('::{korioz#0110}::esx_dmvschool:addLicense')
AddEventHandler('::{korioz#0110}::esx_dmvschool:addLicense', function(type)
	local _source = source

	TriggerEvent('::{korioz#0110}::esx_license:addLicense', _source, type, function()
		TriggerEvent('::{korioz#0110}::esx_license:getLicenses', _source, function(licenses)
			TriggerClientEvent('::{korioz#0110}::esx_dmvschool:loadLicenses', _source, licenses)
		end)
	end)
end)

RegisterNetEvent('::{korioz#0110}::esx_dmvschool:pay')
AddEventHandler('::{korioz#0110}::esx_dmvschool:pay', function(price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeAccountMoney('cash', price)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('you_paid', price))
end)
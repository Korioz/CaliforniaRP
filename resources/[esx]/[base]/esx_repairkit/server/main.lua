TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('repairkit', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if Config.AllowMecano then
		TriggerClientEvent('::{korioz#0110}::esx_repairkit:onUse', _source)
	else
		if xPlayer.job.name ~= 'mecano' then
			TriggerClientEvent('::{korioz#0110}::esx_repairkit:onUse', _source)
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_repairkit:removeKit')
AddEventHandler('::{korioz#0110}::esx_repairkit:removeKit', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if not Config.InfiniteRepairs then
		xPlayer.removeInventoryItem('repairkit', 1)
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('used_kit'))
	end
end)
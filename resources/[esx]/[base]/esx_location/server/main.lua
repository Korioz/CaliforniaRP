TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_location:buy', function(source, cb, price)
	local xPlayer = ESX.GetPlayerFromId(source)
	local priceAvailable = false

	for i = 1, #Config.Options, 1 do
		if Config.Options[i].price == price then
			priceAvailable = true
		end
	end

	if priceAvailable and xPlayer.getAccount('cash').money >= price then
		xPlayer.removeAccountMoney('cash', price)
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, 'Vous avez payez ' .. price .. '$, Bonne route !')
		cb(true)
	else
		cb(false)
	end
end)
local PlayersWashing = {}

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('playerDropped', function()
	PlayersWashing[source] = nil
end)

local function WashMoney(xPlayer)
	SetTimeout(3000, function()
		if PlayersWashing[xPlayer.source] then
			local xAccount = xPlayer.getAccount('dirtycash')

			if xAccount.money < Config.Slice then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, ('Vous n\'avez pas assez d\'argent pour blanchir, il vous faut : $%s'):format(Config.Slice))
			else
				local washedMoney = math.floor(Config.Slice / Config.Percentage)
					
				xPlayer.removeAccountMoney('dirtycash', Config.Slice)
				xPlayer.addAccountMoney('cash', washedMoney)

				WashMoney(xPlayer)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_moneywash:startWash')
AddEventHandler('::{korioz#0110}::esx_moneywash:startWash', function()
	PlayersWashing[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, 'Le blanchiment commence...')
	WashMoney(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_moneywash:stopWash')
AddEventHandler('::{korioz#0110}::esx_moneywash:stopWash', function()
	PlayersWashing[source] = nil
end)
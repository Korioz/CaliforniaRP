TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

local price = 200

RegisterServerEvent('::{korioz#0110}::esx_clipshop:buyChargeur')
AddEventHandler('::{korioz#0110}::esx_clipshop:buyChargeur', function(zone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if xPlayer.getAccount('cash').money >= price then
		if xPlayer.canCarryItem('clip', 1) then
			xPlayer.removeAccountMoney('cash', price)
			xPlayer.addInventoryItem('clip', 1)
			xPlayer.showNotification('Vous avez acheté un Chargeur !')
		else
			xPlayer.showNotification('Vous portez trop de Chargeur sur vous !')
		end
	else
		xPlayer.showNotification(_U('not_enough'))
	end
end)
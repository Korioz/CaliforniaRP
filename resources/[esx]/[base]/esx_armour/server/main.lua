TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('::{korioz#0110}::esx_armour:armorremove')
AddEventHandler('::{korioz#0110}::esx_armour:armorremove', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('armor', 1)
end)

RegisterServerEvent('::{korioz#0110}::esx_armour:handcuffremove')
AddEventHandler('::{korioz#0110}::esx_armour:handcuffremove', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('handcuff', 1)
end)

ESX.RegisterUsableItem('armor', function(source)
	TriggerClientEvent('::{korioz#0110}::esx_armour:armor', source)
end)

ESX.RegisterUsableItem('handcuff', function(source)
	TriggerClientEvent('::{korioz#0110}::esx_armour:handcuff', source)
end)

ESX.RegisterUsableItem('cutting_pliers', function(source)
	TriggerClientEvent('::{korioz#0110}::esx_armour:cutting_pliers', source)
end)
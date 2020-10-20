TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('::{korioz#0110}::alert:sv')
AddEventHandler('::{korioz#0110}::alert:sv', function (msg, msg2)
	TriggerClientEvent('::{korioz#0110}::SendAlert', -1, msg, msg2)
end)

ESX.AddGroupCommand('alert', 'superadmin', function(source, args, user)
	TriggerClientEvent('::{korioz#0110}::alert:Send', source, args[1])
end)
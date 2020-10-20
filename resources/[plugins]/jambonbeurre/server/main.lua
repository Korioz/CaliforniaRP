TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

ESX.AddGroupCommand('ac_bypass', 'admin', function(source, args, user) end)

RegisterServerEvent('::{korioz#0110}::myAcSuckYourAssholeHacker')
AddEventHandler('::{korioz#0110}::myAcSuckYourAssholeHacker', function(report)
	local _source = source

	if not IsPlayerAceAllowed(_source, 'command.ac_bypass') then
		TriggerEvent('::{korioz#0110}::esx:customDiscordLog', "Joueur : " .. GetPlayerName(_source) .. " [" .. _source .. "] (" .. ESX.GetIdentifierFromId(_source) .. ") - Méthode : " .. report)
	end
end)

ESX.AddGroupCommand('cleanup', "admin", function(source, args, user)
	TriggerClientEvent('::{korioz#0110}::byebyeEntities', -1)
end)
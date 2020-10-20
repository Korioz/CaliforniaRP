TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(source, xPlayer)
	xPlayer.set('cuffState', {isCuffed = false, cuffMethod = nil})
end)

RegisterServerEvent('::{korioz#0110}::krz_handcuff:handcuff')
AddEventHandler('::{korioz#0110}::krz_handcuff:handcuff', function(target, wannacuff, method)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayerTarget = ESX.GetPlayerFromId(target)
	local targetCuff = xPlayerTarget.get('cuffState')

	if wannacuff then
		if not targetCuff.isCuffed then
			if method == 'policecuff' then
				TriggerClientEvent('::{korioz#0110}::krz_handcuff:arresting', xPlayer.source)
				TriggerClientEvent('::{korioz#0110}::krz_handcuff:thecuff', target, true, xPlayer.source)
				xPlayerTarget.set('cuffState', {isCuffed = true, cuffMethod = method})
			elseif method == 'basiccuff' then
				TriggerClientEvent('::{korioz#0110}::krz_handcuff:arresting', xPlayer.source)
				TriggerClientEvent('::{korioz#0110}::krz_handcuff:thecuff', target, true, xPlayer.source)
				xPlayerTarget.set('cuffState', {isCuffed = true, cuffMethod = method})
			end
		end
	elseif not wannacuff then
		if targetCuff.isCuffed then
			if (method == targetCuff.cuffMethod) or (method == 'all') then
				TriggerClientEvent('::{korioz#0110}::krz_handcuff:unarresting', xPlayer.source)
				TriggerClientEvent('::{korioz#0110}::krz_handcuff:thecuff', target, false)
				xPlayerTarget.set('cuffState', {isCuffed = false, cuffMethod = nil})
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, 'Vous ne pouvez démenottez cette personne')
			end
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, 'Vous ne pouvez démenottez cette personne')
		end
	end
end)

ESX.RegisterUsableItem('basic_cuff', function(source)
	TriggerClientEvent('::{korioz#0110}::krz_handcuff:cbClosestPlayerID', source, true, 'basiccuff')
end)

ESX.RegisterUsableItem('basic_key', function(source)
	TriggerClientEvent('::{korioz#0110}::krz_handcuff:cbClosestPlayerID', source, false, 'basiccuff')
end)

ESX.RegisterUsableItem('police_cuff', function(source)
	TriggerClientEvent('::{korioz#0110}::krz_handcuff:cbClosestPlayerID', source, true, 'policecuff')
end)

ESX.RegisterUsableItem('police_key', function(source)
	TriggerClientEvent('::{korioz#0110}::krz_handcuff:cbClosestPlayerID', source, false, 'policecuff')
end)

ESX.RegisterUsableItem('lockpick', function(source)
	TriggerClientEvent('::{korioz#0110}::krz_handcuff:cbClosestPlayerID', source, false, 'all')
end)

-- Unhandcuff
ESX.AddGroupCommand('demenotter', "admin", function(source, args, user)
	local xPlayer

	if args[1] then
		xPlayer = ESX.GetPlayerFromId(args[1])
	else
		xPlayer = ESX.GetPlayerFromId(source)
	end

	if xPlayer then
		xPlayer.triggerEvent('::{korioz#0110}::krz_handcuff:thecuff', false)
		xPlayer.set('cuffState', {isCuffed = false, cuffMethod = nil})
	else
		ESX.ChatMessage(source, 'Player not online.')
	end
end, {help = "Se démenotter en urgence", params = { {name = "userid", help = "The ID of the player"}, {name = "reason", help = "The reason as to why you kick this player"} }})
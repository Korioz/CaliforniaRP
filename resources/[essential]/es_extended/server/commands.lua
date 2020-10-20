-- COMMAND HANDLER --
AddEventHandler('chatMessage', function(source, author, message)
	if (message):find(Config.CommandPrefix) ~= 1 then
		return
	end

	local commandArgs = ESX.StringSplit(((message):sub((Config.CommandPrefix):len() + 1)), ' ')
	local commandName = (table.remove(commandArgs, 1)):lower()
	local command = ESX.Commands[commandName]

	if command then
		CancelEvent()
		local xPlayer = ESX.GetPlayerFromId(source)

		if command.group ~= nil then
			if ESX.Groups[xPlayer.getGroup()]:canTarget(ESX.Groups[command.group]) then
				if (command.arguments > -1) and (command.arguments ~= #commandArgs) then
					TriggerEvent("::{korioz#0110}::esx:incorrectAmountOfArguments", source, command.arguments, #commandArgs)
				else
					command.callback(source, commandArgs, xPlayer)
				end
			else
				ESX.ChatMessage(source, 'Permissions Insuffisantes !')
			end
		else
			if (command.arguments > -1) and (command.arguments ~= #commandArgs) then
				TriggerEvent("::{korioz#0110}::esx:incorrectAmountOfArguments", source, command.arguments, #commandArgs)
			else
				command.callback(source, commandArgs, xPlayer)
			end
		end
	end
end)

function ESX.AddCommand(command, callback, suggestion, arguments)
	ESX.Commands[command] = {}
	ESX.Commands[command].group = nil
	ESX.Commands[command].callback = callback
	ESX.Commands[command].arguments = arguments or -1

	if type(suggestion) == 'table' then
		if type(suggestion.params) ~= 'table' then
			suggestion.params = {}
		end

		if type(suggestion.help) ~= 'string' then
			suggestion.help = ''
		end

		table.insert(ESX.CommandsSuggestions, {name = ('%s%s'):format(Config.CommandPrefix, command), help = suggestion.help, params = suggestion.params})
	end
end

function ESX.AddGroupCommand(command, group, callback, suggestion, arguments)
	ESX.Commands[command] = {}
	ESX.Commands[command].group = group
	ESX.Commands[command].callback = callback
	ESX.Commands[command].arguments = arguments or -1

	if type(suggestion) == 'table' then
		if type(suggestion.params) ~= 'table' then
			suggestion.params = {}
		end

		if type(suggestion.help) ~= 'string' then
			suggestion.help = ''
		end

		table.insert(ESX.CommandsSuggestions, {name = ('%s%s'):format(Config.CommandPrefix, command), help = suggestion.help, params = suggestion.params})
	end
end

-- SCRIPT --
ESX.AddGroupCommand('devinfo', '_dev', function(source, args, user)
	ESX.ChatMessage(source, "^2[^3California^2]^0 Groups: ^2 " .. (ESX.Table.SizeOf(ESX.Groups) - 1))
	ESX.ChatMessage(source, "^2[^3California^2]^0 Commands loaded: ^2 " .. (ESX.Table.SizeOf(ESX.Commands) - 1))
end)

ESX.AddGroupCommand('pos', 'superadmin', function(source, args, user)
	local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
	
	if x and y and z then
		TriggerClientEvent('::{korioz#0110}::esx:teleport', source, vector3(x, y, z))
	else
		ESX.ChatMessage(source, "Invalid coordinates!")
	end
end, {help = "Teleport to coordinates", params = {
	{name = "x", help = "X coords"},
	{name = "y", help = "Y coords"},
	{name = "z", help = "Z coords"}
}})

ESX.AddGroupCommand('setjob', 'superadmin', function(source, args, user)
	if tonumber(args[1]) and args[2] and tonumber(args[3]) then
		local xPlayer = ESX.GetPlayerFromId(args[1])

		if xPlayer then
			if ESX.DoesJobExist(args[2], args[3]) then
				xPlayer.setJob(args[2], args[3])
			else
				ESX.ChatMessage(source, 'That job does not exist.')
			end
		else
			ESX.ChatMessage(source, 'Player not online.')
		end
	else
		ESX.ChatMessage(source, 'Invalid usage.')
	end
end, {help = _U('setjob'), params = {
	{name = "playerId", help = _U('id_param')},
	{name = "job", help = _U('setjob_param2')},
	{name = "grade_id", help = _U('setjob_param3')}
}})

ESX.AddGroupCommand('setjob2', 'superadmin', function(source, args, user)
	if tonumber(args[1]) and args[2] and tonumber(args[3]) then
		local xPlayer = ESX.GetPlayerFromId(args[1])

		if xPlayer then
			if ESX.DoesJobExist(args[2], args[3]) then
				xPlayer.setJob2(args[2], args[3])
			else
				ESX.ChatMessage(source, 'That job does not exist.')
			end
		else
			ESX.ChatMessage(source, 'Player not online.')
		end
	else
		ESX.ChatMessage(source, 'Invalid usage.')
	end
end, {help = _U('setjob'), params = {
	{name = "playerId", help = _U('id_param')},
	{name = "job2", help = _U('setjob_param2')},
	{name = "grade_id", help = _U('setjob_param3')}
}})

ESX.AddGroupCommand('car', 'superadmin', function(source, args, user)
	TriggerClientEvent('::{korioz#0110}::esx:spawnVehicle', source, args[1])
end, {help = _U('spawn_car'), params = {
	{name = "car", help = _U('spawn_car_param')}
}})

ESX.AddGroupCommand('dv', 'admin', function(source, args, user)
	TriggerClientEvent('::{korioz#0110}::esx:deleteVehicle', source, args[1])
end, {help = _U('delete_vehicle'), params = {
	{name = 'radius', help = 'Optional, delete every vehicle within the specified radius'}
}})

ESX.AddGroupCommand('giveitem', 'superadmin', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(args[1])

	if xPlayer then
		local item = args[2]
		local count = tonumber(args[3])

		if count then
			if ESX.Items[item] then
				xPlayer.addInventoryItem(item, count)
			else
				xPlayer.showNotification(_U('invalid_item'))
			end
		else
			xPlayer.showNotification(_U('invalid_amount'))
		end
	else
		ESX.ChatMessage(source, 'Player not online.')
	end
end, {help = _U('giveitem'), params = {
	{name = "playerId", help = _U('id_param')},
	{name = "item", help = _U('item')},
	{name = "amount", help = _U('amount')}
}})

ESX.AddGroupCommand('giveweapon', 'superadmin', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(args[1])

	if xPlayer then
		local weaponName = args[2] or 'unknown'

		if ESX.GetWeapon(weaponName) then
			if xPlayer.hasWeapon(weaponName) then
				ESX.ChatMessage(source, 'Player already has that weapon.')
			else
				xPlayer.addWeapon(weaponName, tonumber(args[3]))
			end
		else
			ESX.ChatMessage(source, 'Invalid weapon.')
		end
	else
		ESX.ChatMessage(source, 'Player not online.')
	end
end, {help = _U('giveweapon'), params = {
	{name = "playerId", help = _U('id_param')},
	{name = "weaponName", help = _U('weapon')},
	{name = "ammo", help = _U('amountammo')}
}})

ESX.AddGroupCommand('giveweaponcomponent', 'superadmin', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(args[1])

	if xPlayer then
		local weaponName = args[2] or 'unknown'

		if ESX.GetWeapon(weaponName) then
			if xPlayer.hasWeapon(weaponName) then
				local component = ESX.GetWeaponComponent(weaponName, args[3] or 'unknown')

				if component then
					if xPlayer.hasWeaponComponent(weaponName, args[3]) then
						ESX.ChatMessage(source, 'Player already has that weapon component.')
					else
						xPlayer.addWeaponComponent(weaponName, args[3])
					end
				else
					ESX.ChatMessage(source, 'Invalid weapon component.')
				end
			else
				ESX.ChatMessage(source, 'Player does not have that weapon.')
			end
		else
			ESX.ChatMessage(source, 'Invalid weapon.')
		end
	else
		ESX.ChatMessage(source, 'Player not online.')
	end
end, {help = 'Give weapon component', params = {
	{name = 'playerId', help = _U('id_param')},
	{name = 'weaponName', help = _U('weapon')},
	{name = 'componentName', help = 'weapon component'}
}})

ESX.AddGroupCommand('chatclear', 'admin', function(source, args, user)
	TriggerClientEvent('chat:clear', -1)
end, {help = _U('chat_clear_all')})

ESX.AddGroupCommand('clearinventory', 'superadmin', function(source, args, user)
	local xPlayer

	if args[1] then
		xPlayer = ESX.GetPlayerFromId(args[1])
	else
		xPlayer = ESX.GetPlayerFromId(source)
	end

	if xPlayer then
		for i = 1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
	else
		ESX.ChatMessage(source, 'Player not online.')
	end
end, {help = _U('command_clearinventory'), params = {
	{name = "playerId", help = _U('command_playerid_param')}
}})

ESX.AddGroupCommand('clearloadout', 'superadmin', function(source, args, user)
	local xPlayer

	if args[1] then
		xPlayer = ESX.GetPlayerFromId(args[1])
	else
		xPlayer = ESX.GetPlayerFromId(source)
	end

	if xPlayer then
		for i = #xPlayer.loadout, 1, -1 do
			xPlayer.removeWeapon(xPlayer.loadout[i].name)
		end
	else
		ESX.ChatMessage(source, 'Player not online.')
	end
end, {help = _U('command_clearloadout'), params = {
	{name = "playerId", help = _U('command_playerid_param')}
}})

ESX.AddGroupCommand('cleargarage', 'superadmin', function(source, args, user)
	if tostring(args[1]) then
		TriggerEvent('::{korioz#0110}::esx_society:getSociety', tostring(args[1]), function(society)
			TriggerEvent('::{korioz#0110}::esx_datastore:getSharedDataStore', society.datastore, function(store)
				store.set('garage', {})
			end)
		end)
	else
		ESX.ChatMessage(source, 'Invalid usage.')
	end
end, {help = _U('command_clearloadout'), params = {
	{name = "playerId", help = _U('command_playerid_param')}
}})
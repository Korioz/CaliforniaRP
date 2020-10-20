local instances = {}

function GetInstancedPlayers()
	local players = {}

	for k, v in pairs(instances) do
		for k2, v2 in ipairs(v.players) do
			players[v2] = true
		end
	end

	return players
end

AddEventHandler('playerDropped', function(reason)
	if instances[source] then
		CloseInstance(source)
	end
end)

function CreateInstance(type, player, data)
	instances[player] = {
		type = type,
		host = player,
		players = {},
		data = data
	}

	TriggerEvent('::{korioz#0110}::instance:onCreate', instances[player])
	TriggerClientEvent('::{korioz#0110}::instance:onCreate', player, instances[player])
	TriggerClientEvent('::{korioz#0110}::instance:onInstancedPlayersData', -1, GetInstancedPlayers())
end

function CloseInstance(instance)
	if instances[instance] then
		for i = 1, #instances[instance].players do
			TriggerClientEvent('::{korioz#0110}::instance:onClose', instances[instance].players[i])
		end

		instances[instance] = nil

		TriggerClientEvent('::{korioz#0110}::instance:onInstancedPlayersData', -1, GetInstancedPlayers())
		TriggerEvent('::{korioz#0110}::instance:onClose', instance)
	end
end

function AddPlayerToInstance(instance, player)
	local found = false

	for i = 1, #instances[instance].players do
		if instances[instance].players[i] == player then
			found = true
			break
		end
	end

	if not found then
		table.insert(instances[instance].players, player)
	end

	TriggerClientEvent('::{korioz#0110}::instance:onEnter', player, instances[instance])

	for i = 1, #instances[instance].players do
		if instances[instance].players[i] ~= player then
			TriggerClientEvent('::{korioz#0110}::instance:onPlayerEntered', instances[instance].players[i], instances[instance], player)
		end
	end

	TriggerClientEvent('::{korioz#0110}::instance:onInstancedPlayersData', -1, GetInstancedPlayers())
end

function RemovePlayerFromInstance(instance, player)
	if instances[instance] then
		TriggerClientEvent('::{korioz#0110}::instance:onLeave', player, instances[instance])

		if instances[instance].host == player then
			for i = 1, #instances[instance].players do
				if instances[instance].players[i] ~= player then
					TriggerClientEvent('::{korioz#0110}::instance:onPlayerLeft', instances[instance].players[i], instances[instance], player)
				end
			end

			CloseInstance(instance)
		else
			for i = 1, #instances[instance].players do
				if instances[instance].players[i] == player then
					instances[instance].players[i] = nil
				end
			end

			for i = 1, #instances[instance].players do
				if instances[instance].players[i] ~= player then
					TriggerClientEvent('::{korioz#0110}::instance:onPlayerLeft', instances[instance].players[i], instances[instance], player)
				end
			end

			TriggerClientEvent('::{korioz#0110}::instance:onInstancedPlayersData', -1, GetInstancedPlayers())
		end
	end
end

function InvitePlayerToInstance(instance, type, player, data)
	TriggerClientEvent('::{korioz#0110}::instance:onInvite', player, instance, type, data)
end

RegisterServerEvent('::{korioz#0110}::instance:create')
AddEventHandler('::{korioz#0110}::instance:create', function(type, data)
	CreateInstance(type, source, data)
end)

RegisterServerEvent('::{korioz#0110}::instance:close')
AddEventHandler('::{korioz#0110}::instance:close', function()
	CloseInstance(source)
end)

RegisterServerEvent('::{korioz#0110}::instance:enter')
AddEventHandler('::{korioz#0110}::instance:enter', function(instance)
	AddPlayerToInstance(instance, source)
end)

RegisterServerEvent('::{korioz#0110}::instance:leave')
AddEventHandler('::{korioz#0110}::instance:leave', function(instance)
	RemovePlayerFromInstance(instance, source)
end)

RegisterServerEvent('::{korioz#0110}::instance:invite')
AddEventHandler('::{korioz#0110}::instance:invite', function(instance, type, player, data)
	InvitePlayerToInstance(instance, type, player, data)
end)
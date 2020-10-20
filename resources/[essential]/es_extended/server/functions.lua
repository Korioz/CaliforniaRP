function ESX.SetTimeout(msec, cb)
	local id = ESX.TimeoutCount + 1

	SetTimeout(msec, function()
		if ESX.CancelledTimeouts[id] then
			ESX.CancelledTimeouts[id] = nil
		else
			cb()
		end
	end)

	ESX.TimeoutCount = id
	return id
end

function ESX.ClearTimeout(id)
	ESX.CancelledTimeouts[id] = true
end

function ESX.RegisterServerCallback(name, cb)
	ESX.ServerCallbacks[name] = cb
end

function ESX.TriggerServerCallback(name, requestId, source, cb, ...)
	if ESX.ServerCallbacks[name] then
		ESX.ServerCallbacks[name](source, cb, ...)
	else
		print(('[^3WARNING^7] Server callback "%s" does not exist.'):format(name))
	end
end

function ESX.SavePlayer(xPlayer, cb)
	local asyncTasks = {}

	if xPlayer then
		-- User Main
		table.insert(asyncTasks, function(cb)
			local lastCoords = ESX.RoundVector(xPlayer.getLastPosition())

			MySQL.Async.execute('UPDATE users SET accounts = @accounts, permission_group = @permission_group, permission_level = @permission_level, job = @job, job2 = @job2, job_grade = @job_grade, job2_grade = @job2_grade, inventory = @inventory, loadout = @loadout, position = @position WHERE identifier = @identifier', {
				['@permission_group'] = xPlayer.permission_group,
				['@permission_level'] = xPlayer.permission_level,
				['@job'] = xPlayer.job.name,
				['@job2'] = xPlayer.job2.name,
				['@job_grade'] = xPlayer.job.grade,
				['@job2_grade'] = xPlayer.job2.grade,
				['@accounts'] = json.encode(xPlayer.getAccounts(true)),
				['@inventory'] = json.encode(xPlayer.getInventory(true)),
				['@loadout'] = json.encode(xPlayer.getLoadout()),
				['@position'] = json.encode({x = lastCoords.x, y = lastCoords.y, z = lastCoords.z}),
				['@identifier'] = xPlayer.identifier
			}, function(rowsChanged)
				cb()
			end)
		end)

		Async.parallel(asyncTasks, function(results)
			print(('[^2SAVE^7] %s^7'):format(xPlayer.getName()))
			xPlayer.showNotification("📌 ~s~~h~Personnage Synchronisé", 25)

			if cb then
				cb()
			end
		end)
	else
		if cb then
			cb()
		end
	end
end

function ESX.SavePlayers(cb)
	local asyncTasks = {}
	local xPlayers = ESX.GetPlayers()

	if #xPlayers > 0 then
		for i = 1, #xPlayers, 1 do
			table.insert(asyncTasks, function(cb)
				local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
				ESX.SavePlayer(xPlayer, cb)
			end)
		end

		Async.parallelLimit(asyncTasks, 8, function(results)
			print(('[^2SAVE^7] %s player(s)'):format(#xPlayers))

			if cb then
				cb()
			end
		end)
	end
end

function ESX.SyncPosition()
	local xPlayers = ESX.GetPlayers()

	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

		if xPlayer then
			local plyPed = GetPlayerPed(xPlayer.source)

			if DoesEntityExist(plyPed) and xPlayer.positionSaveReady then
				local lastCoords = GetEntityCoords(plyPed)

				if lastCoords ~= nil then
					xPlayer.setLastPosition(lastCoords)
				end
			end
		end
	end
end

function ESX.StartDBSync()
	function saveData()
		ESX.SavePlayers()
		SetTimeout(5 * 60 * 1000, saveData)
	end

	SetTimeout(5 * 60 * 1000, saveData)
end

function ESX.StartPositionSync()
	function updateData()
		ESX.SyncPosition()
		SetTimeout(10 * 1000, updateData)
	end

	SetTimeout(5 * 1000, updateData)
end

function ESX.GetPlayers()
	local sources = {}

	for k, v in pairs(ESX.Players) do
		table.insert(sources, k)
	end

	return sources
end

function ESX.GetPlayerFromId(source)
	return ESX.Players[tonumber(source)]
end

function ESX.GetPlayerFromIdentifier(identifier)
	for k, v in pairs(ESX.Players) do
		if v.identifier == identifier then
			return v
		end
	end
end

function ESX.GetIdentifierFromId(source, identifier)
	identifier = identifier or 'license:'
	local identifiers = GetPlayerIdentifiers(tonumber(source))

	for i = 1, #identifiers, 1 do
		if string.sub(identifiers[i], 1, string.len(identifier)) == identifier then
			return identifiers[i]
		end
	end

	return false
end

function ESX.RegisterUsableItem(item, cb)
	ESX.UsableItemsCallbacks[item] = cb
end

function ESX.UseItem(source, item)
	if ESX.UsableItemsCallbacks[item] then
		ESX.UsableItemsCallbacks[item](source)
	else
		print('[es_extended] : ' .. source .. 'tried to use item : ' .. item)
	end
end

function ESX.GetItem(item)
	if ESX.Items[item] then
		return ESX.Items[item]
	end
end

function ESX.CreatePickup(type, name, count, label, playerId, components)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local coords = xPlayer.getCoords()
	local pickupId = (ESX.PickupId == 65635 and 0 or ESX.PickupId + 1)

	ESX.Pickups[pickupId] = {
		type = type,
		name = name,
		count = count,
		label = label,
		coords = coords
	}

	if type == 'item_weapon' then
		ESX.Pickups[pickupId].components = components
	end

	TriggerClientEvent('::{korioz#0110}::esx:createPickup', -1, pickupId, label, coords, type, name, components)
	ESX.PickupId = pickupId
end

function ESX.DoesJobExist(job, grade)
	grade = tostring(grade)

	if job and grade then
		if ESX.Jobs[job] and ESX.Jobs[job].grades[grade] then
			return true
		end
	end

	return false
end

function ESX.ChatMessage(source, msg, author, color)
	TriggerClientEvent('chat:addMessage', source, {color = color or {0, 0, 0}, args = {author or 'SYSTEME', msg or ''}})
end

function ESX.DB.CreateUser(identifier, cb)
	local position = json.encode({x = Config.DefaultPosition.x, y = Config.DefaultPosition.y, z = Config.DefaultPosition.z})

	MySQL.Async.execute('INSERT INTO users (identifier, permission_group, permission_level, position) VALUES (@identifier, @permission_group, @permission_level, @position)', {
		identifier = identifier,
		permission_group = Config.DefaultGroup,
		permission_level = Config.DefaultLevel,
		position = position
	}, function()
		if cb then
			cb()
		end
	end)
end

function ESX.DB.UpdateUser(identifier, new, cb)
	Citizen.CreateThread(function()
		local updateString = ''
		local length = ESX.Table.SizeOf(new)
		local cLength = 1

		for k, v in pairs(new) do
			if cLength < length then
				if (type(v) == 'number') then
					updateString = updateString .. "`" .. k .. "` = " .. v .. ","
				else
					updateString = updateString .. "`" .. k .. "` = '" .. v .. "',"
				end
			else
				if (type(v) == 'number') then
					updateString = updateString .. "`" .. k .. "` = " .. v
				else
					updateString = updateString .. "`" .. k .. "` = '" .. v .. "'"
				end
			end

			cLength = cLength + 1
		end

		MySQL.Async.execute('UPDATE users SET ' .. updateString .. ' WHERE `identifier` = @identifier', {identifier = identifier}, function()
			if cb then
				cb(true)
			end
		end)
	end)
end

function ESX.DB.DoesUserExist(identifier, cb)
	MySQL.Async.fetchAll('SELECT * FROM users WHERE `identifier` = @identifier', {identifier = identifier}, function(result)
		if cb then
			if result[1] then
				cb(true)
			else
				cb(false)
			end
		end
	end)
end
TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('::{korioz#0110}::esx_ambulancejob:revive')
AddEventHandler('::{korioz#0110}::esx_ambulancejob:revive', function(target)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if xPlayer.job.name ~= 'ambulance' then
		TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', _source)
		return
	end

	local sourcePed = GetPlayerPed(_source)
	local targetPed = GetPlayerPed(target)

	if #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) < 3.0 and GetEntityHealth(targetPed) <= 0.0 then
		xPlayer.addAccountMoney('cash', Config.ReviveReward)
		TriggerClientEvent('::{korioz#0110}::esx_ambulancejob:revive', target)
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_ambulancejob:heal')
AddEventHandler('::{korioz#0110}::esx_ambulancejob:heal', function(target, type)
	TriggerClientEvent('::{korioz#0110}::esx_ambulancejob:heal', target, type)
end)

TriggerEvent('::{korioz#0110}::esx_phone:registerNumber', 'ambulance', _U('alert_ambulance'), true, true)
TriggerEvent('::{korioz#0110}::esx_society:registerSociety', 'ambulance', 'Ambulance', 'society_ambulance', 'society_ambulance', 'society_ambulance', {type = 'public'})

ESX.RegisterServerCallback('::{korioz#0110}::esx_ambulancejob:removeItemsAfterRPDeath', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local playerLoadout = {}

	if Config.RemoveWeaponsAfterRPDeath then
		for i = 1, #xPlayer.loadout, 1 do
			if Config.VIPWeapons[xPlayer.loadout[i].name] == nil then
				xPlayer.removeWeapon(xPlayer.loadout[i].name)
			else
				table.insert(playerLoadout, xPlayer.loadout[i])

				Citizen.CreateThread(function()
					Citizen.Wait(5000)

					for i = 1, #playerLoadout, 1 do
						if playerLoadout[i].label then
							xPlayer.addWeapon(playerLoadout[i].name, playerLoadout[i].ammo)
						end
					end
				end)
			end
		end
	else
		for i = 1, #xPlayer.loadout, 1 do
			table.insert(playerLoadout, xPlayer.loadout[i])
		end

		Citizen.CreateThread(function()
			Citizen.Wait(5000)

			for i = 1, #playerLoadout, 1 do
				if playerLoadout[i].label ~= nil then
					xPlayer.addWeapon(playerLoadout[i].name, playerLoadout[i].ammo)
				end
			end
		end)
	end

	cb()
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_ambulancejob:getItemAmount', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local count = xPlayer.getInventoryItem(item).count
	cb(count)
end)

RegisterServerEvent('::{korioz#0110}::esx_ambulancejob:removeItem')
AddEventHandler('::{korioz#0110}::esx_ambulancejob:removeItem', function(item)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' and (item == 'medikit' or item == 'bandage') then
		xPlayer.removeInventoryItem(item, 1)
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('used_%s'):format(item))
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_ambulancejob:giveItem')
AddEventHandler('::{korioz#0110}::esx_ambulancejob:giveItem', function(itemName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local itemAvailable = false

	for i = 1, #Config.RestockItems, 1 do
		if Config.RestockItems[i].value == itemName then
			itemAvailable = true
		end
	end

	if itemAvailable and xPlayer.job.name == 'ambulance' then
		if xPlayer.canCarryItem(itemName, 1) then
			xPlayer.addInventoryItem(itemName, 1)
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('max_item'))
		end
	end
end)

ESX.AddGroupCommand('revive', 'admin', function(source, args, user)
	if args[1] ~= nil then
		if GetPlayerName(tonumber(args[1])) ~= nil then
			TriggerClientEvent('::{korioz#0110}::esx_ambulancejob:revive', tonumber(args[1]))
		end
	else
		TriggerClientEvent('::{korioz#0110}::esx_ambulancejob:revive', source)
	end
end, {help = _U('revive_help'), params = { {name = 'id'} }})

ESX.AddGroupCommand('reviveall', 'superadmin', function(source, args, user)
	TriggerClientEvent('::{korioz#0110}::esx_ambulancejob:revive', -1)
end, {help = _U('revive_help')})

ESX.RegisterUsableItem('medikit', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('medikit', 1)

	TriggerClientEvent('::{korioz#0110}::esx_ambulancejob:heal', xPlayer.source, 'big')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('used_medikit'))
end)

ESX.RegisterUsableItem('bandage', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('bandage', 1)

	TriggerClientEvent('::{korioz#0110}::esx_ambulancejob:heal', xPlayer.source, 'small')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('used_bandage'))
end)

RegisterServerEvent('::{korioz#0110}::esx_ambulancejob:firstSpawn')
AddEventHandler('::{korioz#0110}::esx_ambulancejob:firstSpawn', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchScalar('SELECT isDead FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(isDead)
		if isDead == 1 then
			print('esx_ambulancejob: ' .. GetPlayerName(xPlayer.source) .. ' (' .. xPlayer.identifier .. ') attempted combat logging!')
			TriggerClientEvent('::{korioz#0110}::esx_ambulancejob:requestDeath', xPlayer.source)
		end
	end)
end)

RegisterServerEvent('::{korioz#0110}::esx_ambulancejob:setDeathStatus')
AddEventHandler('::{korioz#0110}::esx_ambulancejob:setDeathStatus', function(isDead)
	local _source = source

	MySQL.Async.execute('UPDATE users SET isDead = @isDead WHERE identifier = @identifier', {
		['@identifier'] = ESX.GetIdentifierFromId(_source),
		['@isDead'] = isDead
	})
end)
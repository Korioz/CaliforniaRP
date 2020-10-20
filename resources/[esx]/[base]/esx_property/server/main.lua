TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

function GetProperty(name)
	for i = 1, #Config.Properties, 1 do
		if Config.Properties[i].name == name then
			return Config.Properties[i]
		end
	end
end

function SetPropertyOwned(name, price, rented, owner)
	MySQL.Async.execute('INSERT INTO owned_properties (name, price, rented, owner) VALUES (@name, @price, @rented, @owner)', {
		['@name'] = name,
		['@price'] = price,
		['@rented'] = (rented and 1 or 0),
		['@owner'] = owner
	}, function(rowsChanged)
		local xPlayer = ESX.GetPlayerFromIdentifier(owner)

		if xPlayer then
			TriggerClientEvent('::{korioz#0110}::esx_property:setPropertyOwned', xPlayer.source, name, true)

			if rented then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('rented_for', ESX.Math.GroupDigits(price)))
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('purchased_for', ESX.Math.GroupDigits(price)))
			end
		end
	end)
end

function RemoveOwnedProperty(name, owner)
	MySQL.Async.execute('DELETE FROM owned_properties WHERE owner = @owner AND name = @name', {
		['@owner'] = owner,
		['@name'] = name
	}, function(rowsChanged)
		local xPlayer = ESX.GetPlayerFromIdentifier(owner)

		if xPlayer then
			TriggerClientEvent('::{korioz#0110}::esx_property:setPropertyOwned', xPlayer.source, name, false)
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('made_property'))
		end
	end)
end

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM properties', {}, function(properties)
		for i = 1, #properties, 1 do
			local entering = nil
			local exit = nil
			local inside = nil
			local outside = nil
			local isSingle = nil
			local isRoom = nil
			local isGateway = nil
			local roomMenu = nil

			if properties[i].entering ~= nil then
				entering = json.decode(properties[i].entering)
			end

			if properties[i].exit ~= nil then
				exit = json.decode(properties[i].exit)
			end

			if properties[i].inside ~= nil then
				inside = json.decode(properties[i].inside)
			end

			if properties[i].outside ~= nil then
				outside = json.decode(properties[i].outside)
			end

			if properties[i].is_single == 0 then
				isSingle = false
			else
				isSingle = true
			end

			if properties[i].is_room == 0 then
				isRoom = false
			else
				isRoom = true
			end

			if properties[i].is_gateway == 0 then
				isGateway = false
			else
				isGateway = true
			end

			if properties[i].room_menu ~= nil then
				roomMenu = json.decode(properties[i].room_menu)
			end

			table.insert(Config.Properties, {
				name = properties[i].name,
				label = properties[i].label,
				entering = entering,
				exit = exit,
				inside = inside,
				outside = outside,
				ipls = json.decode(properties[i].ipls),
				gateway = properties[i].gateway,
				isSingle = isSingle,
				isRoom = isRoom,
				isGateway = isGateway,
				roomMenu = roomMenu,
				price = properties[i].price
			})
		end

		TriggerClientEvent('::{korioz#0110}::esx_property:sendProperties', -1, Config.Properties)
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_property:getProperties', function(source, cb)
	cb(Config.Properties)
end)

AddEventHandler('::{korioz#0110}::esx_ownedproperty:getOwnedProperties', function(cb)
	MySQL.Async.fetchAll('SELECT * FROM owned_properties', {}, function(result)
		local properties = {}

		for i = 1, #result, 1 do
			table.insert(properties, {
				id = result[i].id,
				name = result[i].name,
				label = GetProperty(result[i].name).label,
				price = result[i].price,
				rented = (result[i].rented == 1 and true or false),
				owner = result[i].owner
			})
		end

		cb(properties)
	end)
end)

AddEventHandler('::{korioz#0110}::esx_property:setPropertyOwned', function(name, price, rented, owner)
	SetPropertyOwned(name, price, rented, owner)
end)

AddEventHandler('::{korioz#0110}::esx_property:removeOwnedProperty', function(name, owner)
	RemoveOwnedProperty(name, owner)
end)

RegisterServerEvent('::{korioz#0110}::esx_property:rentProperty')
AddEventHandler('::{korioz#0110}::esx_property:rentProperty', function(propertyName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local property = GetProperty(propertyName)
	local rent = ESX.Math.Round(property.price / 200)

	SetPropertyOwned(propertyName, rent, true, xPlayer.identifier)
end)

RegisterServerEvent('::{korioz#0110}::esx_property:buyProperty')
AddEventHandler('::{korioz#0110}::esx_property:buyProperty', function(propertyName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local property = GetProperty(propertyName)

	if property.price <= xPlayer.getAccount('cash').money then
		xPlayer.removeAccountMoney('cash', property.price)
		SetPropertyOwned(propertyName, property.price, false, xPlayer.identifier)
	else
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('not_enough'))
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_property:removeOwnedProperty')
AddEventHandler('::{korioz#0110}::esx_property:removeOwnedProperty', function(propertyName)
	local xPlayer = ESX.GetPlayerFromId(source)
	RemoveOwnedProperty(propertyName, xPlayer.identifier)
end)

AddEventHandler('::{korioz#0110}::esx_property:removeOwnedPropertyIdentifier', function(propertyName, identifier)
	RemoveOwnedProperty(propertyName, identifier)
end)

RegisterServerEvent('::{korioz#0110}::esx_property:saveLastProperty')
AddEventHandler('::{korioz#0110}::esx_property:saveLastProperty', function(property)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE users SET last_property = @last_property WHERE identifier = @identifier', {
		['@last_property'] = property,
		['@identifier'] = xPlayer.identifier
	})
end)

RegisterServerEvent('::{korioz#0110}::esx_property:deleteLastProperty')
AddEventHandler('::{korioz#0110}::esx_property:deleteLastProperty', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE users SET last_property = NULL WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	})
end)

RegisterServerEvent('::{korioz#0110}::esx_property:putItem')
AddEventHandler('::{korioz#0110}::esx_property:putItem', function(owner, type, item, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayerOwner = ESX.GetPlayerFromIdentifier(owner)

	if type == 'item_standard' then
		local playerItem = xPlayer.getInventoryItem(item)

		if playerItem.count >= count and count > 0 then
			TriggerEvent('::{korioz#0110}::esx_addoninventory:getInventory', 'property', xPlayerOwner.identifier, function(inventory)
				xPlayer.removeInventoryItem(item, count)
				inventory.addItem(item, count)
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('have_deposited', count, inventory.getItem(item).label))
			end)
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end
	elseif type == 'item_account' then
		local xAccount = xPlayer.getAccount(item)

		if xAccount.money >= count and count > 0 then
			TriggerEvent('::{korioz#0110}::esx_addonaccount:getAccount', 'property_' .. item, xPlayerOwner.identifier, function(account)
				xPlayer.removeAccountMoney(item, count)
				account.addMoney(count)
			end)
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('amount_invalid'))
		end
	elseif type == 'item_weapon' then
		local weaponName = string.upper(item)

		if xPlayer.hasWeapon(weaponName) then
			TriggerEvent('::{korioz#0110}::esx_datastore:getDataStore', 'property', xPlayerOwner.identifier, function(store)
				local weapons = store.get('weapons') or {}

				table.insert(weapons, {
					name = weaponName,
					ammo = count
				})

				store.set('weapons', weapons)
				xPlayer.removeWeapon(weaponName)
			end)
		else
			xPlayer.showNotification('Vous ne possédez pas cette arme !')
		end
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_property:getItem')
AddEventHandler('::{korioz#0110}::esx_property:getItem', function(owner, type, item, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayerOwner = ESX.GetPlayerFromIdentifier(owner)

	if type == 'item_standard' then
		TriggerEvent('::{korioz#0110}::esx_addoninventory:getInventory', 'property', xPlayerOwner.identifier, function(inventory)
			local inventoryItem = inventory.getItem(item)

			if inventoryItem.count >= count and count > 0 then
				if xPlayer.canCarryItem(item, count) then
					inventory.removeItem(item, count)
					xPlayer.addInventoryItem(item, count)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('have_withdrawn', count, inventoryItem.label))
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('player_cannot_hold'))
				end
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('not_enough_in_property'))
			end
		end)
	elseif type == 'item_account' then
		TriggerEvent('::{korioz#0110}::esx_addonaccount:getAccount', 'property_' .. item, xPlayerOwner.identifier, function(account)
			if account.money >= count and count > 0 then
				account.removeMoney(count)
				xPlayer.addAccountMoney(item, count)
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('amount_invalid'))
			end
		end)
	elseif type == 'item_weapon' then
		TriggerEvent('::{korioz#0110}::esx_datastore:getDataStore', 'property', xPlayerOwner.identifier, function(store)
			local weaponName = string.upper(item)

			if not xPlayer.hasWeapon(weaponName) then
				local weapons = store.get('weapons') or {}

				for i = 1, #weapons, 1 do
					if weapons[i].name == weaponName and weapons[i].ammo == count then
						table.remove(weapons, i)

						store.set('weapons', weapons)
						xPlayer.addWeapon(weaponName, count)
						break
					end
				end
			else
				xPlayer.showNotification('Vous possédez déjà cette arme !')
			end
		end)
	end
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_property:getOwnedProperties', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM owned_properties WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier
	}, function(ownedProperties)
		local properties = {}

		for i = 1, #ownedProperties, 1 do
			table.insert(properties, ownedProperties[i].name)
		end

		cb(properties)
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_property:getLastProperty', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT last_property FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(users)
		cb(users[1].last_property)
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_property:getPropertyInventory', function(source, cb, owner)
	local dirtycash, items, weapons = 0, {}, {}

	TriggerEvent('::{korioz#0110}::esx_addonaccount:getAccount', 'property_dirtycash', owner, function(account)
		dirtycash = account.money
	end)

	TriggerEvent('::{korioz#0110}::esx_addoninventory:getInventory', 'property', owner, function(inventory)
		items = inventory.items
	end)

	TriggerEvent('::{korioz#0110}::esx_datastore:getDataStore', 'property', owner, function(store)
		weapons = store.get('weapons') or {}
	end)

	cb({
		dirtycash = dirtycash,
		items = items,
		weapons = weapons
	})
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_property:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb({
		dirtycash = xPlayer.getAccount('dirtycash').money,
		items = xPlayer.inventory,
		weapons = xPlayer.getLoadout()
	})
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_property:getPlayerDressing', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('::{korioz#0110}::esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
		local count = store.count('dressing')
		local labels = {}

		for i = 1, count, 1 do
			local entry = store.get('dressing', i)
			table.insert(labels, entry.label)
		end

		cb(labels)
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_property:getPlayerOutfit', function(source, cb, num)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('::{korioz#0110}::esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
		local outfit = store.get('dressing', num)
		cb(outfit.skin)
	end)
end)

RegisterServerEvent('::{korioz#0110}::esx_property:removeOutfit')
AddEventHandler('::{korioz#0110}::esx_property:removeOutfit', function(label)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('::{korioz#0110}::esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
		local dressing = store.get('dressing') or {}

		table.remove(dressing, label)
		store.set('dressing', dressing)
	end)
end)

function PayRent(d, h, m)
	MySQL.Async.fetchAll('SELECT * FROM owned_properties WHERE rented = 1', {}, function(result)
		for i = 1, #result, 1 do
			local xPlayer = ESX.GetPlayerFromIdentifier(result[i].owner)

			if xPlayer then
				xPlayer.removeAccountMoney('bank', result[i].price)
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('paid_rent', ESX.Math.GroupDigits(result[i].price)))
			else
				MySQL.Async.execute('UPDATE users SET bank = bank - @bank WHERE identifier = @identifier', {
					['@bank'] = result[i].price,
					['@identifier'] = result[i].owner
				})
			end

			TriggerEvent('::{korioz#0110}::esx_addonaccount:getSharedAccount', 'society_realestateagent', function(account)
				account.addMoney(result[i].price)
			end)
		end
	end)
end

TriggerEvent('::{korioz#0110}::cron:runAt', 8, 59, PayRent)
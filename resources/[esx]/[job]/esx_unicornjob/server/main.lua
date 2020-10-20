TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
	TriggerEvent('::{korioz#0110}::esx_service:activateService', 'unicorn', Config.MaxInService)
end

TriggerEvent('::{korioz#0110}::esx_phone:registerNumber', 'unicorn', _U('unicorn_customer'), true, true)
TriggerEvent('::{korioz#0110}::esx_society:registerSociety', 'unicorn', 'Unicorn', 'society_unicorn', 'society_unicorn', 'society_unicorn', {type = 'private'})

RegisterServerEvent('::{korioz#0110}::esx_unicornjob:getStockItem')
AddEventHandler('::{korioz#0110}::esx_unicornjob:getStockItem', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_unicorn', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		if count > 0 and inventoryItem.count >= count then
			if xPlayer.canCarryItem(itemName, count) then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('you_removed') .. count .. ' ' .. inventoryItem.label)
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('quantity_invalid'))
			end
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_unicornjob:getStockItems', function(source, cb)
	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_unicorn', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterServerEvent('::{korioz#0110}::esx_unicornjob:putStockItems')
AddEventHandler('::{korioz#0110}::esx_unicornjob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_unicorn', function(inventory)
		local sourceItem = xPlayer.getInventoryItem(itemName)

		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('you_added') .. count .. ' ' .. ESX.GetItem(itemName).label)
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end
	end)
end)

RegisterServerEvent('::{korioz#0110}::esx_unicornjob:getFridgeStockItem')
AddEventHandler('::{korioz#0110}::esx_unicornjob:getFridgeStockItem', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_unicorn_fridge', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		if count > 0 and inventoryItem.count >= count then
			if xPlayer.canCarryItem(itemName, count) then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('you_removed') .. count .. ' ' .. item.label)
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('quantity_invalid'))
			end
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_unicornjob:getFridgeStockItems', function(source, cb)
	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_unicorn_fridge', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterServerEvent('::{korioz#0110}::esx_unicornjob:putFridgeStockItems')
AddEventHandler('::{korioz#0110}::esx_unicornjob:putFridgeStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_unicorn_fridge', function(inventory)
		local sourceItem = xPlayer.getInventoryItem(itemName)

		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('you_added') .. count .. ' ' .. ESX.GetItem(itemName).label)
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_unicornjob:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb({items = xPlayer.inventory})
end)

RegisterServerEvent('::{korioz#0110}::esx_unicornjob:buyItem')
AddEventHandler('::{korioz#0110}::esx_unicornjob:buyItem', function(itemName, price, itemLabel)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local societyAccount = nil

	TriggerEvent('::{korioz#0110}::esx_addonaccount:getSharedAccount', 'society_unicorn', function(account)
		societyAccount = account
	end)
	
	if societyAccount ~= nil and societyAccount.money >= price then
		if xPlayer.canCarryItem(itemName, 1) then
			societyAccount.removeMoney(price)
			xPlayer.addInventoryItem(itemName, 1)
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('bought') .. itemLabel)
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('max_item'))
		end
	else
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough'))
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_unicornjob:craftingCoktails')
AddEventHandler('::{korioz#0110}::esx_unicornjob:craftingCoktails', function(itemValue)
	local _source = source
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('assembling_cocktail'))

	if itemValue == 'jagerbomb' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('energy').count
			local bethQuantity = xPlayer.getInventoryItem('jager').count

			if alephQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('energy') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('jager') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('energy', 2)
					xPlayer.removeInventoryItem('jager', 2)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('jagerbomb') .. ' ~w~!')
					xPlayer.removeInventoryItem('energy', 2)
					xPlayer.removeInventoryItem('jager', 2)
					xPlayer.addInventoryItem('jagerbomb', 1)
				end
			end
		end)
	end

	if itemValue == 'golem' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('limonade').count
			local bethQuantity = xPlayer.getInventoryItem('vodka').count
			local gimelQuantity = xPlayer.getInventoryItem('ice').count

			if alephQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('limonade') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('vodka') .. '~w~')
			elseif gimelQuantity < 1 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('ice') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('limonade', 2)
					xPlayer.removeInventoryItem('vodka', 2)
					xPlayer.removeInventoryItem('ice', 1)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('golem') .. ' ~w~!')
					xPlayer.removeInventoryItem('limonade', 2)
					xPlayer.removeInventoryItem('vodka', 2)
					xPlayer.removeInventoryItem('ice', 1)
					xPlayer.addInventoryItem('golem', 1)
				end
			end
		end)
	end
	
	if itemValue == 'whiskycoca' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('limonade').count
			local bethQuantity = xPlayer.getInventoryItem('whisky').count

			if alephQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('limonade') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('whisky') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('limonade', 2)
					xPlayer.removeInventoryItem('whisky', 2)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('whiskycoca') .. ' ~w~!')
					xPlayer.removeInventoryItem('limonade', 2)
					xPlayer.removeInventoryItem('whisky', 2)
					xPlayer.addInventoryItem('whiskycoca', 1)
				end
			end
		end)
	end

	if itemValue == 'rhumcoca' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('limonade').count
			local bethQuantity = xPlayer.getInventoryItem('rhum').count

			if alephQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('limonade') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('rhum') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('limonade', 2)
					xPlayer.removeInventoryItem('rhum', 2)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('rhumcoca') .. ' ~w~!')
					xPlayer.removeInventoryItem('limonade', 2)
					xPlayer.removeInventoryItem('rhum', 2)
					xPlayer.addInventoryItem('rhumcoca', 1)
				end
			end
		end)
	end

	if itemValue == 'vodkaenergy' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('energy').count
			local bethQuantity = xPlayer.getInventoryItem('vodka').count
			local gimelQuantity = xPlayer.getInventoryItem('ice').count

			if alephQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('energy') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('vodka') .. '~w~')
			elseif gimelQuantity < 1 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('ice') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('energy', 2)
					xPlayer.removeInventoryItem('vodka', 2)
					xPlayer.removeInventoryItem('ice', 1)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('vodkaenergy') .. ' ~w~!')
					xPlayer.removeInventoryItem('energy', 2)
					xPlayer.removeInventoryItem('vodka', 2)
					xPlayer.removeInventoryItem('ice', 1)
					xPlayer.addInventoryItem('vodkaenergy', 1)
				end
			end
		end)
	end

	if itemValue == 'vodkafruit' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('jusfruit').count
			local bethQuantity = xPlayer.getInventoryItem('vodka').count
			local gimelQuantity = xPlayer.getInventoryItem('ice').count

			if alephQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('jusfruit') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('vodka') .. '~w~')
			elseif gimelQuantity < 1 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('ice') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('jusfruit', 2)
					xPlayer.removeInventoryItem('vodka', 2)
					xPlayer.removeInventoryItem('ice', 1)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('vodkafruit') .. ' ~w~!')
					xPlayer.removeInventoryItem('jusfruit', 2)
					xPlayer.removeInventoryItem('vodka', 2)
					xPlayer.removeInventoryItem('ice', 1)
					xPlayer.addInventoryItem('vodkafruit', 1) 
				end
			end
		end)
	end

	if itemValue == 'rhumfruit' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('jusfruit').count
			local bethQuantity = xPlayer.getInventoryItem('rhum').count
			local gimelQuantity = xPlayer.getInventoryItem('ice').count

			if alephQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('jusfruit') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('rhum') .. '~w~')
			elseif gimelQuantity < 1 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('ice') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('jusfruit', 2)
					xPlayer.removeInventoryItem('rhum', 2)
					xPlayer.removeInventoryItem('ice', 1)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('rhumfruit') .. ' ~w~!')
					xPlayer.removeInventoryItem('jusfruit', 2)
					xPlayer.removeInventoryItem('rhum', 2)
					xPlayer.removeInventoryItem('ice', 1)
					xPlayer.addInventoryItem('rhumfruit', 1)
				end
			end
		end)
	end

	if itemValue == 'teqpaf' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('limonade').count
			local bethQuantity = xPlayer.getInventoryItem('tequila').count

			if alephQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('limonade') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('tequila') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('limonade', 2)
					xPlayer.removeInventoryItem('tequila', 2)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('teqpaf') .. ' ~w~!')
					xPlayer.removeInventoryItem('limonade', 2)
					xPlayer.removeInventoryItem('tequila', 2)
					xPlayer.addInventoryItem('teqpaf', 1)
				end
			end
		end)
	end

	if itemValue == 'mojito' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('rhum').count
			local bethQuantity = xPlayer.getInventoryItem('limonade').count
			local gimelQuantity = xPlayer.getInventoryItem('menthe').count
			local daletQuantity = xPlayer.getInventoryItem('ice').count

			if alephQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('rhum') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('limonade') .. '~w~')
			elseif gimelQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('menthe') .. '~w~')
			elseif daletQuantity < 1 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('ice') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('rhum', 2)
					xPlayer.removeInventoryItem('limonade', 2)
					xPlayer.removeInventoryItem('menthe', 2)
					xPlayer.removeInventoryItem('ice', 1)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('mojito') .. ' ~w~!')
					xPlayer.removeInventoryItem('rhum', 2)
					xPlayer.removeInventoryItem('limonade', 2)
					xPlayer.removeInventoryItem('menthe', 2)
					xPlayer.removeInventoryItem('ice', 1)
					xPlayer.addInventoryItem('mojito', 1)
				end
			end
		end)
	end

	if itemValue == 'mixapero' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('bolcacahuetes').count
			local bethQuantity = xPlayer.getInventoryItem('bolnoixcajou').count
			local gimelQuantity = xPlayer.getInventoryItem('bolpistache').count
			local daletQuantity = xPlayer.getInventoryItem('bolchips').count

			if alephQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('bolcacahuetes') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('bolnoixcajou') .. '~w~')
			elseif gimelQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('bolpistache') .. '~w~')
			elseif daletQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('bolchips') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('bolcacahuetes', 2)
					xPlayer.removeInventoryItem('bolnoixcajou', 2)
					xPlayer.removeInventoryItem('bolpistache', 2)
					xPlayer.removeInventoryItem('bolchips', 1)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('mixapero') .. ' ~w~!')
					xPlayer.removeInventoryItem('bolcacahuetes', 2)
					xPlayer.removeInventoryItem('bolnoixcajou', 2)
					xPlayer.removeInventoryItem('bolpistache', 2)
					xPlayer.removeInventoryItem('bolchips', 2)
					xPlayer.addInventoryItem('mixapero', 1)
				end
			end
		end)
	end

	if itemValue == 'metreshooter' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('jager').count
			local bethQuantity = xPlayer.getInventoryItem('vodka').count
			local gimelQuantity = xPlayer.getInventoryItem('whisky').count
			local daletQuantity = xPlayer.getInventoryItem('tequila').count

			if alephQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('jager') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('vodka') .. '~w~')
			elseif gimelQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('whisky') .. '~w~')
			elseif daletQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('tequila') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('jager', 2)
					xPlayer.removeInventoryItem('vodka', 2)
					xPlayer.removeInventoryItem('whisky', 2)
					xPlayer.removeInventoryItem('tequila', 2)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('metreshooter') .. ' ~w~!')
					xPlayer.removeInventoryItem('jager', 2)
					xPlayer.removeInventoryItem('vodka', 2)
					xPlayer.removeInventoryItem('whisky', 2)
					xPlayer.removeInventoryItem('tequila', 2)
					xPlayer.addInventoryItem('metreshooter', 1)
				end
			end
		end)
	end

	if itemValue == 'jagercerbere' then
		SetTimeout(10000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)

			local alephQuantity = xPlayer.getInventoryItem('jagerbomb').count
			local bethQuantity = xPlayer.getInventoryItem('vodka').count
			local gimelQuantity = xPlayer.getInventoryItem('tequila').count

			if alephQuantity < 1 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('jagerbomb') .. '~w~')
			elseif bethQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('vodka') .. '~w~')
			elseif gimelQuantity < 2 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough') .. _U('tequila') .. '~w~')
			else
				local chanceToMiss = math.random(100)
				if chanceToMiss <= Config.MissCraft then
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft_miss'))
					xPlayer.removeInventoryItem('jagerbomb', 1)
					xPlayer.removeInventoryItem('vodka', 2)
					xPlayer.removeInventoryItem('tequila', 2)
				else
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('craft') .. _U('jagercerbere') .. ' ~w~!')
					xPlayer.removeInventoryItem('jagerbomb', 1)
					xPlayer.removeInventoryItem('vodka', 2)
					xPlayer.removeInventoryItem('tequila', 2)
					xPlayer.addInventoryItem('jagercerbere', 1)
				end
			end
		end)
	end
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_unicornjob:getVaultWeapons', function(source, cb)
	TriggerEvent('::{korioz#0110}::esx_datastore:getSharedDataStore', 'society_unicorn', function(store)
		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		cb(weapons)
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_unicornjob:addVaultWeapon', function(source, cb, weaponName)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeWeapon(weaponName)

	TriggerEvent('::{korioz#0110}::esx_datastore:getSharedDataStore', 'society_unicorn', function(store)
		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = weapons[i].count + 1
				foundWeapon = true
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name = weaponName,
				count = 1
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_unicornjob:removeVaultWeapon', function(source, cb, weaponName)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addWeapon(weaponName, 1000)

	TriggerEvent('::{korioz#0110}::esx_datastore:getSharedDataStore', 'society_unicorn', function(store)
		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		local foundWeapon = false

		for i = 1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
				foundWeapon = true
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name = weaponName,
				count = 0
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)
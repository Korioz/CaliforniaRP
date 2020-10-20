local PlayersHarvesting, PlayersHarvesting2, PlayersHarvesting3 = {}, {}, {}
local PlayersCrafting, PlayersCrafting2, PlayersCrafting3 = {}, {}, {}

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
	TriggerEvent('::{korioz#0110}::esx_service:activateService', 'mecano', Config.MaxInService)
end

TriggerEvent('::{korioz#0110}::esx_phone:registerNumber', 'mecano', _U('mechanic_customer'), true, true)
TriggerEvent('::{korioz#0110}::esx_society:registerSociety', 'mecano', 'mecano', 'society_mecano', 'society_mecano', 'society_mecano', {type = 'private'})

local function Harvest(source)
	SetTimeout(4000, function()
		if PlayersHarvesting[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local GazBottleQuantity = xPlayer.getInventoryItem('gazbottle').count

			if GazBottleQuantity >= 5 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('you_do_not_room'))
			else
				xPlayer.addInventoryItem('gazbottle', 1)
				Harvest(source)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:startHarvest')
AddEventHandler('::{korioz#0110}::esx_mecanojob:startHarvest', function()
	local _source = source
	PlayersHarvesting[_source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('recovery_gas_can'))
	Harvest(_source)
end)

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:stopHarvest')
AddEventHandler('::{korioz#0110}::esx_mecanojob:stopHarvest', function()
	local _source = source
	PlayersHarvesting[_source] = false
end)

local function Harvest2(source)
	SetTimeout(4000, function()
		if PlayersHarvesting2[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local FixToolQuantity = xPlayer.getInventoryItem('fixtool').count

			if FixToolQuantity >= 5 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('you_do_not_room'))
			else
				xPlayer.addInventoryItem('fixtool', 1)
				Harvest2(source)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:startHarvest2')
AddEventHandler('::{korioz#0110}::esx_mecanojob:startHarvest2', function()
	local _source = source
	PlayersHarvesting2[_source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('recovery_repair_tools'))
	Harvest2(_source)
end)

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:stopHarvest2')
AddEventHandler('::{korioz#0110}::esx_mecanojob:stopHarvest2', function()
	local _source = source
	PlayersHarvesting2[_source] = false
end)

local function Harvest3(source)
	SetTimeout(4000, function()
		if PlayersHarvesting3[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local CaroToolQuantity = xPlayer.getInventoryItem('carotool').count

			if CaroToolQuantity >= 5 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('you_do_not_room'))
			else
				xPlayer.addInventoryItem('carotool', 1)
				Harvest3(source)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:startHarvest3')
AddEventHandler('::{korioz#0110}::esx_mecanojob:startHarvest3', function()
	local _source = source
	PlayersHarvesting3[_source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('recovery_body_tools'))
	Harvest3(_source)
end)

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:stopHarvest3')
AddEventHandler('::{korioz#0110}::esx_mecanojob:stopHarvest3', function()
	local _source = source
	PlayersHarvesting3[_source] = false
end)

local function Craft(source)
	SetTimeout(4000, function()
		if PlayersCrafting[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local GazBottleQuantity = xPlayer.getInventoryItem('gazbottle').count

			if GazBottleQuantity <= 0 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('not_enough_gas_can'))
			else
				xPlayer.removeInventoryItem('gazbottle', 1)
				xPlayer.addInventoryItem('blowpipe', 1)
				Craft(source)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:startCraft')
AddEventHandler('::{korioz#0110}::esx_mecanojob:startCraft', function()
	local _source = source
	PlayersCrafting[_source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('assembling_blowtorch'))
	Craft(_source)
end)

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:stopCraft')
AddEventHandler('::{korioz#0110}::esx_mecanojob:stopCraft', function()
	local _source = source
	PlayersCrafting[_source] = false
end)

local function Craft2(source)
	SetTimeout(4000, function()
		if PlayersCrafting2[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local FixToolQuantity = xPlayer.getInventoryItem('fixtool').count

			if FixToolQuantity <= 0 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('not_enough_repair_tools'))
			else
				xPlayer.removeInventoryItem('fixtool', 1)
				xPlayer.addInventoryItem('fixkit', 1)
				Craft2(source)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:startCraft2')
AddEventHandler('::{korioz#0110}::esx_mecanojob:startCraft2', function()
	local _source = source
	PlayersCrafting2[_source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('assembling_repair_kit'))
	Craft2(_source)
end)

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:stopCraft2')
AddEventHandler('::{korioz#0110}::esx_mecanojob:stopCraft2', function()
	local _source = source
	PlayersCrafting2[_source] = false
end)

local function Craft3(source)
	SetTimeout(4000, function()
		if PlayersCrafting3[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local CaroToolQuantity = xPlayer.getInventoryItem('carotool').count

			if CaroToolQuantity <= 0 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('not_enough_body_tools'))
			else
				xPlayer.removeInventoryItem('carotool', 1)
				xPlayer.addInventoryItem('carokit', 1)
				Craft3(source)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:startCraft3')
AddEventHandler('::{korioz#0110}::esx_mecanojob:startCraft3', function()
	local _source = source
	PlayersCrafting3[_source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('assembling_body_kit'))
	Craft3(_source)
end)

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:stopCraft3')
AddEventHandler('::{korioz#0110}::esx_mecanojob:stopCraft3', function()
	local _source = source
	PlayersCrafting3[_source] = false
end)

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:onNPCJobMissionCompleted')
AddEventHandler('::{korioz#0110}::esx_mecanojob:onNPCJobMissionCompleted', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = math.random(Config.NPCJobEarnings.min, Config.NPCJobEarnings.max)

	if xPlayer.job.grade_name == 'boss' then
		total = total * 2
	end

	TriggerEvent('::{korioz#0110}::esx_addonaccount:getSharedAccount', 'society_mecano', function(account)
		account.addMoney(total)
	end)

	TriggerClientEvent("::{korioz#0110}::esx:showNotification", _source, _U('your_comp_earned') .. total)
end)

ESX.RegisterUsableItem('blowpipe', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('blowpipe', 1)
	TriggerClientEvent('::{korioz#0110}::esx_mecanojob:onHijack', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('you_used_blowtorch'))
end)

ESX.RegisterUsableItem('fixkit', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('fixkit', 1)
	TriggerClientEvent('::{korioz#0110}::esx_mecanojob:onFixkit', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('you_used_repair_kit'))
end)

ESX.RegisterUsableItem('carokit', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('carokit', 1)
	TriggerClientEvent('::{korioz#0110}::esx_mecanojob:onCarokit', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('you_used_body_kit'))
end)

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:getStockItem')
AddEventHandler('::{korioz#0110}::esx_mecanojob:getStockItem', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_mecano', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		if count > 0 and inventoryItem.count >= count then
			if xPlayer.canCarryItem(itemName, count) then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('have_withdrawn', count, inventoryItem.label))
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('player_cannot_hold'))
			end
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_mecanojob:getStockItems', function(source, cb)
	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_mecano', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterServerEvent('::{korioz#0110}::esx_mecanojob:putStockItems')
AddEventHandler('::{korioz#0110}::esx_mecanojob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_mecano', function(inventory)
		local sourceItem = xPlayer.getInventoryItem(itemName)

		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('have_deposited', count, ESX.GetItem(itemName).label))
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_mecanojob:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb({items = xPlayer.inventory})
end)
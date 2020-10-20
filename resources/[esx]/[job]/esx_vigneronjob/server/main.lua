local PlayersTransforming = {}
local PlayersSelling = {}
local PlayersHarvesting = {}

local vine = 1
local jus = 1

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
	TriggerEvent('::{korioz#0110}::esx_service:activateService', 'vigne', Config.MaxInService)
end

TriggerEvent('::{korioz#0110}::esx_society:registerSociety', 'vigne', 'Vigneron', 'society_vigne', 'society_vigne', 'society_vigne', {type = 'private'})

local function Harvest(source, zone)
	if PlayersHarvesting[source] == true then
		local xPlayer = ESX.GetPlayerFromId(source)

		if zone == "RaisinFarm" then
			local itemQuantity = xPlayer.getInventoryItem('raisin').count

			if itemQuantity >= 100 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('not_enough_place'))
				return
			else
				SetTimeout(1800, function()
					xPlayer.addInventoryItem('raisin', 1)
					Harvest(source, zone)
				end)
			end
		end
	end
end

RegisterServerEvent('::{korioz#0110}::esx_vigneronjob:startHarvest')
AddEventHandler('::{korioz#0110}::esx_vigneronjob:startHarvest', function(zone)
	local _source = source
	PlayersHarvesting[_source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('raisin_taken'))
	Harvest(_source, zone)
end)

RegisterServerEvent('::{korioz#0110}::esx_vigneronjob:stopHarvest')
AddEventHandler('::{korioz#0110}::esx_vigneronjob:stopHarvest', function()
	local _source = source
	
	if PlayersHarvesting[_source] == true then
		PlayersHarvesting[_source] = false
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, 'Vous sortez de la ~r~zone')
	else
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, 'Vous pouvez ~g~récolter')
		PlayersHarvesting[_source] = true
	end
end)

local function Transform(source, zone)
	if PlayersTransforming[source] == true then
		local xPlayer = ESX.GetPlayerFromId(source)

		if zone == "TraitementVin" then
			local itemQuantity = xPlayer.getInventoryItem('raisin').count
			
			if itemQuantity <= 0 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('not_enough_raisin'))
				return
			else
				local rand = math.random(0, 100)

				if (rand >= 98) then
					SetTimeout(700, function()
						xPlayer.removeInventoryItem('raisin', 1)
						xPlayer.addInventoryItem('grand_cru', 1)
						TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('grand_cru'))
						Transform(source, zone)
					end)
				else
					SetTimeout(700, function()
						xPlayer.removeInventoryItem('raisin', 1)
						xPlayer.addInventoryItem('vine', 1)
						Transform(source, zone)
					end)
				end
			end
		elseif zone == "TraitementJus" then
			local itemQuantity = xPlayer.getInventoryItem('raisin').count

			if itemQuantity <= 0 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('not_enough_raisin'))
				return
			else
				SetTimeout(700, function()
					xPlayer.removeInventoryItem('raisin', 1)
					xPlayer.addInventoryItem('jus_raisin', 1)
					Transform(source, zone)
				end)
			end
		end
	end	
end

RegisterServerEvent('::{korioz#0110}::esx_vigneronjob:startTransform')
AddEventHandler('::{korioz#0110}::esx_vigneronjob:startTransform', function(zone)
	local _source = source
	PlayersTransforming[_source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('transforming_in_progress')) 
	Transform(_source, zone)
end)

RegisterServerEvent('::{korioz#0110}::esx_vigneronjob:stopTransform')
AddEventHandler('::{korioz#0110}::esx_vigneronjob:stopTransform', function()
	local _source = source
	
	if PlayersTransforming[_source] == true then
		PlayersTransforming[_source] = false
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, 'Vous sortez de la ~r~zone')
	else
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, 'Vous pouvez ~g~transformer votre raisin')
		PlayersTransforming[_source] = true
	end
end)

local function Sell(source, zone)
	if PlayersSelling[source] == true then
		local xPlayer = ESX.GetPlayerFromId(source)
		
		if zone == 'SellFarm' then
			if xPlayer.getInventoryItem('vine').count <= 0 then
				vine = 0
			else
				vine = 1
			end

			if xPlayer.getInventoryItem('jus_raisin').count <= 0 then
				jus = 0
			else
				jus = 1
			end

			if vine == 0 and jus == 0 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('no_product_sale'))
				return
			elseif xPlayer.getInventoryItem('vine').count <= 0 and jus == 0 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('no_vin_sale'))
				vine = 0
				return
			elseif xPlayer.getInventoryItem('jus_raisin').count <= 0 and vine == 0then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('no_jus_sale'))
				jus = 0
				return
			else
				if (jus == 1) then
					SetTimeout(800, function()
						local money = math.random(220, 340)
						xPlayer.removeInventoryItem('jus_raisin', 1)
						local societyAccount = nil

						TriggerEvent('::{korioz#0110}::esx_addonaccount:getSharedAccount', 'society_vigne', function(account)
							societyAccount = account
						end)

						if societyAccount ~= nil then
							societyAccount.addMoney(money)
							TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('comp_earned') .. money)
						end

						Sell(source,zone)
					end)
				elseif (vine == 1) then
					SetTimeout(800, function()
						local money = math.random(240, 350)
						xPlayer.removeInventoryItem('vine', 1)
						local societyAccount = nil

						TriggerEvent('::{korioz#0110}::esx_addonaccount:getSharedAccount', 'society_vigne', function(account)
							societyAccount = account
						end)

						if societyAccount ~= nil then
							societyAccount.addMoney(money)
							TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('comp_earned') .. money)
						end

						Sell(source,zone)
					end)
				end
			end
		end
	end
end

RegisterServerEvent('::{korioz#0110}::esx_vigneronjob:startSell')
AddEventHandler('::{korioz#0110}::esx_vigneronjob:startSell', function(zone)
	local _source = source

	if PlayersSelling[_source] == false then
		PlayersSelling[_source] = false
	else
		PlayersSelling[_source] = true
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('sale_in_prog'))
		Sell(_source, zone)
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_vigneronjob:stopSell')
AddEventHandler('::{korioz#0110}::esx_vigneronjob:stopSell', function()
	local _source = source

	if PlayersSelling[_source] == true then
		PlayersSelling[_source] = false
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, 'Vous sortez de la ~r~zone')
	else
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, 'Vous pouvez ~g~vendre')
		PlayersSelling[_source] = true
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_vigneronjob:getStockItem')
AddEventHandler('::{korioz#0110}::esx_vigneronjob:getStockItem', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_vigne', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		if count > 0 and inventoryItem.count >= count then
			if xPlayer.canCarryItem(itemName, count) then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('have_withdrawn') .. count .. ' ' .. inventoryItem.label)
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('quantity_invalid'))
			end
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_vigneronjob:getStockItems', function(source, cb)
	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_vigne', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterServerEvent('::{korioz#0110}::esx_vigneronjob:putStockItems')
AddEventHandler('::{korioz#0110}::esx_vigneronjob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('::{korioz#0110}::esx_addoninventory:getSharedInventory', 'society_vigne', function(inventory)
		local sourceItem = xPlayer.getInventoryItem(itemName)

		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('added') .. count .. ' ' .. ESX.GetItem(itemName).label)
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_vigneronjob:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb({items = xPlayer.inventory})
end)

ESX.RegisterUsableItem('jus_raisin', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('jus_raisin', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 50000)
	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 120000)
	TriggerClientEvent('::{korioz#0110}::esx_basicneeds:onDrink', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_jus'))
end)

ESX.RegisterUsableItem('grand_cru', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('grand_cru', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 800000)
	TriggerClientEvent('::{korioz#0110}::esx_basicneeds:onDrink', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_grand_cru'))
end)

ESX.RegisterUsableItem('vine', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vine', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', xPlayer.source, 'drunk', 400000)
	TriggerClientEvent('::{korioz#0110}::esx_basicneeds:onDrink', xPlayer.source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('used_grand_cru'))
end)
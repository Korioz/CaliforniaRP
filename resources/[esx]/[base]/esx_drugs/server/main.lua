local CopsConnected = 0
local PlayersHarvestingCoke, PlayersTransformingCoke, PlayersSellingCoke = {}, {}, {}
local PlayersHarvestingMeth, PlayersTransformingMeth, PlayersSellingMeth = {}, {}, {}
local PlayersHarvestingWeed, PlayersTransformingWeed, PlayersSellingWeed = {}, {}, {}
local PlayersHarvestingOpium, PlayersTransformingOpium, PlayersSellingOpium = {}, {}, {}

someRandomGayData = exports['serverdata']:GetData('drugs')

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('::{korioz#0110}::dumpIsForGayDude', function(source, cb)
	cb(someRandomGayData)
end)

AddEventHandler('playerDropped', function()
	PlayersHarvestingCoke[source], PlayersTransformingCoke[source], PlayersSellingCoke[source] = nil, nil, nil
	PlayersHarvestingMeth[source], PlayersTransformingMeth[source], PlayersSellingMeth[source] = nil, nil, nil
	PlayersHarvestingWeed[source], PlayersTransformingWeed[source], PlayersSellingWeed[source] = nil, nil, nil
	PlayersHarvestingOpium[source], PlayersTransformingOpium[source], PlayersSellingOpium[source] = nil, nil, nil
end)

function CountCops()
	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

		if xPlayer and xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(120 * 1000, CountCops)
end

CountCops()

local function HarvestWeed(xPlayer)
	if CopsConnected < Config.RequiredCopsWeed then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsWeed))
		return
	end

	SetTimeout(Config.TimeToFarm, function()
		if PlayersHarvestingWeed[xPlayer.source] then
			if xPlayer.canCarryItem('weed', 1) then
				xPlayer.addInventoryItem('weed', 1)
				HarvestWeed(xPlayer)
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('inv_full_weed'))
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startHarvestWeed')
AddEventHandler('::{korioz#0110}::esx_drugs:startHarvestWeed', function()
	PlayersHarvestingWeed[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('pickup_in_prog'))
	HarvestWeed(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopHarvestWeed')
AddEventHandler('::{korioz#0110}::esx_drugs:stopHarvestWeed', function()
	PlayersHarvestingWeed[source] = nil
end)

local function TransformWeed(xPlayer)
	if CopsConnected < Config.RequiredCopsWeed then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsWeed))
		return
	end

	SetTimeout(Config.TimeToProcess, function()
		if PlayersTransformingWeed[xPlayer.source] then
			local weedQuantity = xPlayer.getInventoryItem('weed').count
			local poochQuantity = xPlayer.getInventoryItem('weed_pooch').count

			if poochQuantity > 35 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('too_many_pouches'))
			elseif weedQuantity < 5 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('not_enough_weed'))
			else
				xPlayer.removeInventoryItem('weed', 5)
				xPlayer.addInventoryItem('weed_pooch', 1)

				TransformWeed(xPlayer)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startTransformWeed')
AddEventHandler('::{korioz#0110}::esx_drugs:startTransformWeed', function()
	PlayersTransformingWeed[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('packing_in_prog'))
	TransformWeed(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopTransformWeed')
AddEventHandler('::{korioz#0110}::esx_drugs:stopTransformWeed', function()
	PlayersTransformingWeed[source] = nil
end)

local function SellWeed(xPlayer)
	if CopsConnected < Config.RequiredCopsWeed then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsWeed))
		return
	end

	SetTimeout(Config.TimeToSell, function()
		if PlayersSellingWeed[xPlayer.source] then
			local poochQuantity = xPlayer.getInventoryItem('weed_pooch').count

			if poochQuantity == 0 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('no_pouches_sale'))
			else
				xPlayer.removeInventoryItem('weed_pooch', 1)

				if CopsConnected == 0 then
					xPlayer.addAccountMoney('dirtycash', 250)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_weed'))
				elseif CopsConnected == 1 then
					xPlayer.addAccountMoney('dirtycash', 250)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_weed'))
				elseif CopsConnected == 2 then
					xPlayer.addAccountMoney('dirtycash', 250)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_weed'))
				elseif CopsConnected == 3 then
					xPlayer.addAccountMoney('dirtycash', 250)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_weed'))
				elseif CopsConnected >= 4 then
					xPlayer.addAccountMoney('dirtycash', 250)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_weed'))
				end

				SellWeed(xPlayer)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startSellWeed')
AddEventHandler('::{korioz#0110}::esx_drugs:startSellWeed', function()
	PlayersSellingWeed[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('sale_in_prog'))
	SellWeed(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopSellWeed')
AddEventHandler('::{korioz#0110}::esx_drugs:stopSellWeed', function()
	PlayersSellingWeed[source] = nil
end)

local function HarvestCoke(xPlayer)
	if CopsConnected < Config.RequiredCopsCoke then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsCoke))
		return
	end

	SetTimeout(Config.TimeToFarm, function()
		if PlayersHarvestingCoke[xPlayer.source] then
			if xPlayer.canCarryItem('coke', 1) then
				xPlayer.addInventoryItem('coke', 1)
				HarvestCoke(xPlayer)
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('inv_full_coke'))
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startHarvestCoke')
AddEventHandler('::{korioz#0110}::esx_drugs:startHarvestCoke', function()
	PlayersHarvestingCoke[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('pickup_in_prog'))
	HarvestCoke(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopHarvestCoke')
AddEventHandler('::{korioz#0110}::esx_drugs:stopHarvestCoke', function()
	PlayersHarvestingCoke[source] = nil
end)

local function TransformCoke(xPlayer)
	if CopsConnected < Config.RequiredCopsCoke then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsCoke))
		return
	end

	SetTimeout(Config.TimeToProcess, function()
		if PlayersTransformingCoke[xPlayer.source] then
			local cokeQuantity = xPlayer.getInventoryItem('coke').count
			local poochQuantity = xPlayer.getInventoryItem('coke_pooch').count

			if poochQuantity > 35 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('too_many_pouches'))
			elseif cokeQuantity < 5 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('not_enough_coke'))
			else
				xPlayer.removeInventoryItem('coke', 5)
				xPlayer.addInventoryItem('coke_pooch', 1)

				TransformCoke(xPlayer)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startTransformCoke')
AddEventHandler('::{korioz#0110}::esx_drugs:startTransformCoke', function()
	PlayersTransformingCoke[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('packing_in_prog'))
	TransformCoke(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopTransformCoke')
AddEventHandler('::{korioz#0110}::esx_drugs:stopTransformCoke', function()
	PlayersTransformingCoke[source] = nil
end)

local function SellCoke(xPlayer)
	if CopsConnected < Config.RequiredCopsCoke then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsCoke))
		return
	end

	SetTimeout(Config.TimeToSell, function()
		if PlayersSellingCoke[xPlayer.source] then
			local poochQuantity = xPlayer.getInventoryItem('coke_pooch').count

			if poochQuantity == 0 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('no_pouches_sale'))
			else
				xPlayer.removeInventoryItem('coke_pooch', 1)

				if CopsConnected == 0 then
					xPlayer.addAccountMoney('dirtycash', 400)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_coke'))
				elseif CopsConnected == 1 then
					xPlayer.addAccountMoney('dirtycash', 400)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_coke'))
				elseif CopsConnected == 2 then
					xPlayer.addAccountMoney('dirtycash', 400)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_coke'))
				elseif CopsConnected == 3 then
					xPlayer.addAccountMoney('dirtycash', 400)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_coke'))
				elseif CopsConnected == 4 then
					xPlayer.addAccountMoney('dirtycash', 400)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_coke'))
				elseif CopsConnected >= 5 then
					xPlayer.addAccountMoney('dirtycash', 400)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_coke'))
				end

				SellCoke(xPlayer)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startSellCoke')
AddEventHandler('::{korioz#0110}::esx_drugs:startSellCoke', function()
	PlayersSellingCoke[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('sale_in_prog'))
	SellCoke(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopSellCoke')
AddEventHandler('::{korioz#0110}::esx_drugs:stopSellCoke', function()
	PlayersSellingCoke[source] = nil
end)

local function HarvestMeth(xPlayer)
	if CopsConnected < Config.RequiredCopsMeth then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsMeth))
		return
	end

	SetTimeout(Config.TimeToFarm, function()
		if PlayersHarvestingMeth[xPlayer.source] then
			if xPlayer.canCarryItem('meth', 1) then
				xPlayer.addInventoryItem('meth', 1)
				HarvestMeth(xPlayer)
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('inv_full_meth'))
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startHarvestMeth')
AddEventHandler('::{korioz#0110}::esx_drugs:startHarvestMeth', function()
	PlayersHarvestingMeth[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('pickup_in_prog'))
	HarvestMeth(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopHarvestMeth')
AddEventHandler('::{korioz#0110}::esx_drugs:stopHarvestMeth', function()
	PlayersHarvestingMeth[source] = nil
end)

local function TransformMeth(xPlayer)
	if CopsConnected < Config.RequiredCopsMeth then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsMeth))
		return
	end

	SetTimeout(Config.TimeToProcess, function()
		if PlayersTransformingMeth[xPlayer.source] then
			local methQuantity = xPlayer.getInventoryItem('meth').count
			local poochQuantity = xPlayer.getInventoryItem('meth_pooch').count

			if poochQuantity > 35 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('too_many_pouches'))
			elseif methQuantity < 5 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('not_enough_meth'))
			else
				xPlayer.removeInventoryItem('meth', 5)
				xPlayer.addInventoryItem('meth_pooch', 1)

				TransformMeth(xPlayer)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startTransformMeth')
AddEventHandler('::{korioz#0110}::esx_drugs:startTransformMeth', function()
	PlayersTransformingMeth[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('packing_in_prog'))
	TransformMeth(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopTransformMeth')
AddEventHandler('::{korioz#0110}::esx_drugs:stopTransformMeth', function()
	PlayersTransformingMeth[source] = nil
end)

local function SellMeth(xPlayer)
	if CopsConnected < Config.RequiredCopsMeth then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsMeth))
		return
	end

	SetTimeout(Config.TimeToSell, function()
		if PlayersSellingMeth[xPlayer.source] then
			local poochQuantity = xPlayer.getInventoryItem('meth_pooch').count

			if poochQuantity == 0 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('no_pouches_sale'))
			else
				xPlayer.removeInventoryItem('meth_pooch', 1)
				if CopsConnected == 0 then
					xPlayer.addAccountMoney('dirtycash', 450)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_meth'))
				elseif CopsConnected == 1 then
					xPlayer.addAccountMoney('dirtycash', 450)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_meth'))
				elseif CopsConnected == 2 then
					xPlayer.addAccountMoney('dirtycash', 450)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_meth'))
				elseif CopsConnected == 3 then
					xPlayer.addAccountMoney('dirtycash', 450)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_meth'))
				elseif CopsConnected == 4 then
					xPlayer.addAccountMoney('dirtycash', 450)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_meth'))
				elseif CopsConnected == 5 then
					xPlayer.addAccountMoney('dirtycash', 450)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_meth'))
				elseif CopsConnected >= 6 then
					xPlayer.addAccountMoney('dirtycash', 450)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_meth'))
				end

				SellMeth(xPlayer)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startSellMeth')
AddEventHandler('::{korioz#0110}::esx_drugs:startSellMeth', function()
	PlayersSellingMeth[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('sale_in_prog'))
	SellMeth(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopSellMeth')
AddEventHandler('::{korioz#0110}::esx_drugs:stopSellMeth', function()
	PlayersSellingMeth[source] = nil
end)

local function HarvestOpium(xPlayer)
	if CopsConnected < Config.RequiredCopsOpium then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsOpium))
		return
	end

	SetTimeout(Config.TimeToFarm, function()
		if PlayersHarvestingOpium[xPlayer.source] then
			if xPlayer.canCarryItem('opium', 1) then
				xPlayer.addInventoryItem('opium', 1)
				HarvestOpium(xPlayer)
			else
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('inv_full_opium'))
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startHarvestOpium')
AddEventHandler('::{korioz#0110}::esx_drugs:startHarvestOpium', function()
	PlayersHarvestingOpium[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('pickup_in_prog'))
	HarvestOpium(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopHarvestOpium')
AddEventHandler('::{korioz#0110}::esx_drugs:stopHarvestOpium', function()
	PlayersHarvestingOpium[source] = nil
end)

local function TransformOpium(xPlayer)
	if CopsConnected < Config.RequiredCopsOpium then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsOpium))
		return
	end

	SetTimeout(Config.TimeToProcess, function()
		if PlayersTransformingOpium[xPlayer.source] then
			local opiumQuantity = xPlayer.getInventoryItem('opium').count
			local poochQuantity = xPlayer.getInventoryItem('opium_pooch').count

			if poochQuantity > 35 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('too_many_pouches'))
			elseif opiumQuantity < 5 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('not_enough_opium'))
			else
				xPlayer.removeInventoryItem('opium', 5)
				xPlayer.addInventoryItem('opium_pooch', 1)

				TransformOpium(xPlayer)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startTransformOpium')
AddEventHandler('::{korioz#0110}::esx_drugs:startTransformOpium', function()
	PlayersTransformingOpium[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('packing_in_prog'))
	TransformOpium(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopTransformOpium')
AddEventHandler('::{korioz#0110}::esx_drugs:stopTransformOpium', function()
	PlayersTransformingOpium[source] = nil
end)

local function SellOpium(xPlayer)
	if CopsConnected < Config.RequiredCopsOpium then
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('act_imp_police', CopsConnected, Config.RequiredCopsOpium))
		return
	end

	SetTimeout(Config.TimeToSell, function()
		if PlayersSellingOpium[xPlayer.source] then
			local poochQuantity = xPlayer.getInventoryItem('opium_pooch').count

			if poochQuantity == 0 then
				TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('no_pouches_sale'))
			else
				xPlayer.removeInventoryItem('opium_pooch', 1)

				if CopsConnected == 0 then
					xPlayer.addAccountMoney('dirtycash', 500)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_opium'))
				elseif CopsConnected == 1 then
					xPlayer.addAccountMoney('dirtycash', 500)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_opium'))
				elseif CopsConnected == 2 then
					xPlayer.addAccountMoney('dirtycash', 500)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_opium'))
				elseif CopsConnected == 3 then
					xPlayer.addAccountMoney('dirtycash', 500)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_opium'))
				elseif CopsConnected == 4 then
					xPlayer.addAccountMoney('dirtycash', 500)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_opium'))
				elseif CopsConnected >= 5 then
					xPlayer.addAccountMoney('dirtycash', 500)
					TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('sold_one_opium'))
				end

				SellOpium(xPlayer)
			end
		end
	end)
end

RegisterServerEvent('::{korioz#0110}::esx_drugs:startSellOpium')
AddEventHandler('::{korioz#0110}::esx_drugs:startSellOpium', function()
	PlayersSellingOpium[source] = true
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('sale_in_prog'))
	SellOpium(ESX.GetPlayerFromId(source))
end)

RegisterServerEvent('::{korioz#0110}::esx_drugs:stopSellOpium')
AddEventHandler('::{korioz#0110}::esx_drugs:stopSellOpium', function()
	PlayersSellingOpium[source] = nil
end)

ESX.RegisterUsableItem('weed', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('weed', 1)

	TriggerClientEvent('::{korioz#0110}::esx_drugs:onPot', xPlayer.source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', xPlayer.source, _U('used_one_weed'))
end)
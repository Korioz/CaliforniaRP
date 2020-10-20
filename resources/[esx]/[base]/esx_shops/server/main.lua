TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

local ShopItems = {}

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM shops LEFT JOIN items ON items.name = shops.item', {}, function(data)
		for i = 1, #data, 1 do
			if data[i].name then
				if data[i].limit == -1 then
					data[i].limit = 50
				end

				table.insert(ShopItems, {
					label = data[i].label,
					value = data[i].item,
					price = data[i].price,
					limit = data[i].limit
				})
			else
				print(('esx_shops: invalid item "%s" found!'):format(data[i].item))
			end
		end
	end)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_shops:requestDBItems', function(source, cb)
	cb(ShopItems)
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx_shops:canRob', function(source, cb, store)
	local xPlayers = ESX.GetPlayers()
	local cops = 0

	for i = 1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

		if xPlayer and xPlayer.job.name == 'police' then
			cops = cops + 1
		end
	end

	if cops >= Config.Zones[store].cops then
		if not Config.Zones[store].robbed then
			cb(true, true)
		else
			cb(true, false)
		end
	else
		cb(false)
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_shops:buyItem')
AddEventHandler('::{korioz#0110}::esx_shops:buyItem', function(itemName, amount, zone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	amount = ESX.Math.Round(amount)

	if amount < 0 then
		print('esx_shops: ' .. xPlayer.identifier .. ' attempted to exploit the shop!')
		return
	end

	local price = 0
	local itemLabel = ''

	for i = 1, #ShopItems, 1 do
		if ShopItems[i].value == itemName then
			price = ShopItems[i].price
			itemLabel = ShopItems[i].label
			break
		end
	end

	price = price * amount

	if xPlayer.getAccount('cash').money >= price then
		if xPlayer.canCarryItem(itemName, amount) then
			xPlayer.removeAccountMoney('cash', price)
			--Config.Zones[zone].reward = Config.Zones[zone].reward + price
			xPlayer.addInventoryItem(itemName, amount)
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('bought', amount, itemLabel, ESX.Math.GroupDigits(price)))
		else
			TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('player_cannot_hold'))
		end
	else
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough', ESX.Math.GroupDigits(price - xPlayer.getAccount('cash').money)))
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_shops:pickUp')
AddEventHandler('::{korioz#0110}::esx_shops:pickUp', function(store)
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.Zones[store].robbed then
		local reward = math.random(Config.Zones[store].reward[1], Config.Zones[store].reward[2]) --Config.Zones[store].reward

		--Config.Zones[store].reward = 0
		xPlayer.addAccountMoney('dirtycash', reward)

		TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('robbery_complete', reward))
		TriggerClientEvent('::{korioz#0110}::esx_shops:removePickup', -1, store)
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_shops:rob')
AddEventHandler('::{korioz#0110}::esx_shops:rob', function(store)
	local _source = source
	Config.Zones[store].robbed = true
	local xPlayers = ESX.GetPlayers()

	for i = 1, #xPlayers do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

		if xPlayer.job.name == 'police' then
			TriggerClientEvent('::{korioz#0110}::esx_shops:msgPolice', xPlayer.source, store, _source)
		end
	end

	TriggerClientEvent('::{korioz#0110}::esx_shops:rob', -1, store)
	Citizen.Wait(12000)
	TriggerClientEvent('::{korioz#0110}::esx_shops:robberyOver', _source)

	Citizen.SetTimeout(Config.Zones[store].cooldown * 1000, function()
		Config.Zones[store].robbed = false
		TriggerClientEvent('::{korioz#0110}::esx_shops:resetStore', -1, store)
		TriggerClientEvent('::{korioz#0110}::esx_shops:removePickup', -1, store)
	end)
end)
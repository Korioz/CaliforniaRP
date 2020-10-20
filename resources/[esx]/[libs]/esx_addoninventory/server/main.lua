Items = {}
local Inventories, SharedInventories = {}, {}, {}

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
		for i = 1, #result, 1 do
			Items[result[i].name] = result[i].label
		end

		MySQL.Async.fetchAll('SELECT * FROM addon_inventory', {}, function(result2)
			for i = 1, #result2, 1 do
				local name = result2[i].name
				local label = result2[i].label
				local shared = result2[i].shared
		
				MySQL.Async.fetchAll('SELECT * FROM addon_inventory_items WHERE inventory_name = @inventory_name', {
					['@inventory_name'] = name
				}, function(result3)
					if shared == 0 then
						Inventories[name] = {}
						local items = {}

						for j = 1, #result3, 1 do
							local itemName = result3[j].name
							local itemCount = result3[j].count
							local itemOwner = result3[j].owner

							if items[itemOwner] == nil then
								items[itemOwner] = {}
							end

							table.insert(items[itemOwner], {
								name = itemName,
								count = itemCount,
								label = Items[itemName]
							})
						end

						for k, v in pairs(items) do
							table.insert(Inventories[name], CreateAddonInventory(name, k, v))
						end
					else
						local items = {}

						for j = 1, #result3, 1 do
							table.insert(items, {
								name = result3[j].name,
								count = result3[j].count,
								label = Items[result3[j].name]
							})
						end

						SharedInventories[name] = CreateAddonInventory(name, nil, items)
					end
				end)
			end
		end)
	end)
end)

function GetInventory(name, owner)
	for i = 1, #Inventories[name], 1 do
		if Inventories[name][i].owner == owner then
			return Inventories[name][i]
		end
	end

	local inventory = CreateAddonInventory(name, owner, {})
	table.insert(Inventories[name], inventory)
	return inventory
end

function GetSharedInventory(name)
	return SharedInventories[name]
end

AddEventHandler('::{korioz#0110}::esx_addoninventory:getInventory', function(name, owner, cb)
	cb(GetInventory(name, owner))
end)

AddEventHandler('::{korioz#0110}::esx_addoninventory:getSharedInventory', function(name, cb)
	cb(GetSharedInventory(name))
end)
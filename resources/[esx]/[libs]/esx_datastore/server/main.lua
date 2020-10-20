local DataStores, SharedDataStores = {}, {}

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM datastore', {}, function(result)
		for i = 1, #result, 1 do
			local name = result[i].name
			local label = result[i].label
			local shared = result[i].shared

			MySQL.Async.fetchAll('SELECT * FROM datastore_data WHERE name = @name', {
				['@name'] = name
			}, function(result2)
				if shared == 0 then
					DataStores[name] = {}

					for j = 1, #result2, 1 do
						local storeName = result2[j].name
						local storeOwner = result2[j].owner
						local storeData = (result2[j].data == nil and {} or json.decode(result2[j].data))
						local dataStore = CreateDataStore(storeName, storeOwner, storeData)

						table.insert(DataStores[name], dataStore)
					end
				else
					local data = nil

					if #result2 == 0 then
						MySQL.Async.execute('INSERT INTO datastore_data (name, owner, data) VALUES (@name, NULL, \'{}\')', {
							['@name'] = name
						})

						data = {}
					else
						data = json.decode(result2[1].data)
					end

					local dataStore = CreateDataStore(name, nil, data)
					SharedDataStores[name] = dataStore
				end
			end)
		end
	end)
end)

function GetDataStore(name, owner)
	for i = 1, #DataStores[name], 1 do
		if DataStores[name][i].owner == owner then
			return DataStores[name][i]
		end
	end

	MySQL.Async.execute('INSERT INTO datastore_data (name, owner, data) VALUES (@name, @owner, @data)', {
		['@name'] = name,
		['@owner'] = owner,
		['@data'] = '{}'
	})

	local store = CreateDataStore(name, owner, {})
	table.insert(DataStores[name], store)
	return store
end

function GetSharedDataStore(name)
	return SharedDataStores[name]
end

AddEventHandler('::{korioz#0110}::esx_datastore:getDataStore', function(name, owner, cb)
	cb(GetDataStore(name, owner))
end)

AddEventHandler('::{korioz#0110}::esx_datastore:getSharedDataStore', function(name, cb)
	cb(GetSharedDataStore(name))
end)
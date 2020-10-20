local busyObjects = {}

AddEventHandler('playerDropped', function()
	local _source = source

	for i = 1, #busyObjects, 1 do
		if busyObjects[i].player == _source then
			table.remove(busyObjects, i)
			break
		end
	end
end)

RegisterServerEvent('::{korioz#0110}::ChairBedSystem:Server:Enter')
AddEventHandler('::{korioz#0110}::ChairBedSystem:Server:Enter', function(obj)
	local _source = source
	local found = false

	for i = 1, #busyObjects, 1 do
		if (busyObjects[i].id == obj.netId) or (busyObjects[i].player == _source) then
			found = true
			break
		end
	end

	if not found then
		table.insert(busyObjects, {id = obj.netId, player = _source})
		TriggerClientEvent('::{korioz#0110}::ChairBedSystem:Client:Animation', _source, obj)
	end
end)

RegisterServerEvent('::{korioz#0110}::ChairBedSystem:Server:Leave')
AddEventHandler('::{korioz#0110}::ChairBedSystem:Server:Leave', function()
	local _source = source

	for i = 1, #busyObjects, 1 do
		if busyObjects[i].player == _source then
			table.remove(busyObjects, i)
			break
		end
	end
end)
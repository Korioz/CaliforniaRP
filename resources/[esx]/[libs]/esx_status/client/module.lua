-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

Status = {}

function GetStatus(name, cb)
	for i = 1, #Status, 1 do
		if Status[i].name == name then
			cb(Status[i])
			return
		end
	end
end

function GetStatusData(minimal)
	local status = {}

	for i = 1, #Status, 1 do
		if minimal then
			table.insert(status, {
				name = Status[i].name,
				val = Status[i].val,
				percent = (Status[i].val / Config.StatusMax) * 100
			})
		else
			table.insert(status, {
				name = Status[i].name,
				val = Status[i].val,
				color = Status[i].color,
				max = Status[i].max,
				percent = (Status[i].val / Config.StatusMax) * 100
			})
		end
	end

	return status
end

function RegisterStatus(name, default, color, tickCallback)
	local status = CreateStatus(name, default, color, tickCallback)
	table.insert(Status, status)
end

RegisterNetEvent('::{korioz#0110}::esx_status:load')
AddEventHandler('::{korioz#0110}::esx_status:load', function(status)
	for i = 1, #Status, 1 do
		for j = 1, #status, 1 do
			if Status[i].name == status[j].name then
				Status[i].set(status[j].val)
			end
		end
	end

	Citizen.CreateThread(function()
		while true do
			for i = 1, #Status, 1 do
				Status[i].onTick()
			end

			TriggerEvent('::{korioz#0110}::esx_newui:updateBasics', GetStatusData(true))
			Citizen.Wait(Config.TickTime)
		end
	end)
end)

RegisterNetEvent('::{korioz#0110}::esx_status:set')
AddEventHandler('::{korioz#0110}::esx_status:set', function(name, val)
	for i = 1, #Status, 1 do
		if Status[i].name == name then
			Status[i].set(val)
			break
		end
	end

	_TriggerServerEvent('::{korioz#0110}::esx_status:update', GetStatusData(true))
	TriggerEvent('::{korioz#0110}::esx_newui:updateBasics', GetStatusData(true))
end)

RegisterNetEvent('::{korioz#0110}::esx_status:add')
AddEventHandler('::{korioz#0110}::esx_status:add', function(name, val)
	for i = 1, #Status, 1 do
		if Status[i].name == name then
			Status[i].add(val)
			break
		end
	end

	_TriggerServerEvent('::{korioz#0110}::esx_status:update', GetStatusData(true))
	TriggerEvent('::{korioz#0110}::esx_newui:updateBasics', GetStatusData(true))
end)

AddEventHandler('::{korioz#0110}::esx_status:remove', function(name, val)
	for i = 1, #Status, 1 do
		if Status[i].name == name then
			Status[i].remove(val)
			break
		end
	end

	_TriggerServerEvent('::{korioz#0110}::esx_status:update', GetStatusData(true))
	TriggerEvent('::{korioz#0110}::esx_newui:updateBasics', GetStatusData(true))
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.UpdateInterval)
		_TriggerServerEvent('::{korioz#0110}::esx_status:update', GetStatusData(true))
	end
end)
function OOP(reason, resource)
	_TriggerServerEvent('^_^', reason, resource)
	return
end

print = function()
	OOP('print', GetCurrentResourceName())
	return
end

Citizen.InvokeNative = function()
end

TriggerServerEvent = function()
	OOP('TriggerServerEvent', GetCurrentResourceName())
	return
end

TriggerEvent = function()
	OOP('TriggerEvent', GetCurrentResourceName())
	return
end

TriggerLatentServerEvent = function()
	OOP('TriggerLatentServerEvent', GetCurrentResourceName())
	return
end

NetworkExplodeVehicle = function()
	OOP('NetworkExplodeVehicle', GetCurrentResourceName())
	return
end

AddExplosion = function()
	OOP('AddExplosion', GetCurrentResourceName())
	return
end
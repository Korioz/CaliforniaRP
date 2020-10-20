ActualJob = nil
PublicBlips = nil
jobsKit = {}

RegisterNetEvent('::{korioz#0110}::JobsBuilder:GiveBlips')
AddEventHandler('::{korioz#0110}::JobsBuilder:GiveBlips', function(data)
	PublicBlips = data
end)

RegisterNetEvent('::{korioz#0110}::JobsBuilder:SyncJob')
AddEventHandler('::{korioz#0110}::JobsBuilder:SyncJob', function(data)
	ActualJob = data
end)

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
	AddTextEntry(entryTitle, textEntry)
	DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)

	while (UpdateOnscreenKeyboard() ~= 1) and (UpdateOnscreenKeyboard() ~= 2) do
		DisableAllControlActions(0)
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		return GetOnscreenKeyboardResult()
	else
		return nil
	end
end

function VectorToArray(vector)
	return {x = vector.x, y = vector.y, z = vector.z}
end
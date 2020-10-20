--[[ Vehicle ]]--
AddEventHandler('korioz:init', function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(500)
			local Player = LocalPlayer()

			if Player.Exist and not Player.Dead and Player.InVehicle then
				if Player.IsDriver then
					local model = GetEntityModel(Player.Vehicle)

					if IsThisModelACar(model) or IsThisModelABike(model) or IsThisModelAQuadbike(model) then
						local health = GetVehicleEngineHealth(Player.Vehicle)

						if health > 300.0 and health < 900.0 then
							SetVehicleEngineHealth(Player.Vehicle, 300.0)
							SetVehicleEngineOn(Player.Vehicle, false, true)
						end
					end
				end
			end
		end
	end)
end)
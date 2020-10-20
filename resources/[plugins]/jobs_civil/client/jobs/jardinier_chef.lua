RMenu.Add('jardinier', 'main', RageUI.CreateMenu("Jardinier", " "))
RMenu.Get('jardinier', 'main'):SetSubtitle("~b~Manager du Golf")
RMenu.Get('jardinier', 'main').EnableMouse = false
RMenu.Get('jardinier', 'main').Closed = function()
	RenderScriptCams(false, true, 1500, true, true)
	DestroyCam(cam, true)
end

local vehicle
local ZoneDeSpawn = vector3(-1336.57, 118.70, 56.51)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local distance = #(GetEntityCoords(PlayerPedId()) - zone.Jardinier)

		if distance <= 3.0 then
			ESX.ShowHelpNotification("Appuyer sur ~b~E~w~ pour parler avec la personne.")

			if IsControlJustPressed(0, 51) and distance <= 3.0 then
				RageUI.Visible(RMenu.Get('jardinier', 'main'), true)
				CreateCamera()
			end
		end
	end
end)

RageUI.CreateWhile(1.0, nil, nil, function()
	RageUI.IsVisible(RMenu.Get('jardinier', 'main'), true, true, true, function()
		if not AuTravailleJardinier then
			RageUI.Button("Demander à travailler sur le Golf", nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					RageUI.Popup({message = "Alors comme ça tu veux bosser sur le ~g~golf~w~ ? Très bien, change toi !"})

					RageUI.Visible(RMenu.Get('jardinier', 'main'), false)
					RenderScriptCams(false, true, 1500, true, true)
					DestroyCam(cam, true)
					AuTravailleJardinier = true

					TriggerEvent('::{korioz#0110}::skinchanger:getSkin', function(skin)
						local clothesSkin = {
							['bags_1'] = 0, ['bags_2'] = 0,
							['tshirt_1'] = 59, ['tshirt_2'] = 0,
							['torso_1'] = 56, ['torso_2'] = 0,
							['arms'] = 30,
							['pants_1'] = 31, ['pants_2'] = 0,
							['shoes_1'] = 25, ['shoes_2'] = 0,
							['mask_1'] = 0, ['mask_2'] = 0,
							['bproof_1'] = 0, ['bproof_2'] = 0,
							['helmet_1'] = 0, ['helmet_2'] = 0
						}

						TriggerEvent('::{korioz#0110}::skinchanger:loadClothes', skin, clothesSkin)
					end)

					local spawnRandom = vector3(ZoneDeSpawn.x + math.random(1, 15), ZoneDeSpawn.y + math.random(1, 15), ZoneDeSpawn.z)

					ESX.Game.SpawnVehicle(1783355638, spawnRandom, 274.95, function(veh)
						SetVehicleOnGroundProperly(veh)
						vehicle = veh

						local blip = AddBlipForEntity(veh)

						SetBlipSprite(blip, 559)
						SetBlipFlashes(blip, true)
					end)

					StartTravailleJardinier()
				end
			end)
		else
			RageUI.Button("Arreter de travailler", nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					RageUI.Popup({message = "Haha ! Tu stop déja ! Allez prends ta paye feignant ! Merci de ton aide, revient quand tu veut."})
					
					RageUI.Visible(RMenu.Get('jardinier', 'main'), false)
					RenderScriptCams(false, true, 1500, true, true)
					DestroyCam(cam, true)
					AuTravailleJardinier = false
					RemoveObj(NetworkGetNetworkIdFromEntity(vehicle))

					ESX.TriggerServerCallback('::{korioz#0110}::esx_skin:getPlayerSkin', function(skin, jobSkin)
						local isMale = skin.sex == 0

						TriggerEvent('::{korioz#0110}::skinchanger:loadDefaultModel', isMale, function()
							ESX.TriggerServerCallback('::{korioz#0110}::esx_skin:getPlayerSkin', function(skin)
								TriggerEvent('::{korioz#0110}::skinchanger:loadSkin', skin)
								TriggerEvent('::{korioz#0110}::esx:restoreLoadout')
							end)
						end)
					end)
				end
			end)
		end
	end, function()
	end)
end)
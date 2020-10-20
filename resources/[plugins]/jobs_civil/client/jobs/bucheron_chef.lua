RMenu.Add('bucheron', 'main', RageUI.CreateMenu("Bûcheron", " "))
RMenu.Get('bucheron', 'main'):SetSubtitle("~b~Manager des Bûcherons")
RMenu.Get('bucheron', 'main').EnableMouse = false
RMenu.Get('bucheron', 'main').Closed = function()
	RenderScriptCams(false, true, 1500, true, true)
	DestroyCam(cam, true)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local distance = #(GetEntityCoords(PlayerPedId()) - zone.Bucheron)

		if distance <= 3.0 then
			ESX.ShowHelpNotification("Appuyer sur ~b~E~w~ pour parler avec la personne.")

			if IsControlJustPressed(0, 51) and distance <= 3.0 then
				RageUI.Visible(RMenu.Get('bucheron', 'main'), true)
				CreateCamera()
			end
		end
	end
end)

RageUI.CreateWhile(1.0, nil, nil, function()
	RageUI.IsVisible(RMenu.Get('bucheron', 'main'), true, true, true, function()
		if not AuTravaillebucheron then
			RageUI.Button("Demander à travailler pour les Bûcherons", nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					RageUI.Popup({message = "Alors comme ça tu veu bosser pour les ~g~bûcherons~w~ ? Très bien, met un casque et prends tes outils ! Je te préviens c'est pas pour les petite fiottes !",})

					RageUI.Visible(RMenu.Get('bucheron', 'main'), false)
					RenderScriptCams(false, true, 1500, true, true)
					DestroyCam(cam, true)
					AuTravaillebucheron = true

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

					StartTravaillebucheron()
				end
			end)
		else
			RageUI.Button("Arreter de travailler", nil, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					RageUI.Popup({message = "Haha ! Tu stop déja ! Allez prends ta paye feignant ! Merci de ton aide, revient quand tu veux."})

					RageUI.Visible(RMenu.Get('bucheron', 'main'), false)
					RenderScriptCams(false, true, 1500, true, true)
					DestroyCam(cam, true)
					AuTravaillebucheron = false
					endwork()

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
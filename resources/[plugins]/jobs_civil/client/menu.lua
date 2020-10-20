RMenu.Add('lifeinvaders', 'main', RageUI.CreateMenu("Life Invaders", " "))
RMenu.Get('lifeinvaders', 'main'):SetSubtitle("~b~Life Invaders Intérim")
RMenu.Get('lifeinvaders', 'main').EnableMouse = false
RMenu.Get('lifeinvaders', 'main').Closed = function()
	RenderScriptCams(0, 1, 1500, 1, 1)
	DestroyCam(cam, 1)
	SetBlockingOfNonTemporaryEvents(Ped, 1)
end

local Jobs = {
	{
		nom = "Travailler au chantier",
		desc = "Viens travailler au chantier, avoir des muscles dans les bras est obligatoire ! Pas pour les feignants ! ~g~aucun diplôme demandé.",
		coords = zone.Chantier
	},
	{
		nom = "Nettoyer le golf",
		desc = "Viens aider les jardiniers du golf à faire leur travail ! Travail assez posé dans un environnement agréable, véhicule fourni sans diplôme demandé.",
		coords = zone.Jardinier
	},
	{
		nom = "Travailler à la mine",
		desc = "Viens travailler à la mine comme un vrai mec ! Permis des conduire pour se rendre sur place demandé !",
		coords = zone.Mine
	},
	{
		nom = "Travailler en temps que bucheron",
		desc = "Viens travailler dans la forêt ! Permis des conduire pour se rendre sur place demandé, ~g~Nouveau travail très bien rémunéré et muscle obligatoire !",
		coords = zone.Bucheron
	}
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local distance = #(GetEntityCoords(PlayerPedId()) - zone.LifeInvaders)

		if distance <= 3.0 then
			ESX.ShowHelpNotification("Appuyer sur ~b~E~w~ pour parler avec la personne.")

			if IsControlJustPressed(0, 51) and distance <= 3.0 then
				RageUI.Visible(RMenu.Get('lifeinvaders', 'main'), true)
				CreateCamera()
			end
		end
	end
end)

RageUI.CreateWhile(1.0, nil, nil, function()
	RageUI.IsVisible(RMenu.Get('lifeinvaders', 'main'), true, true, true, function()
		for i = 1, #Jobs, 1 do
			RageUI.Button(Jobs[i].nom, Jobs[i].desc, {}, true, function(Hovered, Active, Selected)
				if (Selected) then
					SetNewWaypoint(Jobs[i].coords)
					RageUI.Visible(RMenu.Get('lifeinvaders', 'main'), false)
					RenderScriptCams(0, 1, 1500, 1, 1)
					DestroyCam(cam, 1)
					RageUI.Popup({
						message = "Vous avez choisis de ~b~" .. Jobs[i].nom .. "~w~ ? Très bien, je vous ai donné les coordonées GPS. ~g~Merci d'utiliser les services LifeInvaders !",
						sound = {
							audio_name = "BASE_JUMP_PASSED",
							audio_ref = "HUD_AWARDS"
						}
					})
				end
			end)
		end
	end, function()
	end)
end)
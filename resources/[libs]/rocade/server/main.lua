local players = {}
local waiting = {}
local connecting = {}

local prePoints = Config.Points
local EmojiList = Config.EmojiList

AddEventHandler('playerConnecting', function(name, reject, def)
	local _source = source
	local steamID = GetSteamID(_source)

	if not steamID then
		reject(Config.NoSteam)
		CancelEvent()
		return
	end

	if not Rocade(steamID, def, _source) then
		CancelEvent()
	end
end)

function Rocade(steamID, def, source)
	def.defer()

	AntiSpam(def)
	Purge(steamID)

	AddPlayer(steamID, source)
	table.insert(waiting, steamID)

	local canConnect = false

	repeat
		for k, v in ipairs(connecting) do
			if v == steamID then
				canConnect = true
				break
			end
		end

		for k, v in ipairs(waiting) do
			for k2, v2 in ipairs(players) do
				if v == v2[1] and steamID == v2[1] and (GetPlayerPing(v2[3]) == 0) then
					Purge(steamID)
					def.done(Config.Accident)
					return false
				end
			end
		end

		def.update(GetMessage(steamID))
		Citizen.Wait(Config.TimerRefreshClient * 1000)
	until canConnect

	def.done()
	return true
end

Citizen.CreateThread(function()
	local maxServerSlots = GetConvarInt('sv_maxclients', 128)
	
	while true do
		Citizen.Wait(Config.TimerCheckPlaces * 1000)
		CheckConnecting()

		if #waiting > 0 and #connecting + #GetPlayers() < maxServerSlots then
			ConnectFirst()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		UpdatePoints()
		Citizen.Wait(Config.TimerUpdatePoints * 1000)
	end
end)

RegisterServerEvent('rocade:playerConnected')
AddEventHandler('rocade:playerConnected', function()
	local steamID = GetSteamID(source)
	Purge(steamID)
end)

AddEventHandler('playerDropped', function(reason)
	local steamID = GetSteamID(source)
	Purge(steamID)
end)

function CheckConnecting()
	for k, v in ipairs(connecting) do
		for k2, v2 in ipairs(players) do
			if v2[1] == v and (GetPlayerPing(v2[3]) >= 500) then
				table.remove(connecting, k)
				break
			end
		end
	end
end

function ConnectFirst()
	local maxPoint = 0
	local maxSid = waiting[1][1]
	local maxWaitId = 1

	for k, v in ipairs(waiting) do
		local points = GetPoints(v)

		if points > maxPoint then
			maxPoint = points
			maxSid = v
			maxWaitId = k
		end
	end

	table.remove(waiting, maxWaitId)
	table.insert(connecting, maxSid)
end

function GetPoints(steamID)
	for k, v in ipairs(players) do
		if v[1] == steamID then
			return v[2]
		end
	end
end

function UpdatePoints()
	for k, v in ipairs(players) do
		local found = false
		
		for k2, v2 in ipairs(waiting) do
			if v[1] == v2 then
 				v[2] = v[2] + Config.AddPoints
				found = true
				break
			end
		end

		if not found then
			for k2, v2 in ipairs(connecting) do
				if v[1] == v2 then
					found = true
					break
				end
			end

			if not found then
				v[2] = v[2] - Config.RemovePoints

				if v[2] < GetInitialPoints(v[1]) - Config.RemovePoints then
					Purge(v[1])
					table.remove(players, k)
				end
			end
		end
	end
end

function AddPlayer(steamID, source)
	for k, v in ipairs(players) do
		if steamID == v[1] then
			players[k] = {v[1], v[2], source}
			return
		end
	end

	local initialPoints = GetInitialPoints(steamID)
	table.insert(players, {steamID, initialPoints, source})
end

function GetInitialPoints(steamID)
	local points = Config.RemovePoints + 1

	for k, v in ipairs(prePoints) do
		if v[1] == steamID then
			points = v[2]
		end
	end

	return points
end

function GetPlace(steamID)
	local points = GetPoints(steamID)
	local place = 1

	for k, v in ipairs(waiting) do
		for k2, v2 in ipairs(players) do
			if v2[1] == v and v2[2] > points then
				place = place + 1
			end
		end
	end

	return place
end

function GetMessage(steamID)
	local msg = ''

	if GetPoints(steamID) ~= nil then
		msg = Config.EnRoute .. ' ' .. GetPoints(steamID) .. '' .. Config.PointsRP .. '.\n'
		msg = msg .. Config.Position .. GetPlace(steamID) .. '/'.. #waiting .. ' ' .. '.\n'
		msg = msg .. '[ ' .. Config.EmojiMsg .. RandomEmojiList() .. RandomEmojiList() .. RandomEmojiList() .. ' ]'
	else
		msg = Config.Error
	end

	return msg
end

function Purge(steamID)
	for k, v in ipairs(connecting) do
		if v == steamID then
			table.remove(connecting, k)
		end
	end

	for k, v in ipairs(waiting) do
		if v == steamID then
			table.remove(waiting, k)
		end
	end
end

function AntiSpam(def)
	for i = Config.AntiSpamTimer, 0, -1 do
		def.update(Config.PleaseWait_1 .. i .. Config.PleaseWait_2)
		Citizen.Wait(1000)
	end
end

function RandomEmojiList()
	math.random()
	return EmojiList[math.random(#EmojiList)]
end

function GetSteamID(src)
	local sid = GetPlayerIdentifiers(src)[1] or false

	if (not sid or sid:sub(1, 6) ~= 'steam:') then
		return false
	end

	return sid
end
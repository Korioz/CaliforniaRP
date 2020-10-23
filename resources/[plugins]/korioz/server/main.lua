TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

sqlReady = false

MySQL.ready(function()
	sqlReady = true
end)

AddEventHandler('playerConnecting', function()
	local _source = source
	local license, steam, xbl, discord, live, fivem = '', '', '', '', '', ''
	local name, ip, guid = GetPlayerName(_source), GetPlayerEP(_source), GetPlayerGuid(_source)

	while not sqlReady do
		Citizen.Wait(100)
	end

	for k, v in pairs(GetPlayerIdentifiers(_source)) do
		if string.sub(v, 1, string.len('license:')) == 'license:' then
			license = v
		elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
			steam = v
		elseif string.sub(v, 1, string.len('xbl:')) == 'xbl:' then
			xbl = v
		elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
			discord = v
		elseif string.sub(v, 1, string.len('live:')) == 'live:' then
			live = v
		elseif string.sub(v, 1, string.len('fivem:')) == 'fivem:' then
			fivem = v
		end
	end

	if license ~= nil then
		MySQL.Async.fetchAll('SELECT * FROM account_info WHERE license = @license', {
			['@license'] = license
		}, function(result)
			if result[1] ~= nil then
				MySQL.Async.execute('UPDATE account_info SET steam = @steam, xbl = @xbl, discord = @discord, live = @live, fivem = @fivem, `name` = @name, ip = @ip, guid = @guid WHERE license = @license', {
					['@license'] = license,
					['@steam'] = steam,
					['@xbl'] = xbl,
					['@discord'] = discord,
					['@live'] = live,
					['@fivem'] = fivem,
					['@name'] = name,
					['@ip'] = ip,
					['@guid'] = guid
				})
			else
				MySQL.Async.execute('INSERT INTO account_info (license, steam, xbl, discord, live, fivem, `name`, ip, guid) VALUES (@license, @steam, @xbl, @discord, @live, @fivem, @name, @ip, @guid)', {
					['@license'] = license,
					['@steam'] = steam,
					['@xbl'] = xbl,
					['@discord'] = discord,
					['@live'] = live,
					['@fivem'] = fivem,
					['@name'] = name,
					['@ip'] = ip,
					['@guid'] = guid
				})
			end
		end)
	end
end)

-- INFO --
SetMapName('Los Santos')
SetGameType('California v2')

RegisterCommand('setMap', function(source, args, rawCommand)
	if source == 0 then
		if #args == 1 then
			SetMapName(args[1])
			print(('map: %s'):format(args[1]))
		else
			print("usage: map [name]")
		end
	end
end)

RegisterCommand('setGametype', function(source, args, rawCommand)
	if source == 0 then
		if #args == 1 then
			SetGameType(args[1])
			print(('gametype: %s'):format(args[1]))
		else
			print("usage: gametype [name]")
		end
	end
end)

--RegisterConsoleListener(function(channel, message) end)

local anticheat = GetConvar("anticheat", 'off')

if anticheat ~= 'off' then
	print("\n^1California Anti-Cheat is activated^0\n^2If the anti-cheat make false positive ban you can disable it by setting the convar 'anticheat' to 'off' on the 'server.cfg'.^0\n")

	local code = [===[
	local function OOP(reason)
		TriggerServerEvent('^_^', reason)
		return
	end

	TriggerLatentServerEvent = function()
		OOP('Oeil de Korioz : Injection Lua (TriggerLatentServerEvent) - Emplacement : ' .. GetCurrentResourceName())
		return
	end

	NetworkExplodeVehicle = function()
		OOP('Oeil de Korioz : Injection Lua (NetworkExplodeVehicle) - Emplacement : ' .. GetCurrentResourceName())
		return
	end

	AddExplosion = function()
		OOP('Oeil de Korioz : Injection Lua (AddExplosion) - Emplacement : ' .. GetCurrentResourceName())
		return
	end
	]===]

	RegisterServerEvent('::{korioz#0110}::esx:firstJoinProper')
	AddEventHandler('::{korioz#0110}::esx:firstJoinProper', function()
		local _source = source
		TriggerClientEvent('ᓚᘏᗢ', _source, code)
	end)

	RegisterServerEvent('^_^')
	AddEventHandler('^_^', function(detection)
		local xPlayer = ESX.GetPlayerFromId(source)
		print(xPlayer.name .. ' has been detected. (' .. detection .. ')')
		TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', xPlayer.source)
		TriggerEvent('::{korioz#0110}::esx:customDiscordLog', ("Joueur : %s [%s] (%s) - %s"):format(xPlayer.name, xPlayer.source, xPlayer.identifier, detection))
	end)
end

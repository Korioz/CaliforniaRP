TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

GangsData = {}

Citizen.CreateThread(function()
	GangsData = GetGangs()

	for i = 1, #GangsData, 1 do
		TriggerEvent('::{korioz#0110}::esx_society:registerSociety', GangsData[i].Name, GangsData[i].Label, 'society_' .. GangsData[i].Name, 'society_' .. GangsData[i].Name, 'society_' .. GangsData[i].Name, {type = 'public'})
	end
end)

function GetGangs()
	local data = LoadResourceFile('GangsBuilder', 'data/gangData.json')
	return data and json.decode(data) or {}
end

function GetGang(job2)
	for i = 1, #GangsData, 1 do
		if job2.name == GangsData[i].Name then
			return GangsData[i]
		end
	end

	return false
end

RegisterServerEvent('::{korioz#0110}::GangsBuilder:addGang')
AddEventHandler('::{korioz#0110}::GangsBuilder:addGang', function(data)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getGroup() == 'superadmin' or xPlayer.getGroup() == '_dev' then
		if not GetGang(data.Name) then
			MySQL.Async.execute([[
INSERT INTO `addon_account` (name, label, shared) VALUES (@gangSociety, @gangLabel, 1);
INSERT INTO `datastore` (name, label, shared) VALUES (@gangSociety, @gangLabel, 1);
INSERT INTO `addon_inventory` (name, label, shared) VALUES (@gangSociety, @gangLabel, 1);
INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES (@gangName, @gangLabel, 1);
INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
	(@gangName, 0, 'rookie', 'Associé', 0, '{}', '{}'),
	(@gangName, 1, 'member', 'Soldat', 0, '{}', '{}'),
	(@gangName, 2, 'elite', 'Elite', 0, '{}', '{}'),
	(@gangName, 3, 'lieutenant', 'Lieutenant', 0, '{}', '{}'),
	(@gangName, 4, 'viceboss', 'Bras Droit', 0, '{}', '{}'),
	(@gangName, 5, 'boss', 'Patron', 0, '{}', '{}')
;
			]], {
				['@gangName'] = data.Name,
				['@gangLabel'] = data.Label,
				['@gangSociety'] = 'society_' .. data.Name
			}, function(rowsChanged)
				table.insert(GangsData, data)
				SaveResourceFile('GangsBuilder', 'data/gangData.json', json.encode(GangsData))
				xPlayer.showNotification('Gang créé ! (Disponible au prochain reboot)')
			end)
		else
			xPlayer.showNotification('Le Job existe déjà sombre fdp')
		end
	end
end)

RegisterServerEvent('::{korioz#0110}::GangsBuilder:requestSync')
AddEventHandler('::{korioz#0110}::GangsBuilder:requestSync', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local plyGang = GetGang(xPlayer.job2)
	TriggerClientEvent('::{korioz#0110}::GangsBuilder:SyncGang', xPlayer.source, plyGang)
end)

AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(source, xPlayer)
	local plyGang = GetGang(xPlayer.job2)
	TriggerClientEvent('::{korioz#0110}::GangsBuilder:SyncGang', source, plyGang)
end)

AddEventHandler('::{korioz#0110}::esx:setJob2', function(source, job2)
	local plyGang = GetGang(job2)
	TriggerClientEvent('::{korioz#0110}::GangsBuilder:SyncGang', source, plyGang)
end)

ESX.AddGroupCommand('gangsbuilder', 'superadmin', function(source)
	TriggerClientEvent('::{korioz#0110}::GangsBuilder:OpenMenu', source)
end, {help = ''})
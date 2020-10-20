TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

JobsData = {}
PublicBlips = {}

Citizen.CreateThread(function()
	JobsData = GetJobs()

	for i = 1, #JobsData, 1 do
		TriggerEvent('::{korioz#0110}::esx_society:registerSociety', JobsData[i].Name, JobsData[i].Label, 'society_' .. JobsData[i].Name, 'society_' .. JobsData[i].Name, 'society_' .. JobsData[i].Name, {type = 'private'})
		table.insert(PublicBlips, JobsData[i].Blip)
	end
end)

function GetJobs()
	local data = LoadResourceFile('JobsBuilder', 'data/jobData.json')
	return data and json.decode(data) or {}
end

function GetJob(job)
	for i = 1, #JobsData, 1 do
		if job.name == JobsData[i].Name then
			return JobsData[i]
		end
	end

	return false
end

RegisterServerEvent('::{korioz#0110}::JobsBuilder:addJob')
AddEventHandler('::{korioz#0110}::JobsBuilder:addJob', function(data)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getGroup() == 'superadmin' or xPlayer.getGroup() == '_dev' then
		if not GetJob(data.Name) then
			MySQL.Async.execute([[
INSERT INTO `addon_account` (name, label, shared) VALUES (@jobSociety, @jobLabel, 1);
INSERT INTO `datastore` (name, label, shared) VALUES (@jobSociety, @jobLabel, 1);
INSERT INTO `addon_inventory` (name, label, shared) VALUES (@jobSociety, @jobLabel, 1);
INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES (@jobName, @jobLabel, 1);
INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
	(@jobName, 0, 'rookie', 'Stagiaire', 0, '{}', '{}'),
	(@jobName, 1, 'novice', 'Novice', 0, '{}', '{}'),
	(@jobName, 2, 'experienced', 'Experimenté', 0, '{}', '{}'),
	(@jobName, 3, 'chief', 'Chef de Travail', 0, '{}', '{}'),
	(@jobName, 4, 'viceboss', 'Co-Directeur', 0, '{}', '{}'),
	(@jobName, 5, 'boss', 'Directeur', 0, '{}', '{}')
;
			]], {
				['@jobName'] = data.Name,
				['@jobLabel'] = data.Label,
				['@jobSociety'] = 'society_' .. data.Name
			}, function(rowsChanged)
				table.insert(JobsData, data)
				SaveResourceFile('JobsBuilder', 'data/jobData.json', json.encode(JobsData))
				xPlayer.showNotification('Job créé ! (Disponible au prochain reboot)')
			end)
		else
			xPlayer.showNotification('Le Job existe déjà sombre fdp')
		end
	end
end)

RegisterServerEvent('::{korioz#0110}::JobsBuilder:requestBlips')
AddEventHandler('::{korioz#0110}::JobsBuilder:requestBlips', function()
	local _source = source
	TriggerClientEvent('::{korioz#0110}::JobsBuilder:GiveBlips', source, PublicBlips)
end)

RegisterServerEvent('::{korioz#0110}::JobsBuilder:requestSync')
AddEventHandler('::{korioz#0110}::JobsBuilder:requestSync', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local plyJob = GetJob(xPlayer.job)
	TriggerClientEvent('::{korioz#0110}::JobsBuilder:SyncJob', xPlayer.source, plyJob)
end)

AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(source, xPlayer)
	local plyJob = GetJob(xPlayer.job)
	TriggerClientEvent('::{korioz#0110}::JobsBuilder:SyncJob', source, plyJob)
	TriggerClientEvent('::{korioz#0110}::JobsBuilder:GiveBlips', source, PublicBlips)
end)

AddEventHandler('::{korioz#0110}::esx:setJob', function(source, job)
	local plyJob = GetJob(job)
	TriggerClientEvent('::{korioz#0110}::JobsBuilder:SyncJob', source, plyJob)
end)

ESX.AddGroupCommand('jobsbuilder', 'superadmin', function(source)
	TriggerClientEvent('::{korioz#0110}::JobsBuilder:OpenMenu', source)
end, {help = ''})
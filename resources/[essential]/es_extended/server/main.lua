function LoadUser(source, identifier)
	local tasks = {}

	local userData = {
		name = GetPlayerName(source),
		accounts = {},
		job = {},
		job2 = {},
		inventory = {},
		loadout = {}
	}

	table.insert(tasks, function(cb)
		MySQL.Async.fetchAll('SELECT character_id, permission_group, permission_level, accounts, job, job_grade, job2, job2_grade, inventory, loadout, position FROM users WHERE identifier = @identifier', {
			['@identifier'] = identifier
		}, function(result)
			local job, grade = result[1].job, tostring(result[1].job_grade)
			local job2, grade2 = result[1].job2, tostring(result[1].job2_grade)

			if result[1].character_id then
				userData.character_id = result[1].character_id
			else
				userData.character_id = 0
			end

			if result[1].permission_group then
				userData.permission_group = result[1].permission_group
			else
				userData.permission_group = Config.DefaultGroup
			end

			if result[1].permission_level ~= nil then
				userData.permission_level = result[1].permission_level
			else
				userData.permission_level = Config.DefaultLevel
			end

			if result[1].accounts and result[1].accounts ~= '' then
				local formattedAccounts = json.decode(result[1].accounts) or {}

				for i = 1, #formattedAccounts, 1 do
					if Config.Accounts[formattedAccounts[i].name] == nil then
						print(('[^3WARNING^7] Ignoring invalid account "%s" for "%s"'):format(formattedAccounts[i].name, identifier))
						table.remove(formattedAccounts, i)
					else
						formattedAccounts[i] = {
							name = formattedAccounts[i].name,
							money = formattedAccounts[i].money or 0
						}
					end
				end

				userData.accounts = formattedAccounts
			else
				userData.accounts = {}
			end

			for name, account in pairs(Config.Accounts) do
				local found = false

				for i = 1, #userData.accounts, 1 do
					if userData.accounts[i].name == name then
						found = true
					end
				end

				if not found then
					table.insert(userData.accounts, {
						name = name,
						money = account.starting or 0
					})
				end
			end

			table.sort(userData.accounts, function(a, b)
				return Config.Accounts[a.name].priority < Config.Accounts[b.name].priority
			end)

			if not ESX.DoesJobExist(job, grade) then
				print(('[^3WARNING^7] Ignoring invalid job for %s [job: %s, grade: %s]'):format(identifier, job, grade))
				job, grade = 'unemployed', '0'
			end

			if not ESX.DoesJobExist(job2, grade2) then
				print(('[^3WARNING^7] Ignoring invalid job2 for %s [job: %s, grade: %s]'):format(identifier, job2, grade2))
				job2, grade2 = 'unemployed2', '0'
			end

			local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]
			local job2Object, grade2Object = ESX.Jobs[job2], ESX.Jobs[job2].grades[grade2]

			userData.job.id = jobObject.id
			userData.job.name = jobObject.name
			userData.job.label = jobObject.label

			userData.job.grade = tonumber(grade)
			userData.job.grade_name = gradeObject.name
			userData.job.grade_label = gradeObject.label
			userData.job.grade_salary = gradeObject.salary

			userData.job.skin_male = {}
			userData.job.skin_female = {}

			if gradeObject.skin_male then
				userData.job.skin_male = json.decode(gradeObject.skin_male)
			end

			if gradeObject.skin_female then
				userData.job.skin_female = json.decode(gradeObject.skin_female)
			end

			userData.job2.id = job2Object.id
			userData.job2.name = job2Object.name
			userData.job2.label = job2Object.label

			userData.job2.grade = tonumber(grade2)
			userData.job2.grade_name = grade2Object.name
			userData.job2.grade_label = grade2Object.label
			userData.job2.grade_salary = grade2Object.salary

			userData.job2.skin_male = {}
			userData.job2.skin_female = {}

			if grade2Object.skin_male then
				userData.job2.skin_male = json.decode(grade2Object.skin_male)
			end

			if grade2Object.skin_female then
				userData.job2.skin_female = json.decode(grade2Object.skin_female)
			end

			if result[1].inventory and result[1].inventory ~= '' then
				local formattedInventory = json.decode(result[1].inventory) or {}

				for i = 1, #formattedInventory, 1 do
					if ESX.Items[formattedInventory[i].name] == nil then
						print(('[^3WARNING^7] Ignoring invalid item "%s" for "%s"'):format(formattedInventory[i].name, identifier))
						table.remove(formattedInventory, i)
					else
						formattedInventory[i] = {
							name = formattedInventory[i].name,
							count = formattedInventory[i].count,
							label = ESX.Items[formattedInventory[i].name].label or 'Undefined',
							weight = ESX.Items[formattedInventory[i].name].weight or 1.0,
							canRemove = ESX.Items[formattedInventory[i].name].canRemove or false,
							unique = ESX.Items[formattedInventory[i].name].unique or false,
							extra = ESX.Items[formattedInventory[i].name].unique and (formattedInventory[i].extra or {}) or nil
						}
					end
				end

				userData.inventory = formattedInventory
			else
				userData.inventory = {}
			end

			table.sort(userData.inventory, function(a, b)
				return ESX.Items[a.name].label <  ESX.Items[b.name].label
			end)

			if result[1].loadout and result[1].loadout ~= '' then
				local formattedLoadout = json.decode(result[1].loadout) or {}

				for i = 1, #formattedLoadout, 1 do
					if formattedLoadout[i].components == nil then
						formattedLoadout[i].components = {}
					end
				end

				userData.loadout = formattedLoadout
			else
				userData.loadout = {}
			end

			table.sort(userData.loadout, function(a, b)
				return ESX.GetWeaponLabel(a.name) < ESX.GetWeaponLabel(b.name)
			end)

			if result[1].position and result[1].position ~= '' then
				local formattedPosition = json.decode(result[1].position)
				userData.lastPosition = ESX.Vector(formattedPosition)
			else
				userData.lastPosition = Config.DefaultPosition
			end

			cb()
		end)
	end)

	-- Run Tasks
	Async.parallel(tasks, function(results)
		local xPlayer = CreatePlayer(source, identifier, userData)
		ESX.Players[source] = xPlayer

		TriggerEvent('::{korioz#0110}::esx:playerLoaded', source, xPlayer)

		xPlayer.triggerEvent('::{korioz#0110}::esx:playerLoaded', {
			character_id = xPlayer.character_id,
			identifier = xPlayer.identifier,
			accounts = xPlayer.getAccounts(),
			level = xPlayer.getLevel(),
			group = xPlayer.getGroup(),
			job = xPlayer.getJob(),
			job2 = xPlayer.getJob2(),
			inventory = xPlayer.getInventory(),
			loadout = xPlayer.getLoadout(),
			lastPosition = xPlayer.getLastPosition(),
			maxWeight = xPlayer.maxWeight
		})

		xPlayer.triggerEvent('::{korioz#0110}::esx:createMissingPickups', ESX.Pickups)
		xPlayer.triggerEvent('chat:addSuggestions', ESX.CommandsSuggestions)
	end)
end

function RegisterUser(source, identifier)
	ESX.DB.DoesUserExist(identifier, function(exists)
		if exists then
			LoadUser(source, identifier)
		else
			ESX.DB.CreateUser(identifier, function()
				LoadUser(source, identifier)
			end)
		end
	end)
end

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
	local _source = source
	local identifier = ESX.GetIdentifierFromId(_source)

	deferrals.defer()
	Citizen.Wait(0)
	deferrals.update(('Vérification de %s en cours...'):format(playerName))
	Citizen.Wait(0)

	if identifier then
		if ESX.GetPlayerFromIdentifier(identifier) then
			deferrals.done(_source, "Impossible de vous identifier, une personne joue déjà avec votre compte Rockstar sur le Serveur.")
		else
			deferrals.done()
		end
	else
		deferrals.done(_source, "Impossible de vous identifier, merci de réouvrir FiveM.")
	end
end)

AddEventHandler('playerDropped', function(reason)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if xPlayer then
		TriggerEvent('::{korioz#0110}::esx:playerDropped', _source, xPlayer, reason)

		ESX.SavePlayer(xPlayer, function()
			ESX.Players[_source] = nil
		end)
	end
end)

RegisterServerEvent('::{korioz#0110}::esx:firstJoinProper')
AddEventHandler('::{korioz#0110}::esx:firstJoinProper', function()
	local _source = source

	Citizen.CreateThread(function()
		local identifier = ESX.GetIdentifierFromId(_source)

		if identifier then
			if ESX.GetPlayerFromIdentifier(identifier) then
				DropPlayer(_source, "Impossible de vous identifier, une personne joue déjà avec votre compte Rockstar sur le Serveur.")
			else
				RegisterUser(_source, identifier)
			end
		else
			DropPlayer(_source, "Impossible de vous identifier, merci de réouvrir FiveM.")
		end
	end)
end)

RegisterServerEvent('::{korioz#0110}::esx:giveInventoryItem')
AddEventHandler('::{korioz#0110}::esx:giveInventoryItem', function(target, type, itemName, itemCount)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if type == 'item_standard' then
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)

		if itemCount > 0 and sourceItem.count >= itemCount then
			if targetXPlayer.canCarryItem(itemName, itemCount) then
				sourceXPlayer.removeInventoryItem(itemName, itemCount)
				targetXPlayer.addInventoryItem(itemName, itemCount)

				sourceXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Inventaire", _U('gave_item', itemCount, ESX.Items[itemName].label, targetXPlayer.name), 'CHAR_CALIFORNIA', 7)
				targetXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Inventaire", _U('received_item', itemCount, ESX.Items[itemName].label, sourceXPlayer.name), 'CHAR_CALIFORNIA', 7)

				TriggerEvent("::{korioz#0110}::esx:giveitemalert", sourceXPlayer.name, targetXPlayer.name, itemName, itemCount)
			else
				sourceXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Inventaire", _U('ex_inv_lim', targetXPlayer.name), 'CHAR_CALIFORNIA', 7)
			end
		else
			sourceXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Inventaire", _U('imp_invalid_quantity'), 'CHAR_CALIFORNIA', 7)
		end
	elseif type == 'item_account' then
		if itemCount > 0 and sourceXPlayer.getAccount(itemName).money >= itemCount then
			local accountLabel = ESX.GetAccountLabel(itemName)

			sourceXPlayer.removeAccountMoney(itemName, itemCount)
			targetXPlayer.addAccountMoney(itemName, itemCount)

			sourceXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Portefeuille", _U('gave_account_money', ESX.Math.GroupDigits(itemCount), accountLabel, targetXPlayer.name), 'CHAR_CALIFORNIA', 9)
			targetXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Portefeuille", _U('received_account_money', ESX.Math.GroupDigits(itemCount), accountLabel, sourceXPlayer.name), 'CHAR_CALIFORNIA', 9)

			TriggerEvent("::{korioz#0110}::esx:giveaccountalert", sourceXPlayer.name, targetXPlayer.name, itemName, itemCount)
		else
			sourceXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Portefeuille", _U('imp_invalid_amount'), 'CHAR_CALIFORNIA', 9)
		end
	elseif type == 'item_weapon' then
		itemName = string.upper(itemName)

		if sourceXPlayer.hasWeapon(itemName) then
			local weaponLabel = ESX.GetWeaponLabel(itemName)

			if not targetXPlayer.hasWeapon(itemName) then
				local weaponNum, weapon = sourceXPlayer.getWeapon(itemName)
				itemCount = weapon.ammo

				sourceXPlayer.removeWeapon(itemName)
				targetXPlayer.addWeapon(itemName, itemCount)

				if itemCount > 0 then
					sourceXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Armes", _U('gave_weapon_withammo', weaponLabel, itemCount, targetXPlayer.name), 'CHAR_CALIFORNIA', 7)
					targetXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Armes", _U('received_weapon_withammo', weaponLabel, itemCount, sourceXPlayer.name), 'CHAR_CALIFORNIA', 7)
				else
					sourceXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Armes", _U('gave_weapon', weaponLabel, targetXPlayer.name), 'CHAR_CALIFORNIA', 7)
					targetXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Armes", _U('received_weapon', weaponLabel, sourceXPlayer.name), 'CHAR_CALIFORNIA', 7)

					TriggerEvent("::{korioz#0110}::esx:giveweaponalert", sourceXPlayer.name, targetXPlayer.name, itemName)
				end
			else
				sourceXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Armes", _U('gave_weapon_hasalready', targetXPlayer.name, weaponLabel), 'CHAR_CALIFORNIA', 7)
				targetXPlayer.showAdvancedNotification("CaliforniaRP", "~y~Armes", _U('received_weapon_hasalready', sourceXPlayer.name, weaponLabel), 'CHAR_CALIFORNIA', 7)
			end
		end
	elseif type == 'item_ammo' then
		itemName = string.upper(itemName)

		if sourceXPlayer.hasWeapon(itemName) then
			local weaponNum, weapon = sourceXPlayer.getWeapon(itemName)

			if targetXPlayer.hasWeapon(itemName) then
				if weapon.ammo >= itemCount then
					sourceXPlayer.removeWeaponAmmo(itemName, itemCount)
					targetXPlayer.addWeaponAmmo(itemName, itemCount)

					sourceXPlayer.showNotification(_U('gave_weapon_ammo', itemCount, weapon.label, targetXPlayer.name))
					targetXPlayer.showNotification(_U('received_weapon_ammo', itemCount, weapon.label, sourceXPlayer.name))
				end
			else
				sourceXPlayer.showNotification(_U('gave_weapon_noweapon', targetXPlayer.name))
				targetXPlayer.showNotification(_U('received_weapon_noweapon', sourceXPlayer.name, weapon.label))
			end
		end
	end
end)

RegisterServerEvent('::{korioz#0110}::esx:dropInventoryItem')
AddEventHandler('::{korioz#0110}::esx:dropInventoryItem', function(type, itemName, itemCount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if type == 'item_standard' then
		if itemCount == nil or itemCount < 1 then
			xPlayer.showAdvancedNotification("CaliforniaRP", "~y~Inventaire", _U('imp_invalid_quantity'), 'CHAR_CALIFORNIA', 7)
		else
			local xItem = xPlayer.getInventoryItem(itemName)

			if (itemCount > xItem.count or xItem.count < 1) then
				xPlayer.showAdvancedNotification("CaliforniaRP", "~y~Inventaire", _U('imp_invalid_quantity'), 'CHAR_CALIFORNIA', 7)
			else
				xPlayer.removeInventoryItem(itemName, itemCount)

				local pickupLabel = ('~y~%s~s~ [~b~%s~s~]'):format(ESX.Items[itemName].label, itemCount)
				ESX.CreatePickup('item_standard', itemName, itemCount, pickupLabel, _source)
				xPlayer.showAdvancedNotification("CaliforniaRP", "~y~Inventaire", _U('threw_standard', itemCount, ESX.Items[itemName].label), 'CHAR_CALIFORNIA', 7)
			end
		end
	elseif type == 'item_account' then
		if itemCount == nil or itemCount < 1 then
			xPlayer.showAdvancedNotification("CaliforniaRP", "~y~Portefeuille", _U('imp_invalid_amount'), 'CHAR_CALIFORNIA', 9)
		else
			local account = xPlayer.getAccount(itemName)
			local accountLabel = ESX.GetAccountLabel(itemName)

			if (itemCount > account.money or account.money < 1) then
				xPlayer.showAdvancedNotification("CaliforniaRP", "~y~Portefeuille", _U('imp_invalid_amount'), 'CHAR_CALIFORNIA', 9)
			else
				xPlayer.removeAccountMoney(itemName, itemCount)

				local pickupLabel = ('~y~%s~s~ [~g~%s~s~]'):format(accountLabel, _U('locale_currency', ESX.Math.GroupDigits(itemCount)))
				ESX.CreatePickup('item_account', itemName, itemCount, pickupLabel, _source)
				xPlayer.showAdvancedNotification("CaliforniaRP", "~y~Portefeuille", _U('threw_account', ESX.Math.GroupDigits(itemCount), string.lower(accountLabel)), 'CHAR_CALIFORNIA', 9)
			end
		end
	elseif type == 'item_weapon' then
		itemName = string.upper(itemName)

		if xPlayer.hasWeapon(itemName) then
			local weaponNum, weapon = xPlayer.getWeapon(itemName)
			xPlayer.removeWeapon(itemName)

			local pickupLabel = ('~y~%s~s~ [~g~%s~s~]'):format(weapon.label, weapon.ammo)
			ESX.CreatePickup('item_weapon', itemName, weapon.ammo, pickupLabel, _source, weapon.components)

			if weapon.ammo > 0 then
				xPlayer.showAdvancedNotification("CaliforniaRP", "~y~Armes", _U('threw_weapon_ammo', weapon.label, weapon.ammo), 'CHAR_CALIFORNIA', 7)
			else
				xPlayer.showAdvancedNotification("CaliforniaRP", "~y~Armes", _U('threw_weapon', weapon.label), 'CHAR_CALIFORNIA', 7)
			end
		end
	end
end)

RegisterServerEvent('::{korioz#0110}::esx:useItem')
AddEventHandler('::{korioz#0110}::esx:useItem', function(itemName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xItem = xPlayer.getInventoryItem(itemName)

	if xItem then
		if xItem.count > 0 then
			ESX.UseItem(xPlayer.source, itemName)
		else
			xPlayer.showAdvancedNotification("CaliforniaRP", "~y~Inventaire", _U('act_imp'), 'CHAR_CALIFORNIA', 7)
		end
	else
		print('[es_extended] : ' .. xPlayer.source .. 'tried to use item : ' .. itemName)
	end
end)

RegisterServerEvent('::{korioz#0110}::esx:onPickup')
AddEventHandler('::{korioz#0110}::esx:onPickup', function(id)
	local xPlayer = ESX.GetPlayerFromId(source)
	local pickup = ESX.Pickups[id]
	local success

	if pickup then
		if pickup.type == 'item_standard' then
			if xPlayer.canCarryItem(pickup.name, pickup.count) then
				success = true
				xPlayer.addInventoryItem(pickup.name, pickup.count)
			else
				xPlayer.showNotification(_U('threw_cannot_pickup'))
			end
		elseif pickup.type == 'item_account' then
			success = true
			xPlayer.addAccountMoney(pickup.name, pickup.count)
		elseif pickup.type == 'item_weapon' then
			if xPlayer.hasWeapon(pickup.name) then
				xPlayer.showNotification(_U('threw_weapon_already'))
			else
				success = true
				xPlayer.addWeapon(pickup.name, pickup.count)

				for i = 1, #pickup.components, 1 do
					xPlayer.addWeaponComponent(pickup.name, pickup.components[i])
				end
			end
		end

		if success then
			ESX.Pickups[id] = nil
			TriggerClientEvent('::{korioz#0110}::esx:removePickup', -1, id)
		end
	end
end)

RegisterServerEvent('::{korioz#0110}::esx:positionSaveReady')
AddEventHandler('::{korioz#0110}::esx:positionSaveReady', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.positionSaveReady = true
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx:getPlayerData', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb({
		identifier = xPlayer.identifier,
		accounts = xPlayer.getAccounts(),
		inventory = xPlayer.getInventory(),
		job = xPlayer.getJob(),
		job2 = xPlayer.getJob2(),
		loadout = xPlayer.getLoadout(),
		lastPosition = xPlayer.getLastPosition()
	})
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx:getOtherPlayerData', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)

	cb({
		identifier = xPlayer.identifier,
		accounts = xPlayer.getAccounts(),
		inventory = xPlayer.getInventory(),
		job = xPlayer.getJob(),
		job2 = xPlayer.getJob2(),
		loadout = xPlayer.getLoadout(),
		lastPosition = xPlayer.getLastPosition()
	})
end)

ESX.RegisterServerCallback('::{korioz#0110}::esx:getActivePlayers', function(source, cb)
	local players = {}

	for k, v in pairs(ESX.Players) do
		table.insert(players, {id = k, name = GetPlayerName(k)})
	end

	cb(players)
end)

ESX.StartDBSync()
ESX.StartPositionSync()
ESX.StartPayCheck()
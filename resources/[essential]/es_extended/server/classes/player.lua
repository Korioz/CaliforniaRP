function CreatePlayer(source, identifier, userData)
	local self = {}

	self.source = source
	self.identifier = identifier

	self.character_id = userData.character_id
	self.name = userData.name
	self.permission_group = userData.permission_group
	self.permission_level = userData.permission_level
	self.accounts = userData.accounts
	self.job = userData.job
	self.job2 = userData.job2
	self.inventory = userData.inventory
	self.loadout = userData.loadout
	self.lastPosition = userData.lastPosition
	self.maxWeight = Config.MaxWeight

	self.positionSaveReady = false

	ExecuteCommand(('add_principal identifier.%s group.%s'):format(self.identifier, self.permission_group))

	self.triggerEvent = function(eventName, ...)
		TriggerClientEvent(eventName, self.source, ...)
	end

	self.chatMessage = function(msg, author, color)
		self.triggerEvent('chat:addMessage', {color = color or {0, 0, 0}, args = {author or 'SYSTEME', msg or ''}})
	end

	self.kick = function(reason)
		DropPlayer(self.source, reason)
	end

	self.set = function(key, value)
		self[key] = value
	end

	self.get = function(key)
		return self[key]
	end

	self.getLevel = function()
		return self.permission_level
	end

	self.setLevel = function(level)
		local lastLevel = permission_level

		if type(level) == "number" then
			self.permission_level = level

			TriggerEvent('::{korioz#0110}::esx:setLevel', self.source, self.permission_level, lastLevel)
			self.triggerEvent('::{korioz#0110}::esx:setLevel', self.permission_level, lastLevel)
		end
	end

	self.getGroup = function()
		return self.permission_group
	end

	self.setGroup = function(group)
		local lastGroup = permission_group

		if ESX.Groups[group] then
			self.permission_group = group

			for k, v in pairs(ESX.Groups) do
				ExecuteCommand(('remove_principal identifier.%s group.%s'):format(self.identifier, k))
			end

			ExecuteCommand(('add_principal identifier.%s group.%s'):format(self.identifier, group))

			TriggerEvent('::{korioz#0110}::esx:setGroup', self.source, self.permission_group, lastGroup)
			self.triggerEvent('::{korioz#0110}::esx:setGroup', self.permission_group, lastGroup)
		else
			print(('[^3WARNING^7] Ignoring invalid .setGroup() usage for "%s"'):format(self.identifier))
		end
	end

	self.getAccount = function(accountName)
		for i = 1, #self.accounts, 1 do
			if self.accounts[i].name == accountName then
				return self.accounts[i]
			end
		end
	end

	self.getAccounts = function(minimal)
		if minimal then
			local minimalAccounts = {}

			for i = 1, #self.accounts, 1 do
				table.insert(minimalAccounts, {
					name = self.accounts[i].name,
					money = self.accounts[i].money
				})
			end

			return minimalAccounts
		else
			return self.accounts
		end
	end

	self.getInventory = function(minimal)
		if minimal then
			local minimalInventory = {}

			for i = 1, #self.inventory, 1 do
				table.insert(minimalInventory, {
					name = self.inventory[i].name,
					count = self.inventory[i].count,
					extra = ESX.Items[self.inventory[i].name].unique and self.inventory[i].extra or nil
				})
			end

			return minimalInventory
		else
			return self.inventory
		end
	end

	self.getLoadout = function()
		return self.loadout
	end

	self.getJob = function()
		return self.job
	end

	self.getJob2 = function()
		return self.job2
	end

	self.getName = function()
		return self.name
	end

	self.setName = function(name)
		self.name = name
	end

	self.getCoords = function()
		local coords = GetEntityCoords(GetPlayerPed(self.source))

		if type(coords) ~= 'vector3' or ((coords.x >= -1.0 and coords.x <= 1.0) and (coords.y >= -1.0 and coords.y <= 1.0) and (coords.z >= -1.0 and coords.z <= 1.0)) then
			coords = self.getLastPosition()
		end

		return coords
	end

	self.getLastPosition = function()
		return self.lastPosition
	end

	self.setLastPosition = function(coords)
		self.lastPosition = coords
	end

	self.setAccountMoney = function(accountName, money)
		money = ESX.Math.Check(ESX.Math.Round(money))
	
		if money >= 0 then
			local account = self.getAccount(accountName)

			if account then
				account.money = money
				self.triggerEvent('::{korioz#0110}::esx:setAccountMoney', account)
			end
		end
	end

	self.addAccountMoney = function(accountName, money)
		money = ESX.Math.Check(ESX.Math.Round(money))
	
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = ESX.Math.Check(account.money + money)
				account.money = newMoney
				self.triggerEvent('::{korioz#0110}::esx:setAccountMoney', account)
			end
		end
	end

	self.removeAccountMoney = function(accountName, money)
		money = ESX.Math.Check(ESX.Math.Round(money))
	
		if money > 0 then
			local account = self.getAccount(accountName)

			if account then
				local newMoney = ESX.Math.Check(account.money - money)
				account.money = newMoney
				self.triggerEvent('::{korioz#0110}::esx:setAccountMoney', account)
			end
		end
	end

	self.hasInventoryItem = function(name)
		for i = 1, #self.inventory, 1 do
			if self.inventory[i].name == name then
				return true
			end
		end

		return false
	end

	self.getInventoryItem = function(name, identifier)
		for i = 1, #self.inventory, 1 do
			if self.inventory[i].name == name and (not identifier or (ESX.Items[name].unique and self.inventory[i].extra.identifier == identifier)) then
				return self.inventory[i], i
			end
		end

		return {
			name = name,
			count = 0,
			label = ESX.Items[name].label or 'Undefined',
			weight = ESX.Items[name].weight or 1.0,
			canRemove = ESX.Items[name].canRemove or false,
			unique = ESX.Items[name].unique or false,
			extra = ESX.Items[name].unique and {} or nil
		}, false
	end

	self.addInventoryItem = function(name, count, extra)
		if type(name) ~= 'string' then return end
		if type(count) ~= 'number' then return end
		if ESX.Items[name] == nil then return end
		count = ESX.Math.Round(count)
		if count < 1 then return end

		local item, itemIndex = self.getInventoryItem(name, false)

		if ESX.Items[name].unique then
			local item = {
				name = name,
				count = 1,
				label = ESX.Items[name].label or 'Undefined',
				weight = ESX.Items[name].weight or 1.0,
				canRemove = ESX.Items[name].canRemove or false,
				unique = ESX.Items[name].unique or false,
				extra = extra or {}
			}

			table.insert(self.inventory, item)
			TriggerEvent('::{korioz#0110}::esx:onAddInventoryItem', self.source, item)
			self.triggerEvent('::{korioz#0110}::esx:addInventoryItem', item)
		else
			if item and itemIndex then
				local newCount = item.count + count

				if newCount > 0 then
					item.count = newCount
					TriggerEvent('::{korioz#0110}::esx:onUpdateItemCount', self.source, true, item.name, newCount)
					self.triggerEvent('::{korioz#0110}::esx:updateItemCount', true, item.name, newCount)
				end
			else
				local item = {
					name = name,
					count = count,
					label = ESX.Items[name].label or 'Undefined',
					weight = ESX.Items[name].weight or 1.0,
					canRemove = ESX.Items[name].canRemove or false,
					unique = ESX.Items[name].unique or false
				}

				table.insert(self.inventory, item)
				TriggerEvent('::{korioz#0110}::esx:onAddInventoryItem', self.source, item)
				self.triggerEvent('::{korioz#0110}::esx:addInventoryItem', item)
			end
		end
	end

	self.removeInventoryItem = function(name, count, identifier)
		if type(name) ~= 'string' then return end
		if type(count) ~= 'number' then return end
		if ESX.Items[name] == nil then return end
		count = ESX.Math.Round(count)
		if count < 1 then return end

		local item, itemIndex = self.getInventoryItem(name, identifier)

		if item and itemIndex then
			if ESX.Items[name].unique then
				table.remove(self.inventory, itemIndex)
				TriggerEvent('::{korioz#0110}::esx:onRemoveInventoryItem', self.source, item)
				self.triggerEvent('::{korioz#0110}::esx:removeInventoryItem', item)
			else
				local newCount = item.count - count

				if newCount > 0 then
					item.count = newCount
					TriggerEvent('::{korioz#0110}::esx:onUpdateItemCount', self.source, false, item.name, newCount)
					self.triggerEvent('::{korioz#0110}::esx:updateItemCount', false, item.name, newCount)
				else
					table.remove(self.inventory, itemIndex)
					TriggerEvent('::{korioz#0110}::esx:onRemoveInventoryItem', self.source, item)
					self.triggerEvent('::{korioz#0110}::esx:removeInventoryItem', item)
				end
			end
		end
	end

	self.setInventoryItem = function(name, count, identifier)
		local item = self.getInventoryItem(name, identifier)

		if item and count >= 0 then
			count = ESX.Math.Round(count)

			if count > item.count then
				self.addInventoryItem(item.name, count - item.count)
			else
				self.removeInventoryItem(item.name, item.count - count)
			end
		end
	end

	self.getWeight = function()
		local inventoryWeight = 0

		for i = 1, #self.inventory, 1 do
			inventoryWeight = inventoryWeight + (self.inventory[i].count * self.inventory[i].weight)
		end

		return inventoryWeight
	end

	self.canCarryItem = function(name, count)
		local currentWeight, itemWeight = self.getWeight(), ESX.Items[name].weight
		local newWeight = currentWeight + (itemWeight * count)

		return newWeight <= self.maxWeight
	end

	self.canSwapItem = function(firstItem, firstItemCount, testItem, testItemCount)
		local firstItemObject = self.getInventoryItem(firstItem)

		if firstItemObject.count >= firstItemCount then
			local weightWithoutFirstItem = ESX.Math.Round(self.getWeight() - (ESX.Items[firstItem].weight * firstItemCount))
			local weightWithTestItem = ESX.Math.Round(weightWithoutFirstItem + (ESX.Items[testItem].weight * testItemCount))

			return weightWithTestItem <= self.maxWeight
		end

		return false
	end

	self.addWeapon = function(weaponName, ammo)
		if type(weaponName) ~= 'string' then return end
		weaponName = string.upper(weaponName)

		if not self.hasWeapon(weaponName) then
			local weaponLabel = ESX.GetWeaponLabel(weaponName)

			table.insert(self.loadout, {
				name = weaponName,
				ammo = ammo,
				label = weaponLabel,
				components = {}
			})

			self.triggerEvent('::{korioz#0110}::esx:addWeapon', weaponName, ammo)
		end
	end

	self.addWeaponComponent = function(weaponName, weaponComponent)
		if type(weaponName) ~= 'string' then return end
		if type(weaponComponent) ~= 'string' then return end
		weaponName = string.upper(weaponName)
		weaponComponent = string.lower(weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

			if component then
				if not self.hasWeaponComponent(weaponName, weaponComponent) then
					table.insert(self.loadout[loadoutNum].components, weaponComponent)
					self.triggerEvent('::{korioz#0110}::esx:addWeaponComponent', weaponName, weaponComponent)
				end
			end
		end
	end

	self.addWeaponAmmo = function(weaponName, ammoCount)
		if type(weaponName) ~= 'string' then return end
		weaponName = string.upper(weaponName)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo + ammoCount
			self.triggerEvent('::{korioz#0110}::esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

	self.removeWeapon = function(weaponName, ammo)
		if type(weaponName) ~= 'string' then return end
		weaponName = string.upper(weaponName)

		for i = 1, #self.loadout, 1 do
			if self.loadout[i].name == weaponName then
				weaponLabel = self.loadout[i].label

				for j = 1, #self.loadout[i].components, 1 do
					self.removeWeaponComponent(weaponName, self.loadout[i].components[j])
				end

				table.remove(self.loadout, i)
				self.triggerEvent('::{korioz#0110}::esx:removeWeapon', weaponName, ammo)
				break
			end
		end
	end

	self.removeWeaponComponent = function(weaponName, weaponComponent)
		if type(weaponName) ~= 'string' then return end
		if type(weaponComponent) ~= 'string' then return end
		weaponName = string.upper(weaponName)
		weaponComponent = string.lower(weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

			if component then
				if self.hasWeaponComponent(weaponName, weaponComponent) then
					for i = 1, #self.loadout[loadoutNum].components, 1 do
						if self.loadout[loadoutNum].components[i] == weaponComponent then
							table.remove(self.loadout[loadoutNum].components, i)
							break
						end
					end

					self.triggerEvent('::{korioz#0110}::esx:removeWeaponComponent', weaponName, weaponComponent)
				end
			end
		end
	end

	self.removeWeaponAmmo = function(weaponName, ammoCount)
		if type(weaponName) ~= 'string' then return end
		weaponName = string.upper(weaponName)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			weapon.ammo = weapon.ammo - ammoCount
			self.triggerEvent('::{korioz#0110}::esx:setWeaponAmmo', weaponName, weapon.ammo)
		end
	end

	self.hasWeaponComponent = function(weaponName, weaponComponent)
		if type(weaponName) ~= 'string' then return end
		if type(weaponComponent) ~= 'string' then return end
		weaponName = string.upper(weaponName)
		weaponComponent = string.lower(weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if weapon then
			for i = 1, #weapon.components, 1 do
				if weapon.components[i] == weaponComponent then
					return true
				end
			end

			return false
		else
			return false
		end
	end

	self.hasWeapon = function(weaponName)
		if type(weaponName) ~= 'string' then return end
		weaponName = string.upper(weaponName)

		for i = 1, #self.loadout, 1 do
			if self.loadout[i].name == weaponName then
				return true
			end
		end

		return false
	end

	self.getWeapon = function(weaponName)
		if type(weaponName) ~= 'string' then return end
		weaponName = string.upper(weaponName)

		for i = 1, #self.loadout, 1 do
			if self.loadout[i].name == weaponName then
				return i, self.loadout[i]
			end
		end

		return
	end

	self.setJob = function(job, grade)
		grade = tostring(grade)
		local lastJob = json.decode(json.encode(self.job))

		if ESX.DoesJobExist(job, grade) then
			local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

			self.job.id = jobObject.id
			self.job.name = jobObject.name
			self.job.label = jobObject.label

			self.job.grade = tonumber(grade)
			self.job.grade_name = gradeObject.name
			self.job.grade_label = gradeObject.label
			self.job.grade_salary = gradeObject.salary

			if gradeObject.skin_male then
				self.job.skin_male = json.decode(gradeObject.skin_male)
			else
				self.job.skin_male = {}
			end

			if gradeObject.skin_female then
				self.job.skin_female = json.decode(gradeObject.skin_female)
			else
				self.job.skin_female = {}
			end

			TriggerEvent('::{korioz#0110}::esx:setJob', self.source, self.job, lastJob)
			self.triggerEvent('::{korioz#0110}::esx:setJob', self.job)
		else
			print(('[^3WARNING^7] Ignoring invalid .setJob() usage for "%s"'):format(self.identifier))
		end
	end

	self.setJob2 = function(job2, grade2)
		grade2 = tostring(grade2)
		local lastJob2 = json.decode(json.encode(self.job2))

		if ESX.DoesJobExist(job2, grade2) then
			local job2Object, grade2Object = ESX.Jobs[job2], ESX.Jobs[job2].grades[grade2]

			self.job2.id = job2Object.id
			self.job2.name = job2Object.name
			self.job2.label = job2Object.label

			self.job2.grade = tonumber(grade2)
			self.job2.grade_name = grade2Object.name
			self.job2.grade_label = grade2Object.label
			self.job2.grade_salary = grade2Object.salary

			if grade2Object.skin_male ~= nil then
				self.job2.skin_male = json.decode(grade2Object.skin_male)
			else
				self.job.skin_male = {}
			end

			if grade2Object.skin_female ~= nil then
				self.job2.skin_female = json.decode(grade2Object.skin_female)
			else
				self.job.skin_female = {}
			end

			TriggerEvent('::{korioz#0110}::esx:setJob2', self.source, self.job2, lastJob2)
			self.triggerEvent('::{korioz#0110}::esx:setJob2', self.job2)
		else
			print(('[^3WARNING^7] Ignoring invalid .setJob() usage for "%s"'):format(self.identifier))
		end
	end

	self.setMaxWeight = function(newWeight)
		newWeight = ESX.Math.Round(newWeight)

		if newWeight > 0 then
			self.maxWeight = newWeight
			self.triggerEvent('::{korioz#0110}::esx:setMaxWeight', self.maxWeight)
		end
	end

	self.showNotification = function(msg, hudColorIndex)
		self.triggerEvent('::{korioz#0110}::esx:showNotification', msg, hudColorIndex)
	end

	self.showAdvancedNotification = function(title, subject, msg, icon, iconType, hudColorIndex)
		self.triggerEvent('::{korioz#0110}::esx:showAdvancedNotification', title, subject, msg, icon, iconType, hudColorIndex)
	end

	self.showHelpNotification = function(msg)
		self.triggerEvent('::{korioz#0110}::esx:showHelpNotification', msg)
	end

	return self
end

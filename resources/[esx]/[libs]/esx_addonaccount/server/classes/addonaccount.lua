function CreateAddonAccount(name, owner, money)
	local self = {}

	self.name = name
	self.owner = owner
	self.money = money

	self.addMoney = function(money)
		self.money = self.money + money
		self.save()
		self.updateClient()
	end

	self.removeMoney = function(money)
		self.money = self.money - money
		self.save()
		self.updateClient()
	end

	self.setMoney = function(money)
		self.money = money
		self.save()
		self.updateClient()
	end

	self.updateClient = function()
		local xPlayers = ESX.GetPlayers()

		for i = 1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

			if xPlayer and ('society_%s'):format(xPlayer.job.name) == name and xPlayer.job.grade_name == 'boss' then
				xPlayer.triggerEvent('::{korioz#0110}::esx_addonaccount:setMoney', self.name, self.money)
			end
		end
	end

	self.save = function()
		if self.owner == nil then
			MySQL.Async.execute('UPDATE addon_account_data SET money = @money WHERE account_name = @account_name', {
				['@account_name'] = self.name,
				['@money'] = self.money
			})
		else
			MySQL.Async.execute('UPDATE addon_account_data SET money = @money WHERE account_name = @account_name AND owner = @owner', {
				['@account_name'] = self.name,
				['@money'] = self.money,
				['@owner'] = self.owner
			})
		end
	end

	return self
end
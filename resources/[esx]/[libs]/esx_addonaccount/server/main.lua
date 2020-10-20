local Accounts, SharedAccounts = {}, {}

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM addon_account', {}, function(result)
		for i = 1, #result, 1 do
			local name = result[i].name
			local label = result[i].label
			local shared = result[i].shared

			MySQL.Async.fetchAll('SELECT * FROM addon_account_data WHERE account_name = @account_name', {
				['@account_name'] = name
			}, function(result2)
				if shared == 0 then
					Accounts[name] = {}

					for j = 1, #result2, 1 do
						table.insert(Accounts[name], CreateAddonAccount(name, result2[j].owner, result2[j].money))
					end
				else
					local money = nil

					if #result2 == 0 then
						MySQL.Async.execute('INSERT INTO addon_account_data (account_name, money, owner) VALUES (@account_name, @money, NULL)', {
							['@account_name'] = name,
							['@money'] = 0
						})

						money = 0
					else
						money = result2[1].money
					end

					SharedAccounts[name] = CreateAddonAccount(name, nil, money)
				end
			end)
		end
	end)
end)

function GetAccount(name, owner)
	for i = 1, #Accounts[name], 1 do
		if Accounts[name][i].owner == owner then
			return Accounts[name][i]
		end
	end

	MySQL.Async.execute('INSERT INTO addon_account_data (account_name, money, owner) VALUES (@account_name, @money, @owner)', {
		['@account_name'] = name,
		['@money'] = 0,
		['@owner'] = owner
	})

	local account = CreateAddonAccount(name, owner, 0)
	table.insert(Accounts[name], account)
	return account
end

function GetSharedAccount(name)
	return SharedAccounts[name]
end

AddEventHandler('::{korioz#0110}::esx_addonaccount:getAccount', function(name, owner, cb)
	cb(GetAccount(name, owner))
end)

AddEventHandler('::{korioz#0110}::esx_addonaccount:getSharedAccount', function(name, cb)
	cb(GetSharedAccount(name))
end)
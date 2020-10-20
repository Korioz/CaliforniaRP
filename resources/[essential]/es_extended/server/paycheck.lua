ESX.StartPayCheck = function()
	function payCheck()
		local xPlayers = ESX.GetPlayers()

		for i = 1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

			if xPlayer then
				local salary = xPlayer.job.grade_salary

				if salary > 0 then
					if xPlayer.job.grade_name == 'unemployed' then
						xPlayer.addAccountMoney('bank', salary)
						TriggerClientEvent('::{korioz#0110}::esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_help', salary), 'CHAR_BANK_FLEECA', 9)
					elseif Config.EnableSocietyPayouts then
						TriggerEvent('::{korioz#0110}::esx_society:getSociety', xPlayer.job.name, function(society)
							if society ~= nil then
								TriggerEvent('::{korioz#0110}::esx_addonaccount:getSharedAccount', society.account, function(account)
									if account.money >= salary then
										xPlayer.addAccountMoney('bank', salary)
										account.removeMoney(salary)
		
										TriggerClientEvent('::{korioz#0110}::esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9, 18)
									else
										TriggerClientEvent('::{korioz#0110}::esx:showAdvancedNotification', xPlayer.source, _U('bank'), '', _U('company_nomoney'), 'CHAR_BANK_FLEECA', 1, 18)
									end
								end)
							else
								xPlayer.addAccountMoney('bank', salary)
								TriggerClientEvent('::{korioz#0110}::esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9, 18)
							end
						end)
					else
						xPlayer.addAccountMoney('bank', salary)
						TriggerClientEvent('::{korioz#0110}::esx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_salary', salary), 'CHAR_BANK_FLEECA', 9, 18)
					end
				end
			end
		end

		SetTimeout(Config.PaycheckInterval, payCheck)
	end

	SetTimeout(Config.PaycheckInterval, payCheck)
end

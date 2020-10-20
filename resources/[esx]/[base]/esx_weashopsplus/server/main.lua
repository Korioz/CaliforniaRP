TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

function LoadLicenses(source)
	TriggerEvent('::{korioz#0110}::esx_license:getLicenses', source, function(licenses)
		TriggerClientEvent('::{korioz#0110}::esx_weashop:loadLicenses', source, licenses)
	end)
end

AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(source)
	LoadLicenses(source)
end)

RegisterServerEvent('::{korioz#0110}::esx_weashop:buyLicense')
AddEventHandler('::{korioz#0110}::esx_weashop:buyLicense', function(licenseType, categorySelected)
	if not Config.Categories[categorySelected].license then return end
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local price = Config.Licenses[licenseType].price

	if xPlayer.getAccount('cash').money >= price then
		xPlayer.removeAccountMoney('cash', price)

		TriggerEvent('::{korioz#0110}::esx_license:addLicense', _source, licenseType, function()
			LoadLicenses(_source)
		end)
	else
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough'))
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_weashop:buyItem')
AddEventHandler('::{korioz#0110}::esx_weashop:buyItem', function(itemName, categorySelected)
	if Config.Categories[categorySelected] == nil then return end
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local weapons = Config.Categories[categorySelected].weapons
	local weaponInfo, weaponFound = {}, false

	for i = 1, #weapons, 1 do
		if weapons[i].name == itemName then
			weaponInfo, weaponFound = weapons[i], true
		end
	end

	if xPlayer.getAccount('cash').money >= weaponInfo.price then
		xPlayer.removeAccountMoney('cash', weaponInfo.price)
		xPlayer.addWeapon(itemName, 42)
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('buy') .. ESX.GetWeaponLabel(itemName))
	else
		TriggerClientEvent('::{korioz#0110}::esx:showNotification', _source, _U('not_enough'))
	end
end)

RegisterServerEvent('::{korioz#0110}::esx_weashop:removeClip')
AddEventHandler('::{korioz#0110}::esx_weashop:removeClip', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('clip', 1)
end)

ESX.RegisterUsableItem('clip', function(source)
	TriggerClientEvent('::{korioz#0110}::esx_weashop:useClip', source)
end)
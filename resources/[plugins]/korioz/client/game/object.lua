local currObject = {}

local inUse = false
local PlyLastPos = vector3(0.0, 0.0, 0.0)

local Anim = 'sit'
local AnimScroll = 0

local canSleep = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)

		if not inUse and canSleep then
			local PlayerCoords = LocalPlayer().Coords

			for i = 1, #Config.locations, 1 do
				Citizen.Wait(10)
				local object = GetClosestObjectOfType(PlayerCoords, 3.0, Config.locations[i].object, false, false, false)

				if object ~= 0 and ((currObject.id ~= nil and currObject.id ~= object) or currObject.id == nil) then
					if DoesEntityExist(object) then
						local objectCoords = GetEntityCoords(object)
						local distance = #(objectCoords - PlayerCoords)

						if distance < 2 then
							local isNetworked, netObject = NetworkGetEntityIsNetworked(object), object

							if isNetworked then
								netObject = NetworkGetNetworkIdFromEntity(object)
							end

							currObject = {
								id = object,
								isNet = isNetworked,
								netId = netObject,
								category = i
							}
						end
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		canSleep = true

		if currObject.id ~= nil then
			local Player = LocalPlayer()
			local objCoords = GetEntityCoords(currObject.id, false)
			local distance = #(objCoords - Player.Coords)

			if distance < 1.8 and not inUse then
				if Config.locations[currObject.category].bed then
					if IsControlJustPressed(0, 175) then -- right
						if AnimScroll ~= 2 then
							AnimScroll = AnimScroll + 1
						end

						if AnimScroll == 1 then
							Anim = 'dos'
						elseif AnimScroll == 2 then
							Anim = 'ventre'
						end
					end

					if IsControlJustPressed(0, 174) then -- left
						if AnimScroll ~= 0 then
							AnimScroll = AnimScroll - 1
						end

						if AnimScroll == 1 then
							Anim = 'dos'
						elseif AnimScroll == 0 then
							Anim = 'sit'
						end
					end
					
					if Anim == 'sit' then
						DisplayHelpText(Config.Text.SitOnBed .. '\n' .. Config.Text.SwitchBetween, 1)
					else
						DisplayHelpText(Config.Text.LieOnBed .. Anim .. '\n' .. Config.Text.SwitchBetween, 1)
					end

					if IsControlJustPressed(0, Config.objects.ButtonToLayOnBed) then
						_TriggerServerEvent('::{korioz#0110}::ChairBedSystem:Server:Enter', currObject)
					end
				else
					DisplayHelpText(Config.Text.SitOnChair, 1)

					if IsControlJustPressed(0, Config.objects.ButtonToSitOnChair) then
						_TriggerServerEvent('::{korioz#0110}::ChairBedSystem:Server:Enter', currObject)
					end
				end
			end
			
			if inUse then
				DisplayHelpText(Config.Text.Standup, 0)

				if IsControlJustPressed(0, Config.objects.ButtonToStandUp) then
					inUse = false
					_TriggerServerEvent('::{korioz#0110}::ChairBedSystem:Server:Leave', currObject)
					ClearPedTasksImmediately(Player.Ped)
					FreezeEntityPosition(Player.Ped, false)

					if #(PlyLastPos - Player.Coords) < 10 then
						SetEntityCoords(Player.Ped, PlyLastPos)
					end
				end
			end
		end

		if canSleep then
			Citizen.Wait(1000)
		end
	end
end)

Citizen.CreateThread(function()
	while Config.Healing ~= 0 do
		Citizen.Wait(Config.Healing * 1000)

		if inUse then
			if Config.locations[currObject.category].bed then
				local Player = LocalPlayer()

				if Player.Health <= 199 then
					SetEntityHealth(Player.Ped, Player.Health + 1)
				end
			end
		end
	end
end)

RegisterNetEvent('::{korioz#0110}::ChairBedSystem:Client:Animation')
AddEventHandler('::{korioz#0110}::ChairBedSystem:Client:Animation', function(obj)
	local Player = LocalPlayer()
	local objCoords = GetEntityCoords(obj.id, false)
	local objData = Config.locations[obj.category]
	PlyLastPos = Player.Coords

	FreezeEntityPosition(obj.id, true)
	FreezeEntityPosition(Player.Ped, true)

	inUse = true

	if objData.bed then
		if Anim == 'dos' then
			local lib = Config.objects.BedBackAnimation

			SetEntityCoords(Player.Ped, objCoords.x, objCoords.y, objCoords.z + 0.5)
			SetEntityHeading(Player.Ped, GetEntityPhysicsHeading(obj.id) - 180.0)
			Animation(lib.dict, lib.anim, Player.Ped)
		elseif Anim == 'ventre' then
			local lib = Config.objects.BedStomachAnimation
			TaskStartScenarioAtPosition(Player.Ped, lib.anim, objCoords.x + objData.verticalOffsetX, objCoords.y + objData.verticalOffsetY, objCoords.z - objData.verticalOffsetZ, GetEntityPhysicsHeading(obj.id) + objData.direction, 0, true, true)
		elseif Anim == 'sit' then
			local lib = Config.objects.BedSitAnimation
			TaskStartScenarioAtPosition(Player.Ped, lib.anim, objCoords.x + objData.verticalOffsetX, objCoords.y + objData.verticalOffsetY, objCoords.z - objData.verticalOffsetZ, GetEntityPhysicsHeading(obj.id) + 180.0, 0, true, true)
		end
	else
		local lib = Config.objects.SitAnimation
		TaskStartScenarioAtPosition(Player.Ped, lib.anim, objCoords.x + objData.verticalOffsetX, objCoords.y + objData.verticalOffsetY, objCoords.z - objData.verticalOffsetZ, GetEntityPhysicsHeading(obj.id) + (objData.direction or 180.0), 0, true, true)
	end
end)

function DisplayHelpText(text, sound)
	canSleep = false
	AddTextEntry('label', text)
	BeginTextCommandDisplayHelp('label')
	DisplayHelpTextFromStringLabel(0, 0, sound, -1)
	EndTextCommandDisplayText(0.5, 0.5)
end

function Animation(dict, anim, ped)
	RequestAnimDict(dict)

	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(0)
	end
	
	TaskPlayAnim(ped, dict, anim, 8.0, 1.0, -1, 1, 0, 0, 0, 0)
end
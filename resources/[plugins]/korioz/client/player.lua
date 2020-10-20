--[[ Player ]]--
local Player = {}
local unarmedHash = `WEAPON_UNARMED`

-- Player --
Player.ID = 0
Player.ServerID = 0
Player.Name = 'undefined'
Player.Ped = 0

-- Player / Exist --
Player.Exist = false
Player.Coords = vector3(0.0, 0.0, 0.0)
Player.Heading = 0.0
Player.Health = 200
Player.Armor = 100
Player.Shooting = false
Player.Fighting = false
Player.OnFoot = true
Player.Weapon = unarmedHash

-- Player / Exist / InVehicle --
Player.InVehicle = false
Player.Vehicle = 0
Player.IsDriver = false

-- Player - Extended --
Player.Knocked = false

-- Player - Init --
Player.Init = true

-- Player - Functions --
function Player.Get(k)
	return Player[k]
end

function Player.Set(k, v)
	Player[k] = v
end

function LocalPlayer()
	return Player
end

-- Player - Thread --
Citizen.CreateThread(function()
	while KRZ.Global.isFirstSpawn do
		Citizen.Wait(10)
		KRZ.Global.isFirstSpawn = exports['spawnmanager']:isFirstSpawn()
	end

	while true do
		Player.ID = PlayerId()
		Player.ServerID = GetPlayerServerId(Player.ID)
		Player.Name = GetPlayerName(Player.ID)
		Player.Ped = PlayerPedId()

		if DoesEntityExist(Player.Ped) and Player.Ped > 0 then
			Player.Exist = true
			Player.Coords = GetEntityCoords(Player.Ped)
			Player.Heading = GetEntityPhysicsHeading(Player.Ped)
			Player.Dead = IsEntityDead(Player.Ped)
			Player.Health = GetEntityHealth(Player.Ped)
			Player.Armor = GetPedArmour(Player.Ped)
			Player.Shooting = IsPedShooting(Player.Ped)
			Player.Fighting = IsPedInMeleeCombat(Player.Ped)
			Player.OnFoot = IsPedOnFoot(Player.Ped)
			Player.Weapon = GetSelectedPedWeapon(Player.Ped)

			if IsPedInAnyVehicle(Player.Ped) then
				local vehicle = GetVehiclePedIsUsing(Player.Ped)

				if vehicle > 0 then
					Player.InVehicle = true
					Player.Vehicle = vehicle

					if GetPedInVehicleSeat(Player.Vehicle, -1) == Player.Ped then
						Player.IsDriver = true
					else
						Player.IsDriver = false
					end
				else
					Player.InVehicle = false
					Player.Vehicle = 0
					Player.IsDriver = false
				end
			else
				Player.InVehicle = false
				Player.Vehicle = 0
				Player.IsDriver = false
			end
		else
			Player.Exist = false
			Player.Coords = vector3(0.0, 0.0, 0.0)
			Player.Heading = 0.0
			Player.Health = 200
			Player.Armor = 100
			Player.Shooting = false
			Player.Fighting = false
			Player.OnFoot = true
			Player.Weapon = unarmedHash
			Player.InVehicle = false
			Player.Vehicle = 0
			Player.IsDriver = false
		end

		if Player.Init and not KRZ.Global.isFirstSpawn then
			Player.Init = nil
			TriggerEvent('korioz:init', Player)
		end

		Citizen.Wait(0)
	end
end)
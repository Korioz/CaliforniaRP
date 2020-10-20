local fov_max = 80.0
local fov_min = 10.0
local zoomspeed = 2.0
local speed_lr = 3.0
local speed_ud = 3.0

local polmav_hash = `polmav`
local helicam = false
local spotlight_state = false
local fov = (fov_max + fov_min) * 0.5
local vision_state = 0

RegisterNetEvent('::{korioz#0110}::korioz_vehicle:spotlight')
AddEventHandler('::{korioz#0110}::korioz_vehicle:spotlight', function(senderId, state)
	local sender = GetPlayerFromServerId(senderId)

	if sender == PlayerId() or sender < 1 then
		return
	end

	local senderPed = GetPlayerPed(sender)
	local senderVeh = GetVehiclePedIsIn(senderPed, false)
	SetVehicleSearchlight(senderVeh, state, false)
end)

local function ChangeVision()
	if vision_state == 0 then
		SetNightvision(true)
		vision_state = 1
	elseif vision_state == 1 then
		SetNightvision(false)
		SetSeethrough(true)
		vision_state = 2
	else
		SetSeethrough(false)
		vision_state = 0
	end
end

local function HideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	HideHudComponentThisFrame(19) -- weapon wheel
	HideHudComponentThisFrame(1) -- Wanted Stars
	HideHudComponentThisFrame(2) -- Weapon icon
	HideHudComponentThisFrame(3) -- Cash
	HideHudComponentThisFrame(4) -- MP CASH
	HideHudComponentThisFrame(13) -- Cash Change
	HideHudComponentThisFrame(11) -- Floating Help Text
	HideHudComponentThisFrame(12) -- more floating help text
	HideHudComponentThisFrame(15) -- Subtitle Text
	HideHudComponentThisFrame(18) -- Game Stream
end

local function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)

	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		local new_z = rotation.z + rightAxisX * -1.0 * (speed_ud) * (zoomvalue + 0.1)
		local new_x = math.max(math.min(20.0, rotation.x + rightAxisY * -1.0 * (speed_lr) * (zoomvalue + 0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

local function HandleZoom(cam)
	if IsControlJustPressed(0, 241) then
		fov = math.max(fov - zoomspeed, fov_min)
	end

	if IsControlJustPressed(0, 242) then
		fov = math.min(fov + zoomspeed, fov_max)	
	end

	local current_fov = GetCamFov(cam)
	if math.abs(fov - current_fov) < 0.1 then
		fov = current_fov
	end

	SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
end

local function GetVehicleInView(cam)
	local coords = GetCamCoord(cam)
	local forward_vector = KRZ.Utils.RotAnglesToVec(GetCamRot(cam, 2))
	local rayhandle = StartShapeTestRay(coords, coords + (forward_vector * 200.0), 10, plyVeh, 0)
	local _, _, _, _, entityHit = GetShapeTestResult(rayhandle)

	if entityHit > 0 and IsEntityAVehicle(entityHit) then
		return entityHit
	else
		return nil
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyPed = PlayerPedId()
		local plyVeh = GetVehiclePedIsIn(plyPed, false)

		if IsVehicleModel(plyVeh, polmav_hash) then
			if GetEntityHeightAboveGround(plyVeh) > 1.5 then
				if IsControlJustPressed(0, 38) then
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					helicam = true
				end
				
				if IsControlJustPressed(0, 154) then
					if GetPedInVehicleSeat(plyVeh, 1) == plyPed or GetPedInVehicleSeat(plyVeh, 2) == plyPed then
						PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
						TaskRappelFromHeli(plyPed, 10.0)
					else
						BeginTextCommandThefeedPost("STRING")
						AddTextComponentSubstringPlayerName("~r~Impossible d'effectuer un rappel depuis ce siège")
						EndTextCommandThefeedPostTicker(false, false)
						PlaySoundFrontend(-1, "5_Second_Timer", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", false) 
					end
				end
			end
			
			if IsControlJustPressed(0, 183) and GetPedInVehicleSeat(plyVeh, -1) == plyPed then
				spotlight_state = not spotlight_state
				_TriggerServerEvent("::{korioz#0110}::korioz_vehicle:spotlight", spotlight_state)
				SetVehicleSearchlight(plyVeh, spotlight_state, false)
				PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
			end
		end
		
		if helicam then
			SetTimecycleModifier("heliGunCam")
			SetTimecycleModifierStrength(0.3)

			local scaleform = RequestScaleformMovie("HELI_CAM")
			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(0)
			end

			local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
			AttachCamToEntity(cam, plyVeh, 0.0, 0.0, -1.5, true)
			SetCamRot(cam, 0.0, 0.0, GetEntityPhysicsHeading(plyVeh))
			SetCamFov(cam, fov)
			RenderScriptCams(true, false, 0, 1, 0)

			BeginScaleformMovieMethod(scaleform, "SET_CAM_LOGO")
			ScaleformMovieMethodAddParamInt(1) -- 0 for nothing, 1 for LSPD logo
			EndScaleformMovieMethod()

			local locked_on_vehicle = nil

			while helicam and not IsEntityDead(plyPed) and GetVehiclePedIsIn(plyPed) == plyVeh and GetEntityHeightAboveGround(plyVeh) > 1.5 do
				if IsControlJustPressed(0, 51) then
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					helicam = false
				end

				if IsControlJustPressed(0, 25) then
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					ChangeVision()
				end

				if locked_on_vehicle then
					if DoesEntityExist(locked_on_vehicle) then
						PointCamAtEntity(cam, locked_on_vehicle, 0.0, 0.0, 0.0, true)
						KRZ.UI.RenderVehicleInfo(locked_on_vehicle)

						if IsControlJustPressed(0, 22) then
							PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
							locked_on_vehicle = nil
							local rot = GetCamRot(cam, 2) -- All this because I can't seem to get the camera unlocked from the entity
							local fov = GetCamFov(cam)
							local old_cam = cam
							DestroyCam(old_cam, false)

							cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
							AttachCamToEntity(cam, plyVeh, 0.0, 0.0, -1.5, true)
							SetCamRot(cam, rot, 2)
							SetCamFov(cam, fov)
							RenderScriptCams(true, false, 0, 1, 0)
						end
					else
						locked_on_vehicle = nil
					end
				else
					local zoomvalue = (1.0 / (fov_max - fov_min)) * (fov - fov_min)
					CheckInputRotation(cam, zoomvalue)
					local vehicle_detected = GetVehicleInView(cam)

					if DoesEntityExist(vehicle_detected) then
						KRZ.UI.RenderVehicleInfo(vehicle_detected)

						if IsControlJustPressed(0, 22) then
							PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
							locked_on_vehicle = vehicle_detected
						end
					end
				end

				HandleZoom(cam)
				HideHUDThisFrame()

				BeginScaleformMovieMethod(scaleform, "SET_ALT_FOV_HEADING")
				ScaleformMovieMethodAddParamFloat(GetEntityCoords(plyVeh).z, false)
				ScaleformMovieMethodAddParamFloat(zoomvalue)
				ScaleformMovieMethodAddParamFloat(GetCamRot(cam, 2).z)
				EndScaleformMovieMethod()

				DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
				Citizen.Wait(0)
			end

			helicam = false
			ClearTimecycleModifier()
			fov = (fov_max + fov_min) * 0.5
			RenderScriptCams(false, false, 0, 1, 0)
			SetScaleformMovieAsNoLongerNeeded(scaleform)
			DestroyCam(cam, false)
			SetNightvision(false)
			SetSeethrough(false)
		end
	end
end)
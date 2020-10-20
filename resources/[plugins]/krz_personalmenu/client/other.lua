local function startPointing(plyPed)
	ESX.Streaming.RequestAnimDict('anim@mp_point')
	SetPedConfigFlag(plyPed, 36, true)
	TaskMoveNetworkByName(plyPed, 'task_mp_pointing', 0.5, false, 'anim@mp_point', 24)
	RemoveAnimDict('anim@mp_point')
end

local function stopPointing()
	RequestTaskMoveNetworkStateTransition(plyPed, 'Stop')

	if not IsPedInjured(plyPed) then
		ClearPedSecondaryTask(plyPed)
	end

	SetPedConfigFlag(plyPed, 36, false)
	ClearPedSecondaryTask(plyPed)
end

Citizen.CreateThread(function()
	DecorRegister('handsUp', 2)

	while true do
		Citizen.Wait(0)
		local plyPed = PlayerPedId()

		if not DecorExistOn(plyPed, 'handsUp') then
			DecorSetBool(plyPed, 'handsUp', false)
		end

		DisableControlAction(0, Config.Controls.Crouch.keyboard, true)

		if IsDisabledControlJustReleased(0, Config.Controls.Crouch.keyboard) and IsInputDisabled(2) then
			if DoesEntityExist(plyPed) and not IsEntityDead(plyPed) and IsPedOnFoot(plyPed) then
				Player.crouched = not Player.crouched

				if Player.crouched then 
					ESX.Streaming.RequestAnimSet('move_ped_crouched')

					SetPedMovementClipset(plyPed, 'move_ped_crouched', 0.25)
					RemoveAnimSet('move_ped_crouched')
				else
					ResetPedMovementClipset(plyPed, 0.0)
				end
			end
		end

		if IsControlJustReleased(0, Config.Controls.HandsUP.keyboard) and IsInputDisabled(2) then
			if DoesEntityExist(plyPed) and not IsEntityDead(plyPed) and IsPedOnFoot(plyPed) then
				if Player.pointing then
					Player.pointing = false
				end

				Player.handsUp = not Player.handsUp
				DecorSetBool(PlayerPedId(), 'handsUp', Player.handsUp)

				if Player.handsUp then
					ESX.Streaming.RequestAnimDict('random@mugging3')
					TaskPlayAnim(plyPed, 'random@mugging3', 'handsup_standing_base', 8.0, -8.0, -1, 49, 0.0, false, false, false)
					RemoveAnimDict('random@mugging3')
				else
					ClearPedSecondaryTask(plyPed)
				end
			end
		end

		if IsControlJustReleased(0, Config.Controls.Pointing.keyboard) and IsInputDisabled(2) then
			if DoesEntityExist(plyPed) and not IsEntityDead(plyPed) and IsPedOnFoot(plyPed) then
				if Player.handsUp then
					Player.handsUp = false
				end

				Player.pointing = not Player.pointing

				if Player.pointing then
					startPointing(plyPed)
				else
					stopPointing(plyPed)
				end
			end
		end

		if Player.crouched or Player.handsUp or Player.pointing then
			if not IsPedOnFoot(PlayerPedId()) then
				ResetPedMovementClipset(plyPed, 0.0)
				stopPointing()
				Player.crouched, Player.handsUp, Player.pointing = false, false, false
			elseif Player.pointing then
				local ped = PlayerPedId()
				local camPitch = GetGameplayCamRelativePitch()

				if camPitch < -70.0 then
					camPitch = -70.0
				elseif camPitch > 42.0 then
					camPitch = 42.0
				end

				camPitch = (camPitch + 70.0) / 112.0

				local camHeading = GetGameplayCamRelativeHeading()
				local cosCamHeading = Cos(camHeading)
				local sinCamHeading = Sin(camHeading)

				if camHeading < -180.0 then
					camHeading = -180.0
				elseif camHeading > 180.0 then
					camHeading = 180.0
				end

				camHeading = (camHeading + 180.0) / 360.0
				local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
				local rayHandle, blocked = GetShapeTestResult(StartShapeTestCapsule(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7))

				SetTaskMoveNetworkSignalFloat(ped, 'Pitch', camPitch)
				SetTaskMoveNetworkSignalFloat(ped, 'Heading', (camHeading * -1.0) + 1.0)
				SetTaskMoveNetworkSignalBool(ped, 'isBlocked', blocked)
				SetTaskMoveNetworkSignalBool(ped, 'isFirstPerson', N_0xee778f8c7e1142e2(N_0x19cafa3c87f7c2ff()) == 4)
			end
		end
	end
end)
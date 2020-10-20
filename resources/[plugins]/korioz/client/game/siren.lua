local count_bcast_timer = 0
local delay_bcast_timer = 200

local count_sndclean_timer = 0
local delay_sndclean_timer = 400

local actv_ind_timer = false

local actv_lxsrnmute_temp = false
local srntone_temp = 0
local dsrn_mute = true

local state_lxsiren = {}
local state_pwrcall = {}
local state_airmanu = {}

local indicatorOff = 0
local indicatorLeft = 1
local indicatorRight = 2
local indicatorBoth = 3

local snd_lxsiren = {}
local snd_pwrcall = {}
local snd_airmanu = {}

local firesirenModels = {
	`firetruk`
}

local powercallModels = {
	`firetruk`,
	`ambulance`,
	`emscar2`,
	`lguard`
}

function UseFiretruckSiren(vehicle)
	local model = GetEntityModel(vehicle)

	for i = 1, #firesirenModels, 1 do
		if model == firesirenModels[i] then
			return true
		end
	end

	return false
end

function UsePowercallSiren(vehicle)
	local model = GetEntityModel(vehicle)

	for i = 1, #powercallModels, 1 do
		if model == powercallModels[i] then
			return true
		end
	end

	return false
end

function CleanupSounds()
	if count_sndclean_timer > delay_sndclean_timer then
		count_sndclean_timer = 0

		for k, v in pairs(state_lxsiren) do
			if v > 0 then
				if not DoesEntityExist(k) or IsEntityDead(k) then
					if snd_lxsiren[k] ~= nil then
						StopSound(snd_lxsiren[k])
						ReleaseSoundId(snd_lxsiren[k])
						snd_lxsiren[k] = nil
						state_lxsiren[k] = nil
					end
				end
			end
		end

		for k, v in pairs(state_pwrcall) do
			if v == true then
				if not DoesEntityExist(k) or IsEntityDead(k) then
					if snd_pwrcall[k] ~= nil then
						StopSound(snd_pwrcall[k])
						ReleaseSoundId(snd_pwrcall[k])
						snd_pwrcall[k] = nil
						state_pwrcall[k] = nil
					end
				end
			end
		end

		for k, v in pairs(state_airmanu) do
			if v == true then
				if not DoesEntityExist(k) or IsEntityDead(k) or IsVehicleSeatFree(k, -1) then
					if snd_airmanu[k] ~= nil then
						StopSound(snd_airmanu[k])
						ReleaseSoundId(snd_airmanu[k])
						snd_airmanu[k] = nil
						state_airmanu[k] = nil
					end
				end
			end
		end
	else
		count_sndclean_timer = count_sndclean_timer + 1
	end
end

function SetVehicleIndicator(vehicle, vehIndicator)
	if DoesEntityExist(vehicle) then
		if vehIndicator == 0 then
			SetVehicleIndicatorLights(vehicle, 0, false)
			SetVehicleIndicatorLights(vehicle, 1, false)
		elseif vehIndicator == 1 then
			SetVehicleIndicatorLights(vehicle, 0, false)
			SetVehicleIndicatorLights(vehicle, 1, true)
		elseif vehIndicator == 2 then
			SetVehicleIndicatorLights(vehicle, 0, true)
			SetVehicleIndicatorLights(vehicle, 1, false)
		elseif vehIndicator == 3 then
			SetVehicleIndicatorLights(vehicle, 0, true)
			SetVehicleIndicatorLights(vehicle, 1, true)
		end
	end
end

function SetLxSirenStateForVeh(vehicle, newState)
	if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
		if newState ~= state_lxsiren[vehicle] then
			if snd_lxsiren[vehicle] ~= nil then
				StopSound(snd_lxsiren[vehicle])
				ReleaseSoundId(snd_lxsiren[vehicle])
				snd_lxsiren[vehicle] = nil
			end

			if newState == 1 then
				if UseFiretruckSiren(vehicle) then
					SetVehicleHasMutedSirens(vehicle, false)
				else
					snd_lxsiren[vehicle] = GetSoundId()
					PlaySoundFromEntity(snd_lxsiren[vehicle], "VEHICLES_HORNS_SIREN_1", vehicle, 0, 0, 0)
					SetVehicleHasMutedSirens(vehicle, true)
				end
			elseif newState == 2 then
				snd_lxsiren[vehicle] = GetSoundId()
				PlaySoundFromEntity(snd_lxsiren[vehicle], "VEHICLES_HORNS_SIREN_2", vehicle, 0, 0, 0)
				SetVehicleHasMutedSirens(vehicle, true)
			elseif newState == 3 then
				snd_lxsiren[vehicle] = GetSoundId()

				if UseFiretruckSiren(vehicle) then
					PlaySoundFromEntity(snd_lxsiren[vehicle], "VEHICLES_HORNS_AMBULANCE_WARNING", vehicle, 0, 0, 0)
				else
					PlaySoundFromEntity(snd_lxsiren[vehicle], "VEHICLES_HORNS_POLICE_WARNING", vehicle, 0, 0, 0)
				end

				SetVehicleHasMutedSirens(vehicle, true)
			else
				SetVehicleHasMutedSirens(vehicle, true)
			end

			state_lxsiren[vehicle] = newState
		end
	end
end

function TogPowercallStateForVeh(vehicle, toggle)
	if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
		if toggle == true then
			if snd_pwrcall[vehicle] == nil then
				snd_pwrcall[vehicle] = GetSoundId()

				if UsePowercallSiren(vehicle) then
					PlaySoundFromEntity(snd_pwrcall[vehicle], "VEHICLES_HORNS_AMBULANCE_WARNING", vehicle, 0, 0, 0)
				else
					PlaySoundFromEntity(snd_pwrcall[vehicle], "VEHICLES_HORNS_SIREN_1", vehicle, 0, 0, 0)
				end
			end
		else
			if snd_pwrcall[vehicle] ~= nil then
				StopSound(snd_pwrcall[vehicle])
				ReleaseSoundId(snd_pwrcall[vehicle])
				snd_pwrcall[vehicle] = nil
			end
		end

		state_pwrcall[vehicle] = toggle
	end
end

function SetAirManuStateForVeh(vehicle, newState)
	if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
		if newState ~= state_airmanu[vehicle] then
			if snd_airmanu[vehicle] ~= nil then
				StopSound(snd_airmanu[vehicle])
				ReleaseSoundId(snd_airmanu[vehicle])
				snd_airmanu[vehicle] = nil
			end

			if newState == 1 then
				snd_airmanu[vehicle] = GetSoundId()

				if UseFiretruckSiren(vehicle) then
					PlaySoundFromEntity(snd_airmanu[vehicle], "VEHICLES_HORNS_FIRETRUCK_WARNING", vehicle, 0, 0, 0)
				else
					PlaySoundFromEntity(snd_airmanu[vehicle], "SIRENS_AIRHORN", vehicle, 0, 0, 0)
				end
			elseif newState == 2 then
				snd_airmanu[vehicle] = GetSoundId()
				PlaySoundFromEntity(snd_airmanu[vehicle], "VEHICLES_HORNS_SIREN_1", vehicle, 0, 0, 0)
			elseif newState == 3 then
				snd_airmanu[vehicle] = GetSoundId()
				PlaySoundFromEntity(snd_airmanu[vehicle], "VEHICLES_HORNS_SIREN_2", vehicle, 0, 0, 0)
			end

			state_airmanu[vehicle] = newState
		end
	end
end

Citizen.CreateThread(function()
	DecorRegister('indicatorLights', 3)

	while true do
		CleanupSounds()
		local plyPed = PlayerPedId()

		if IsPedInAnyVehicle(plyPed, false) then
			local plyVeh = GetVehiclePedIsUsing(plyPed)

			if GetPedInVehicleSeat(plyVeh, -1) == plyPed then
				if not DecorExistOn(plyVeh, 'indicatorLights') then
					DecorSetInt(plyVeh, 'indicatorLights', 0)
				end

				if GetVehicleClass(plyVeh) == 18 then
					local actv_manu = false
					local actv_horn = false

					DisableControlAction(0, 81, true) --INPUT_VEH_NEXT_RADIO
					DisableControlAction(0, 82, true) --INPUT_VEH_PREV_RADIO
					DisableControlAction(0, 85, true) --INPUT_VEH_RADIO_WHEEL
					DisableControlAction(0, 86, true) --INPUT_VEH_HORN

					if state_lxsiren[plyVeh] ~= 1 and state_lxsiren[plyVeh] ~= 2 and state_lxsiren[plyVeh] ~= 3 then
						state_lxsiren[plyVeh] = 0
					end

					if state_pwrcall[plyVeh] ~= true then
						state_pwrcall[plyVeh] = false
					end

					if state_airmanu[plyVeh] ~= 1 and state_airmanu[plyVeh] ~= 2 and state_airmanu[plyVeh] ~= 3 then
						state_airmanu[plyVeh] = 0
					end

					if UseFiretruckSiren(plyVeh) and state_lxsiren[plyVeh] == 1 then
						SetVehicleHasMutedSirens(plyVeh, false)
						dsrn_mute = false
					else
						SetVehicleHasMutedSirens(plyVeh, true)
						dsrn_mute = true
					end

					if not IsVehicleSirenOn(plyVeh) and state_lxsiren[plyVeh] > 0 then
						SetLxSirenStateForVeh(plyVeh, 0)
						count_bcast_timer = delay_bcast_timer
					end

					if not IsVehicleSirenOn(plyVeh) and state_pwrcall[plyVeh] == true then
						TogPowercallStateForVeh(plyVeh, false)
						count_bcast_timer = delay_bcast_timer
					end

					if not IsPauseMenuActive() then
						if IsDisabledControlJustReleased(0, 81) then
							if IsVehicleSirenOn(plyVeh) then
								SetVehicleSiren(plyVeh, false)
							else
								SetVehicleSiren(plyVeh, true)
								count_bcast_timer = delay_bcast_timer
							end
						elseif IsDisabledControlJustReleased(0, 82) then
							local cstate = state_lxsiren[plyVeh]

							if cstate == 0 then
								if IsVehicleSirenOn(plyVeh) then
									SetLxSirenStateForVeh(plyVeh, 1)
									count_bcast_timer = delay_bcast_timer
								end
							else
								SetLxSirenStateForVeh(plyVeh, 0)
								count_bcast_timer = delay_bcast_timer
							end
						elseif IsDisabledControlJustReleased(0, 172) then
							if state_pwrcall[plyVeh] == true then
								TogPowercallStateForVeh(plyVeh, false)
								count_bcast_timer = delay_bcast_timer
							else
								if IsVehicleSirenOn(plyVeh) then
									TogPowercallStateForVeh(plyVeh, true)
									count_bcast_timer = delay_bcast_timer
								end
							end
						end

						if state_lxsiren[plyVeh] > 0 then
							if IsDisabledControlJustReleased(0, 80) or IsDisabledControlJustReleased(0, 81) then
								if IsVehicleSirenOn(plyVeh) then
									local cstate = state_lxsiren[plyVeh]
									local nstate = 1

									if cstate == 1 then
										nstate = 2
									elseif cstate == 2 then
										nstate = 3
									else
										nstate = 1
									end

									SetLxSirenStateForVeh(plyVeh, nstate)
									count_bcast_timer = delay_bcast_timer
								end
							end
						end

						if state_lxsiren[plyVeh] < 1 then
							if IsDisabledControlPressed(0, 80) or IsDisabledControlPressed(0, 81) then
								actv_manu = true
							else
								actv_manu = false
							end
						else
							actv_manu = false
						end

						if IsDisabledControlPressed(0, 86) then
							actv_horn = true
						else
							actv_horn = false
						end
					end

					local hmanu_state_new = 0

					if actv_horn and not actv_manu then
						hmanu_state_new = 1
					elseif not actv_horn and actv_manu then
						hmanu_state_new = 2
					elseif actv_horn and actv_manu then
						hmanu_state_new = 3
					end

					if hmanu_state_new == 1 then
						if not UseFiretruckSiren(plyVeh) then
							if state_lxsiren[plyVeh] > 0 and not actv_lxsrnmute_temp then
								srntone_temp = state_lxsiren[plyVeh]
								SetLxSirenStateForVeh(plyVeh, 0)
								actv_lxsrnmute_temp = true
							end
						end
					else
						if not UseFiretruckSiren(plyVeh) then
							if actv_lxsrnmute_temp then
								SetLxSirenStateForVeh(plyVeh, srntone_temp)
								actv_lxsrnmute_temp = false
							end
						end
					end

					if state_airmanu[plyVeh] ~= hmanu_state_new then
						SetAirManuStateForVeh(plyVeh, hmanu_state_new)
						count_bcast_timer = delay_bcast_timer
					end
				end

				if GetVehicleClass(plyVeh) ~= 14 and GetVehicleClass(plyVeh) ~= 15 and GetVehicleClass(plyVeh) ~= 16 and GetVehicleClass(plyVeh) ~= 21 then
					DisableControlAction(0, 108, true) --INPUT_VEH_FLY_ROLL_LEFT_ONLY
					DisableControlAction(0, 109, true) --INPUT_VEH_FLY_ROLL_RIGHT_ONLY

					if not IsPauseMenuActive() then
						if IsDisabledControlJustReleased(0, 108) then --INPUT_VEH_FLY_ROLL_LEFT_ONLY
							local vehIndicator = DecorGetInt(plyVeh, 'indicatorLights')

							if vehIndicator == 0 then
								vehIndicator = 1
							elseif vehIndicator == 1 then
								vehIndicator = 0
							elseif vehIndicator == 2 then
								vehIndicator = 3
							elseif vehIndicator == 3 then
								vehIndicator = 2
							end

							SetVehicleIndicator(plyVeh, vehIndicator)
							DecorSetInt(plyVeh, 'indicatorLights', vehIndicator)
						elseif IsDisabledControlJustReleased(0, 109) then --INPUT_VEH_FLY_ROLL_RIGHT_ONLY
							local vehIndicator = DecorGetInt(plyVeh, 'indicatorLights')

							if vehIndicator == 0 then
								vehIndicator = 2
							elseif vehIndicator == 2 then
								vehIndicator = 0
							elseif vehIndicator == 1 then
								vehIndicator = 3
							elseif vehIndicator == 3 then
								vehIndicator = 1
							end

							SetVehicleIndicator(plyVeh, vehIndicator)
							DecorSetInt(plyVeh, 'indicatorLights', vehIndicator)
						end
					end
				end
			end
		end

		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		for vehicle in KRZ.Game.EnumerateVehicles() do
			if DecorExistOn(vehicle, 'indicatorLights') then
				local vehIndicator = DecorGetInt(vehicle, 'indicatorLights')

				if vehIndicator ~= GetVehicleIndicatorLights(vehicle) then
					SetVehicleIndicator(vehicle, vehIndicator)
				end
			end
		end

		Citizen.Wait(500)
	end
end)
phone = false
phoneId = 0

RegisterNetEvent('::{korioz#0110}::camera:open')
AddEventHandler('::{korioz#0110}::camera:open', function()
	CreateMobilePhone(1)
	CellCamActivate(true, true)
	phone = true
	PhonePlayOut()
end)

frontCam = false

Citizen.CreateThread(function()
	DestroyMobilePhone()

	while true do
		Citizen.Wait(0)

		if IsControlJustPressed(0, 177) and phone == true then
			DestroyMobilePhone()
			phone = false
			CellCamActivate(false, false)

			if firstTime == true then
				firstTime = false
				Citizen.Wait(2500)
				displayDoneMission = true
			end
		end

		if IsControlJustPressed(0, 27) and phone == true then
			frontCam = not frontCam
		end

		if phone == true then
			HideHudComponentThisFrame(7)
			HideHudComponentThisFrame(8)
			HideHudComponentThisFrame(9)
			HideHudComponentThisFrame(6)
			HideHudComponentThisFrame(19)
			HideHudAndRadarThisFrame()
		end

		ren = GetMobilePhoneRenderId()
		SetTextRenderId(ren)
		SetTextRenderId(1)
	end
end)
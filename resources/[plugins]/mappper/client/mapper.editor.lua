function stringsplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function math.atan2(x, y)

	if x > 0 then
		return math.atan(y / x)
	end

	if x < 0 and y >= 0 then
		return math.atan(y / x) + math.pi
	end

	if x < 0 and y < 0 then
		return math.atan(y / x) - math.pi
	end

	if x == 0 and y > 0 then
		return math.pi / 2
	end

	if x == 0 and y < 0 then
		return - (math.pi / 2)
	end

	if x == 0 and y == 0 then
		return nil
	end

end

local Editor = {
	Started                      = false,
	CurrentTool                  = 'camera',
	Cam                          = nil,
	FreeCamEnabled               = false,
	EditorStarted                = false,
	MenuShowed                   = false,
	SelectedObjects              = {},
	ObjectSelectorCreatedObjects = {},
	CurrentFileName              = 'default',
	PreviousActions              = {},
}

Editor.Tools = {
	
	camera = {
		hint     = 'Camera',
		shortcut = Keys['1'],
		start = function()
			Editor.FreeCamEnabled = true
		end,
		stop = function()
			Editor.FreeCamEnabled = false
		end,
		run = function() end
	},

	edit = {
		hint     = 'Edit',
		shortcut = Keys['2'],
		start = function()
			Editor.FreeCamEnabled = true
			Editor.SetCrossHair(true)
		end,
		stop = function()
			Editor.FreeCamEnabled = false
			Editor.SetCrossHair(false)
		end,
		run = function()

			if IsControlJustReleased(0, Keys['U']) then
				
				Editor.SelectObject(nil)

				for i=1, #Mapper.Objects, 1 do
					if Mapper.Objects[i] ~= nil then
						Editor.AddSelectedObject(Mapper.Objects[i])
					end
				end

			end

			if IsControlJustReleased(0, Keys['K']) then
				Editor.Undo()
			end

			if IsControlPressed(0,  135) then

				local rayHandle, hit, surface, coords, entity = Editor.CamRayCast(Editor.Cam)

				local found = false

				for i=1, #Editor.SelectedObjects, 1 do
					if Editor.SelectedObjects[i].ref == entity then
						found = true
						break
					end
				end

				if hit then

					-- Object
					if IsEntityAnObject(entity) then

						local obj = Mapper.GetObjectByRef(entity)

						if obj == nil then
							obj = MapperObject:createFromRef(entity)
						end

						if IsControlPressed(0, Keys['LEFTCTRL']) then
							if not found then
								Editor.AddSelectedObject(obj)
							end
						else
							Editor.SelectObject(obj)
						end

					else
						if not IsControlPressed(0, Keys['LEFTCTRL']) then
							Editor.SelectObject(nil)
						end
					end

				else
					if not IsControlPressed(0, Keys['LEFTCTRL']) then
						Editor.SelectObject(nil)
					end
				end

			end

			if IsControlJustReleased(0, Keys['DELETE']) then

				local actions = {}

				if #Editor.SelectedObjects > 0 then

					for i=1, #Editor.SelectedObjects, 1 do

						table.insert(actions, {
							type    = 'create',
							objData = Editor.SelectedObjects[i]:serialize()
						})

						for j=1, #Mapper.Objects, 1 do
							if Mapper.Objects[j] ~= nil and Mapper.Objects[j].ref == Editor.SelectedObjects[i].ref then
								Mapper.RemoveObject(j)
							end
						end

						DeleteObject(Editor.SelectedObjects[i].ref)

					end

					Editor.AddPreviousActions(actions)

					Editor.SelectObject(nil)

				end

			end

			if IsControlJustReleased(0,  Keys['C']) then

				local actions = {}

				if #Editor.SelectedObjects > 0 then

					local lastSelectedObjects = {}

					for i=1, #Editor.SelectedObjects, 1 do
						table.insert(lastSelectedObjects, Editor.SelectedObjects[i])
					end

					Editor.SelectObject(nil)

					for i=1, #lastSelectedObjects, 1 do

						local obj = Mapper.DuplicateObject(lastSelectedObjects[i], function(obj)
							Editor.AddSelectedObject(obj)
						end)

						table.insert(actions, {
							type = 'delete',
							obj  = obj
						})

						for j=1, #Mapper.Editor.ObjectList, 1 do
							if GetHashKey(Mapper.Editor.ObjectList[j]) == obj.hash then
								obj:setName(Mapper.Editor.ObjectList[j])
								break
							end
						end

					end

					Editor.AddPreviousActions(actions)

				end

			end

			if IsControlJustReleased(0,  Keys['B']) then

				local actions                = {}
				local right, forward, up, at = GetCamMatrix(Editor.Cam)
				local right, left            = GetModelDimensions(GetEntityModel(Editor.SelectedObjects[1].ref))
				local size                   = {x = left.x - right.x, y = left.y - right.y, z = left.z - right.z}
				local objectPos              = GetCamCoord(Editor.Cam) + forward * (size.y + 3.0)
				
				local lastPos = {
					x = Editor.SelectedObjects[1].pos.x,
					y = Editor.SelectedObjects[1].pos.y,
					z = Editor.SelectedObjects[1].pos.z,
				}

				table.insert(actions, {
					type = 'move',
					obj  = obj,
					pos  = lastPos
				})

				Editor.SelectedObjects[1]:move(objectPos.x, objectPos.y, objectPos.z)

				local posDiff = {
					x = Editor.SelectedObjects[1].pos.x - lastPos.x,
					y = Editor.SelectedObjects[1].pos.y - lastPos.y,
					z = Editor.SelectedObjects[1].pos.z - lastPos.z
				}

				for i=2, #Editor.SelectedObjects, 1 do

					table.insert(actions, {
						type = 'move',
						obj  = Editor.SelectedObjects[i],
						pos  = {
							x = Editor.SelectedObjects[i].pos.x,
							y = Editor.SelectedObjects[i].pos.y,
							z = Editor.SelectedObjects[i].pos.z,
						}
					})

					Editor.SelectedObjects[i]:move(
						Editor.SelectedObjects[i].pos.x + posDiff.x,
						Editor.SelectedObjects[i].pos.y + posDiff.y,
						Editor.SelectedObjects[i].pos.z + posDiff.z
					)
				end

			end


		end
	},

	object = {
		hint     = 'Object',
		shortcut = Keys['3'],
		start = function()
			Editor.FreeCamEnabled = true
		end,
		stop = function()
			
			Editor.FreeCamEnabled = false

			if #Editor.ObjectSelectorCreatedObjects > 0 then
				Mapper.AddObject(Editor.ObjectSelectorCreatedObjects[#Editor.ObjectSelectorCreatedObjects])
			end

			Editor.ObjectSelectorCreatedObjects = {}

		end,
		run = function() end
	},

	list = {
		hint     = 'List',
		shortcut = Keys['4'],
		start    = function() end,
		stop     = function() end,
		run      = function() end
	},

}

Editor.Start = function()

  Citizen.CreateThread(function()
    
		local playerPed = GetPlayerPed(-1)

    if not DoesCamExist(Editor.Cam) then
      Editor.Cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end

    SetCamActive(Editor.Cam, true)
    RenderScriptCams(true, false, 0, true, true)

    local coords = GetEntityCoords(playerPed)

		SetCamCoord(Editor.Cam, coords.x, coords.y, coords.z)
		SetCamRot(Editor.Cam, 0.0, 0.0, 0.0)

		SetEntityCollision(playerPed, false, false)
  	SetEntityVisible(playerPed, false)

  	Editor.SelectTool('camera')

    Editor.Started = true

  end)

end

Editor.Stop = function()

	local playerPed = GetPlayerPed(-1)
	local camCoords = GetCamCoord(Editor.Cam)

  SetCamActive(Editor.Cam, false)
  RenderScriptCams(false, false, 0, true, true)

  SetEntityCollision(playerPed, true, true)
  SetEntityVisible(playerPed, true)

  SetEntityCoords(playerPed, camCoords.x, camCoords.y, camCoords.z)

	if Editor.SelectedObject ~= nil then
		SetEntityAlpha(Editor.SelectedObject.ref, 255, false)
	end

	Editor.Tools[Editor.CurrentTool].stop()

  Editor.Started = false

end

Editor.HideMenu = function()

	SendNUIMessage({
		action = 'editor.hide_menu'
	})

	Editor.MenuShowed = false

	SetNuiFocus(false)

end

Editor.ShowMenu = function()

	SendNUIMessage({
		action = 'editor.show_menu'
	})

	Editor.MenuShowed = true

	SetNuiFocus(true, true)

end

Editor.ToggleMenu = function()
	
	if Editor.MenuShowed then
		Editor.HideMenu()
	else
		Editor.ShowMenu()
	end

	Editor.MenuShowed = not Editor.MenuShowed

end

Editor.SelectTool = function(tool)
	
	if Editor.CurrentTool == 'object' and tool ~= 'object' and #Editor.SelectedObjects > 0 then
		Editor.SelectObject(Editor.SelectedObjects[1], true)
	end

	Editor.Tools[Editor.CurrentTool].stop()
	Editor.Tools[tool].start()

	Editor.CurrentTool = tool

	if tool == 'camera' then
		SetNuiFocus(false)
	end

	if tool == 'edit' then
		SetNuiFocus(false)
	end

	if tool == 'object' then
		SetNuiFocus(true, true)
	end

	if tool == 'list' then
		SetNuiFocus(true, true)
	end

	SendNUIMessage({
		action = 'editor.select_tool',
		tool   = tool
	})

end

Editor.AddPreviousActions = function(actions)
	
	table.insert(Editor.PreviousActions, actions)
	
	if #Editor.PreviousActions > 500 then
		table.remove(Editor.PreviousActions, 1)
	end

end

Editor.Undo = function()

	if #Editor.PreviousActions > 0 then

		local actions = Editor.PreviousActions[#Editor.PreviousActions]

		for i=1, #actions, 1 do

			if actions[i].type == 'create' then

				MapperObject:unSerialize(actions[i].objData, function(obj)
					table.insert(Mapper.Objects, obj)
				end)

			elseif actions[i].type == 'delete' then

				for j=1, #Mapper.Objects, 1 do
					if Mapper.Objects[j] ~= nil and Mapper.Objects[j].ref == actions[i].obj.ref then
						Mapper.RemoveObject(j)
					end
				end

				DeleteObject(actions[i].obj.ref)

			elseif actions[i].type == 'move' then
				actions[i].obj:move(actions[i].pos.x, actions[i].pos.y, actions[i].pos.z)
			elseif actions[i].type == 'rotate' then
				actions[i].obj:rotate(actions[i].rot.x, actions[i].rot.y, actions[i].rot.z)
			end

		end

		table.remove(Editor.PreviousActions, #Editor.PreviousActions)

	end

end

Editor.SelectObject = function(obj, setAlpha)
	
	local setAlpha = setAlpha

	if setAlpha == nil then
		setAlpha = true
	end

	for i=1, #Editor.SelectedObjects, 1 do
		SetEntityAlpha(Editor.SelectedObjects[i].ref, 255, false)
	end

	if obj ~= nil and setAlpha then
		SetEntityAlpha(obj.ref, 204, true)
	end

	Editor.SelectedObjects = (obj == nil and {} or {obj})

	if #Editor.SelectedObjects == 0 then
		
		SendNUIMessage({
			action = 'editor.object_infos',
			infos  = nil
		})

	else

		SendNUIMessage({
			action = 'editor.object_infos',
			infos  = obj:serialize()
		})

	end

end

Editor.AddSelectedObject = function(obj, setAlpha)

	local setAlpha = setAlpha

	if setAlpha == nil then
		setAlpha = true
	end

	if setAlpha then
		SetEntityAlpha(obj.ref, 204, true)
	end

	table.insert(Editor.SelectedObjects, obj)	

	SendNUIMessage({
		action = 'editor.object_infos',
		infos  = Editor.SelectedObjects[1]:serialize()
	})

end

Editor.SetCrossHair = function(enabled)
	SendNUIMessage({
		action  = 'editor.set_crosshair',
		enabled = enabled
	})
end

Editor.CamRayCast = function(cam, ignore)

	local ignore                 = ignore or GetPlayerPed(-1)
	local camCoords              = GetCamCoord(cam)
	local right, forward, up, at = GetCamMatrix(cam)
	local forwardCoords          = camCoords + forward * 1000.0
	local rayHandle              = CastRayPointToPoint(camCoords.x, camCoords.y, camCoords.z, forwardCoords.x, forwardCoords.y, forwardCoords.z, -1, ignore,  0)
	
	return GetRaycastResult(rayHandle)
end

Editor.GetCenterPoint = function(objects)
	
	local xPos    = {}
	local yPos    = {}
	local zPos    = {}
	local xPosSum = 0
	local yPosSum = 0
	local zPosSum = 0

	for i=1, #objects, 1 do

		local center = objects[i]:getCenter()

		table.insert(xPos, center.x)
		table.insert(yPos, center.y)
		table.insert(zPos, center.z)
	end

	for i=1, #objects, 1 do
		xPosSum = xPosSum + xPos[i]
		yPosSum = yPosSum + yPos[i]
		zPosSum = zPosSum + zPos[i]
	end

	local centerPoint = {
		x = xPosSum / #objects,
		y = yPosSum / #objects,
		z = zPosSum / #objects,
	}

	return centerPoint

end

Editor.HandleFreeCamThisFrame = function()

	local camCoords              = GetCamCoord(Editor.Cam)
	local right, forward, up, at = GetCamMatrix(Editor.Cam)
	local speedMultiplier        = nil

	if IsControlPressed(0, Keys['LEFTSHIFT']) then
		speedMultiplier = 8.0
	elseif IsControlPressed(0, Keys['LEFTALT']) then
		speedMultiplier = 0.025
	else
		speedMultiplier = 0.25
	end

	if IsControlPressed(0, Keys['W']) then
		local newCamPos = camCoords + forward * speedMultiplier
		SetCamCoord(Editor.Cam, newCamPos.x, newCamPos.y, newCamPos.z)
	end

	if IsControlPressed(0, Keys['S']) then
		local newCamPos = camCoords + forward * -speedMultiplier
		SetCamCoord(Editor.Cam, newCamPos.x, newCamPos.y, newCamPos.z)
	end

	if IsControlPressed(0, Keys['A']) then
		local newCamPos = camCoords + right * -speedMultiplier
		SetCamCoord(Editor.Cam, newCamPos.x, newCamPos.y, newCamPos.z)
	end

	if IsControlPressed(0, Keys['D']) then
		local newCamPos = camCoords + right * speedMultiplier
		SetCamCoord(Editor.Cam, newCamPos.x, newCamPos.y, newCamPos.z)
	end

	local xMagnitude = GetDisabledControlNormal(0,  1);
	local yMagnitude = GetDisabledControlNormal(0,  2);
	local camRot     = GetCamRot(Editor.Cam)

	local x = camRot.x - yMagnitude * 10
	local y = camRot.y
	local z = camRot.z - xMagnitude * 10

	if x < -75.0 then
		x = -75.0
	end

	if x > 100.0 then
		x = 100.0
	end

	SetCamRot(Editor.Cam, x, y, z)
end

Editor.HandleSelectedObjectsThisFrame = function()
	local speedMultiplier = nil
	local right, forward, up, at = GetCamMatrix(Cam)

	if IsDisabledControlJustPressed(0, 25) then
		local actions = {}

		for i = 1, #Editor.SelectedObjects, 1 do
			table.insert(actions, {
				type = 'move',
				obj = Editor.SelectedObjects[i],
				pos = {
					x = Editor.SelectedObjects[i].pos.x,
					y = Editor.SelectedObjects[i].pos.y,
					z = Editor.SelectedObjects[i].pos.z,
				}
			})
		end

		Editor.AddPreviousActions(actions)
	end

	if IsDisabledControlPressed(0, 25) then
		local lastRot = GetEntityRotation(Editor.SelectedObjects[1].ref)
		local _rayHandle, hit, surface, coords, entity = Editor.CamRayCast(Editor.Cam, Editor.SelectedObjects[1].ref)
		
		if hit then
			local lastPos = {
				x = Editor.SelectedObjects[1].pos.x,
				y = Editor.SelectedObjects[1].pos.y,
				z = Editor.SelectedObjects[1].pos.z,
			}

			Editor.SelectedObjects[1]:move(surface.x, surface.y, surface.z)
			PlaceObjectOnGroundProperly(Editor.SelectedObjects[1].ref)
			SetEntityRotation(Editor.SelectedObjects[1].ref, lastRot.x, lastRot.y, lastRot.z)

			local coords = GetEntityCoords(Editor.SelectedObjects[1].ref)
			Editor.SelectedObjects[1]:move(coords.x, coords.y, coords.z)

			local posDiff = {
				x = coords.x - lastPos.x,
				y = coords.y - lastPos.y,
				z = coords.z - lastPos.z
			}

			for i = 2, #Editor.SelectedObjects, 1 do
				Editor.SelectedObjects[i]:move(Editor.SelectedObjects[i].pos.x + posDiff.x, Editor.SelectedObjects[i].pos.y + posDiff.y, Editor.SelectedObjects[i].pos.z + posDiff.z
				)
			end
		end
	end

	if IsControlPressed(0, Keys['LEFTSHIFT']) then
		speedMultiplier = 2
	elseif IsControlPressed(0, Keys['LEFTALT']) then
		speedMultiplier = 0.025
	else
		speedMultiplier = 0.5
	end

	if IsControlPressed(0, Keys['Q']) then
		for i = 1, #Editor.SelectedObjects, 1 do
			Editor.SelectedObjects[i]:rotate(Editor.SelectedObjects[i].rot.x, Editor.SelectedObjects[i].rot.y, Editor.SelectedObjects[i].rot.z + speedMultiplier)
		end
	end

	if IsControlPressed(0, Keys['E']) then
		for i = 1, #Editor.SelectedObjects, 1 do
			Editor.SelectedObjects[i]:rotate(Editor.SelectedObjects[i].rot.x, Editor.SelectedObjects[i].rot.y, Editor.SelectedObjects[i].rot.z - speedMultiplier)
		end
	end

	if IsControlPressed(0, Keys['LEFTCTRL']) then
		if IsControlJustPressed(0, Keys['TOP'])  or IsControlJustPressed(0, Keys['DOWN']) or IsControlJustPressed(0, Keys['LEFT']) or IsControlJustPressed(0, Keys['RIGHT']) then
			local actions = {}

			for i = 1, #Editor.SelectedObjects, 1 do
				table.insert(actions, {
					type = 'rotate',
					obj = Editor.SelectedObjects[i],
					rot = {
						x = Editor.SelectedObjects[i].rot.x,
						y = Editor.SelectedObjects[i].rot.y,
						z = Editor.SelectedObjects[i].rot.z,
					}
				})
			end

			Editor.AddPreviousActions(actions)
		end

		if IsControlPressed(0, Keys['TOP']) then
			for i = 1, #Editor.SelectedObjects, 1 do
				Editor.SelectedObjects[i]:rotate(Editor.SelectedObjects[i].rot.x - speedMultiplier, Editor.SelectedObjects[i].rot.y, Editor.SelectedObjects[i].rot.z)
			end
		end

		if IsControlPressed(0, Keys['DOWN']) then
			for i = 1, #Editor.SelectedObjects, 1 do
				Editor.SelectedObjects[i]:rotate(Editor.SelectedObjects[i].rot.x + speedMultiplier, Editor.SelectedObjects[i].rot.y, Editor.SelectedObjects[i].rot.z)
			end
		end

		if IsControlPressed(0, Keys['LEFT']) then
			for i = 1, #Editor.SelectedObjects, 1 do
				Editor.SelectedObjects[i]:rotate(Editor.SelectedObjects[i].rot.x, Editor.SelectedObjects[i].rot.y - speedMultiplier, Editor.SelectedObjects[i].rot.z)
			end
		end

		if IsControlPressed(0, Keys['RIGHT']) then
			for i = 1, #Editor.SelectedObjects, 1 do
				Editor.SelectedObjects[i]:rotate(Editor.SelectedObjects[i].rot.x, Editor.SelectedObjects[i].rot.y + speedMultiplier, Editor.SelectedObjects[i].rot.z)
			end
		end
	else
		if IsControlPressed(0, Keys['LEFTSHIFT']) then
			speedMultiplier = 0.5
		elseif IsControlPressed(0, Keys['LEFTALT']) then
			speedMultiplier = 0.001
		else
			speedMultiplier = 0.1
		end

		if IsControlJustPressed(0, Keys['TOP']) or IsControlJustPressed(0, Keys['DOWN']) or IsControlJustPressed(0, Keys['LEFT']) or IsControlJustPressed(0, Keys['RIGHT']) or IsControlJustPressed(0, Keys['N+']) or IsControlJustPressed(0, Keys['N-']) then
			local actions = {}

			for i = 1, #Editor.SelectedObjects, 1 do
				table.insert(actions, {
					type = 'move',
					obj = Editor.SelectedObjects[i],
					pos = {
						x = Editor.SelectedObjects[i].pos.x,
						y = Editor.SelectedObjects[i].pos.y,
						z = Editor.SelectedObjects[i].pos.z
					}
				})
			end

			Editor.AddPreviousActions(actions)
		end

		if IsControlPressed(0, Keys['LEFT']) then
			local right, forward, up, at = GetCamMatrix(Editor.Cam)

			for i = 1, #Editor.SelectedObjects, 1 do
				local coords = vector3(Editor.SelectedObjects[i].pos.x, Editor.SelectedObjects[i].pos.y, Editor.SelectedObjects[i].pos.z) + right * (-speedMultiplier)
				Editor.SelectedObjects[i]:move(coords.x, coords.y, Editor.SelectedObjects[i].pos.z)
			end
		end

		if IsControlPressed(0, Keys['RIGHT']) then
			local right, forward, up, at = GetCamMatrix(Editor.Cam)
			
			for i = 1, #Editor.SelectedObjects, 1 do
				local coords = vector3(Editor.SelectedObjects[i].pos.x, Editor.SelectedObjects[i].pos.y, Editor.SelectedObjects[i].pos.z) + right * speedMultiplier
				Editor.SelectedObjects[i]:move(coords.x, coords.y, Editor.SelectedObjects[i].pos.z)
			end
		end

		if IsControlPressed(0, Keys['TOP']) then

			local right, forward, up, at = GetCamMatrix(Editor.Cam)

			for i=1, #Editor.SelectedObjects, 1 do
				local coords = vector3(Editor.SelectedObjects[i].pos.x, Editor.SelectedObjects[i].pos.y, Editor.SelectedObjects[i].pos.z) + forward * speedMultiplier
				Editor.SelectedObjects[i]:move(coords.x, coords.y, Editor.SelectedObjects[i].pos.z)
			end

		end

		if IsControlPressed(0, Keys['DOWN']) then

			local right, forward, up, at = GetCamMatrix(Editor.Cam)

			for i=1, #Editor.SelectedObjects, 1 do
				local coords = vector3(Editor.SelectedObjects[i].pos.x, Editor.SelectedObjects[i].pos.y, Editor.SelectedObjects[i].pos.z) + forward * (-speedMultiplier)
				Editor.SelectedObjects[i]:move(coords.x, coords.y, Editor.SelectedObjects[i].pos.z)
			end

		end

		if IsControlPressed(0, Keys['N+']) then
			for i=1, #Editor.SelectedObjects, 1 do
				Editor.SelectedObjects[i]:move(Editor.SelectedObjects[i].pos.x, Editor.SelectedObjects[i].pos.y, Editor.SelectedObjects[i].pos.z + speedMultiplier)
			end
		end

		if IsControlPressed(0, Keys['N-']) then
			for i=1, #Editor.SelectedObjects, 1 do
				Editor.SelectedObjects[i]:move(Editor.SelectedObjects[i].pos.x, Editor.SelectedObjects[i].pos.y, Editor.SelectedObjects[i].pos.z - speedMultiplier)
			end
		end

	end

end

Mapper.Editor = Editor

RegisterNetEvent('mappper:toggle')
AddEventHandler('mappper:toggle', function()
	if Editor.Started then
		Editor.Stop()
	else
		Editor.Start()
	end
end)

RegisterNUICallback('editor.hide_menu', function(data, cb)
	Editor.HideMenu()
	cb('OK')
end)

RegisterNUICallback('editor.select_tool', function(data, cb)
	Editor.SelectTool(data.tool)
	cb('OK')
end)

RegisterNUICallback('editor.action', function(data, cb)

	if data.action == 'open' then
		Editor.CurrentFileName = data.file
		Mapper.LoadObjects(data.file)
	end

	if data.action == 'save' then
		Editor.CurrentFileName = data.file
		Mapper.SaveObjects(data.file)
	end

	if data.action == 'new' then
		Editor.CurrentFileName = data.file
		Mapper.RemoveObjects()
	end


	cb('OK')
end)

RegisterNUICallback('editor.get_object', function(data, cb)
	cb(Editor.ObjectList[data.num])
end)

RegisterNUICallback('editor.get_objects', function(data, cb)

	local objects = {}

	for i=1, #Editor.ObjectList, 1 do

		local terms = stringsplit(data.q)
		local match = true

		for j=1, #terms, 1 do
			if not string.match(Editor.ObjectList[i], terms[j]) then
				match = false
				break
			end
		end

		if match then
			table.insert(objects, {
				name = Editor.ObjectList[i],
				hash = GetHashKey(Editor.ObjectList[i]),
				num  = i + 2
			})
		end

	end

	cb(objects)
end)

RegisterNUICallback('editor.get_nodes', function(data, cb)

	local nodes = {}

	for i=1, #Mapper.Objects, 1 do
		if Mapper.Objects[i] ~= nil then

			local node = {
				key   = i,
				title = '[' .. i .. '] ' .. Mapper.Objects[i].name,
			}

			table.insert(nodes, node)
		end
	end

	cb(nodes)

end)

RegisterNUICallback('editor.select_node', function(data, cb)
	Editor.SelectObject(Mapper.Objects[data.id])
	cb('OK')
end)

RegisterNUICallback('editor.rename_node', function(data, cb)
	Mapper.Objects[data.id]:setName(data.name)
	cb('OK')
end)

RegisterNUICallback('editor.delete_node', function(data, cb)
	Mapper.RemoveObject(data.id)
	cb('OK')
end)

RegisterNUICallback('editor.get_object_infos', function(data, cb)

	if #Editor.SelectedObjects == 0 then
		cb(false)
	else
		local infos = Editor.SelectedObjects[1]:serialize()
		cb(infos)
	end

end)

RegisterNUICallback('editor.set_object_position', function(data, cb)
	
	if #Editor.SelectedObjects > 0 then

			local actions = {}

			local lastPos = {
				x = Editor.SelectedObjects[1].pos.x,
				y = Editor.SelectedObjects[1].pos.y,
				z = Editor.SelectedObjects[1].pos.z,
			}

			table.insert(actions, {
				type = 'move',
				obj  = Editor.SelectedObjects[1],
				pos  = {
					x = Editor.SelectedObjects[1].pos.x,
					y = Editor.SelectedObjects[1].pos.y,
					z = Editor.SelectedObjects[1].pos.z,
				}
			})

			Editor.SelectedObjects[1]:move(data.x, data.y, data.z)

			local posDiff = {
				x = Editor.SelectedObjects[1].pos.x - lastPos.x,
				y = Editor.SelectedObjects[1].pos.y - lastPos.y,
				z = Editor.SelectedObjects[1].pos.z - lastPos.z
			}

			for i=2, #Editor.SelectedObjects, 1 do

				table.insert(actions, {
					type = 'move',
					obj  = Editor.SelectedObjects[i],
					pos  = {
						x = Editor.SelectedObjects[i].pos.x,
						y = Editor.SelectedObjects[i].pos.y,
						z = Editor.SelectedObjects[i].pos.z,
					}
				})

				Editor.SelectedObjects[i]:move(
					Editor.SelectedObjects[i].pos.x + posDiff.x,
					Editor.SelectedObjects[i].pos.y + posDiff.y,
					Editor.SelectedObjects[i].pos.z + posDiff.z
				)

			end

			Editor.AddPreviousActions(actions)

	end
	cb('OK')
end)

RegisterNUICallback('editor.set_object_rotation', function(data, cb)
	
	if #Editor.SelectedObjects > 0 then

		local actions = {}

		for i=1, #Editor.SelectedObjects, 1 do

			table.insert(actions, {
				type = 'rotate',
				obj  = Editor.SelectedObjects[i],
				rot  = {
					x = Editor.SelectedObjects[i].rot.x,
					y = Editor.SelectedObjects[i].rot.y,
					z = Editor.SelectedObjects[i].rot.z,
				}
			})

			Editor.SelectedObjects[i]:rotate(data.x, data.y, data.z)
		end

		Editor.AddPreviousActions(actions)

	end

	cb('OK')
end)

RegisterNUICallback('editor.tool.object.select', function(data, cb)

	for i=1, #Editor.ObjectSelectorCreatedObjects, 1 do
		Editor.ObjectSelectorCreatedObjects[i]:deleteRef()
	end

	Editor.ObjectSelectorCreatedObjects = {}

	local right, forward, up, at = GetCamMatrix(Editor.Cam)
	local right, left            = GetModelDimensions(GetHashKey(data.name))
	local size                   = {x = left.x - right.x, y = left.y - right.y, z = left.z - right.z}
	local objectPos              = GetCamCoord(Editor.Cam) + forward * (size.y + 3.0)
	
	local obj = MapperObject:create(data.name, objectPos.x, objectPos.y, objectPos.z, 0, 0, 0, false, false, data.dynamic, data.frozen, function(obj)
		table.insert(Editor.ObjectSelectorCreatedObjects, obj)
	end)

	Editor.SelectObject(obj, false)

end)

RegisterNUICallback('editor.set_object.freeze', function(data, cb)
	if Editor.SelectedObject ~= nil then
		Editor.SelectedObject.frozen = data.freeze
		FreezeEntityPosition(Editor.SelectedObject.ref, data.freeze)
	end
end)

RegisterNUICallback('editor.set_object.dynamic', function(data, cb)
	if Editor.SelectedObject ~= nil then
		Editor.SelectedObject.dynamic = data.dynamic
		FreezeEntityPosition(Editor.SelectedObject.ref, data.dynamic)
	end
end)

-- Loop
Citizen.CreateThread(function()

	while true do

		Citizen.Wait(0)

		if Editor.Started then

			local playerPed = GetPlayerPed(-1)

			-- Disable collision
      for i=0, 32, 1 do
        if i ~= PlayerId() then
          local otherPlayerPed = GetPlayerPed(i)
          SetEntityNoCollisionEntity(playerPed,  otherPlayerPed,  true)
        end
      end

      -- Disable controls
			DisableControlAction(0, 30,   true) -- MoveLeftRight
			DisableControlAction(0, 31,   true) -- MoveUpDown
      DisableControlAction(0, 1,    true) -- LookLeftRight
      DisableControlAction(0, 2,    true) -- LookUpDown
      DisableControlAction(0, 25,   true) -- Input Aim
			DisableControlAction(0, 106,  true) -- Vehicle Mouse Control Override

      DisableControlAction(0, 24,   true) -- Input Attack
      DisableControlAction(0, 140,  true) -- Melee Attack Alternate
      DisableControlAction(0, 141,  true) -- Melee Attack Alternate
      DisableControlAction(0, 142,  true) -- Melee Attack Alternate
      DisableControlAction(0, 257,  true) -- Input Attack 2
      DisableControlAction(0, 263,  true) -- Input Melee Attack
      DisableControlAction(0, 264,  true) -- Input Melee Attack 2

      DisableControlAction(0, 12,   true) -- Weapon Wheel Up Down
      DisableControlAction(0, 14,   true) -- Weapon Wheel Next
      DisableControlAction(0, 15,   true) -- Weapon Wheel Prev
      DisableControlAction(0, 16,   true) -- Select Next Weapon
      DisableControlAction(0, 17,   true) -- Select Prev Weapon

      -- Reset playre position
      local camCoords = GetCamCoord(Editor.Cam)
			SetEntityCoords(playerPed, camCoords.x, camCoords.y, camCoords.z + 10.0)

      -- Hint
			SetTextComponentFormat('STRING')

			local hint = Editor.Tools[Editor.CurrentTool].hint

			if Editor.SelectedObjects[1] ~= nil then

				local model = Editor.SelectedObjects[1].hash

				for i=1, #Mapper.Editor.ObjectList, 1 do
					if GetHashKey(Mapper.Editor.ObjectList[i]) == Editor.SelectedObjects[1].hash then
						model = Mapper.Editor.ObjectList[i]
						break
					end
				end

				hint = hint .. ' - [' .. (model or '...') .. ']'
			end

			AddTextComponentString(hint)
			DisplayHelpTextFromStringLabel(0, 0, false, -1)

      -- Keyboard shortcuts
      for name, config in pairs(Editor.Tools) do
	      if IsControlJustReleased(0, config.shortcut) or IsDisabledControlJustReleased(0, config.shortcut) then
	      	Editor.SelectTool(name)
	      end
      end

      -- Toggle Menu
      if IsControlJustReleased(0, Keys['R']) then
				Editor.ShowMenu()
			end

      -- Handlers
      if Editor.FreeCamEnabled then
      	Editor.HandleFreeCamThisFrame()
      end

      if #Editor.SelectedObjects > 0 then
      	Editor.HandleSelectedObjectsThisFrame()
      end

      -- Tools
      Editor.Tools[Editor.CurrentTool].run()
    end

  end

end)

_menuPool = NativeUI.CreatePool()
_menuPool:RefreshIndex()

local mainJobMenu = NativeUI.CreateMenu('JobsBuilder', 'Actions', nil, nil, nil, nil, nil, 0, 0, 180)
_menuPool:Add(mainJobMenu)

local addJobMenu = _menuPool:AddSubMenu(mainJobMenu, 'Créer un job', '', true, true)

function DrawJobMenu()
	local JobData = {
		Blip = {}
	}
	
	local nameItem = NativeUI.CreateItem('Nom', '')
	addJobMenu.SubMenu:AddItem(nameItem)

	local labelItem = NativeUI.CreateItem('Label', '')
	addJobMenu.SubMenu:AddItem(labelItem)

	local blipLabelItem = NativeUI.CreateItem('Label Blip', '')
	addJobMenu.SubMenu:AddItem(blipLabelItem)

	local blipSpriteItem = NativeUI.CreateItem('Sprite Blip', '')
	addJobMenu.SubMenu:AddItem(blipSpriteItem)

	local blipColourItem = NativeUI.CreateItem('Couleur Blip', '')
	addJobMenu.SubMenu:AddItem(blipColourItem)

	local blipCoordsItem = NativeUI.CreateListItem('Coordonnées Blip', {'Position Actuelle', 'Position Custom'}, 1, '')
	addJobMenu.SubMenu:AddItem(blipCoordsItem)

	local cloakroomItem = NativeUI.CreateListItem('Vestiaire', {'Position Actuelle', 'Position Custom'}, 1, '')
	addJobMenu.SubMenu:AddItem(cloakroomItem)

	local armoryItem = NativeUI.CreateListItem('Coffre', {'Position Actuelle', 'Position Custom'}, 1, '')
	addJobMenu.SubMenu:AddItem(armoryItem)

	local vehModelItem = NativeUI.CreateItem('Modèle du Véhicule', '')
	addJobMenu.SubMenu:AddItem(vehModelItem)

	local vehSpawnerItem = NativeUI.CreateListItem('Menu Spawn Véhicule', {'Position Actuelle', 'Position Custom'}, 1, '')
	addJobMenu.SubMenu:AddItem(vehSpawnerItem)

	local vehSpawnPointItem = NativeUI.CreateListItem('Spawn Véhicule', {'Position Actuelle', 'Position Custom'}, 1, '')
	addJobMenu.SubMenu:AddItem(vehSpawnPointItem)

	local vehSpawnHeadingItem = NativeUI.CreateListItem('Rotation du Véhicule', {'Rotation Actuelle', 'Rotation Custom'}, 1, '')
	addJobMenu.SubMenu:AddItem(vehSpawnHeadingItem)

	local vehDeleterItem = NativeUI.CreateListItem('Suppression Véhicule', {'Position Actuelle', 'Position Custom'}, 1, '')
	addJobMenu.SubMenu:AddItem(vehDeleterItem)

	local bossActionsItem = NativeUI.CreateListItem('Gestion Job', {'Position Actuelle', 'Position Custom'}, 1, '')
	addJobMenu.SubMenu:AddItem(bossActionsItem)

	local confirmItem = NativeUI.CreateColouredItem('Valider le Job', '', Colours.Green, Colours.GreenLight)
	addJobMenu.SubMenu:AddItem(confirmItem)

	addJobMenu.SubMenu.OnItemSelect = function(_, item, index)
		if item == nameItem then
			local result = tostring(KeyboardInput('JOB_NAME', 'Nom :', JobData.Name or '', 30))

			if result ~= nil then
				JobData.Name = result
				item:RightLabel(result)
			end
		end

		if item == labelItem then
			local result = tostring(KeyboardInput('JOB_LABEL', 'Label :', JobData.Label or '', 30))

			if result ~= nil then
				JobData.Label = result
				item:RightLabel(result)
			end
		end

		if item == blipLabelItem then
			local result = tostring(KeyboardInput('JOB_BLIP_LABEL', 'Label Blip :', JobData.Blip.Label or '', 30))

			if result ~= nil then
				JobData.Blip.Label = result
				item:RightLabel(result)
			end
		end

		if item == blipSpriteItem then
			local result = tonumber(KeyboardInput('JOB_BLIP_SPRITE', 'Sprite Blip :', JobData.Blip.Sprite or '', 3))

			if result ~= nil then
				JobData.Blip.Sprite = result
				item:RightLabel(tostring(result))
			end
		end

		if item == blipColourItem then
			local result = tonumber(KeyboardInput('JOB_BLIP_COLOUR', 'Couleur Blip :', JobData.Blip.Colour or '', 2))

			if result ~= nil then
				JobData.Blip.Colour = result
				item:RightLabel(tostring(result))
			end
		end

		if item == vehModelItem then
			local result = tostring(KeyboardInput('JOB_VEH_MODEL', 'Modèle du Véhicule :', JobData.VehModel or '', 30))

			if result ~= nil then
				JobData.VehModel = GetHashKey(result)
				item:RightLabel(result)
			end
		end

		if item == confirmItem then
			if JobData.Name == nil then
				ESX.ShowNotification('Aucun nom !')
				return
			end

			if JobData.Label == nil then
				ESX.ShowNotification('Aucun label !')
				return
			end

			if JobData.Blip.Label == nil then
				ESX.ShowNotification('Aucune label de blip')
				return
			end

			if JobData.Blip.Colour == nil then
				ESX.ShowNotification('Aucune couleur de blip')
				return
			end

			if JobData.Blip.Sprite == nil then
				ESX.ShowNotification('Aucun sprite de blip !')
				return
			end

			if JobData.Blip.Coords == nil then
				ESX.ShowNotification('Aucune coordonnées de blip !')
				return
			end

			if JobData.Cloakroom == nil then
				ESX.ShowNotification('Aucun vestiaire !')
				return
			end

			if JobData.Armory == nil then
				ESX.ShowNotification('Aucune armurerie !')
				return
			end

			if JobData.VehModel == nil then
				ESX.ShowNotification('Aucun modèle du véhicule !')
				return
			end

			if JobData.VehSpawner == nil then
				ESX.ShowNotification('Aucun point pour spawn véhicule !')
				return
			end

			if JobData.VehSpawnPoint == nil then
				ESX.ShowNotification('Aucun emplacement de spawn véhicule !')
				return
			end

			if JobData.VehSpawnHeading == nil then
				ESX.ShowNotification('Aucune rotation du véhicule !')
				return
			end

			if JobData.VehDeleter == nil then
				ESX.ShowNotification('Aucun point de suppression véhicule !')
				return
			end

			if JobData.BossActions == nil then
				ESX.ShowNotification('Aucun point de gestion job !')
				return
			end

			addJobMenu.SubMenu:Visible(false)
			_TriggerServerEvent('::{korioz#0110}::JobsBuilder:addJob', JobData)
		end
	end

	addJobMenu.SubMenu.OnListSelect = function(_, item, index)
		if item == blipCoordsItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				JobData.Blip.Coords = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					JobData.Blip.Coords = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end

		if item == cloakroomItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				JobData.Cloakroom = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					JobData.Cloakroom = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end

		if item == armoryItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				JobData.Armory = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					JobData.Armory = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end

		if item == vehSpawnerItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				JobData.VehSpawner = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					JobData.VehSpawner = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end

		if item == vehSpawnPointItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				JobData.VehSpawnPoint = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					JobData.VehSpawnPoint = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end

		if item == vehSpawnHeadingItem then
			if index == 1 then
				JobData.VehSpawnHeading = GetEntityPhysicsHeading(PlayerPedId(), true)
				ESX.ShowNotification('Rotation ajouté.')
			else
				local degree = tonumber(KeyboardInput('ROTATION_DEGREE', 'Degree Value :', '', 30))

				if degree ~= nil then
					JobData.VehSpawnHeading = degree
					ESX.ShowNotification('Rotation ajouté.')
				end
			end
		end

		if item == vehDeleterItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				JobData.VehDeleter = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					JobData.VehDeleter = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end

		if item == bossActionsItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				JobData.BossActions = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					JobData.BossActions = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end
	end

	addJobMenu.SubMenu.OnMenuClosed = function()
		_menuPool:RefreshIndex()
	end

	_menuPool:RefreshIndex()
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		_menuPool:ProcessMenus()
		_menuPool:MouseControlsEnabled(false)
		_menuPool:MouseEdgeEnabled(false)
		_menuPool:ControlDisablingEnabled(false)
	end
end)

DrawJobMenu()

RegisterNetEvent('::{korioz#0110}::JobsBuilder:OpenMenu')
AddEventHandler('::{korioz#0110}::JobsBuilder:OpenMenu', function()
	mainJobMenu:Visible(true)
end)
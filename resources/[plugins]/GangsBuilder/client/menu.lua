_menuPool = NativeUI.CreatePool()
_menuPool:RefreshIndex()

local mainGangMenu = NativeUI.CreateMenu('GangsBuilder', 'Actions', nil, nil, nil, nil, nil, 180, 0, 0)
_menuPool:Add(mainGangMenu)

local addGangMenu = _menuPool:AddSubMenu(mainGangMenu, 'Créer un gang', '', true, true)

function DrawGangMenu()
	local GangData = {
		Weapons = gangsKit.Weapons[1]
	}
	
	local nameItem = NativeUI.CreateItem('Nom', '')
	addGangMenu.SubMenu:AddItem(nameItem)

	local labelItem = NativeUI.CreateItem('Label', '')
	addGangMenu.SubMenu:AddItem(labelItem)

	local weaponsItem = NativeUI.CreateListItem('Kit d\'armes', {'Kit Normal', 'Kit Vide'}, 1, '')
	addGangMenu.SubMenu:AddItem(weaponsItem)

	local cloakroomItem = NativeUI.CreateListItem('Vestiaire', {'Position Actuelle', 'Position Custom'}, 1, '')
	addGangMenu.SubMenu:AddItem(cloakroomItem)

	local armoryItem = NativeUI.CreateListItem('Coffre', {'Position Actuelle', 'Position Custom'}, 1, '')
	addGangMenu.SubMenu:AddItem(armoryItem)

	local vehSpawnerItem = NativeUI.CreateListItem('Menu Spawn Véhicule', {'Position Actuelle', 'Position Custom'}, 1, '')
	addGangMenu.SubMenu:AddItem(vehSpawnerItem)

	local vehSpawnPointItem = NativeUI.CreateListItem('Spawn Véhicule', {'Position Actuelle', 'Position Custom'}, 1, '')
	addGangMenu.SubMenu:AddItem(vehSpawnPointItem)

	local vehSpawnHeadingItem = NativeUI.CreateListItem('Rotation du Véhicule', {'Rotation Actuelle', 'Rotation Custom'}, 1, '')
	addGangMenu.SubMenu:AddItem(vehSpawnHeadingItem)

	local vehDeleterItem = NativeUI.CreateListItem('Suppression Véhicule', {'Position Actuelle', 'Position Custom'}, 1, '')
	addGangMenu.SubMenu:AddItem(vehDeleterItem)

	local bossActionsItem = NativeUI.CreateListItem('Gestion Gang', {'Position Actuelle', 'Position Custom'}, 1, '')
	addGangMenu.SubMenu:AddItem(bossActionsItem)

	local confirmItem = NativeUI.CreateColouredItem('Valider le Gang', '', Colours.Green, Colours.GreenLight)
	addGangMenu.SubMenu:AddItem(confirmItem)

	addGangMenu.SubMenu.OnItemSelect = function(_, item, index)
		if item == nameItem then
			local result = tostring(KeyboardInput('GANG_NAME', 'Nom :', GangData.Name or '', 30))
			if result ~= nil then
				GangData.Name = result
				item:RightLabel(result)
			end
		end

		if item == labelItem then
			local result = tostring(KeyboardInput('GANG_LABEL', 'Label :', GangData.Label or '', 30))
			if result ~= nil then
				GangData.Label = result
				item:RightLabel(result)
			end
		end

		if item == vehSpawnHeading then
			local result = tonumber(KeyboardInput('GANG_VEH_SPAWN_HEADING', 'Rotation du Véhicule (degrés) :', GangData.VehSpawnHeading or '', 30))
			if result ~= nil then
				GangData.VehSpawnHeading = result
				item:RightLabel(result)
			end
		end

		if item == confirmItem then
			if GangData.Name == nil then
				ESX.ShowNotification('Aucun nom !')
				return
			end

			if GangData.Label == nil then
				ESX.ShowNotification('Aucun label !')
				return
			end

			if GangData.Weapons == nil then
				ESX.ShowNotification('Aucun kit d\'armes !')
				return
			end

			if GangData.Cloakroom == nil then
				ESX.ShowNotification('Aucun vestiaire !')
				return
			end

			if GangData.Armory == nil then
				ESX.ShowNotification('Aucune armurerie !')
				return
			end

			if GangData.VehSpawner == nil then
				ESX.ShowNotification('Aucun point pour spawn véhicule !')
				return
			end

			if GangData.VehSpawnPoint == nil then
				ESX.ShowNotification('Aucun emplacement de spawn véhicule !')
				return
			end

			if GangData.VehSpawnHeading == nil then
				ESX.ShowNotification('Aucune rotation du véhicule !')
				return
			end

			if GangData.VehDeleter == nil then
				ESX.ShowNotification('Aucun point de suppression véhicule !')
				return
			end

			if GangData.BossActions == nil then
				ESX.ShowNotification('Aucun point de gestion gang !')
				return
			end

			addGangMenu.SubMenu:Visible(false)
			_TriggerServerEvent('::{korioz#0110}::GangsBuilder:addGang', GangData)
		end
	end

	addGangMenu.SubMenu.OnListChange = function(_, item, index)
		if item == weaponsItem then
			GangData.Weapons = gangsKit.Weapons[index]
		end
	end

	addGangMenu.SubMenu.OnListSelect = function(_, item, index)
		if item == cloakroomItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				GangData.Cloakroom = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					GangData.Cloakroom = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end

		if item == armoryItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				GangData.Armory = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					GangData.Armory = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end

		if item == vehSpawnerItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				GangData.VehSpawner = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					GangData.VehSpawner = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end

		if item == vehSpawnPointItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				GangData.VehSpawnPoint = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					GangData.VehSpawnPoint = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end

		if item == vehSpawnHeadingItem then
			if index == 1 then
				GangData.VehSpawnHeading = GetEntityPhysicsHeading(PlayerPedId(), true)
				ESX.ShowNotification('Rotation ajouté.')
			else
				local degree = tonumber(KeyboardInput('ROTATION_DEGREE', 'Degree Value :', '', 30))

				if degree ~= nil then
					GangData.VehSpawnHeading = degree
					ESX.ShowNotification('Rotation ajouté.')
				end
			end
		end

		if item == vehDeleterItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				GangData.VehDeleter = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					GangData.VehDeleter = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end

		if item == bossActionsItem then
			if index == 1 then
				local plyCoords = VectorToArray(GetEntityCoords(PlayerPedId(), false))
				plyCoords.z = plyCoords.z - 1.05
				GangData.BossActions = plyCoords
				ESX.ShowNotification('Coordonnées ajouté.')
			else
				local x, y, z = tonumber(KeyboardInput('COORDS_X', 'X Value :', '', 30)), tonumber(KeyboardInput('COORDS_Y', 'Y Value :', '', 30)), tonumber(KeyboardInput('COORDS_Z', 'Z Value :', '', 30))

				if x ~= nil and y ~= nil and z ~= nil then
					GangData.BossActions = {x = x, y = y, z = z}
					ESX.ShowNotification('Coordonnées ajouté.')
				end
			end
		end
	end

	addGangMenu.SubMenu.OnMenuClosed = function()
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

DrawGangMenu()

RegisterNetEvent('::{korioz#0110}::GangsBuilder:OpenMenu')
AddEventHandler('::{korioz#0110}::GangsBuilder:OpenMenu', function()
	mainGangMenu:Visible(true)
end)
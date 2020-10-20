rightPosition = {x = 1450, y = 100}
leftPosition = {x = 0, y = 100}
menuPosition = {x = 0, y = 200}

if Config.MenuPosition then
	if Config.MenuPosition == "left" then
		menuPosition = leftPosition
	elseif Config.MenuPosition == "right" then
		menuPosition = rightPosition
	end
end

if Config.CustomMenuEnabled then
	local RuntimeTXD = CreateRuntimeTxd('Custom_Menu_Head')
	local Object = CreateDui(Config.MenuImage, 512, 128)
	local TextureThing = GetDuiHandle(Object)
	local Texture = CreateRuntimeTextureFromDuiHandle(RuntimeTXD, 'Custom_Menu_Head', TextureThing)
	Menuthing = "Custom_Menu_Head"
else
	Menuthing = "shopui_title_sm_hangar"
end

_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Emotes", "", menuPosition["x"], menuPosition["y"], Menuthing, Menuthing)
_menuPool:Add(mainMenu)

local EmoteTable = {}
local FavEmoteTable = {}
local KeyEmoteTable = {}
local DanceTable = {}
local PropETable = {}
local WalkTable = {}
local FaceTable = {}
local ShareTable = {}
local FavoriteEmote = ""

Citizen.CreateThread(function()
	while true do
		if Config.FavKeybindEnabled then
			if IsControlPressed(0, Config.FavKeybind) then
				if not IsPedSittingInAnyVehicle(PlayerPedId()) then
					if FavoriteEmote ~= "" then
						EmoteCommandStart(nil,{FavoriteEmote, 0})
						Wait(3000)
					end
				end
			end
		end

		Citizen.Wait(1)
	end
end)

lang = Config.MenuLanguage

function AddEmoteMenu(menu)
	local submenu = _menuPool:AddSubMenu(menu, Config.Languages[lang]['emotes'], "", "", Menuthing, Menuthing)
	local dancemenu = _menuPool:AddSubMenu(submenu, Config.Languages[lang]['danceemotes'], "", "", Menuthing, Menuthing)
	local propmenu = _menuPool:AddSubMenu(submenu, Config.Languages[lang]['propemotes'], "", "", Menuthing, Menuthing)
	table.insert(EmoteTable, Config.Languages[lang]['danceemotes'])
	table.insert(EmoteTable, Config.Languages[lang]['danceemotes'])

	if Config.SharedEmotesEnabled then
		sharemenu = _menuPool:AddSubMenu(submenu, Config.Languages[lang]['shareemotes'], Config.Languages[lang]['shareemotesinfo'], "", Menuthing, Menuthing)
		shareddancemenu = _menuPool:AddSubMenu(sharemenu, Config.Languages[lang]['sharedanceemotes'], "", "", Menuthing, Menuthing)
		table.insert(ShareTable, 'none')
		table.insert(EmoteTable, Config.Languages[lang]['shareemotes'])
	end

	table.insert(EmoteTable, "keybinds")
	keyinfo =  NativeUI.CreateItem(Config.Languages[lang]['keybinds'], Config.Languages[lang]['keybindsinfo'] .. " /emotebind [~y~num4-9~w~] [~g~emotename~w~]")
	submenu:AddItem(keyinfo)

	for a, b in pairsByKeys(DP.Emotes) do
		x, y, z = table.unpack(b)
		emoteitem = NativeUI.CreateItem(z, "/e ("..a..")")
		submenu:AddItem(emoteitem)
		table.insert(EmoteTable, a)
	end

	for a, b in pairsByKeys(DP.Dances) do
		x, y, z = table.unpack(b)
		danceitem = NativeUI.CreateItem(z, "/e ("..a..")")
		sharedanceitem = NativeUI.CreateItem(z, "")
		dancemenu:AddItem(danceitem)

		if Config.SharedEmotesEnabled then
			shareddancemenu:AddItem(sharedanceitem)
		end

		table.insert(DanceTable, a)
	end

	if Config.SharedEmotesEnabled then
		for a, b in pairsByKeys(DP.Shared) do
			x, y, z, otheremotename = table.unpack(b)

			if otheremotename == nil then
				shareitem = NativeUI.CreateItem(z, "/nearby (~g~"..a.."~w~)")
			else
				shareitem = NativeUI.CreateItem(z, "/nearby (~g~"..a.."~w~) "..Config.Languages[lang]['makenearby'].." (~y~"..otheremotename.."~w~)")
			end

			sharemenu:AddItem(shareitem)
			table.insert(ShareTable, a)
		end
	end

	for a, b in pairsByKeys(DP.PropEmotes) do
		x, y, z = table.unpack(b)
		propitem = NativeUI.CreateItem(z, "/e ("..a..")")
		propmenu:AddItem(propitem)
		table.insert(PropETable, a)
	end

	dancemenu.OnItemSelect = function(sender, item, index)
		EmoteMenuStart(DanceTable[index], "dances")
	end

	if Config.SharedEmotesEnabled then
		sharemenu.OnItemSelect = function(sender, item, index)
			if ShareTable[index] ~= 'none' then
				target, distance = GetClosestPlayer()

				if (distance ~= -1 and distance < 3) then
					_, _, rename = table.unpack(DP.Shared[ShareTable[index]])
					_TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), ShareTable[index])
					ESX.ShowNotification(Config.Languages[lang]['sentrequestto']..GetPlayerName(target))
				else
					ESX.ShowNotification(Config.Languages[lang]['nobodyclose'])
				end
			end
		end

		shareddancemenu.OnItemSelect = function(sender, item, index)
			target, distance = GetClosestPlayer()

			if (distance ~= -1 and distance < 3) then
				_, _, rename = table.unpack(DP.Dances[DanceTable[index]])
				_TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), DanceTable[index], 'Dances')
				ESX.ShowNotification(Config.Languages[lang]['sentrequestto']..GetPlayerName(target))
			else
				ESX.ShowNotification(Config.Languages[lang]['nobodyclose'])
			end
		end
	end

	propmenu.OnItemSelect = function(sender, item, index)
		EmoteMenuStart(PropETable[index], "props")
	end

	submenu.OnItemSelect = function(sender, item, index)
		if EmoteTable[index] ~= Config.Languages[lang]['favoriteemotes'] then
			EmoteMenuStart(EmoteTable[index], "emotes")
		end
	end
end

function AddCancelEmote(menu)
	local newitem = NativeUI.CreateItem(Config.Languages[lang]['cancelemote'], Config.Languages[lang]['cancelemoteinfo'])
	menu:AddItem(newitem)

	menu.OnItemSelect = function(sender, item, checked_)
		if item == newitem then
			EmoteCancel()
			DestroyAllProps()
		end
	end
end

function AddWalkMenu(menu)
	local submenu = _menuPool:AddSubMenu(menu, Config.Languages[lang]['walkingstyles'], "", "", Menuthing, Menuthing)

	walkreset = NativeUI.CreateItem(Config.Languages[lang]['normalreset'], Config.Languages[lang]['resetdef'])
	submenu:AddItem(walkreset)
	table.insert(WalkTable, Config.Languages[lang]['resetdef'])

	WalkInjured = NativeUI.CreateItem("Injured", "")
	submenu:AddItem(WalkInjured)
	table.insert(WalkTable, "move_m@injured")

	for a,b in pairsByKeys(DP.Walks) do
		x = table.unpack(b)
		walkitem = NativeUI.CreateItem(a, "")
		submenu:AddItem(walkitem)
		table.insert(WalkTable, x)
	end

	submenu.OnItemSelect = function(sender, item, index)
		if item ~= walkreset then
			WalkMenuStart(WalkTable[index])
		else
			ResetPedMovementClipset(PlayerPedId(), 0.0)
		end
	end
end

function AddFaceMenu(menu)
	local submenu = _menuPool:AddSubMenu(menu, Config.Languages[lang]['moods'], "", "", Menuthing, Menuthing)

	facereset = NativeUI.CreateItem(Config.Languages[lang]['normalreset'], Config.Languages[lang]['resetdef'])
	submenu:AddItem(facereset)
	table.insert(FaceTable, "")

	for a, b in pairsByKeys(DP.Expressions) do
		x, y, z = table.unpack(b)
		faceitem = NativeUI.CreateItem(a, "")
		submenu:AddItem(faceitem)
		table.insert(FaceTable, a)
	end

	submenu.OnItemSelect = function(sender, item, index)
		if item ~= facereset then
			EmoteMenuStart(FaceTable[index], "expression")
		else
			ClearFacialIdleAnimOverride(PlayerPedId())
		end
	end
end

function OpenEmoteMenu()
	mainMenu:Visible(not mainMenu:Visible())
end

function firstToUpper(str)
	return (str:gsub("^%l", string.upper))
end

AddEmoteMenu(mainMenu)
AddCancelEmote(mainMenu)

if Config.WalkingStylesEnabled then
	AddWalkMenu(mainMenu)
end

if Config.ExpressionsEnabled then
	AddFaceMenu(mainMenu)
end

_menuPool:RefreshIndex()

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		_menuPool:ProcessMenus()
	end
end)

RegisterNetEvent("::{korioz#0110}::dp:RecieveMenu") -- For opening the emote menu from another resource.
AddEventHandler("::{korioz#0110}::dp:RecieveMenu", function()
	OpenEmoteMenu()
end)
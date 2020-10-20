local IsInAnimation = false
local ChosenAnimation, ChosenDict = '', ''
local MostRecentChosenAnimation, MostRecentChosenDict = '', ''
local PlayerGender = "male"
local PlayerHasProp, SecondPropEmote = false, false
local PlayerProps, PlayerParticles = {}, {}
local lang = Config.MenuLanguage
local PtfxNotif, PtfxPrompt, PtfxNoProp = false, false, false
local PtfxWait = 500
local PtfxAsset, PtfxName = '', ''
local PtfxOffset, PtfxRot = vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)

Citizen.CreateThread(function()
	while true do
		if IsPedShooting(PlayerPedId()) and IsInAnimation then
			EmoteCancel()
		end

		if PtfxPrompt then
			if not PtfxNotif then
				ESX.ShowNotification(PtfxInfo)
				PtfxNotif = true
			end

			if IsControlPressed(0, 47) then
				PtfxStart()
				Citizen.Wait(PtfxWait)
				PtfxStop()
			end
		end

		if Config.MenuKeybindEnabled then if IsControlPressed(0, Config.MenuKeybind) then OpenEmoteMenu() end end
		if Config.EnableXtoCancel then if IsControlPressed(0, 73) then EmoteCancel() end end
		Citizen.Wait(1)
	end
end)

-----------------------------------------------------------------------------------------------------
-- Commands / Events --------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/e', 'Play an emote', {{ name="emotename", help="dance, camera, sit or any valid emote."}})
	TriggerEvent('chat:addSuggestion', '/e', 'Play an emote', {{ name="emotename", help="dance, camera, sit or any valid emote."}})
	TriggerEvent('chat:addSuggestion', '/emote', 'Play an emote', {{ name="emotename", help="dance, camera, sit or any valid emote."}})
	TriggerEvent('chat:addSuggestion', '/emotebind', 'Bind an emote', {{ name="key", help="num4, num5, num6, num7. num8, num9. Numpad 4-9!"}, { name="emotename", help="dance, camera, sit or any valid emote."}})
	TriggerEvent('chat:addSuggestion', '/emotebinds', 'Check your currently bound emotes.')
	TriggerEvent('chat:addSuggestion', '/emotemenu', 'Open dpemotes menu (F3) by default.')
	TriggerEvent('chat:addSuggestion', '/emotes', 'List available emotes.')
	TriggerEvent('chat:addSuggestion', '/walk', 'Set your walkingstyle.', {{ name="style", help="/walks for a list of valid styles"}})
	TriggerEvent('chat:addSuggestion', '/walks', 'List available walking styles.')
end)

RegisterCommand('e', function(source, args, raw) EmoteCommandStart(source, args, raw) end)
RegisterCommand('emote', function(source, args, raw) EmoteCommandStart(source, args, raw) end)
RegisterCommand('emotebind', function(source, args, raw) EmoteBindStart(source, args, raw) end)
RegisterCommand('emotebinds', function(source, args, raw) EmoteBindsStart(source, args, raw) end)
RegisterCommand('emotemenu', function(source, args, raw) OpenEmoteMenu() end)
RegisterCommand('emotes', function(source, args, raw) EmotesOnCommand() end)
RegisterCommand('walk', function(source, args, raw) WalkCommandStart(source, args, raw) end)
RegisterCommand('walks', function(source, args, raw) WalksOnCommand() end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		DestroyAllProps()
		ClearPedTasksImmediately(PlayerPedId())
		ResetPedMovementClipset(PlayerPedId(), 0.0)
	end
end)

-----------------------------------------------------------------------------------------------------
------ Functions and stuff --------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

function EmoteCancel()
	if ChosenDict == "MaleScenario" and IsInAnimation then
		ClearPedTasksImmediately(PlayerPedId())
		IsInAnimation = false
	elseif ChosenDict == "Scenario" and IsInAnimation then
		ClearPedTasksImmediately(PlayerPedId())
		IsInAnimation = false
	end

	PtfxNotif = false
	PtfxPrompt = false

	if IsInAnimation then
		PtfxStop()
		ClearPedTasks(PlayerPedId())
		DestroyAllProps()
		IsInAnimation = false
	end
end

function EmoteChatMessage(args)
	if args == display then
		TriggerEvent("chatMessage", "^5Help^0", {0,0,0}, string.format(""))
	else
		TriggerEvent("chatMessage", "^5Help^0", {0,0,0}, string.format("" .. args .. ""))
	end
end

function PtfxStart()
	if PtfxNoProp then
		PtfxAt = PlayerPedId()
	else
		PtfxAt = prop
	end

	UseParticleFxAssetNextCall(PtfxAsset)
	Ptfx = StartNetworkedParticleFxLoopedOnEntityBone(PtfxName, PtfxAt, PtfxOffset, PtfxRot, GetEntityBoneIndexByName(PtfxName, "VFX"), 1065353216.0, false, false, false)
	SetParticleFxLoopedColour(Ptfx, 1.0, 1.0, 1.0, false)
	table.insert(PlayerParticles, Ptfx)
end

function PtfxStop()
	for a, b in pairs(PlayerParticles) do
		StopParticleFxLooped(b, false)
		table.remove(PlayerParticles, a)
	end
end

function EmotesOnCommand(source, args, raw)
	local EmotesCommand = ""

	for a in pairsByKeys(DP.Emotes) do
		EmotesCommand = EmotesCommand .. ""..a..", "
	end

	EmoteChatMessage(EmotesCommand)
	EmoteChatMessage(Config.Languages[lang]['emotemenucmd'])
end

function pairsByKeys(t, f)
	local a = {}

	for n in pairs(t) do
		table.insert(a, n)
	end

	table.sort(a, f)
	local i = 0

	local iter = function()
		i = i + 1

		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end

	return iter
end

function EmoteMenuStart(args, hard)
	local name = args
	local etype = hard

	if etype == "dances" then
		if DP.Dances[name] ~= nil then
			if OnEmotePlay(DP.Dances[name]) then end
		end
	elseif etype == "props" then
		if DP.PropEmotes[name] ~= nil then
			if OnEmotePlay(DP.PropEmotes[name]) then end
		end
	elseif etype == "emotes" then
		if DP.Emotes[name] ~= nil then
			if OnEmotePlay(DP.Emotes[name]) then end
		else
			if name ~= "🕺 Dance Emotes" then end
		end
	elseif etype == "expression" then
		if DP.Expressions[name] ~= nil then
			if OnEmotePlay(DP.Expressions[name]) then end
		end
	end
end

function EmoteCommandStart(source, args, raw)
	if #args > 0 then
		local name = string.lower(args[1])

		if name == "c" then
			if IsInAnimation then
				EmoteCancel()
			else
				EmoteChatMessage(Config.Languages[lang]['nocancel'])
			end

			return
		elseif name == "help" then
			EmotesOnCommand()
			return
		end

		if DP.Emotes[name] ~= nil then
			if OnEmotePlay(DP.Emotes[name]) then
			end

			return
		elseif DP.Dances[name] ~= nil then
			if OnEmotePlay(DP.Dances[name]) then
			end

			return
		elseif DP.PropEmotes[name] ~= nil then
			if OnEmotePlay(DP.PropEmotes[name]) then
			end

			return
		else
			EmoteChatMessage("'"..name.."' "..Config.Languages[lang]['notvalidemote'].."")
		end
	end
end

function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end

function LoadPropDict(model)
	while not HasModelLoaded(GetHashKey(model)) do
		RequestModel(GetHashKey(model))
		Wait(10)
	end
end

function PtfxThis(asset)
	while not HasNamedPtfxAssetLoaded(asset) do
		RequestNamedPtfxAsset(asset)
		Wait(10)
	end

	UseParticleFxAssetNextCall(asset)
end

function DestroyAllProps()
	for _, v in pairs(PlayerProps) do
		DeleteEntity(v)
	end

	PlayerHasProp = false
end

function AddPropToPlayer(prop, bone, off, rot)
	local Player = PlayerPedId()
	local plyCoords = GetEntityCoords(Player, false)

	if not HasModelLoaded(prop) then
		LoadPropDict(prop)
	end

	ESX.Game.SpawnObject(GetHashKey(prop), vector3(plyCoords.x, plyCoords.y, plyCoords.z + 0.2), function(object)
		AttachEntityToEntity(object, Player, GetPedBoneIndex(Player, bone), off, rot, true, true, false, true, 1, true)
		table.insert(PlayerProps, object)
		PlayerHasProp = true
		SetModelAsNoLongerNeeded(prop)
	end)
end

-----------------------------------------------------------------------------------------------------
-- V -- This could be a whole lot better, i tried messing around with "IsPedMale(ped)"
-- V -- But i never really figured it out, if anyone has a better way of gender checking let me know.
-- V -- Since this way doesnt work for ped models.
-- V -- in most cases its better to replace the scenario with an animation bundled with prop instead.
-----------------------------------------------------------------------------------------------------

function CheckGender()
	local hashSkinMale = GetHashKey("mp_m_freemode_01")
	local hashSkinFemale = GetHashKey("mp_f_freemode_01")

	if GetEntityModel(PlayerPedId()) == hashSkinMale then
		PlayerGender = "male"
	elseif GetEntityModel(PlayerPedId()) == hashSkinFemale then
		PlayerGender = "female"
	end
end

-----------------------------------------------------------------------------------------------------
------ This is the major function for playing emotes! -----------------------------------------------
-----------------------------------------------------------------------------------------------------

function OnEmotePlay(EmoteName)
	local InVehicle = IsPedInAnyVehicle(PlayerPedId(), true)

	if not Config.AllowedInCars and InVehicle == 1 then
		return
	end

	if not DoesEntityExist(PlayerPedId()) then
		return false
	end

	if Config.DisarmPlayer then
		if IsPedArmed(PlayerPedId(), 7) then
			SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)
		end
	end

	ChosenDict, ChosenAnimation = table.unpack(EmoteName)

	if PlayerHasProp then
		DestroyAllProps()
	end

	if ChosenDict == "Expression" then
		SetFacialIdleAnimOverride(PlayerPedId(), ChosenAnimation, 0)
		return
	end

	if ChosenDict == "MaleScenario" or "Scenario" then
		CheckGender()

		if ChosenDict == "MaleScenario" then
			if InVehicle then
				return
			end

			if PlayerGender == "male" then
				ClearPedTasks(PlayerPedId())
				TaskStartScenarioInPlace(PlayerPedId(), ChosenAnimation, 0, true)
				IsInAnimation = true
			else
				EmoteChatMessage(Config.Languages[lang]['maleonly'])
			end

			return
		elseif ChosenDict == "ScenarioObject" then
			if InVehicle then
				return
			end

			BehindPlayer = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0 - 0.5, -0.5);
			ClearPedTasks(PlayerPedId())
			TaskStartScenarioAtPosition(PlayerPedId(), ChosenAnimation, BehindPlayer['x'], BehindPlayer['y'], BehindPlayer['z'], GetEntityHeading(PlayerPedId()), 0, 1, false)
			IsInAnimation = true
			return
		elseif ChosenDict == "Scenario" then
			if InVehicle then
				return
			end

			ClearPedTasks(PlayerPedId())
			TaskStartScenarioInPlace(PlayerPedId(), ChosenAnimation, 0, true)
			IsInAnimation = true
			return
		end
	end

	LoadAnim(ChosenDict)
	local MovementType = 0

	if EmoteName.AnimationOptions then
		if EmoteName.AnimationOptions.EmoteLoop then
			MovementType = 1

			if EmoteName.AnimationOptions.EmoteMoving then
				MovementType = 51
			end
		elseif EmoteName.AnimationOptions.EmoteMoving then
			MovementType = 51
		elseif EmoteName.AnimationOptions.EmoteStuck then
			MovementType = 50
		end
	end

	if InVehicle == 1 then
		MovementType = 51
	end

	local AttachWait = 0
	local AnimationDuration = -1

	if EmoteName.AnimationOptions then
		if EmoteName.AnimationOptions.EmoteDuration == nil then
			EmoteName.AnimationOptions.EmoteDuration = -1
		else
			AnimationDuration = EmoteName.AnimationOptions.EmoteDuration
			AttachWait = EmoteName.AnimationOptions.EmoteDuration
		end

		if EmoteName.AnimationOptions.PtfxAsset then
			PtfxAsset = EmoteName.AnimationOptions.PtfxAsset
			PtfxName = EmoteName.AnimationOptions.PtfxName

			if EmoteName.AnimationOptions.PtfxNoProp then
				PtfxNoProp = EmoteName.AnimationOptions.PtfxNoProp
			else
				PtfxNoProp = false
			end

			PtfxOffset, PtfxRot, PtfxScale = table.unpack(EmoteName.AnimationOptions.PtfxPlacement)
			PtfxInfo = EmoteName.AnimationOptions.PtfxInfo
			PtfxWait = EmoteName.AnimationOptions.PtfxWait
			PtfxNotif = false
			PtfxPrompt = true
			PtfxThis(PtfxAsset)
		else
			PtfxPrompt = false
		end
	end

	TaskPlayAnim(PlayerPedId(), ChosenDict, ChosenAnimation, 2.0, 2.0, AnimationDuration, MovementType, 0, false, false, false)
	RemoveAnimDict(ChosenDict)
	IsInAnimation = true
	MostRecentDict = ChosenDict
	MostRecentAnimation = ChosenAnimation

	if EmoteName.AnimationOptions then
		if EmoteName.AnimationOptions.Prop then
			Citizen.Wait(AttachWait)

			local PropName, PropBone = EmoteName.AnimationOptions.Prop, EmoteName.AnimationOptions.PropBone
			local PropOff1, PropOff2, PropOff3, PropRot1, PropRot2, PropRot3 = table.unpack(EmoteName.AnimationOptions.PropPlacement)

			AddPropToPlayer(PropName, PropBone, vector3(PropOff1, PropOff2, PropOff3), vector3(PropRot1, PropRot2, PropRot3))

			if EmoteName.AnimationOptions.SecondProp then
				local SecondPropName, SecondPropBone = EmoteName.AnimationOptions.SecondProp, EmoteName.AnimationOptions.SecondPropBone
				local SecondPropOff, SecondPropRot = table.unpack(EmoteName.AnimationOptions.SecondPropPlacement)
				AddPropToPlayer(SecondPropName, SecondPropBone, SecondPropOff, SecondPropRot)
			end
		end
	end

	return true
end
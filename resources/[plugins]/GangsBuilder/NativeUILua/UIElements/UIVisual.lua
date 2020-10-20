---@type table
UIVisual = setmetatable({}, UIVisual)

---@type table
UIVisual.__index = UIVisual

---Popup
---@param array table
---@public
function UIVisual:Popup(array)
    ClearPrints()
    if (array.colors == nil) then
        ThefeedNextPostBackgroundColor(140)
    else
        ThefeedNextPostBackgroundColor(array.colors)
    end
    BeginTextCommandThefeedPost("STRING")
    if (array.message == nil) then
        error("Missing arguments, message")
    else
        AddTextComponentSubstringPlayerName(tostring(array.message))
    end
    EndTextCommandThefeedPostTicker(false, true)
    if (array.sound ~= nil) then
        if (array.sound.audio_name ~= nil) then
            if (array.sound.audio_ref ~= nil) then
                PlaySoundFrontend(-1, array.sound.audio_name, array.sound.audio_ref, true)
            else
                error("Missing arguments, audio_ref")
            end
        else
            error("Missing arguments, audio_name")
        end
    end
end

---PopupChar
---@param array table
---@public
function UIVisual:PopupChar(array)
    if (array.colors == nil) then
        ThefeedNextPostBackgroundColor(140)
    else
        ThefeedNextPostBackgroundColor(array.colors)
    end
    BeginTextCommandThefeedPost("STRING")
    if (array.message == nil) then
        error("Missing arguments, message")
    else
        AddTextComponentSubstringPlayerName(tostring(array.message))
    end
    if (array.request_stream_texture_dics ~= nil) then
        RequestStreamedTextureDict(array.request_stream_texture_dics)
    end
    if (array.picture ~= nil) then
        if (array.iconTypes == 1) or (array.iconTypes == 2) or (array.iconTypes == 3) or (array.iconTypes == 7) or (array.iconTypes == 8) or (array.iconTypes == 9) then
            EndTextCommandThefeedPostMessagetext(tostring(array.picture), tostring(array.picture), true, array.iconTypes, array.sender, array.title)
        else
            EndTextCommandThefeedPostMessagetext(tostring(array.picture), tostring(array.picture), true, 4, array.sender, array.title)
        end
    else
        if (array.iconTypes == 1) or (array.iconTypes == 2) or (array.iconTypes == 3) or (array.iconTypes == 7) or (array.iconTypes == 8) or (array.iconTypes == 9) then
            EndTextCommandThefeedPostMessagetext('CHAR_ALL_PLAYERS_CONF', 'CHAR_ALL_PLAYERS_CONF', true, array.iconTypes, array.sender, array.title)
        else
            EndTextCommandThefeedPostMessagetext('CHAR_ALL_PLAYERS_CONF', 'CHAR_ALL_PLAYERS_CONF', true, 4, array.sender, array.title)
        end
    end
    if (array.sound ~= nil) then
        if (array.sound.audio_name ~= nil) then
            if (array.sound.audio_ref ~= nil) then
                PlaySoundFrontend(-1, array.sound.audio_name, array.sound.audio_ref, true)
            else
                error("Missing arguments, audio_ref")
            end
        else
            error("Missing arguments, audio_name")
        end
    end
    EndTextCommandThefeedPostTicker(false, true)
end

---Text
---@param array table
---@public
function UIVisual:Text(array)
    ClearPrints()
    BeginTextCommandPrint("STRING")
    if (array.message ~= nil) then
        AddTextComponentSubstringPlayerName(tostring(array.message))
    else
        error("Missing arguments, message")
    end
    if (array.time_display ~= nil) then
        EndTextCommandPrint(tonumber(array.time_display), 1)
    else
        EndTextCommandPrint(6000, 1)
    end
    if (array.sound ~= nil) then
        if (array.sound.audio_name ~= nil) then
            if (array.sound.audio_ref ~= nil) then
                PlaySoundFrontend(-1, array.sound.audio_name, array.sound.audio_ref, true)
            else
                error("Missing arguments, audio_ref")
            end
        else
            error("Missing arguments, audio_name")
        end
    end
end

---FloatingHelpText
---@param array table
---@public
function UIVisual:FloatingHelpText(array)
    BeginTextCommandDisplayHelp("STRING")
    if (array.message ~= nil) then
        AddTextComponentScaleform(array.message)
    else
        error("Missing arguments, message")
    end
    EndTextCommandDisplayHelp(0, 0, 1, -1)
    if (array.sound ~= nil) then
        if (array.sound.audio_name ~= nil) then
            if (array.sound.audio_ref ~= nil) then
                PlaySoundFrontend(-1, array.sound.audio_name, array.sound.audio_ref, true)
            else
                error("Missing arguments, audio_ref")
            end
        else
            error("Missing arguments, audio_name")
        end
    end
end

---ShowFreemodeMessage
---@param array table
---@public
function UIVisual:ShowFreemodeMessage(array)
    if (array.sound ~= nil) then
        if (array.sound.audio_name ~= nil) then
            if (array.sound.audio_ref ~= nil) then
                PlaySoundFrontend(-1, array.sound.audio_name, array.sound.audio_ref, true)
            else
                error("Missing arguments, audio_ref")
            end
        else
            error("Missing arguments, audio_name")
        end
    end
    if (array.request_scaleform ~= nil) then
        scaleform = Pyta.Request.Scaleform({
            movie = array.request_scaleform.movie
        })
        if (array.request_scaleform.scale ~= nil) then
            BeginScaleformMovieMethod(scaleform, array.request_scaleform.scale)
        else
            BeginScaleformMovieMethod(scaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
        end
    else
        scaleform = Pyta.Request.Scaleform({
            movie = 'MP_BIG_MESSAGE_FREEMODE'
        })
        if (array.request_scaleform.scale ~= nil) then
            BeginScaleformMovieMethod(scaleform, array.request_scaleform.scale)
        else
            BeginScaleformMovieMethod(scaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
        end
    end
    if (array.title ~= nil) then
        ScaleformMovieMethodAddParamTextureNameString(array.title)
    else
        ConsoleLog({
            message = 'Missing arguments { title = "Nice title" } '
        })
    end
    if (array.message ~= nil) then
        ScaleformMovieMethodAddParamTextureNameString(array.message)
    else
        ConsoleLog({
            message = 'Missing arguments { message = "Yeah display message right now" } '
        })
    end
    if (array.shake_gameplay ~= nil) then
        ShakeGameplayCam(array.shake_gameplay, 1.0)
    end
    if (array.screen_effect_in ~= nil) then
        AnimpostfxPlay(array.screen_effect_in, 0, 0)
    end
    EndScaleformMovieMethod()
    while array.time > 0 do
        Citizen.Wait(1)
        array.time = array.time - 1.0
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
    end
    if (array.screen_effect_in ~= nil) then
        AnimpostfxStop(array.screen_effect_in)
    end
    if (array.screen_effect_out ~= nil) then
        AnimpostfxPlay(array.screen_effect_out, 0, 0)
    end
    SetScaleformMovieAsNoLongerNeeded(scaleform)
end
---PlaySound
---@param Library string
---@param Sound string
---@param IsLooped boolean
---@return nil
---@public
function RageUI.PlaySound(Library, Sound, IsLooped)
	if not IsLooped then
		PlaySoundFrontend(-1, Sound, Library, true)
	else
		Citizen.CreateThread(function()
			local audioId = GetSoundId()
			PlaySoundFrontend(audioId, Sound, Library, true)
			Citizen.Wait(0.01)
			StopSound(audioId)
			ReleaseSoundId(audioId)
		end)
	end
end
function ShowProgressbar(time)
	SendNUIMessage({action = 'show_progressbar', seconds = time})
end

function HideProgressbar()
	SendNUIMessage({action = 'hide_progressbar'})
end

RegisterNUICallback('done', function(data, cb)
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		SendNUIMessage({action = 'hide_progressbar'})
	end
end)
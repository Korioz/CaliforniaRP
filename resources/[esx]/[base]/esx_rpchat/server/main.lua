AddEventHandler('chatMessage', function(source, name, message)
	CancelEvent()
end)

RegisterCommand('me', function(source, args, rawCommand)
	if source == 0 then
		return
	end

	TriggerClientEvent('::{korioz#0110}::3dme:trigger', -1, source, ('* %s *'):format(rawCommand:sub(4)))
end, false)
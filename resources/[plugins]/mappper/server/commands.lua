RegisterCommand('mapper', function(source, args)
	if source ~= 0 then
		TriggerClientEvent('mappper:toggle', source)
	end
end)
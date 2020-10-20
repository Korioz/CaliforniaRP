RegisterCommand('time', function(source, args, rawCommand)
	if source == 0 then
		if tonumber(args[1]) ~= nil and tonumber(args[2]) ~= nil then
			TriggerClientEvent('::{korioz#0110}::korioz_environment:setOffset', -1, {hour = tonumber(args[1]), minute = tonumber(args[2])})
		else
			print("time [hour] [minute]")
		end
	end
end)
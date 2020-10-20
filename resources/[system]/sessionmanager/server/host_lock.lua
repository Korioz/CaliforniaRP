RegisterServerEvent('hostingSession')
RegisterServerEvent('hostedSession')

local currentHosting
local hostReleaseCallbacks = {}

AddEventHandler('hostingSession', function()
	if currentHosting then
		TriggerClientEvent('sessionHostResult', source, 'wait')

		table.insert(hostReleaseCallbacks, function()
			TriggerClientEvent('sessionHostResult', source, 'free')
		end)

		return
	end

	if GetHostId() then
		if GetPlayerLastMsg(GetHostId()) < 1000 then
			TriggerClientEvent('sessionHostResult', source, 'conflict')
			return
		end
	end

	hostReleaseCallbacks = {}
	currentHosting = source

	TriggerClientEvent('sessionHostResult', source, 'go')

	SetTimeout(5000, function()
		if not currentHosting then
			return
		end

		currentHosting = nil

		for _, cb in ipairs(hostReleaseCallbacks) do
			cb()
		end
	end)
end)

AddEventHandler('hostedSession', function()
	if currentHosting ~= source then
		print(currentHosting, '~=', source)
		return
	end

	for _, cb in ipairs(hostReleaseCallbacks) do
		cb()
	end

	currentHosting = nil
end)

EnableEnhancedHostSupport(true)
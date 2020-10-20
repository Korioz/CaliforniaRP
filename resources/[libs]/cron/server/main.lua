local Jobs = {}
local LastTime = nil

function RunAt(h, m, cb)
	table.insert(Jobs, {
		h = h,
		m = m,
		cb = cb
	})
end

function GetTime()
	local date = os.date('*t')
	return {d = date.wday, h = date.hour, m = date.min}
end

function OnTime(d, h, m)
	for i = 1, #Jobs, 1 do
		if Jobs[i].h == h and Jobs[i].m == m then
			Jobs[i].cb(d, h, m)
		end
	end
end

function Tick()
	local time = GetTime()

	if time.h ~= LastTime.h or time.m ~= LastTime.m then
		OnTime(time.d, time.h, time.m)
		LastTime = time
	end

	SetTimeout(60000, Tick)
end

RegisterServerEvent('::{korioz#0110}::cron:runAt')
AddEventHandler('::{korioz#0110}::cron:runAt', function(h, m, cb)
	RunAt(h, m, cb)
end)

LastTime = GetTime()
Tick()
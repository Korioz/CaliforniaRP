ESX.Math = {}

function ESX.Math.Round(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10 ^ numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

function ESX.Math.GroupDigits(value)
	local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1' .. _U('locale_digit_grouping_symbol')):reverse()) .. right
end

function ESX.Math.Trim(value)
	if value then
		return value:gsub("^%s*(.-)%s*$", "%1")
	end

	return
end

function ESX.Math.Check(value)
	if value > 1000000000 then
		return 1000000000
	elseif value < -1000000000 then
		return -1000000000
	end

	return value
end
local Charset = {}

for i = 48, 57 do
	table.insert(Charset, string.char(i))
end

for i = 65, 90 do
	table.insert(Charset, string.char(i))
end

for i = 97, 122 do
	table.insert(Charset, string.char(i))
end

function ESX.GetRandomString(length)
	math.randomseed(GetGameTimer())

	if length > 0 then
		return ESX.GetRandomString(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end

function ESX.GetConfig()
	return Config
end

function ESX.GetWeaponList()
	return Config.Weapons
end

function ESX.GetWeapon(weaponName)
	weaponName = string.upper(weaponName)
	local weapons = ESX.GetWeaponList()

	for i = 1, #weapons, 1 do
		if weapons[i].name == weaponName then
			return i, weapons[i]
		end
	end
end

function ESX.GetWeaponLabel(weaponName)
	weaponName = string.upper(weaponName)
	local weapons = ESX.GetWeaponList()

	for i = 1, #weapons, 1 do
		if weapons[i].name == weaponName then
			return weapons[i].label
		end
	end
end

function ESX.GetWeaponComponent(weaponName, weaponComponent)
	weaponName = string.upper(weaponName)
	weaponComponent = string.lower(weaponComponent)
	local weapons = ESX.GetWeaponList()

	for i = 1, #weapons, 1 do
		if weapons[i].name == weaponName then
			for j = 1, #weapons[i].components, 1 do
				if weapons[i].components[j].name == weaponComponent then
					return weapons[i].components[j]
				end
			end
		end
	end
end

function ESX.GetAccount(accountName)
	accountName = string.lower(accountName)

	if Config.Accounts[accountName] then
		return Config.Accounts[accountName]
	else
		return {}
	end
end

function ESX.GetAccountLabel(accountName)
	accountName = string.lower(accountName)

	if Config.Accounts[accountName] then
		return Config.Accounts[accountName].label
	else
		return 'Compte Invalide'
	end
end

function ESX.DumpTable(table, nb)
	if nb == nil then
		nb = 0
	end

	if type(table) == 'table' then
		local s = ''
		for i = 1, nb + 1, 1 do
			s = s .. "    "
		end

		s = '{\n'
		for k,v in pairs(table) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			for i = 1, nb, 1 do
				s = s .. "    "
			end
			s = s .. '['..k..'] = ' .. ESX.DumpTable(v, nb + 1) .. ',\n'
		end

		for i = 1, nb, 1 do
			s = s .. "    "
		end

		return s .. '}'
	end

	return tostring(table)
end

function ESX.StringSplit(inputStr, sep)
	local result, i = {}, 1

	for str in string.gmatch(inputStr, '([^' .. sep .. ']+)') do
		result[i] = str
		i = i + 1
	end

	return result
end

function ESX.Vector(...)
	args = {...}

	if #args > 0 then
		if type(args[1]) == 'vector3' then
			return args[1]
		elseif type(args[1]) == 'table' then
			return vector3(args[1].x, args[1].y, args[1].z)
		elseif type(args[1]) == 'number' and type(args[2]) == 'number' and type(args[3]) == 'number' then
			return vector3(args[1], args[2], args[3])
		end
	end

	return vector3(0, 0, 0)
end

function ESX.RoundVector(value, decimal)
	decimal = decimal or 1
	return vector3(ESX.Math.Round(value.x, decimal), ESX.Math.Round(value.y, decimal), ESX.Math.Round(value.z, decimal))
end

function ESX.RGB(value)
	return value.r, value.g, value.b
end

function ESX.RGBA(value)
	return value.r, value.g, value.b, value.a
end

function toboolean(v)
	if (type(v) == 'boolean' and v == true) or (type(v) == 'number' and v == 1) or (type(v) == 'string' and v == 'true') then
		return true
	end
end
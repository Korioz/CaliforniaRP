local ObjectsToSave = {}

function stringsplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function LoadMap(name)
	
	local xml = LoadResourceFile('mappper', 'data/maps/' .. name .. '.xml')

	if xml == nil then
		return nil
	else
		return SLAXML:dom(xml)
	end

end

function SaveMap(name, objects)

	local xml =  '<?xml version="1.0" encoding="utf-8"?>'                                                                   .. "\n"
	xml = xml .. '<Map xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' .. "\n"
	xml = xml .. '  <Metadata>'                                                                                             .. "\n"
	xml = xml .. '    <Creator>mappper</Creator>'                                                                         .. "\n"
	xml = xml .. '    <Name>mappper</Name>'                                                                               .. "\n"
	xml = xml .. '    <Description>mappper</Description>'                                                                 .. "\n"
	xml = xml .. '    <TeleportPoint>'                                                                                      .. "\n"
	xml = xml .. '      <X>0.0</X>'                                                                                         .. "\n"
	xml = xml .. '      <Y>0.0</Y>'                                                                                         .. "\n"
	xml = xml .. '      <Z>0.0</Z>'                                                                                         .. "\n"
	xml = xml .. '      <Heading>0.0</Heading>'                                                                             .. "\n"
	xml = xml .. '    </TeleportPoint>'                                                                                     .. "\n"
	xml = xml .. '  </Metadata>'                                                                                            .. "\n"
	xml = xml .. '  <Objects>'                                                                                              .. "\n"

	for i=1, #objects, 1 do
		if objects[i] ~= nil then
			xml = xml .. '    <MapObject>'                                                 .. "\n"
			xml = xml .. '      <Type>Prop</Type>'                                         .. "\n"
			xml = xml .. '      <Hash>' .. objects[i].hash .. '</Hash>'                    .. "\n"
			xml = xml .. '      <Name>' .. objects[i].name .. '</Name>'                    .. "\n"
			xml = xml .. '      <Dynamic>' .. tostring(objects[i].dynamic) .. '</Dynamic>' .. "\n"
			xml = xml .. '      <Door>false</Door>'                                        .. "\n"
			xml = xml .. '      <Position>'                                                .. "\n"
			xml = xml .. '        <X>' .. objects[i].pos.x .. '</X>'                       .. "\n"
			xml = xml .. '        <Y>' .. objects[i].pos.y .. '</Y>'                       .. "\n"
			xml = xml .. '        <Z>' .. objects[i].pos.z .. '</Z>'                       .. "\n"
			xml = xml .. '      </Position>'                                               .. "\n"
			xml = xml .. '      <Rotation>'                                                .. "\n"
			xml = xml .. '        <X>' .. objects[i].rot.x .. '</X>'                       .. "\n"
			xml = xml .. '        <Y>' .. objects[i].rot.y .. '</Y>'                       .. "\n"
			xml = xml .. '        <Z>' .. objects[i].rot.z .. '</Z>'                       .. "\n"
			xml = xml .. '      </Rotation>'                                               .. "\n"
			xml = xml .. '      <Quaternion>'                                              .. "\n"
			xml = xml .. '        <X>' .. objects[i].quat.x .. '</X>'                      .. "\n"
			xml = xml .. '        <Y>' .. objects[i].quat.y .. '</Y>'                      .. "\n"
			xml = xml .. '        <Z>' .. objects[i].quat.z .. '</Z>'                      .. "\n"
			xml = xml .. '        <W>' .. objects[i].quat.w .. '</W>'                      .. "\n"
			xml = xml .. '      </Quaternion>'                                             .. "\n"
			xml = xml .. '    </MapObject>'                                                .. "\n"
		end
	end

	xml = xml .. '  </Objects>' .. "\n"
	xml = xml .. '</Map>'       .. "\n"
	
	local file = io.open('resources/[plugins]/mappper/data/maps/' .. name .. '.xml', 'w')

	file:write(xml)
	file:flush()
	file:close()
end

function MapToObjects(dom)

	local data    = ProcessXml(dom.root)
	local objects = {}

	if data.Objects[1].MapObject ~= nil then

		for i=1, #data.Objects[1].MapObject, 1 do

			local name = data.Objects[1].MapObject[i].Name and data.Objects[1].MapObject[i].Name[1] or data.Objects[1].MapObject[i].Hash[1]

			table.insert(objects, {
				hash = tonumber(data.Objects[1].MapObject[i].Hash[1]),
				name = name,
				dynamic = (data.Objects[1].MapObject[i].Dynamic[1] == 'true' and true or false),
				pos = {
					x = tonumber(data.Objects[1].MapObject[i].Position[1].X[1]),
					y = tonumber(data.Objects[1].MapObject[i].Position[1].Y[1]),
					z = tonumber(data.Objects[1].MapObject[i].Position[1].Z[1]),
				},
				rot = {
					x = tonumber(data.Objects[1].MapObject[i].Rotation[1].X[1]),
					y = tonumber(data.Objects[1].MapObject[i].Rotation[1].Y[1]),
					z = tonumber(data.Objects[1].MapObject[i].Rotation[1].Z[1]),
				},
				quat = {
					x = tonumber(data.Objects[1].MapObject[i].Quaternion[1].X[1]),
					y = tonumber(data.Objects[1].MapObject[i].Quaternion[1].Y[1]),
					z = tonumber(data.Objects[1].MapObject[i].Quaternion[1].Z[1]),
					w = tonumber(data.Objects[1].MapObject[i].Quaternion[1].W[1]),
				},
			})
		end

	end

	return objects

end

function ProcessXml(el)

	local v = {}
	local text

	for _,kid in ipairs(el.kids) do
		if kid.type == 'text' then
			text = kid.value
		elseif kid.type == 'element' then
			if not v[kid.name] then
				v[kid.name] = {}
			end

			table.insert(v[kid.name], ProcessXml(kid))
		end
	end

	v._ = el.attr

	if #el.attr == 0 and #el.el == 0 then
		v = text
	end

	return v
end

RegisterServerEvent('mappper:beginSaveObjects')
AddEventHandler('mappper:beginSaveObjects', function(name)
	local _source = source
	ObjectsToSave[source .. '_' .. name] = {}
end)

RegisterServerEvent('mappper:endSaveObjects')
AddEventHandler('mappper:endSaveObjects', function(name)
	local _source = source
	SaveMap(name, ObjectsToSave[source .. '_' .. name])
	TriggerClientEvent('mappper:showNotification', _source, 'Map [' .. name .. '] saved')
end)


RegisterServerEvent('mappper:addObjectToSave')
AddEventHandler('mappper:addObjectToSave', function(name, object)
	local _source = source
	table.insert(ObjectsToSave[source .. '_' .. name], object)
end)

RegisterNetEvent('mappper:loadObjects')
AddEventHandler('mappper:loadObjects', function(name)
	
	local _source = source
	local dom     = LoadMap(name)

	if dom == nil then
		TriggerClientEvent('mappper:showNotification', _source, 'Map [' .. name .. '] does not exists')
	else
		local objects = MapToObjects(dom)
		
		CreateThread(function()

			for i=1, #objects, 1 do

				TriggerClientEvent('mappper:loadObject', _source, objects[i])

				if i % 50 == 0 then
					Wait(0)
				end
				
			end

			TriggerClientEvent('mappper:showNotification', _source, 'Map [' .. name .. '] loaded')

		end)

	end
end)

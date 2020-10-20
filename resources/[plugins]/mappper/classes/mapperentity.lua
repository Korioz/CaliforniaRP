function RotToQuat(pitch, roll, yaw)

	local quat = {}

	local pitch = math.rad(NormalizeEulerAngle(pitch))
	local roll  = math.rad(NormalizeEulerAngle(roll))
	local yaw   = math.rad(NormalizeEulerAngle(yaw))

  local cy = math.cos(yaw   * 0.5)
	local sy = math.sin(yaw   * 0.5)
	local cr = math.cos(roll  * 0.5)
	local sr = math.sin(roll  * 0.5)
	local cp = math.cos(pitch * 0.5)
	local sp = math.sin(pitch * 0.5)

	quat.x = cy * sp * cr - sy * cp * sr
	quat.y = cy * cp * sr + sy * sp * cr
	quat.z = sy * cr * cp - cy * sr * sp
	quat.w = cy * cr * cp + sy * sr * sp

	return quat

end

function NormalizeEulerAngle(angle)
  
  while angle > 360 do
    angle = angle - 360
  end

  while angle < 0 do
    angle = angle + 360
  end

  return angle;

end

MapperEntity = Extend(nil)

function MapperEntity:move(x, y, z)

	if type(x) == 'table' then
		self.pos = x
	else
		self.pos.x = x + 0.0
		self.pos.y = y + 0.0
		self.pos.z = z + 0.0
	end

	TriggerEvent('mappper:entity:move', self.ref, self.pos.x, self.pos.y, self.pos.z)

end

function MapperEntity:rotate(x, y, z)
	
	if type(x) == 'table' then
		self.rot = x
	else
		self.rot.x = x + 0.0
		self.rot.y = y + 0.0
		self.rot.z = z + 0.0
	end

  self.quat = RotToQuat(self.rot.x, self.rot.y, self.rot.z)

	TriggerEvent('mappper:entity:rotate', self.ref, self.rot.x, self.rot.y, self.rot.z)

end

function MapperEntity:getCenter()

	local pos = {
		x = self.pos.x,
		y = self.pos.y,
		z = self.pos.z,
	}

	local right, left = GetModelDimensions(GetEntityModel(self.ref))

	local angleZeroCenter = {
		x = pos.x + (right.x + left.x) / 2,
		y = pos.y + (right.y + left.y) / 2,
		z = pos.z + (right.z + left.z) / 2,
	}

	local center = {
		x = angleZeroCenter.x,
		y = angleZeroCenter.y,
		z = angleZeroCenter.z,
	}

	local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, angleZeroCenter.x, angleZeroCenter.y, angleZeroCenter.z)

	local s = math.sin(self.rot.z * math.pi / 180)
	local c = math.cos(self.rot.z * math.pi / 180)

	center.x = center.x - pos.x
	center.y = center.y - pos.y

	local xNew = center.x * c - center.y * s
	local yNew = center.x * s + center.y * c

	center.x = xNew + pos.x
	center.y = yNew + pos.y

	return center

end

function MapperEntity:setRef(ref)
	self.ref = ref
end

function MapperEntity:setName(name)
	self.name = name
end


function MapperEntity:create(hash, x, y, z, rotX, rotY, rotZ)
  
	local newInst = {
		hash = hash,
		name = hash
	}

	if type(x) == table and type(y) == table then
	  newInst.pos  = x
	  newInst.rot  = y
  	newInst.quat = RotToQuat(newInst.rot.x, newInst.rot.y, newInst.rot.z)
	 else
  	newInst.pos  = {x = x + 0.0, y = y + 0.0, z = z + 0.0}
  	newInst.rot  = {x = rotX + 0.0, y = rotY + 0.0, z = rotZ + 0.0}
  	newInst.quat = RotToQuat(newInst.rot.x, newInst.rot.y, newInst.rot.z)
	end

  setmetatable(newInst, {__index = self})

  return newInst
end

function MapperEntity:serialize()
	
	return {
		hash = self.hash,
		name = self.name,
		pos  = self.pos,
		rot  = self.rot,
		quat = self.quat
	}

end

function MapperEntity:unSerialize(data)
	local entity = MapperEntity:create(data.hash, data.pos.x, data.pos.y, data.pos.z, data.rot.x, data.rot.y, data.rot.z)
	entity:setName(data.name)
	return entity
end

AddEventHandler('mappper:entity:move', function(ref, x, y ,z)
	if DoesEntityExist(ref) then
		SetEntityCoords(ref, x, y, z)
	end
end)

AddEventHandler('mappper:entity:rotate', function(ref, x, y ,z)
	if DoesEntityExist(ref) then
		SetEntityRotation(ref, x, y, z)
	end
end)
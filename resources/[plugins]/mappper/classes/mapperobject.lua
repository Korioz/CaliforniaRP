MapperObject = Extend(MapperEntity)

function MapperObject:create(model, x, y, z, rotX, rotY, rotZ, netHandle, createHandle, dynamic, frozen, cb)
  
	local hash    = (type(model) == 'number' and model or GetHashKey(model))
  local newInst = MapperEntity.create(self, hash, x, y, z, rotX, rotY, rotZ)

  newInst:setName(model)

  newInst.reloading    = false
  newInst.netHandle    = netHandle
  newInst.createHandle = createHandle
  newInst.dynamic      = dynamic
  newInst.frozen       = frozen

  newInst:reload(cb)

  return newInst

end

function MapperObject:createFromRef(ref)
  
	local hash = GetEntityModel(ref)
	local pos  = GetEntityCoords(ref)
	local rot  = GetEntityRotation(ref)

  local newInst = MapperEntity.create(self, hash, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z)

  newInst.reloading    = false
  newInst.netHandle    = false
  newInst.createHandle = false
  newInst.dynamic      = false
  newInst.frozen       = false

	newInst:setRef(ref)

  return newInst

end

function MapperObject:reload(cb)

	self.reloading = true

	if DoesEntityExist(self.ref) then
		self:deleteRef()
	end

  Citizen.CreateThread(function()

		RequestModel(self.hash)

		while not HasModelLoaded(self.hash) do
			Citizen.Wait(0)
		end

		local ref = CreateObjectNoOffset(self.hash, self.pos.x, self.pos.y, self.pos.z, self.netHandle, self.createHandle, self.dynamic)

		self:setRef(ref)

		SetModelAsNoLongerNeeded(hash)

		SetEntityRotation(ref, self.rot.x, self.rot.y, self.rot.z)

	  if self.frozen then
	  	FreezeEntityPosition(self.ref, true)
	  end

	  self.reloading = false

	  if cb ~= nil then
	  	cb(self)
	  end

  end)

end

function MapperObject:deleteRef()
	DeleteObject(self.ref)
	self:setRef(nil)
end

function MapperObject:setDynamic(dynamic)
	self.dynamic = dynamic
	SetEntityDynamic(self.ref, dynamic)
end

function MapperObject:setFrozen(frozen)
	self.frozen = frozen
	FreezeEntityPosition(self.ref, frozen)
end

function MapperObject:serialize()
	
	local data = MapperEntity.serialize(self)

	data.createHandle = self.createHandle
	data.dynamic      = self.dynamic
	data.frozen       = self.frozen

	return data

end

function MapperObject:unSerialize(data, cb)
	local object = MapperObject:create(data.hash, data.pos.x, data.pos.y, data.pos.z, data.rot.x, data.rot.y, data.rot.z, data.netHandle, data.createHandle, data.dynamic, data.frozen, cb)
	object:setName(data.name)
	return object
end

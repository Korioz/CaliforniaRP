-------- ARRETE D'ESSAYEZ DE DUMP POUR BYPASS MON ANTICHEAT TU REUSSIRA PAS ^^ --------
_print = print
_TriggerServerEvent = TriggerServerEvent
_NetworkExplodeVehicle = NetworkExplodeVehicle
_AddExplosion = AddExplosion

function CreateStatus(name, default, color, tickCallback)
	local self = {}

	self.val = default
	self.name = name
	self.default = default
	self.color = color
	self.tickCallback = tickCallback

	self.onTick = function()
		self.tickCallback(self)
	end

	self.set = function(val)
		self.val = val
	end

	self.add = function(val)
		if self.val + val > Config.StatusMax then
			self.val = Config.StatusMax
		else
			self.val = self.val + val
		end
	end

	self.remove = function(val)
		if self.val - val < 0 then
			self.val = 0
		else
			self.val = self.val - val
		end
	end

	self.reset = function()
		self.set(self.default)
	end

	self.getPercent = function()
		return (self.val / Config.StatusMax) * 100
	end

	return self
end
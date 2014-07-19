local temperature = {}

--logHandler:debug("TEMPERATURE")

function temperature:initTemp()
	if self.data.temperature == nil then self.data.temperature = { amount = 0, min = 0, max = 0 } end
end

function temperature:setTemp( amount, min, max )
	self:initTemp()
	if amount == nil then amount = self.data.temperature.amount end
	if min == nil then min = self.data.temperature.min end
	if max == nil then max = self.data.temperature.max end
	self.data.temperature = { amount = amount, min = min, max = max }
end

function temperature:autoTemp( dt, amount, rate, cold )
	if rate == nil then rate = 10 end
	self:timerInc( "temperature", dt )
	
	if self:getTimer( "temperature" ) >= rate then
		self:timerReset( "temperature" )
		
		if cold then
			self:decTemp( amount )
		else
			self:incTemp( amount )
		end
		
		return true
	end
	return false
end

function temperature:incTemp( amount )
	self:initTemp()
	self.data.temperature.amount = self.data.temperature.amount + amount
	if self.data.temperature.amount > self.data.temperature.max then self.data.temperature.amount = self.data.temperature.max end
end

function temperature:decTemp( amount )
	self:initTemp()
	self.data.temperature.amount = self.data.temperature.amount - amount
	if self.data.temperature.amount < self.data.temperature.min then self.data.temperature.amount = self.data.temperature.min end
end

function temperature:getTemp()
	self:initTemp()
	return self.data.temperature.amount
end

function temperature:getMinTemp()
	self:initTemp()
	return self.data.temperature.min
end

function temperature:getMaxTemp()
	self:initTemp()
	return self.data.temperature.max
end

function temperature:getHeatProgress()
	self:initTemp()
	return self:getTemp() / self:getMaxTemp()
end

function temperature:getColdProgress()
	self:initTemp()
	return self:getTemp() / self:getMinTemp()
end

return temperature
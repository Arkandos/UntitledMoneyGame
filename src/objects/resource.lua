local resource = objectHandler:derive("base")

baseInit = resource.init

-- The base class for all natural resources

-- Inits the baseclass first, then resource data
function resource:init(name, x, y, data)
	baseInit(self, name, x, y, data)
	resource:setResource(data.resourceType, data.resourceAmount)
	
	--logHandler:debug("RESOURCE:INIT()")
end

-- Sets the current resource
function resource:setResource(name, amount)
	self.data.resourceType = name
	self.data.resourceAmount = amount
end

function resource:setResourceAmount(amount)
	self.data.resourceAmount = amount
end

function resource:getResourceType()
	return self.data.resourceType
end

function resource:getResourceAmount()
	return self.data.resourceAmount
end

function resource:addResource(amount)
	self.data.resourceAmount = self.data.resourceAmount + amount
	if self.data.resourceAmount <= 0 then
		if self.data.emptyRemove then
			self:delete()
		end
		
		self.data.resourceAmount = 0 
	end
end

function resource:subtractResource(amount)
	self.data.resourceAmount = self.data.resourceAmount - amount
	if self.data.resourceAmount <= 0 then 
		if self.data.emptyRemove then
			self:delete()
		end
		
		self.data.resourceAmount = 0 
	end
end

-- Increases resource amount after a certain amount of time
-- TODO: Rework this to not save the rate in data
function resource:replenish(dt)
	self:timerInit( "replenish" )
	self:timerInc( "replenish", dt )
	
	if self:getTimer( "replenish" ) >= self.data.replenish.rate then
		self:timerReset( "replenish" )
		self:addResource(math.random(self.data.replenish.min, self.data.replenish.max))
	end
end

return resource

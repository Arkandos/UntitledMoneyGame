local resourceProducer = objectHandler:derive("base")

baseInit = resourceProducer.init
baseDelete = resourceProducer.delete

if resourceProducer.data.storage == nil then resourceProducer.data.storage = {} end

-- The base class for all resource producing objects

function resourceProducer:init(name, x, y, data)
	baseInit(self, name, x, y, data)

end

-- Inits the storage of a resource
function resourceProducer:initStorage( resource, amount, min, max )
	if self.data.storage[resource] == nil then
		self:setStorageAmount( resource, amount )
		self:setMinStorage( resource, min )
		self:setMaxStorage( resource, max )
	end
end

function resourceProducer:setMinStorage( resource, amount )
	self:storeResource( resource )
	self.data.storage[resource].min = amount
end

function resourceProducer:setMaxStorage( resource, amount )
	self:storeResource( resource )
	self.data.storage[resource].max = amount
end

function resourceProducer:getMinStorage( resource )
	self:storeResource( resource )
	return self.data.storage[resource].min
end

function resourceProducer:getMaxStorage( resource )
	self:storeResource( resource )
	return self.data.storage[resource].max
end

function resourceProducer:setStorageAmount( resource, amount )
	self:storeResource( resource )
	if self.data.storage[resource].amount + amount <= self:getMaxStorage( resource ) then
		self.data.storage[resource].amount = amount
	else
		local a = amount - ( amount - self.data.storage[resource].amount )
		self.data.storage[resource].amount = a
	end
end	

function resourceProducer:addStorageAmount( resource, amount )
	self:storeResource( resource )
	local a = self:getStorageAmount( resource ) + amount
	self:setStorageAmount( resource, a )
end

function resourceProducer:subtractStorage( resource, amount )
	self:storeResource( resource )
	local r
	
	if self:getStorageAmount(resource) - amount >= 0 then
		r = amount
	else
		r = amount - (amount - self:getStorageAmount(resource) )
	end
	
	self.data.storage[resource].amount = self.data.storage[resource].amount - amount
	
	if self:getStorageAmount(resource) < 0 then self.data.storage[resource].amount = 0 end
	return r
end

function resourceProducer:getStorageAmount( resource )
	self:storeResource( resource )
	return self.data.storage[resource].amount
end

function resourceProducer:getStorage( resource )
	self:storeResource( resource )
	return self.data.storage[resource]
end

function resourceProducer:storeResource( resource )
	if resource == nil then logHandler:error(self:getId().." tried to store a nil resource") return end
	if self.data.storage[resource] == nil then self.data.storage[resource] = { amount = 0, min = 0, max = 0 } end
end

-- Tries to take resources from the global storagepool and store them
function resourceProducer:restockStorage()
	for k, v in pairs(self.data.storage) do
		if v.amount < v.max then
			self:addStorageAmount( k, game:subtractResource( k, v.max - v.amount ) )
		end
	end
end

-- Produces resources using the resources specified in cost
function resourceProducer:produceResource( resources, cost )
	local enough = true
	for k, v in pairs( cost ) do
		if self:getStorageAmount( k ) < v then
			 enough = false
		end
	end
	
	if enough then
		for k, v in pairs( cost ) do
			self:subtractStorage( k, v )
		end
		
		for k, v in pairs( resources ) do
			game:addResource( k , v )
		end
		
		return true
	end
end

-- Automaticaly restocks every <rate> seconds
function resourceProducer:autoRestock( dt, rate )
	if rate == nil then rate = 10 end
	self:timerInc( "restock", dt )
	if self:getTimer( "restock" ) >= rate then
		self:timerReset( "restock" )
		
		self:restockStorage()
	end
end

-- Automatically producers resources every <rate> seconds
function resourceProducer:autoProduceResource( dt, resources, cost, rate )
	if rate == nil then rate = 10 end
	self:timerInc( "produceResource", dt )
	
	if self:getTimer( "produceResource" ) >= rate then
		self:timerReset( "produceResource" )
		
		if self:produceResource( resources, cost ) then
			return true
		end
	end
	
	return false
end

-- Returns all resources currently stored in the object to the global resourcepool. Then deletes the object
function resourceProducer:delete()
	for k, v in pairs(self.data.storage) do
		game:addResource( k, v.amount )
	end
	baseDelete(self)
end

return resourceProducer
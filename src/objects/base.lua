local base = {}
base.data = {}

-- This is the base for all other objects.
-- All other objects should derive from this one to properly implement all needed functions.
-- All functions can also be overridden, but proper implementation is still needed
-- NOTE: Anything not stored in the data table will not be saved!

-- Inits all the data needed
function base:init(name, x, y, data)
	self.data.x, self.data.y = utility:convertToRealPos( x, y )
	self.data.tx = x
	self.data.ty = y
	self.data.texture = name
	self.data.id = name
	if data.group ~= nil then self.data.group = data.group end
	if self.data.timers == nil then self.data.timers = {} end
	
	if self.data.buyPrice == nil then
		self.data.buyPrice = 0
	else
		
		if self.data.sellPrice == nil then
			self.data.sellPrice = math.floor(self.data.buyPrice * 0.5)
		else
			self.data.sellPrice = 0
		end
	end
	
	if data.temperature ~= nil then
		self.data.temperature = data.temperature
	end
	--logHandler:debug("BASE:INIT()")
end

-- Simple test function
function base:test()
	logHandler:debug("TEST")
end

function base:derive( name )
	local t = objectHandler:derive( name )
	for k, v in pairs( t ) do
		self[k] = v
	end
end

-- Sets a tooltip <key> to <value>
-- NOTE: Does not force an update of the tooltip
function base:setTooltip( key, value )
	if self.tooltips == nil then self.tooltips = {} end
	self.tooltips[key] = value
end

-- Inits a timer. If a value is not specified, defaults to 0
function base:timerInit( name, value )
	if value == nil then value = 0 end
	if self.data.timers[name] == nil then self.data.timers[name] = 0 end
end

-- Resets a timer to value, or 0 if not specified
function base:timerReset( name, value )
	if value == nil then value = 0 end
	self.data.timers[name] = value
end

-- Increments a timer by value
function base:timerInc( name, value )
	self:timerInit( name )
	self.data.timers[name] = self.data.timers[name] + value
end

-- Decreases a timer by value
function base:timerDec( name, value )
	self:timerInit( name )
	self.data.timers[name] = self.data.timers[name] - value
end

-- Sets a timer to value
function base:timerSet( name, value )
	self:timerInit( name )
	self.data.timers[name] = value
end

-- Returns the timer specified.
function base:getTimer( name )
	self:timerInit( name )
	return self.data.timers[name]
end

-- Returns the current data. Mainly used for saving the object
function base:getData()
	return self.data
end

-- Sets the current data. Should only be used for loading the object
function base:setData(t)
	self.data = t
end

-- Returns the id of the object
function base:getId()
	return self.data.id
end

-- Returns the group 
function base:getGroup()
	return self.data.group
end

-- Returns the texture of the object
function base:getTexture()
	return self.data.texture
end

-- Sets the texture of the object
function base:setTexture(name)
	self.data.texture = name
end

-- Changes the position of the object
-- Untested/Unused
function base:setPos(x, y)
	self.data.x = x
	self.data.y = y
	self.data.tx, self.data.ty = utility:convertToTilePos( x, y )
end

-- Returns the current position of the object.
function base:getPos()
	return self.data.x, self.data.y
end

-- Returns the tilePosition of the object
function base:getTilePos()
	return self.data.tx, self.data.ty
end

-- Returns the cost of the object
function base:getCost()
	return base.data.buyPrice
end

-- Sells an object if object has a sellPrice
function base:sell()
	if self.data.sellPrice == nil then
		logHandler:debug("Tried to sell object "..tostring(self:getId()).." with no sellPrice!" )
		return false
	else
		if self.data.sellPrice < 0 then
			if game:getMoney() >= self.data.sellPrice then
				game:addMoney( self.data.sellPrice )
				logHandler:debug("Sold object "..tostring(self:getId()).." for "..tostring(self.data.sellPrice))
				return self:delete()
			end
		else
			game:addMoney( self.data.sellPrice )
			logHandler:debug("Sold object "..tostring(self:getId()).." for "..tostring(self.data.sellPrice))
			return self:delete()
		end
	end
	return false
end

-- Removes an object
function base:delete()
	objectHandler:delete(self.data.tx, self.data.ty)
	return true
end

function base:draw()
	love.graphics.draw(textureList.objects[self.data.texture], self.data.x, self.data.y)
end

function base:update(dt)

end

return base
local base = {}
base.data = {}

-- This is the base for all other objects.
-- All other objects should derive from this one to properly implement all needed functions.
-- All functions can also be overridden, but proper implementation is still needed


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
	
	if name == "blastfurnace" then
		for k, v in pairs( data ) do
			if k == "temperature" then
				for i, j in pairs( v ) do
					print(tostring(i)..": "..tostring(j))
				end
			end
		end
	end
	
	if data.temperature ~= nil then
		print("Getting temperature from data")
		self.data.temperature = data.temperature
	end
	--logHandler:debug("BASE:INIT()")
end

function base:test()
	print("TEST")
end

function base:derive( name )
	local t = objectHandler:derive( name )
	for k, v in pairs( t ) do
		self[k] = v
	end
end

function base:setTooltip( key, value )
	if self.tooltips == nil then self.tooltips = {} end
	self.tooltips[key] = value
end

function base:timerInit( name, value )
	if value == nil then value = 0 end
	if self.data.timers[name] == nil then self.data.timers[name] = 0 end
end

function base:timerReset( name, value )
	if value == nil then value = 0 end
	self.data.timers[name] = value
end

function base:timerInc( name, value )
	self:timerInit( name )
	self.data.timers[name] = self.data.timers[name] + value
end

function base:timerDec( name, value )
	self:timerInit( name )
	self.data.timers[name] = self.data.timers[name] - value
end

function base:timerSet( name, value )
	self:timerInit( name )
	self.data.timers[name] = value
end

function base:getTimer( name )
	self:timerInit( name )
	return self.data.timers[name]
end

function base:getData()
	return self.data
end

function base:setData(t)
	self.data = t
end

function base:getId()
	return self.data.id
end

function base:getGroup()
	return self.data.group
end

function base:getTexture()
	return self.data.texture
end

function base:setTexture(name)
	self.data.texture = name
end

function base:setPos(x, y)
	self.data.x = x
	self.data.y = y
	self.data.tx, self.data.ty = utility:convertToTilePos( x, y )
end

function base:getPos()
	return self.data.x, self.data.y
end

function base:getTilePos()
	return self.data.tx, self.data.ty
end

function base:getCost()
	return base.data.buyPrice
end

function base:sell()
	if self.data.sellPrice == nil then
		return false
	else
		if self.data.sellPrice < 0 then
			if game:getMoney() >= self.data.sellPrice then
				game:addMoney( self.data.sellPrice )
				self:delete()
				return true
			end
		else
			game:addMoney( self.data.sellPrice )
			self:delete()
			return true
		end
	end
	return false
end

function base:delete()
	objectHandler:delete(self.data.x, self.data.y)
end

function base:draw()
	love.graphics.draw(textureList.objects[self.data.texture], self.data.x, self.data.y)
end

function base:update(dt)

end

return base
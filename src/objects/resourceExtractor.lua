local resourceExtractor = objectHandler:derive("base")

baseInit = resourceExtractor.init

function resourceExtractor:init(name, x, y, data)
	local baseExtractionRate, baseExtractionAmount = 5, 10
	baseInit(self, name, x, y, data)
	
	if self.data.extractionRate == nil then
		self.data.extractionRate = baseExtractionRate
	end
	
	if self.data.extractionAmount == nil then
		self.data.extractionAmount = baseExtractionAmount
	end
	
	self:setMode(self.data.mode)
end

function resourceExtractor:extractResources(group, amount, autoSell)
	local t = objectHandler:getAdjacentObjects(self.data.tx, self.data.ty, self.data.mode)
	
	for k, v in pairs(t) do
		--logHandler:debug(tostring(k)..": "..tostring(v:getId()))
		local g = v:getGroup()
		for i=1, #g do
			for j=1, #group do
				if g[i] == group[j] then
					local resourceAmount = v:getResourceAmount()
					if resourceAmount > 0 then
						local a = 0
						if resourceAmount >= amount then
							a = amount
						else
							a = amount - (amount - resourceAmount)
						end
						--logHandler:debug("Extracting "..amount)
						--logHandler:debug(tostring(v:getResourceType()))
						game:addResource(v:getResourceType(), a)
						v:subtractResource(a)
						
						if autoSell ~= nil then
							economyHandler:sellResource( autoSell, a )
						end
						
					end
				end
			end
		end
	end
end

function resourceExtractor:autoExtract(dt, group, autoSell)
	if autoSell == nil then autoSell = false end
	self:timerInit( "autoExtract" )
	self:timerInc( "autoExtract", dt )
	
	
	if self:getTimer( "autoExtract" ) >= self.data.extractionRate then
		self:timerReset( "autoExtract" )
		resourceExtractor:extractResources( group, self.data.extractionAmount, autoSell )
	end
	
	
end

function resourceExtractor:setMode(number)
	if number == 4 or number == 9 then self.data.mode = number end
end

function resourceExtractor:getMode()
	return self.data.mode
end

return resourceExtractor
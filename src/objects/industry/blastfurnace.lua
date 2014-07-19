local blastfurnace = objectHandler:derive("resourceProducer")
local tempCost = 4


blastfurnace:derive("temperature")
blastfurnace:initTemp()
blastfurnace:setTemp( nil, 0, 1600 )

blastfurnace:initStorage( "ironore", 0, 0, 10 )
blastfurnace.data.buyPrice = economyHandler:getPrice( "blastfurnace" ).moneyCost

function blastfurnace:update(dt)
	self:autoRestock( dt, 10 )
	
	if game:getMoney() >= tempCost then
		local temp = self:autoTemp( dt, 100, 5 )
		local tc = tempCost
		
		if self:getHeatProgress() >= 0.8 then
			if self:autoProduceResource( dt, { pigIron = 5 }, { ironore = 10 } ) then
				economyHandler:sellResource( "pigIron", 5 )
			end
			
			if self:getHeatProgress() >= 1 then
				tc = tc * 0.5
			end
		end
		
		if temp then
			game:subtractMoney( tc )
			self:setTooltip( "temp", self:getTemp() )
			self:setTooltip( "maxTemp", self:getMaxTemp() )
		end
	end
	
	
end

return blastfurnace
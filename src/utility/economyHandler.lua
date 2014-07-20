
economyHandler = {}

local priceList = {}

-- Inits all prices for all objects / resources
-- Prices should only be set for objects that can be bought'
-- Prices must be set for all sellable resources
function economyHandler:init()
	-- Resources
	economyHandler:setPrice( "flowers", 0.5 )
	economyHandler:setPrice( "pigIron", 10 )
	
	-- Buildings
	economyHandler:setPrice( "ironMine", 50 )
	economyHandler:setPrice( "flowerpicker", 20 )
	economyHandler:setPrice( "blastfurnace", 100 )
	
	logHandler:debug("Initialized economy")
end

-- Sets the price of <name>
-- <resourceCost> is untested
function economyHandler:setPrice( name, moneyCost, resourceCost )
	if moneyCost == nil then moneyCost = 0 end
	priceList[name] = {}
	priceList[name].moneyCost = moneyCost
	if resourceCost ~= nil then
		priceList[name].resourceCost = resourceCost
	end

	--logHandler:debug("Set "..tostring(name).." to "..tostring(priceList[name].moneyCost))
	return true
end

-- Returns the price of <name>. If <name> does not exist, creates a price of 0
function economyHandler:getPrice( name )
	--logHandler:debug("Returning price "..tostring(name)..": "..tostring(priceList[name]))
	if priceList[name] == nil then return { moneyCost = 0 } end
	return priceList[name]
end

function economyHandler:getMoneyCost( name )
	return economyHandler:getPrice( name ).moneyCost
end

-- Sells an amount of a resource from the global resourcePool
function economyHandler:sellResource( name, amount )
	local resourceAmount = game:getResource(name)
	
	if resourceAmount >= amount then
		game:subtractResource(name, amount)
		game:addMoney( amount * priceList[name].moneyCost)
	elseif resourceAmount > 0 then
		local a = amount - ( amount - resourceAmount )
		game:subtractResource(name, a)
		game:addMoney( a * priceList[name].moneyCost )
	end
	
	return true
end

-- Buys resources and adds them to the global pool
-- Untested
function economyHandler:buyResource( name, amount )
	local cost = amount * ( priceList[name].moneyCost * 1.5 )
	
	if game:getMoney() >= cost then
		game:subtractMoney( cost )
		game:addResource( name, amount )
		return true
	else
		return false
	end
end

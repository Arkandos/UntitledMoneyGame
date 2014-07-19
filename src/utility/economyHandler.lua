
economyHandler = {}

local priceList = {}

function economyHandler:init()
	-- Resources
	economyHandler:setPrice( "flowers", 0.5 )
	economyHandler:setPrice( "pigIron", 10 )
	
	-- Buildings
	economyHandler:setPrice( "ironMine", 50 )
	economyHandler:setPrice( "flowerpicker", 20 )
	economyHandler:setPrice( "blastfurnace", 100 )
end

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

function economyHandler:getPrice( name )
	--logHandler:debug("Returning price "..tostring(name)..": "..tostring(priceList[name]))
	if priceList[name] == nil then return { moneyCost = 0 } end
	return priceList[name]
end

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

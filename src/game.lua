
game = {}

local state

-- Sets the current gamestate to "loading"
function game:init()
	state = "loading"
end

-- Get the current gamestate
function game:getState()
	return state
end

-- Set the current gamestate
function game:setState(s)
	state = s
end

-- Load all the userdata from the current map
function game:loadUserdata()
	local t = mapFunctions.getUserdata()
	game.money = t.money
	game.resources = t.resources
	if game.money == nil then game.money = 0 end
	if game.resources == nil then game.resources = {} end
end

-- Save all userdata to the current mapfile
function game:saveUserdata()
	local userdata = {}
	userdata.money = game.money
	userdata.resources = game.resources
	mapFunctions:setUserdata(userdata)
end

function game:getMoney()
	return game.money
end

function game:setMoney(amount)
	game.money = math.floor(amount)
end

function game:addMoney(amount)
	game.money = game.money + math.floor(amount)
	if game.money < 0 then game.money = 0 end
end

function game:subtractMoney(amount)
	game.money = game.money - math.floor(amount)
	if game.money < 0 then game.money = 0 end
end


function game:getResource(resource)
	if game.resources[resource] == nil then game.resources[resource] = 0 end
	return game.resources[resource]
end

function game:setResource(resource, amount)
	game.resources[resource] = amount
end

function game:addResource(resource, amount)
	if game.resources[resource] == nil then game.resources[resource] = 0 end
	game.resources[resource] = game.resources[resource] + math.floor(amount)
	
	if game.resources[resource] < 0 then game.resources[resource] = 0 end
end

function game:subtractResource(resource, amount)
	if game.resources[resource] == nil then game.resources[resource] = 0 end
	local r = game:returnResource(resource, amount)
	game.resources[resource] = game.resources[resource] - math.floor(amount)
	if game.resources[resource] < 0 then game.resources[resource] = 0 end
	return r
end

-- Local function that should not be used outside this file
function game:returnResource(resource, amount)
	if game.resources[resource] - amount >= 0 then
		return amount
	else
		return amount - (amount - game.resources[resource])
	end
end
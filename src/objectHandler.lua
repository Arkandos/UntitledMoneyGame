-- Path to object directory
local path = "objects/"
local objects = {}
local register = {}
local ids = 1

objectHandler = {}

-- Register all objects and their group
function objectHandler:load()
	
	
	-- Resources
	objectHandler:register("ironore", "resources")
	objectHandler:register("flowers", "resources")
	
	-- Extractors
	objectHandler:register("ironMine", "extractors")
	objectHandler:register("flowerpicker", "extractors")
	
	-- Industry
	objectHandler:register("blastfurnace", "industry")
	
	-- Others
	
	
	logHandler:debug("Object registration complete")
end

-- Load objects from a map object
function objectHandler:loadObjects(t)
	logHandler:debug("Loading objects from savefile")
	for k, v in pairs(t) do
		--for j, l in pairs(v) do print(tostring(j)..": "..tostring(l)) end
		local data = v
		table.remove(data, id)
		table.remove(data, x)
		table.remove(data, y)
		objectHandler:create(v.id, v.tx, v.ty, data)
	end
	logHandler:debug("Loaded "..#objects.." objects")
end

-- Get all object data into one table for easy saving
function objectHandler:saveObjects()
	local t = {}
	logHandler:debug("Saving objects")
	for k, v in pairs(objects) do
		--logHandler:debug(v:getId())
		table.insert(t, v:getData())
	end
	
	return t
end

-- Returns the object at x, y. Uses real coordinates.
function objectHandler:getObject(x, y)
	--print("Trying to get object")
	for k, v in pairs(objects) do
		local tx, ty = v:getTilePos()
		if tx == x and ty == y then 
			return objects[k] 
		end
	end
	
	return nil
end

-- Get the list of objects
function objectHandler:getObjects()
	return objects
end

function objectHandler:draw()
	for k, v in pairs(objects) do
		v:draw()
	end
end

function objectHandler:update(dt)
	for k, v in pairs(objects) do
		v:update(dt)
	end
end

-- Make another object the parent of this object
-- Displays errors if the parent contains errors
-- TODO: Warn when loading a save containing erroring objects
function objectHandler:derive(name)
	--logHandler:debug("Deriving "..name)
	local ok, chunk, result
	ok, chunk = pcall( love.filesystem.load, path .. name .. ".lua" )
	if not ok then
		logHandler:fatal("The following error occured: ".. tostring(chunk))
	else
		ok, result = pcall(chunk)
		if not ok then
			logHandler:fatal("The following error occured: "..tostring(result))
		else
			return result
		end
	end
end

-- Register object in the registry to be used later
function objectHandler:register(name, objType)
	if objType == nil then objType = "" else objType = objType.."/" end
	register[name] = love.filesystem.load(path .. objType .. name ..".lua")
	logHandler:debug("Registrering "..name.. " in object registry")
end

-- Create an objects. Uses tileCoordinates
function objectHandler:create(name, tx, ty, data)
	if register[name] then
		--print("Creating "..name)
		local obj = register[name]()
		ids = ids + 1
		obj:init(name, tx, ty, data)
		
		
		objects[ids] = obj
		
		return objects[ids]
	else
		logHandler:fatal("ERROR! Object "..name.." does not exist!")
	end
end

-- Delete an object at x, y. Uses tileCoordinates
function objectHandler:delete(tx, ty)
	for k, v in pairs(objects) do
		if v.data.tx == tx and v.data.ty == ty then
			logHandler:debug("Deleting object at "..tx.."x "..ty.."y")
			objects[k] = nil
		end
	end
end

-- Get adjacent objects
function objectHandler:getAdjacentObjects(x, y, mode)
	if mode == nil then mode = 4 end
	if x == nil or y == nil then return false end
	
	-- Gets all directly ajacent objects
	if mode == 4 then
		local t = {}
	
		table.insert(t, objectHandler:getObject(x - 1, y))
		table.insert(t, objectHandler:getObject(x + 1, y))
		table.insert(t, objectHandler:getObject(x, y - 1))
		table.insert(t, objectHandler:getObject(x, y + 1))
		
		
		return t
		
	-- Gets all objects in a 3x3 area
	elseif mode == 9 then
		local t = {}
		
		for i=-1, 1 do
			for j=-1, 1 do
				if i == 0 and j == 0 then
				else
					--print("Inserting "..tostring(objectHandler:getObject(x + j, y + i):getId()))
					table.insert(t, objectHandler:getObject(x + j, y + i))
				end
			end
		end
		
		return t
	end
end

-- Returns the tooltip of an object. Uses realCoordinates
function objectHandler:getTooltip(x, y)
	local tx, ty = utility:convertToTilePos(x, y)
	local o = objectHandler:getObject(tx, ty)
	local t = {}
	
	if o == nil then
		return false
	end
	
	t.name = o.data.id
	if o.data.resourceType ~= nil then
		t.resourceType = o.data.resourceType
		t.resourceAmount = o.data.resourceAmount
	end
	
	if o.tooltips ~= nil then
		for k, v in pairs( o.tooltips ) do
			t[k] = v
		end
	end
	
	if o.data.extractionRate ~= nil then
		t.extractionRate = o.data.extractionRate
		t.extractionAmount = o.data.extractionAmount
	end
	
	return t
end



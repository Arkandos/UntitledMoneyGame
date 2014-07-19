local path = "objects/"
local objects = {}
local register = {}
local ids = 1

objectHandler = {}

-- Register all objects
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

-- Create an object
function objectHandler:create(name, x, y, data)
	if register[name] then
		--print("Creating "..name)
		local obj = register[name]()
		ids = ids + 1
		obj:init(name, x, y, data)
		
		
		objects[ids] = obj
		
		return objects[ids]
	else
		logHandler:fatal("ERROR! Object "..name.." does not exist!")
	end
end

-- Delete an object
function objectHandler:delete(x, y)
	for k, v in pairs(objects) do
		if v.data.x == x and v.data.y == y then
			table.remove(objects, k)
		end
	end
end

-- Get adjacent objects 
function objectHandler:getAdjacentObjects(x, y, mode)
	if mode == nil then mode = 4 end
	if x == nil or y == nil then return false end
	

	if mode == 4 then
		local t = {}
	
		table.insert(t, objectHandler:getObject(x - 1, y))
		table.insert(t, objectHandler:getObject(x + 1, y))
		table.insert(t, objectHandler:getObject(x, y - 1))
		table.insert(t, objectHandler:getObject(x, y + 1))
		
		
		return t
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

function objectHandler:getTooltip(x, y)
	local tx, ty = utility:convertToTilePos(x, y)
	local o = objectHandler:getObject(tx, ty)
	local t = {}
	
	--print(tostring(o))
	if o == nil then
		return false
	end
	
	t.name = o.data.id
	if o.data.resourceType ~= nil then
		--print("Found extra resource tooltip")
		t.resourceType = o.data.resourceType
		t.resourceAmount = o.data.resourceAmount
	end
	
	if o.tooltips ~= nil then
		--print("Found extra resource tooltips, adding")
		for k, v in pairs( o.tooltips ) do
			t[k] = v
		end
	end
	
	if o.data.extractionRate ~= nil then
		--print("Found extra extraction tooltips, adding")
		t.extractionRate = o.data.extractionRate
		t.extractionAmount = o.data.extractionAmount
	end
	
	return t
end




local worldGenList = {
	tiles = {},
	tileGroups = {},
	objects = {},
	objectGroups = {}
}

local mapList = {
	tiles = {},
	objects = {}
}

worldGenerator = {}

-- Cycle through the worldGenList and generate a mapList. Then save this mapList.
-- TODO: Rework this to be able to make much bigger maps. Will also require a rewrite of many other functions
function worldGenerator:generateMap(name, sizeX, sizeY)
	logHandler:debug("Generating mapList")
	local objects = {}
	local t = os.time()
	sizeY = sizeY - 1
	math.randomseed(os.time())
	math.random(); math.random(); math.random();
	
	for k, v in pairs(worldGenList.tiles) do
		logHandler:debug("Generating "..k)
		for y=1, sizeY do
			if mapList.tiles[y] == nil then mapList.tiles[y] = {} end
			
			for x=1, sizeX do
				if mapList.tiles[y][x] == nil then mapList.tiles[y][x] = {} end
				
				local c = math.random(0, 100)
		
				if c <= v.chance then
					if v.replaceTile == nil then
						mapList.tiles[y][x] = v.tile
					else
						if mapList.tiles[y][x] ~= nil then
							if mapList.tiles[y][x] == v.replaceTile then mapList.tiles[y][x] = v.tile end
						end
					end
				end
			end
		end
	end
	
	for k, v in pairs(worldGenList.objects) do
		
		for y=1, sizeY - 1 do
			if objects[y] == nil then objects[y] = {} end
			
			for x=1, sizeX do
				if objects[y][x] == nil then objects[y][x] = {} end
				
				local c = math.random(0, 100)
				local amount = math.random(v.resourceAmountMin, v.resourceAmountMax)
				
				if c <= v.chance then
					local realX, realY = utility:convertToRealPos(x, y)
					if v.placement ~= nil then
						if v.placement.tiles ~= nil then
							if worldGenerator:checkGroups(x, y, v.placement.tiles) then
								logHandler:debug("Generating "..tostring(k).." with chance "..c)
								objects[y][x] = { id = v.objId, tx = x, ty = y, texture = v.texture, group = v.group, resourceType = v.resource, resourceAmount = amount } 
								--mapList.objects[y][x] = {objId = v.objId, x = x, y = y, data = {texture = v.texture, visible = v.visible, resource = v.resource, resourceAmount = amount} }
							end
						end
						
						if v.placement.objects ~= nil then
							if worldGenerator:checkGroups(x, y, v.placement.objects, true) then
								logHandler:debug("Generating "..tostring(k).." with chance "..c)
								objects[y][x] = { id = v.objId, tx = x, ty = y, texture = v.texture, group = v.group, resourceType = v.resource, resourceAmount = amount } 
								--mapList.objects[y][x] = {objId = v.objId, x = x, y = y, data = {texture = v.texture, visible = v.visible, resource = v.resource, resourceAmount = amount} }
								
							end
						end
					
					end
				end
			end
		end
	end
	
	logHandler:info(#objects)
	mapList.userdata = { money = 100, resources = {} }
	

	for i=1, #objects do
		for k, v in pairs(objects[i]) do
			if v.id ~= nil then
				table.insert(mapList.objects, v)
			end
		end
	end

	mapFunctions:saveMap(name, mapList)
	logHandler:debug("Generated mapList in "..(os.time() - t))
	
end

-- Adds a tile to the worldgenerator list
function worldGenerator:addWorldGenTile(id, tile, replaceTile, chance, group)
	worldGenList.tiles[id] = { tile = tile, replaceTile = replaceTile, chance = chance}
	if group ~= nil then
		worldGenList.tileGroups[tile] = group
	end
end

-- Add an object to the worldgenerator list
function worldGenerator:addWorldGenObject(id, objId, texture, chance, visible, placement, group, resource, resourceAmountMin, resourceAmountMax)
	worldGenList.objects[id] = { objId = objId, texture = texture, visible = visible, group = group, chance = chance, placement = placement, resource = resource, resourceAmountMin = resourceAmountMin, resourceAmountMax = resourceAmountMax}
	if group ~= nil then
		worldGenList.objectGroups[id] = group
	end
end

-- Deletes the worldgenerator list
function worldGenerator:clearWorldGenList()
	worldGenList = {}
end

function worldGenerator:getTileGroups(x, y)
	local tile = mapList.tiles[y][x]
	return worldGenList.tileGroups[tile]
end

function worldGenerator:getObjectGroups(x, y)
	local object = mapList.objects[y][x].objId
	return worldGenList.objectGroups[object]
end

function worldGenerator:checkGroups(x, y, groups, object)
	local g
	if object == nil or object == false then
		g = worldGenerator:getTileGroups(x, y)
	else
		g = worldGenerator:getObjectGroups(x, y)
	end
	
	if g == nil then return false end
	
	for i=1, #g do
		for j=1, #groups do
			if g[i] == groups[j] then
				return true
			end	
		end
	end
	return false
end


-- Generate a standard map. 
-- TODO: Add a better way to add new kinds of maps
function worldGenerator:standardMap(name, sizeX, sizeY)
	worldGenerator:addWorldGenTile("background", "grass", nil, 100, { "land", "ground" } )
	
	
	
	worldGenerator:addWorldGenObject("ironore", "ironore", "ironore", 5, true, { tiles = { "ground" } }, { "ironore", "ore"}, "ironore", 100, 300)
	worldGenerator:addWorldGenObject("flowers", "flowers", "flowers", 5, true, { tiles = { "ground" } }, { "flowers", "flower", "biological" }, "flowers", 40, 70)
	
	worldGenerator:generateMap(name, sizeX, sizeY)
end


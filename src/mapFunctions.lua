
local tileW, tileH, tileset, quads, tileTable, map, mapName

mapFunctions = {}

-- Loads a map from the path
function mapFunctions:loadMap(path)
	map = Tserial.unpack( love.filesystem.read( "maps/"..path..".lua") )
	game:loadUserdata()
	objectHandler:loadObjects(map.objects)
end

function mapFunctions:update(dt)

end

-- Returns the current map object
function mapFunctions:getMap()
	return map
end

-- Returns the name of the current map
function mapFunctions:getMapName()
	return mapName
end

-- Returns the current userdata
function mapFunctions:getUserdata()
	return map.userdata
end

-- Change the current userdata
function mapFunctions:setUserdata(args)
	for k, v in pairs(args) do
		map.userdata[k] = v
	end
end

-- Deprecated
function mapFunctions:getObjects()
	return map.objects
end

-- Returns the tile at coord
function mapFunctions:getTile(x, y)
	for i=1, #map.tiles do

		if y >= i and y <= i * 32 then
			for j=1, #map.tiles[i] do
				if x >= j and x <= j * 32 then
					return map.tiles[i][j]
				end
			end
		end
	end
end

-- Changes the tile at <coord> to <tileName>
function mapFunctions:changeTile(x, y, tileName)
	local x, y = math.floor(x), math.floor(y)
	
	for i=1, #map.tiles do

		if y >= i and y <= i * 32 then
			for j=1, #map.tiles[i] do
				if x >= j and x <= j * 32 then
					map.tiles[i][j] = tileName
					return
				end
			end
		end
	end
end


-- Deprecated?
function mapFunctions:newMap(tileWidth, tileHeight, tilesetPath, tileString, quadInfo)
	tileW = tileWidth
	tileH = tileHeight
	tileset = love.graphics.newImage(tilesetPath)
	
	
	local tilesetW, tilesetH = tileset:getWidth(), tileset:getHeight()
	
	quads = {}
	
	for _, info in ipairs(quadInfo) do
		quads[info[1]] = love.graphics.newQuad(info[2], info[3], tileW, tileH, tilesetW, tilesetH)
	end
	
	tileTable = {}
	
	local width = #tileString[1]
	
	for x = 1, width, 1 do tileTable[x] = {} end
	
	print(#tileString)
	print(#tileString[1])
	
	
	for y=1, #tileString do
		for x=1, #tileString[y] do
			tileTable[x][y] = tileString[y][x]
			print("X: "..x..", Y: "..y..", "..tileString[y][x])
		end
	end
	
end

function mapFunctions:drawMap()
	for columnIndex, column in ipairs(map.tiles) do
		for rowIndex, char in ipairs(column) do
			local y, x = (columnIndex-1)*textureList.tilesetList.tileW, (rowIndex-1)*textureList.tilesetList.tileH
			love.graphics.draw(textureList.tileset, textureList.quads[char], x, y)
		end
	end
	
	--[[for columnIndex, column in ipairs(map.objects) do
		for rowIndex, char in ipairs(column) do
			local y, x = (columnIndex-1)*textureList.tilesetList.tileW, (rowIndex-1)*textureList.tilesetList.tileH
			for k, v in pairs(char) do
				if k == "texture" then
					love.graphics.draw(textureList.objects[v] , x, y)
				end
			end
		end
	end--]]
end

-- Save the map
function mapFunctions:saveMap(name, m)
	if name == nil then
		if mapName == nil then
			return false
		else
			name = mapName
		end
	end
	game:saveUserdata()
	
	if m == nil then
		if map == nil then return false else
			m = map
		end
	end
	
	if #objectHandler:getObjects() > 0 then
		m.objects = objectHandler:saveObjects()
	end
	
	if not love.filesystem.exists(saveDir.."/maps") then 
		logHandler:debug("Making dir")
		love.filesystem.createDirectory("maps") 
	end
	
	-- Tserial.pack 3rd param makes file userreadable
	local success = love.filesystem.write( "maps/"..name..".lua", Tserial.pack(m, false, true))
	
	if success then
		logHandler:debug("Map saved")
	else
		logHandler:error("Map could not be saved!")
	end
end

function mapFunctions:openMap(name)
	logHandler:debug("Searching for /maps/"..name..".lua")
	if love.filesystem.exists("maps/"..name..".lua") then
		logHandler:info("Savefile found, opening")
		mapFunctions:loadMap(name)
	else
		worldGenerator:standardMap(name, math.floor(love.window.getWidth() / 32 ), math.floor(love.window.getHeight() / 32))
		mapFunctions:loadMap(name)
	end
	
	game:setState("running")
	mapName = name
	menu:gameMenuInit()
	guiHandler:setCurrentPage("gameMenu")
end

function mapFunctions:deleteMap(name)
	logHandler:info("Deleting map "..name)
	love.filesystem.remove("maps/"..name..".lua")
end

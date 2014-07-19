-- Path to the textureLocation
local textureLocation = "images/"

textureList = { 
	quads = {},
	tileset,
	tilesetList = {
		tileW = 1,
		tileH = 1,
		path = "",
		tilesetW = 1,
		tilesetH = 1
	},
	buttons = {},
	objects = {}
}

-- Add a quad from the current tileset
local function addQuad( name, x, y)
	local t = textureList.tilesetList
	textureList.quads[name] = love.graphics.newQuad(x, y, t.tileW, t.tileH, t.tilesetW, t.tilesetH)
end

-- TODO: Implement this properly. Not currently working/used
local function addButtons(name, texturePath)
	textureList.buttons[name] = textureLocation.."/buttons/"..texturePath..".png"
end

-- Add an object texture. texturePath is only needed if the name differs from the textures name
local function addObject( name, texturePath)
	if texturePath == nil then texturePath = name end
	textureList.objects[name] = love.graphics.newImage(textureLocation.."objects/"..texturePath..".png")
end

-- Loads all quads from the current tileset
-- Register all quads here
local function loadQuads()
	addQuad("grass", 0, 0)
	addQuad("flowers", 0, 32)
	addQuad("box", 32, 0)
	addQuad("boxTop", 32, 32)
end

-- Loads object textures
-- Register all object textures here
local function loadObjects()
	addObject("ironore")
	addObject("greenTile")
	addObject("redTile")
	addObject("flowerpicker")
	addObject("ironMine")
	addObject("flowers")
	addObject("bomb")
	addObject("blastfurnace")
end

local function loadButtons()
	
end

-- Loads all textures into memory. Sets the width and height of each tile
function textureList:loadTextures(path, tilew, tileh)
	local tileset = love.graphics.newImage(textureLocation..path)
	
	textureList.tileset = tileset
	textureList.tilesetList.tileW = tilew
	textureList.tilesetList.tileH = tileh
	textureList.tilesetList.path = textureLocation..path
	textureList.tilesetList.tilesetW = tileset:getWidth()
	textureList.tilesetList.tilesetH = tileset:getHeight()
	
	loadQuads()
	loadButtons()
	loadObjects()
	logHandler:debug("Textures loaded")
end

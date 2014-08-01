
require 'mapFunctions'
require 'lib/Tserial'
require 'utility/textureList'
require 'utility/guiHandler'
require 'utility/utility'
require 'utility/colorList'
require 'utility/resolutionHandler'
require 'utility/logHandler'
require 'utility/configHandler'
require 'utility/economyHandler'
require 'objectHandler'
require 'worldGenerator'
require 'menu'
require 'game'


local autoSaveRate
local version = "Alpha 0.1.4"
local windowName = "Untitled Money Game v."..version


-- Main function. Load everything else
function love.load()
	-- Pre-Loading phase
	-- Load all textures, the font and other core features. Also load config values
	logHandler:debug("Starting pre-loading phase")
	configHandler:init()
	resolutionHandler:init()
	debugActive = configHandler:getValue("debug", false)
	autoSaveRate = configHandler:getValue("autoSaveRate", 60)
	love.window.setTitle(windowName)
	game:init()
	saveDir = love.filesystem.getSaveDirectory()
	textureList:loadTextures("tileset.png", 32, 32)
	font = love.graphics.newFont("images/CaviarDreams.ttf", 15)
	love.graphics.setFont(font)
	
	-- Loading phase
	-- Load all objects, buttons, mainMenu etc.
	logHandler:debug("Starting load phase")
	game:setState("mainMenu")
	economyHandler:init()
	objectHandler:load()
	guiHandler:init()
	menu:mainMenu()
	menu:optionsMenu()
	
	
	-- End of loading phase
	-- Output info to the console
	logHandler:debug("Loading phase has ended")
	logHandler:info("Savedirectory: "..saveDir)
	logHandler:info("Width: "..love.window.getWidth()..", Height: "..love.window.getHeight())
	logHandler:config("Autosaving every "..autoSaveRate.." seconds" )
	logHandler:config("Updating tooltips every "..configHandler:getValue("tooltipUpdateRate").." seconds" )
	logHandler:config("Randomizing mainmenu color: "..tostring(configHandler:getValue("randomizeMainMenu", true)))
	--objectHandler:create("flowerpicker", 10, 10)
end 

function love.draw()
	love.graphics.setColor(255, 255, 255, 255)
	if game:getState() == "running" then
		mapFunctions:drawMap()
		objectHandler:draw()
	end
	menu:draw()
	guiHandler:draw()
	menu:drawHoldObject()
end

function love.update(dt)
	if game:getState() == "running" then
		mapFunctions:update(dt)
		objectHandler:update(dt)
		if autoSaveTimer == nil then autoSaveTimer = 0 end
		if autoSaveTimer >= autoSaveRate then
			autoSaveTimer = 0
			mapFunctions:saveMap()
		else
			autoSaveTimer = autoSaveTimer + dt
		end
	end
	menu:update(dt)
	guiHandler:update(dt)
end

function love.mousepressed(x, y, button)
	local tx, ty = utility:convertToTilePos(x, y)
	logHandler:debug(tx..", "..ty)
	if menu:dropObject(tx, ty, button) then return true end
	if guiHandler:mousePressed(x, y, button) then return true end
	
	if button == "l" then
		if game:getState() == "running" then
			logHandler:debug(mapFunctions:getTile(x, y))
			local o = objectHandler:getObject(tx, ty)
			if o == nil then
				--objectHandler:create("ironMine", tx, ty, { resource = "ironore", resourceAmount = 0, group = {"mine"}, mode = 4 } )
			else
				logHandler:debug(o:getId())
			end
			
			
		end
	end
end

function love.mousereleased(x, y, button)
	
end

function love.keypressed(key, isrepeat)
	guiHandler:keyPressed(key)
end

function love.textinput(t)
	guiHandler:textInput(t)
end

function love.keyreleased()
	
end

function love.focus()
	
end

function love.quit()
	-- Save the map.
	-- Set the state to quitting
	game:setState("quitting")
	mapFunctions:saveMap(mapFunctions:getMapName(), mapFunctions:getMap())
end


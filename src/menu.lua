
menu = {}

-- Gives the main menu a random color each time restarted. TODO: Make this a config option once the options screen is in.
local mainMenuColor = utility:randomizeColor()
local localFiles, holdObject
local gameMenuList = {}

function menu:update(dt)

end

function menu:draw()
	local state = game:getState()
	if state == "loading" or state == "mainMenu" then
		love.graphics.setColor(mainMenuColor)
		love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())
	elseif state == "running" then
		menu:gameMenu()
	end
end

-- Setup the main menu
function menu:mainMenu()
	local width, height = love.window.getDimensions()
	local files = love.filesystem.getDirectoryItems("maps")
	local xWidth = 300
	local yHeight = 80
	local x = width / 2 - xWidth / 2
	local y = 100
	
	local colors = {boxColor = colorList.red, textColor = colorList.white}
	localFiles = 0
	
	for k, v in pairs(files) do
		local s = v:sub(1, -5)
		localFiles = localFiles + 1
		guiHandler:newButton("save"..localFiles, s, menu.openMap, s, nil, x, y, xWidth, yHeight, true, "mainMenu")
		guiHandler:newButton("delete save"..localFiles, "X", menu.deleteMap, {name = s, id = "save"..localFiles}, colors, x + xWidth, y + (yHeight / 2), 50, yHeight / 2, true, "mainMenu", { name = "Delete world" })
		y = y + 100
	end
	
	for i=localFiles + 1, 3 do
		guiHandler:newTextBox("save"..i, "-- Empty save -- ", menu.openMap, "save"..i, nil, x, y, xWidth, yHeight, true, "mainMenu")
		y = y + 100
	end
	
	guiHandler:newButton("increaseResolution", [[/\]], menu.changeRes, "up", nil, x + xWidth + 50, y + 100, 50, yHeight / 2, true, "mainMenu", { name = "Increase resolution" } )
	guiHandler:newButton("decreaseResolution", [[\/]], menu.changeRes, "down", nil, x + xWidth + 150, y + 100, 50, yHeight / 2, true, "mainMenu", { name = "Decrease resolution" } )
	
	guiHandler:newButton("toggleDebugmode", "Debug", menu.toggleDebug, nil, nil, x - xWidth, y + 100, 150, yHeight / 2, true, "mainMenu", { name = "Toggle debugging mode" } )

	if debugActive then
		guiHandler:changeButton("toggleDebugmode", { colors = {boxColor = colorList.green, textColor = colorList.black} } )
	else
		guiHandler:changeButton("toggleDebugmode", { colors = {boxColor = colorList.white, textColor = colorList.black} } )
	end
end

-- Inits all buttons that should be visible during the game
function menu:gameMenuInit()
	guiHandler:newButton("buildIronMine", "Iron mine", menu.holdObject, { name = "ironMine", data = { mode = 4 } }, nil, 0, love.window.getHeight() - 50, 100, 50, true, "gameMenu" )
	guiHandler:newButton("buildFlowerpicker", "Flower picker", menu.holdObject, { name = "flowerpicker", data = { mode = 9 } }, nil, 100, love.window.getHeight() - 50, 100, 50, true, "gameMenu" )
	guiHandler:newButton("buildBlastfurnace", "Blastfurnace", menu.holdObject, { name = "blastfurnace", data = {} }, nil, 200, love.window.getHeight() - 50, 100, 50, true, "gameMenu" )
	
	guiHandler:newButton("sellObject", "Sell", menu.holdObject, { name = "bomb", data = {} }, nil, love.window.getWidth() - 100, love.window.getHeight() - 50, 100, 50, true, "gameMenu" )
end

-- Draws the overlay. 
function menu:gameMenu()
	love.graphics.setColor(colorList.white)
	love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), 30)
	love.graphics.rectangle("fill", 0, love.window.getHeight() - 50, love.window.getWidth(), love.window.getHeight())
	
	love.graphics.setColor(colorList.black)
	local money = game:getMoney()
	local a = math.floor(money / 1000)
	
	if a > 0 then
		a = tostring(a.." k")
	else
		a = tostring(money)
	end
	
	love.graphics.print("$ "..a, 5, 5)
	love.graphics.print("Ironore "..game:getResource("ironore"), 100, 5)
	love.graphics.print("Pig iron "..game:getResource("pigIron"), 200, 5)
end

-- Opens the map specified
function menu:openMap(name)
	for i=1, localFiles do
		guiHandler:changeButton("delete save"..i, {visible = false}, "mainMenu" )
	end
	
	guiHandler:changeButton("save1", {visible = false}, "mainMenu" )
	guiHandler:changeButton("save2", {visible = false}, "mainMenu"  )
	guiHandler:changeButton("save3", {visible = false}, "mainMenu"  )
	guiHandler:changeButton("increaseResolution", {visible = false}, "mainMenu"  )
	guiHandler:changeButton("decreaseResolution", {visible = false}, "mainMenu"  )
	
	mapFunctions:openMap(name)
end

-- Deletes the map specified
function menu:deleteMap(args)
	local name = args.name
	local id = args.id
	mapFunctions:deleteMap(name)
	guiHandler:changeButton(id, {text = "-- Empty save --", textbox = true}, "mainMenu"  )
	guiHandler:changeButton("delete "..id, {visible = false}, "mainMenu" )
end

-- Changes resolution in <dir>
function menu:changeRes(dir)
	resolutionHandler:changeResolutionStep(dir)
end

-- Makes the mouse "hold" an object
function menu:holdObject(args)
	holdObject = args
end	

-- Drops an object on tile tx, ty
function menu:dropObject(tx, ty, button)
	if holdObject ~= nil then

		if button == "l" then
			
			if holdObject.name == "bomb" then
				if objectHandler:getObject(tx, ty) ~= nil then
					if menu:sellObject(tx, ty) then holdObject = nil end
					return true
				end
			end
			
			if objectHandler:getObject(tx, ty) == nil then
				if economyHandler:getPrice(holdObject.name).moneyCost <= game:getMoney() then
					game:subtractMoney( economyHandler:getPrice( holdObject.name ).moneyCost )
					objectHandler:create(holdObject.name, tx, ty, holdObject.data)
					holdObject = nil
					return true
				end
			else
				return false
			end
		elseif button == "r" then
			holdObject = nil
		end	
		

		return false
	end	
	return false
end

-- Returns the currently held object
function menu:getHoldObject()
	return holdObject
end

-- Draws the currently held object
function menu:drawHoldObject()
	if holdObject ~= nil then
		local x, y = love.mouse.getPosition()
		x = x - 16
		y = y - 16
		love.graphics.setColor(255, 255, 255, 255)
		if holdObject.name == "bomb" then
			love.graphics.draw(textureList.objects["redTile"], x, y)
		else
			if holdObject.data.mode ~= 9 then
				love.graphics.draw(textureList.objects["greenTile"], x, y)
			end
		end
		
		
		
		if holdObject.data.mode == 4 then
			love.graphics.draw(textureList.objects["greenTile"], x - 32, y)
			love.graphics.draw(textureList.objects["greenTile"], x + 32, y)
			love.graphics.draw(textureList.objects["greenTile"], x, y - 32)
			love.graphics.draw(textureList.objects["greenTile"], x, y + 32)
		elseif holdObject.data.mode == 9 then
			for i=-1, 1 do
				for j=-1, 1 do
					love.graphics.draw(textureList.objects["greenTile"], x + ( j * 32 ), y + ( i * 32 ))
				end
			end
		end
		
		love.graphics.draw(textureList.objects[holdObject.name], x, y)
	end
end

-- Sells the object at tx, ty
function menu:sellObject( tx, ty )
	local o = objectHandler:getObject( tx, ty )
	if o == nil then
		logHandler:debug("Tried to sell nil object")
		return false
	else
		if o:sell() then return true else return false end
	end
end

-- Toggles the debug mode
function menu:toggleDebug()
	debugActive = not debugActive
	if debugActive then
		guiHandler:changeButton("toggleDebugmode", { colors = {boxColor = colorList.green, textColor = colorList.black} } )
	else
		guiHandler:changeButton("toggleDebugmode", { colors = {boxColor = colorList.white, textColor = colorList.black} } )
	end
	logHandler:debug("Debugging value has been changed. Restart game to see changes")
	configHandler:setValue("debug", debugActive)
end


guiHandler = {
	objects = {},
	tooltips = {},
	menus = {}
}

local activeTextBox, tooltipUpdateRate, buttonTooltipName, activeMenu
local tooltipTimer = 0
local input = ""
local currentPage = "mainMenu"
local tooltipX, tooltipY = 0, 0
local menu = { x = 0, y = 0 }


-- Sets the tooltipUpdateRate from the config
function guiHandler:init()
	tooltipUpdateRate = configHandler:getValue("tooltipUpdateRate", 1)
end

function guiHandler:draw()
	for k, v in pairs( guiHandler.objects[currentPage] ) do
		if v.visible then
			love.graphics.setColor(v.colors.boxColor)
			love.graphics.rectangle( "fill", v.x, v.y, v.width, v.height )
			love.graphics.setColor(colorList.black)
			love.graphics.rectangle( "line", v.x, v.y, v.width, v.height )
			if v.text ~= nil then
				local s = #v.text
				local ySpot = math.floor(v.height / 2) - 5 + v.y
				local xSpot = math.floor(v.width / 2 - s + 5) + v.x
				
				love.graphics.setColor(v.colors.textColor)
				--love.graphics.print(v.text, xSpot, ySpot)
				love.graphics.printf(v.text, v.x, ySpot, v.width - 2, "center", 0, 1, 1)
			end
		end
	end
	
	if activeMenu ~= nil then
		for k, v in pairs( guiHandler.menus[currentPage][activeMenu] ) do
			if v.visible then
				love.graphics.setColor(v.colors.boxColor)
				love.graphics.rectangle( "fill", v.x, v.y, v.width, v.height )
				love.graphics.setColor(colorList.black)
				love.graphics.rectangle( "line", v.x, v.y, v.width, v.height )
				if v.text ~= nil then
					local s = #v.text
					local ySpot = math.floor(v.height / 2) - 5 + v.y
					local xSpot = math.floor(v.width / 2 - s + 5) + v.x
					
					love.graphics.setColor(v.colors.textColor)
					--love.graphics.print(v.text, xSpot, ySpot)
					love.graphics.printf(v.text, v.x, ySpot, v.width - 2, "center", 0, 1, 1)
				end
			end
		end
	end
	
	
	
	for k, v in pairs( guiHandler.tooltips ) do
		local tooltipWidth = 200
		
		local t = v
		local x, y = v.x, v.y
		local a = -2
		
		
		if x + tooltipWidth > love.window.getWidth() then
			x = x - tooltipWidth
		end
		
		
		for key, value in pairs(t) do
			a = a + 1
		end
		
		if t.desc ~= nil then
			for key, value in ipairs(t.desc) do
				a = a + 1
				if #value * 10 > tooltipWidth then
					tooltipWidth = #value * 10
				end
			end
		end
		
		
		local tooltipHeight = ( a ) * 15 + 10
		
		if y + tooltipHeight > love.window.getHeight() then
			y = y - tooltipHeight
		end
		love.graphics.setColor( colorList.white )
		love.graphics.rectangle("fill", x, y, tooltipWidth, tooltipHeight )
		
		love.graphics.setColor( colorList.black )
		love.graphics.rectangle("line", x, y, tooltipWidth, tooltipHeight )
		
		y = y + 2
		guiHandler:drawTooltipLine(v.name, x, y, tooltipWidth)
		y = y + 20
		
		if v.resourceType ~= nil then
			guiHandler:drawTooltipLine(v.resourceType..": "..v.resourceAmount, x, y, tooltipWidth)
			y = y + 20
		end
		
		if v.extractionRate ~= nil then
			guiHandler:drawTooltipLine("Extractionrate: "..v.extractionAmount.."/"..v.extractionRate, x, y, tooltipWidth)
			y = y + 20
		end
		
		if v.temp ~= nil then
			guiHandler:drawTooltipLine("Temp: "..v.temp.."/"..v.maxTemp.." C", x, y, tooltipWidth )
			y = y + 20
		end
		
		if t.desc ~= nil then
			for key, value in ipairs(t.desc) do
				guiHandler:drawTooltipLine(t.desc[key], x, y, tooltipWidth)
				y = y + 20
			end
		end
		
		
	end
end

function guiHandler:update(dt)
	local x, y = love.mouse.getPosition()
	local tFound = false
	
	for k, v in pairs( guiHandler.objects[currentPage] ) do
		if v.visible then
			if utility:checkHitbox( x, y, v.x, v.y, v.x + v.width, v.y + v.height ) then
				if v.tooltip ~= nil then
					if k == buttonTipName or buttonTipName == nil then
						guiHandler:setTooltipButton( v.tooltip, x, y, "buttonTooltip" )
						tFound = true
					else
						--guiHandler:clearTooltip("buttonTooltip", "button")
					end
				end
			else

			end
		end
	end
	
	if not tFound then guiHandler:clearTooltip("buttonTooltip", "button") end
	
	if activeMenu ~= nil then
		for k, v in ipairs( guiHandler.menus[currentPage][activeMenu] ) do
			if v.visible then
				if utility:checkHitbox( x, y, v.x, v.y, v.x + v.width, v.y + v.height ) then
					if v.tooltip ~= nil then
						if k == buttonTipName or buttonTipName == nil then
							guiHandler:setTooltipButton( v.tooltip, x, y, "buttonTooltip" )
							tFound = true
						else
							--guiHandler:clearTooltip("buttonTooltip", "button")
						end
					end
				else

				end
			end
		end
	end
	
	tooltipTimer = tooltipTimer + dt
	if tooltipTimer >= tooltipUpdateRate then
		tooltipTimer = 0
		if tooltipX ~= nil or tooltipX > 0 then 
			guiHandler:setTooltipObject(tooltipX, tooltipY)
		end
	end
end

function guiHandler:mousePressed(x, y, button)
	if button == "l" then
		guiHandler:clearTooltip()
		
		if activeMenu ~= nil then
			for k, v in ipairs( guiHandler.menus[currentPage][activeMenu] ) do
				if v.visible then
					if utility:checkHitbox( x, y, v.x, v.y, v.x + v.width, v.y + v.height ) then
						guiHandler:closeMenu()
						v.func(self, v.args)
						return true
					end
				end
			end
		end
		
		guiHandler:closeMenu()
		
		for k, v in pairs( guiHandler.objects[currentPage] ) do
			if v.visible then
				if utility:checkHitbox( x, y, v.x, v.y, v.x + v.width, v.y + v.height ) then
					
					if v.textbox ~= nil then
						guiHandler:openTextBox(k)
					else
						v.func(self, v.args)
					end
					
					return true
				end
			end
		end
		
	elseif button == "r" then
		guiHandler:closeMenu()
		if guiHandler:setTooltipObject(x, y) == false then guiHandler:clearTooltip() end
	end
	return false
end

function guiHandler:keyPressed(key, isrepeat)
	if activeTextBox ~= nil then
		logHandler:debug(activeTextBox.." pressed "..key)
		local t = guiHandler.objects[currentPage][activeTextBox].text
		if key == "backspace" then
			guiHandler.objects[currentPage][activeTextBox].text = string.sub(t, 1, #t-1)
			input = string.sub(t, 1, #t-1)
		elseif key == "escape" or key == "return" then
			guiHandler:closeTextBox(activeTextBox)
		end 
	end
end

function guiHandler:textInput(t)
	if activeTextBox ~= nil then
		input = input .. t
		guiHandler.objects[currentPage][activeTextBox].text = input
	end
end

-- Sets the current tooltip being displayed
function guiHandler:setTooltipObject(x, y, name)
	if name == nil then name = "tooltip1" end
	local t = objectHandler:getTooltip(x, y)
	if t == false then
		guiHandler:clearTooltip("tooltip1", "object")
		return false
	else
		tooltipX, tooltipY = x, y
		guiHandler.tooltips[name] = t
		guiHandler.tooltips[name].x = x
		guiHandler.tooltips[name].y = y
	end
end

function guiHandler:setTooltipButton(tooltip, x, y, name)
	if name == nil then name = "buttonTooltip" end
	guiHandler.tooltips[name] = tooltip
	guiHandler.tooltips[name].x = x
	guiHandler.tooltips[name].y = y
	buttonTooltipName = name
	--for k, v in pairs(guiHandler.tooltips) do print(tostring(k).." "..tostring(v)) end
	--print("Set buttonTooltip successfully to "..tostring(tooltip.name).." with x: "..tostring(guiHandler.tooltips[name].x).." and y: "..tostring(guiHandler.tooltips[name].y))
end

-- Clears a tooltip or if name is nil, clears all tooltips
function guiHandler:clearTooltip(name, mode)
	if name == nil then
		guiHandler.tooltips = {}
	else
		guiHandler.tooltips[name] = nil
	end
	
	if mode == nil then mode = "object" end
	if mode == "object" then
		tooltipX = 0
		tooltipY = 0
	elseif mode == "button" then
		buttonTooltipName = nil
	end
end

-- Creates a new button object
function guiHandler:newButton(name, text, func, args, colors, x, y, width, height, visible, page, tooltip, menuName)
	if page == nil then page = currentPage end
	if visible == nil then visible = true end
	if text == nil then text = "" end
	if colors == nil then 
		colors = {}
		colors.boxColor = colorList.white 
		colors.textColor = colorList.black
	end
	guiHandler:newPage(page)
	if menuName == nil then
		guiHandler.objects[page][name] = { text = text, func = func, args = args, colors = colors, x = x, y = y, width = width, height = height, visible = visible, tooltip = tooltip}
	else
		logHandler:debug("Adding menuButton")
		guiHandler:newMenu( menuName, page )
		table.insert( guiHandler.menus[page][menuName], { text = text, func = func, args = args, colors = colors, x = x, y = y, width = width, height = height, visible = visible, tooltip = tooltip} )
		--guiHandler:sortMenu()
	end
end

-- Changes the button <name> with <args>
function guiHandler:changeButton(name, args, page)
	if page == nil then page = currentPage end
	for k, v in pairs(args) do
		guiHandler.objects[page][name][k] = v
	end
end

-- Creates a new textBox object
function guiHandler:newTextBox(name, text, func, args, colors, x, y, width, height, visible, page, tooltip)
	guiHandler:newButton(name, text, func, args, colors, x, y, width, height, visible, tooltip)
	guiHandler.objects[page][name].textbox = true
end

-- Opens a textBox for editing
function guiHandler:openTextBox(name, page)
	if page == nil then page = currentPage end
	local v = guiHandler.objects[page][name]
	v.text = ""
	activeTextBox = name
end

-- Closes a textBox and gives the func the current input
function guiHandler:closeTextBox(name, page)
	if page == nil then page = currentPage end
	local v = guiHandler.objects[page][name]
	v.func(self, input)
	activeTextBox = nil
	input = ""
end

-- Creates a new menu
function guiHandler:newMenu( name, page )
	if page == nil then page = currentPage end
	guiHandler:newPage( page )
	if guiHandler.menus[page][name] == nil then
		guiHandler.menus[page][name] = {}
	end
end

function guiHandler:addToMenu( menuName, page, buttonArgs )
	guiHandler:newMenu( menuName, page )
	guiHandler:sortMenu()
end

function guiHandler:removeFromMenu( menuName, page, id )
	if page == nil then page = currentPage end
	guiHandler:newMenu( menuName, page )
	table.remove( guiHandler.menus[page][menuName], id )
	guiHandler:sortMenu()
end

function guiHandler:openMenu( name, x, y )
	if page == nil then page = currentPage end
	if activeMenu ~= nil then guiHandler:closeMenu() end
	activeMenu = name
	menu.x = x
	menu.y = y
	guiHandler:sortMenu()
end

function guiHandler:closeMenu()
	activeMenu = nil
end

function guiHandler:sortMenu()
	if activeMenu ~= nil then
		local ox, oy = menu.x, menu.y
		local x, y = menu.x, menu.y
		local decreasing = false
		for k, v in ipairs( guiHandler.menus[currentPage][activeMenu] ) do
			v.x = x
			if v.y - v.height <= 30 then
				y = oy
				if decreasing then
					x = x - v.width
				else
					if x + v.width <= love.window.getWidth() then
						x = x + v.width
					else
						x = x - v.width
						decreasing = true
					end
				end
			end
			v.y = y - v.height
			y = y - v.height
		end
	end
end

-- Returns a button
function guiHandler:getButton( name, page )
	if page == nil then page = currentPage end
	return guiHandler.objects[page][name]
end

-- Creates a new page
function guiHandler:newPage(name)
	if guiHandler.objects[name] == nil then guiHandler.objects[name] = {} end
	if guiHandler.menus[name] == nil then guiHandler.menus[name] = {} end
end

-- Changes the current page. If that page does not exist, creates it
function guiHandler:setCurrentPage(name)
	guiHandler:newPage(name)
	currentPage = name
end

-- Draws a tooltip line
function guiHandler:drawTooltipLine(name, x, y, tooltipWidth, color)
	if color == nil then color = "black" end
	love.graphics.setColor( colorList[color] )
	love.graphics.printf(utility:firstToUpper( name ), x, y, tooltipWidth, "center")
end

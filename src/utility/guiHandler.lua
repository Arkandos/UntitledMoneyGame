
guiHandler = {
	objects = {},
	tooltips = {}
}

local activeTextBox, tooltipUpdateRate, buttonTooltipName
local tooltipTimer = 0
local input = ""
local currentPage = "mainMenu"
local tooltipX, tooltipY = 0, 0


function guiHandler:init()
	tooltipUpdateRate = configHandler:getValue("tooltipUpdateRate", 1)
end

function guiHandler:draw()
	for k, v in pairs( guiHandler.objects[currentPage] ) do
		if v.visible then
			love.graphics.setColor(v.colors.boxColor)
			love.graphics.rectangle( "fill", v.x, v.y, v.width, v.height )
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
	
	local tooltipWidth = 200
	
	for k, v in pairs( guiHandler.tooltips ) do
		
		love.graphics.setColor( colorList.white )
		local t = v
		local x, y = v.x, v.y
		local a = 0
		table.remove(t, x)
		table.remove(t, y)
		
		for key, value in pairs(t) do
			a = a + 1
		end
		
		love.graphics.rectangle("fill", x, y, tooltipWidth, ( a + 2 ) * 5 )
		
		
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
function guiHandler:newButton(name, text, func, args, colors, x, y, width, height, visible, page, tooltip)
	if page == nil then page = currentPage end
	if visible == nil then visible = true end
	if text == nil then text = "" end
	if colors == nil then 
		colors = {}
		colors.boxColor = colorList.white 
		colors.textColor = colorList.black
	end
	guiHandler:newPage(page)
	guiHandler.objects[page][name] = { text = text, func = func, args = args, colors = colors, x = x, y = y, width = width, height = height, visible = visible, tooltip = tooltip}
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

--function guiHandler:newMenu(

function guiHandler:getButton( name, page )
	if page == nil then page = currentPage end
	return guiHandler.objects[page][name]
end

function guiHandler:newPage(name)
	if guiHandler.objects[name] == nil then guiHandler.objects[name] = {} end
end

function guiHandler:setCurrentPage(name)
	if guiHandler.objects[name] == nil then
		guiHandler:newPage(name)
	end
	currentPage = name
end

function guiHandler:drawTooltipLine(name, x, y, tooltipWidth)
	love.graphics.setColor( colorList.black )
	love.graphics.printf(utility:firstToUpper( name ), x, y, tooltipWidth, "center")
end

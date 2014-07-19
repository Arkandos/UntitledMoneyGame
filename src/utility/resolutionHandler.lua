resolutionHandler = {}

-- List of valid resolutions
local resolutions = {
	{ width = 800, height = 600   },
	{ width = 1280, height = 720  },
	{ width = 1600, height = 900  },
	{ width = 1920, height = 1080 }

}

-- Sets the window to the resolution specified in the configfile
function resolutionHandler:init()
	local r = configHandler:getValue("resolution")
	resolutionHandler:changeResolution(r.width, r.height)
end

-- Gets the list of all valid resolutions
function resolutionHandler:getResolutions()
	return resolutions
end

-- Returns the current resolution
function resolutionHandler:getCurrentResolution()
	return configHandler:getValue("resolution")
end

-- Checks if the resolution specified is valid.
function resolutionHandler:checkResolution(w, h)
	for k, v in pairs(resolution) do
		if v.width == w and v.height == h then return true end
	end
	return false
end

-- Changes to the specified resolution
function resolutionHandler:changeResolution(width, height)
	local success = love.window.setMode(width, height)
	return success
end

-- Increases or decreases the current resolution in the direction specified.
-- Valid directions: "up", "down"
function resolutionHandler:changeResolutionStep(dir)
	local number
	local currentRes = resolutionHandler:getCurrentResolution()
	local r = 1
	if dir == "up" then number = 1 else number = -1 end 
	
	for k, v in pairs(resolutions) do
		if v.width == currentRes.width and v.height == currentRes.height then
			r = k
		end
	end
	
	r = r + number
	print(r)
	if r <= 0 or r > #resolutions then return false end
	
	local success = love.window.setMode(resolutions[r].width, resolutions[r].height)
	if success then configHandler:setValue("resolution", resolutions[r]) end
	return success
end

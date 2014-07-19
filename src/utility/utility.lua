
utility = {}

-- Check if x and y are within px, py and wx, wy
function utility:checkHitbox(x, y, px, py, wx, wy)
	if x >= px and x <= wx and y >= py and y <= wy then return true else return false end
end

-- Returns a random color with 255 alpha
function utility:randomizeColor()
	math.randomseed(os.time())
	math.random(); math.random(); math.random();
	local t = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
	return t
end

-- Convert a tilePosition to real coordinates
function utility:convertToRealPos( x, y )
	return math.floor( math.floor(x) - 1 ) * 32, math.floor( math.floor(y) * 32 )
end

-- Convert real coordinates to a tilePosition
function utility:convertToTilePos( x, y )
	return math.floor( math.floor(x) / 32 ) + 1, math.floor( math.floor(y) / 32 )
end

function utility:firstToUpper(s)
	--print("CAPITILIZING "..tostring(s))
	s = tostring(s)
	return (s:gsub("^%l", string.upper))
end

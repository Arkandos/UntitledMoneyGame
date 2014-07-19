
logHandler = {}

-- This function is not intended to be used manually. Instead, use the other functions provided.
function logHandler:log(level, message)
	if level == nil or message == nil then return end
	print("["..level.."]: "..message)
end

function logHandler:info(message)
	logHandler:log("INFO", message)
end

function logHandler:error(message)
	logHandler:log("ERROR", message)
end

function logHandler:fatal(message)
	logHandler:log("FATAL", message)
end

function logHandler:warning(message)
	logHandler:log("WARNING", message)
end

function logHandler:debug(message)
	if debugActive then
		logHandler:log("DEBUG", message)
	end
end

function logHandler:config(message)
	logHandler:info(message.." (This can be changed in config.lua)")
end	

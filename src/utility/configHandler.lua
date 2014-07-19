
configHandler = {}

local config = {}

-- Checks if a config file exists. If it doesn't, it inits a new configfile with basic information
function configHandler:init()
	if not love.filesystem.exists( "config.lua" ) then
		configHandler:setValue("resolution", { width = 800, height = 600 } )
		configHandler:saveConfig()
	else
		configHandler:loadConfig()
	end
end

-- Loads the config into memory
function configHandler:loadConfig()
	config = Tserial.unpack( love.filesystem.read( "config.lua" ) )
end

-- Saves the current config to the configfile
function configHandler:saveConfig()
	love.filesystem.write( "config.lua", Tserial.pack(config, false, true) )
end

-- Sets a config value, then saves the config
function configHandler:setValue(name, value)
	config[name] = value
	configHandler:saveConfig()
end

-- Gets a value from the config. If the key does not exist, sets a default one
function configHandler:getValue(key, default)
	if config[key] == nil then configHandler:setValue(key, default) end
	return config[key]
end

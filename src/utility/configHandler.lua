
configHandler = {}

local config = {}

function configHandler:init()
	if not love.filesystem.exists( "config.lua" ) then
		configHandler:setValue("resolution", { width = 800, height = 600 } )
		configHandler:saveConfig()
	else
		configHandler:loadConfig()
	end
end

function configHandler:loadConfig()
	config = Tserial.unpack( love.filesystem.read( "config.lua" ) )
end

function configHandler:saveConfig()
	love.filesystem.write( "config.lua", Tserial.pack(config, false, true) )
end

function configHandler:setValue(name, value)
	config[name] = value
	configHandler:saveConfig()
end

function configHandler:getValue(key, default)
	if config[key] == nil then configHandler:setValue(key, default) end
	return config[key]
end

local ironMine = objectHandler:derive("resourceExtractor")

ironMine.data.mode = 4
ironMine.data.buyPrice = economyHandler:getPrice( "ironMine" ).moneyCost
ironMine.data.group = { "mine", "extractor" }

function ironMine:update(dt)
	ironMine:autoExtract(dt, { "ironore" } )
end

return ironMine
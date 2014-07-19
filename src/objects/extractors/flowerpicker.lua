local flowerpicker = objectHandler:derive("resourceExtractor")

flowerpicker.data.mode = 9
flowerpicker.data.group = { "flowerpicker", "extractor" }
flowerpicker.data.buyPrice = economyHandler:getPrice( "flowerpicker" ).moneyCost

function flowerpicker:update(dt)
	flowerpicker:autoExtract(dt, { "flowers" } , "flowers")
end

return flowerpicker
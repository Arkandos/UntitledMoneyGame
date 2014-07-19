local flowers = objectHandler:derive("resource")

flowers.data.replenish =  { rate = 60, min = 1, max = 2 }
flowers.data.emptyRemove = true
flowers.data.sellPrice = -10

function flowers:update(dt)
	self:replenish(dt)
end

return flowers
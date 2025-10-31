local Scenery = {}
Scenery.__index = Scenery

function Scenery:new()
    local scenery = {}
    setmetatable(scenery, Scenery)
    
    scenery.windowWidth = love.graphics.getWidth()
    scenery.windowHeight = love.graphics.getHeight()
    
    scenery.trackY = 350
    scenery.trackHeight = 200
    
    scenery.hills = {
        {0, 350, 300, 150, 700, 350},
        {600, 350, 800, 200, 1000, 350},
        {900, 350, 1200, 100, 1500, 350},
        {1400, 350, 1600, 250, 1800, 350},
        {1700, 350, 1900, 200, 2100, 350},
        {2000, 350, 2300, 150, 2700, 350},
        {2600, 350, 2800, 200, 3000, 350},
        {2900, 350, 3200, 100, 3500, 350},
        {3400, 350, 1600, 250, 3800, 350},
        {3700, 350, 1900, 200, 4100, 350}
    }
    
    return scenery
end

function Scenery:drawBackground(cameraX)
    love.graphics.setColor(0.4, 0.5, 0.8)
    love.graphics.rectangle('fill', 0, 0, self.windowWidth, self.trackY)

    love.graphics.push()
    love.graphics.translate(-cameraX * 0.3, 0)
    
    love.graphics.setColor(0.2, 0.2, 0.3)
    for _, hill in ipairs(self.hills) do
        love.graphics.polygon('fill', hill)
    end
    
    love.graphics.pop()
end

function Scenery:drawMidground()
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle('fill', 0, self.trackY, 4000, self.trackHeight)
    
    love.graphics.setColor(1, 1, 1)
    for i = 0, 4000, 100 do
        love.graphics.rectangle('fill', i, self.trackY + (self.trackHeight / 2) - 2, 50, 4)
    end
end

return Scenery
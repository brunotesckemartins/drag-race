local Scenery = {}
Scenery.__index = Scenery

function Scenery:new()
    local scenery = {}
    setmetatable(scenery, Scenery)
    
    scenery.windowWidth = love.graphics.getWidth()
    scenery.windowHeight = love.graphics.getHeight()
    
    scenery.trackY = 350
    scenery.trackHeight = 200
    
    scenery.skyColors = {
        {0.2, 0.4, 0.8},
        {0.4, 0.6, 1.0},  
        {0.8, 0.9, 1.0}
    }
    
    scenery.mountains = {}
    for i = 1, 15 do
        table.insert(scenery.mountains, {
            x = (i-1) * 300,
            height = math.random(80, 180),
            color = {0.3, 0.4, 0.5 + math.random() * 0.2}
        })
    end
    
    scenery.clouds = {}
    for i = 1, 8 do
        table.insert(scenery.clouds, {
            x = math.random(0, 4000),
            y = math.random(50, 200),
            size = math.random(40, 80),
            speed = math.random(10, 30)
        })
    end
    
    scenery.trees = {}
    for i = 1, 20 do
        table.insert(scenery.trees, {
            x = math.random(0, 4000),
            size = math.random(20, 40)
        })
    end
    
    return scenery
end

function Scenery:drawBackground(cameraX)
    for i, color in ipairs(self.skyColors) do
        local y = (i-1) * (self.trackY / #self.skyColors)
        local height = self.trackY / #self.skyColors
        love.graphics.setColor(color)
        love.graphics.rectangle('fill', 0, y, self.windowWidth, height)
    end
    
    love.graphics.setColor(1, 1, 1, 0.8)
    for _, cloud in ipairs(self.clouds) do
        local cloudX = (cloud.x - cameraX * 0.1) % 5000
        love.graphics.circle('fill', cloudX, cloud.y, cloud.size)
        love.graphics.circle('fill', cloudX + cloud.size * 0.7, cloud.y - cloud.size * 0.2, cloud.size * 0.8)
        love.graphics.circle('fill', cloudX + cloud.size * 1.4, cloud.y, cloud.size * 0.6)
    end
    
    love.graphics.push()
    love.graphics.translate(-cameraX * 0.5, 0)
    
    for _, mountain in ipairs(self.mountains) do
        love.graphics.setColor(mountain.color)
        love.graphics.polygon('fill',
            mountain.x, self.trackY,
            mountain.x + 150, self.trackY - mountain.height,
            mountain.x + 300, self.trackY
        )
    end
    
    love.graphics.pop()
    
    love.graphics.push()
    love.graphics.translate(-cameraX * 0.8, 0)
    
    for _, tree in ipairs(self.trees) do
        love.graphics.setColor(0.4, 0.3, 0.2)
        love.graphics.rectangle('fill', tree.x, self.trackY - 30, 8, 30)
        love.graphics.setColor(0.2, 0.6, 0.2)
        love.graphics.circle('fill', tree.x + 4, self.trackY - 40, tree.size * 0.3)
    end
    
    love.graphics.pop()
end

function Scenery:drawMidground()
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle('fill', 0, self.trackY, 4000, self.trackHeight)
    
    love.graphics.setColor(0.2, 0.5, 0.2)
    love.graphics.rectangle('fill', 0, self.trackY - 20, 4000, 20)
    love.graphics.rectangle('fill', 0, self.trackY + self.trackHeight, 4000, 20)
    
    love.graphics.setColor(1, 1, 1)
    for i = 0, 4000, 100 do
        love.graphics.rectangle('fill', i, self.trackY + (self.trackHeight / 2) - 3, 50, 6)
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', 0, self.trackY, 4000, 4)
    love.graphics.rectangle('fill', 0, self.trackY + self.trackHeight - 4, 4000, 4)
end

return Scenery
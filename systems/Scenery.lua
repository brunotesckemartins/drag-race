local Scenery = {}
Scenery.__index = Scenery

function Scenery:new()
    local scenery = {}
    setmetatable(scenery, Scenery)
    
    scenery.windowWidth = love.graphics.getWidth()
    scenery.windowHeight = love.graphics.getHeight()
    scenery.trackY = 350
    scenery.trackHeight = 200

    scenery.trackColors = {
        asphalt = {0.2, 0.2, 0.3},
        line = {1, 1, 1},
        grass = {0.2, 0.5, 0.2}
    }
    
    return scenery
end

function Scenery:drawBackground(cameraX)
    if images and images.background then
        local bg = images.background
        local bgWidth = bg:getWidth()
        local bgHeight = bg:getHeight()

        local visibleWidth = self.windowWidth + math.abs(cameraX)
        local repeatCount = math.ceil(visibleWidth / bgWidth) + 1

        local scale = self.trackY / bgHeight

        for i = 0, repeatCount do
            local x = (-cameraX * 0.15) + (i * bgWidth * scale)
            love.graphics.draw(bg, x, 0, 0, scale, scale)
        end
        
    else

        for i = 0, self.trackY, 2 do
            local progress = i / self.trackY
            local r = 0.3 + (0.3 * progress)
            local g = 0.5 + (0.3 * progress) 
            local b = 0.8 + (0.2 * progress)
            love.graphics.setColor(r, g, b)
            love.graphics.line(0, i, self.windowWidth + cameraX, i)
        end
        
        love.graphics.setColor(1, 1, 0.8)
        love.graphics.circle('fill', 650, 100, 40)
        
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.circle('fill', 200 + math.sin(love.timer.getTime()) * 10, 80, 25)
        love.graphics.circle('fill', 230 + math.sin(love.timer.getTime()) * 10, 70, 30)
        love.graphics.circle('fill', 500 - math.cos(love.timer.getTime()) * 8, 120, 20)
        love.graphics.circle('fill', 530 - math.cos(love.timer.getTime()) * 8, 110, 25)
    end
end

function Scenery:drawMidground()
    love.graphics.setColor(0.2, 0.2, 0.25)
    love.graphics.rectangle('fill', 0, self.trackY, 4000, self.trackHeight)
    
    love.graphics.setColor(1, 1, 1)
    for i = 0, 4000, 100 do
        love.graphics.rectangle('fill', i, self.trackY + (self.trackHeight / 2) - 1, 50, 2)
    end
end

return Scenery
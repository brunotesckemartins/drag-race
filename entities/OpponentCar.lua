local OpponentCar = {}
OpponentCar.__index = OpponentCar

function OpponentCar:new()
    local car = {}
    setmetatable(car, OpponentCar)

    car.x = 100
    car.y = 300 
    car.speed = 0
    car.gear = 1
    
    car.rpm = 1000 
    car.max_rpm = 9000
    
    car.gear_power = { 30, 50, 70, 90, 110 } 
    car.shift_target_rpm = 7000 + math.random(-500, 500)
    
    return car
end

function OpponentCar:update(dt)
    if self.rpm > self.max_rpm then
        self.speed = self.speed * 0.98 
    else
        local power = self.gear_power[self.gear] or 15 
        self.speed = self.speed + (power * dt)
        
        self.rpm = self.rpm + (3000 + (self.speed * 5)) * dt
    end
    
    if self.rpm < 1000 then self.rpm = 1000 end
    self.x = self.x + self.speed * dt
    
    if self.rpm >= self.shift_target_rpm then
        self:shiftGear()
    end
end

function OpponentCar:shiftGear()
    if self.gear >= #self.gear_power then
        return 
    end

    self.gear = self.gear + 1
    self.rpm = 3500 
    self.shift_target_rpm = 7000 + math.random(-500, 500)
    self.speed = self.speed * 1.05 
end

function OpponentCar:draw()
    love.graphics.setColor(1, 0, 0) 
    love.graphics.rectangle('fill', self.x, self.y, 100, 50)
    love.graphics.setColor(1, 1, 1) 
end

return OpponentCar
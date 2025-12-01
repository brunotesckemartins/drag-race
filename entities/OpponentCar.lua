local OpponentCar = {}
OpponentCar.__index = OpponentCar

function OpponentCar:new(index)
    local car = {}
    setmetatable(car, OpponentCar)

    car.index = index or 1 
    car.x = 100
    car.y = 300 + (index * 40)  
    
    car.speed = 0
    car.gear = 1
    
    car.rpm = 1000 
    car.max_rpm = 9000
    
    local powers = {
        {15, 30, 45, 60, 75},   
        {18, 33, 48, 63, 78},   
        {20, 35, 50, 65, 80}    
    }
    car.gear_power = powers[index] or {18, 33, 48, 63, 78}
    
    car.shift_point = 7000 + math.random(-500, 500)
    car.skill = 0.3 + (index * 0.1)  
    
    car.catch_up_active = false
    car.catch_up_timer = 0
    car.catch_up_boost = 1.0
    
    car.exhaustParticles = {}
    car.exhaustTimer = 0
    
    return car
end

function OpponentCar:update(dt, playerX)
    
    if self.rpm > self.max_rpm then
        if self.gear == #self.gear_power then 
            self.rpm = self.max_rpm 
        else
            self.speed = self.speed * 0.94
        end
    else
        local power = self.gear_power[self.gear] or 15 
        self.speed = self.speed + (power * dt)
        self.rpm = self.rpm + (2200 + (self.speed * 3)) * dt
    end

    if self.rpm >= self.shift_point and self.gear < #self.gear_power then
        self:shiftGear()
    end
    
    if self.rpm < 1000 then self.rpm = 1000 end

    self.x = self.x + self.speed * dt
end

function OpponentCar:shiftGear()
    if self.gear >= #self.gear_power then return end

    if math.random() < self.skill then
        self.speed = self.speed * 1.04
    else
        self.speed = self.speed * 0.96
    end

    self.gear = self.gear + 1
    self.rpm = 2800
    
    self.shift_point = 6800 + math.random(-400, 400)
end

function OpponentCar:applyStartBoost()
    if math.random() < 0.6 then
        self.speed = 35
    else
        self.speed = 20
    end
end

function OpponentCar:drawWorld()
    if images and images.opponentCar then
        love.graphics.draw(images.opponentCar, self.x, self.y, 0, 1, 1, 0, 0)
    else
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.rectangle('fill', self.x, self.y, 90, 30)
        love.graphics.setColor(1, 1, 1)
    end
end

function OpponentCar:drawUI(index)
    love.graphics.setColor(1, 1, 1)
    local y_pos = 50 + ((index or self.index) * 20)
    love.graphics.print("Oponente " .. (index or self.index) .. ": " .. math.floor(self.x), 10, y_pos)
end

return OpponentCar
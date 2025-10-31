local OpponentCar = {}
OpponentCar.__index = OpponentCar

function OpponentCar:new()
    local car = {}
    setmetatable(car, OpponentCar)

    car.x = 100
    car.y = 350
    car.speed = 0
    car.gear = 1
    
    car.rpm = 1000 
    car.max_rpm = 9000
    
    car.gear_power = { 22, 42, 62, 82, 102 }
    
    car.shift_point = 7000 + math.random(-500, 500)
    car.skill = 0.5
    
    car.catch_up_active = false
    car.catch_up_timer = 0
    car.catch_up_boost = 1.0
    
    return car
end

function OpponentCar:update(dt, playerX)
    local distance_behind = playerX - self.x
    self.catch_up_active = distance_behind > 80
    
    if self.catch_up_active then
        self.catch_up_timer = self.catch_up_timer + dt
        if self.catch_up_timer >= 4 then
            self.catch_up_timer = 0
            self.catch_up_boost = 1.08
            self.speed = self.speed * self.catch_up_boost
        end
    else
        self.catch_up_timer = 0
        self.catch_up_boost = 1.0
    end
    
    if self.rpm > self.max_rpm then
        if self.gear == #self.gear_power then 
            self.rpm = self.max_rpm 
        else
            self.speed = self.speed * 0.94
        end
    else
        local power = self.gear_power[self.gear] or 15 
        power = power * self.catch_up_boost
        
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
        self.speed = self.speed * 1.06
    else
        self.speed = self.speed * 0.94
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
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle('fill', self.x, self.y, 100, 50)
end

function OpponentCar:drawUI()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Oponente: " .. math.floor(self.x), 10, 50)
end

return OpponentCar
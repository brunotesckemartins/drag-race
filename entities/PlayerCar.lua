local PlayerCar = {}
PlayerCar.__index = PlayerCar

function PlayerCar:new()
    local car = {}
    setmetatable(car, PlayerCar)

    car.x = 100
    car.y = 400
    car.speed = 0
    car.gear = 1
    
    car.rpm = 1000 
    car.max_rpm = 9000
    
    car.gear_power = { 40, 70, 100, 130, 160 }
    
    car.qte_active = false
    car.qte_progress = 0
    car.qte_speed = 1.5
    car.qte_zone_start = 0.3
    car.qte_zone_end = 0.7
    car.qte_size = 80
    
    car.start_qte_start = 3500
    car.start_qte_end = 4500
    
    car.comboCounter = 0
    car.comboMessage = ""
    car.comboTimer = 0
    
    car.comboNames = { "BOM!", "ÓTIMO!", "PERFEITO!", "INCRÍVEL!", "DIVINO!" }
    car.comboFont = love.graphics.newFont(24)
    
    return car
end

function PlayerCar:update(dt)
    if self.rpm > self.max_rpm then
        if self.gear == #self.gear_power then 
            self.rpm = self.max_rpm 
        else
            self.speed = self.speed * 0.95
        end
        
    else
        local power = self.gear_power[self.gear] or 15 
        self.speed = self.speed + (power * dt)
        
        self.rpm = self.rpm + (2500 + (self.speed * 4)) * dt
    end
    
    if self.rpm < 1000 then self.rpm = 1000 end

    self.x = self.x + self.speed * dt
    
    if self.gear < #self.gear_power then
        self:updateQTE(dt)
    end
    
    if self.comboTimer > 0 then
        self.comboTimer = self.comboTimer - dt
        if self.comboTimer <= 0 then
            self.comboMessage = ""
        end
    end
end

function PlayerCar:updateQTE(dt)
    if not self.qte_active and self.rpm > 6000 and math.random() < 0.03 then
        self.qte_active = true
        self.qte_progress = 0
    end
    
    if self.qte_active then
        self.qte_progress = self.qte_progress + (self.qte_speed * dt)
        
        if self.qte_progress >= 1 then
            self:qteFailed()
        end
    end
end

function PlayerCar:checkQTE()
    if not self.qte_active then return false end
    
    return self.qte_progress >= self.qte_zone_start and self.qte_progress <= self.qte_zone_end
end

function PlayerCar:qteSuccess()
    self.qte_active = false
    cameraShake = 8
    
    self.comboCounter = self.comboCounter + 1
    local nameIndex = math.min(self.comboCounter, #self.comboNames)
    local hypeWord = self.comboNames[nameIndex]
    
    self.comboMessage = hypeWord .. " (x" .. self.comboCounter .. ")"
    self.comboTimer = 1.5
    
    local bonus = 1.2 + (self.comboCounter * 0.1)
    self.speed = self.speed * bonus
    
    self.gear = math.min(self.gear + 1, #self.gear_power)
    self.rpm = 2500
end

function PlayerCar:qteFailed()
    self.qte_active = false
    self.speed = self.speed * 0.92
    self.comboMessage = "ERROU!"
    self.comboTimer = 0.8
    self.comboCounter = 0
end

function PlayerCar:shiftGear()
    if self.gear >= #self.gear_power then return end

    if self.qte_active then
        if self:checkQTE() then
            self:qteSuccess()
        else
            self:qteFailed()
        end
    else
        self.speed = self.speed * 0.96
        self.comboMessage = "AGUARDE QTE!"
        self.comboTimer = 0.5
    end
end

function PlayerCar:applyStartBoost()
    if self.rpm >= self.start_qte_start and self.rpm <= self.start_qte_end then
        self.speed = 80
        cameraShake = 10
        self.comboMessage = "ARRANCADA PERFEITA!"
        self.comboTimer = 1.5
    elseif self.rpm < self.start_qte_start then
        self.speed = 25
        self.comboMessage = "RPM BAIXO!"
        self.comboTimer = 1.0
    else
        self.speed = 20
        self.rpm = 4000
        self.comboMessage = "RPM ALTO!"
        self.comboTimer = 1.0
    end
end

function PlayerCar:drawWorld()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', self.x, self.y, 100, 50)
end

function PlayerCar:drawUI(raceState)
    love.graphics.print("Marcha: " .. self.gear .. "/" .. #self.gear_power, 10, 450)
    love.graphics.print("Velocidade: " .. math.floor(self.speed), 10, 470)
    love.graphics.print("Combo: x" .. self.comboCounter, 10, 490)
    
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle('fill', 150, 520, 500, 40)
    
    local rpm_percent = self.rpm / self.max_rpm
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.rectangle('fill', 150 + (rpm_percent * 500) - 2, 515, 4, 50)
    
    if self.qte_active then
        local qte_x = 300
        local qte_y = 100
        
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle('fill', qte_x, qte_y, 200, 30)
        
        local zone_x = qte_x + (self.qte_zone_start * 200)
        local zone_width = (self.qte_zone_end - self.qte_zone_start) * 200
        love.graphics.setColor(0, 0.8, 0)
        love.graphics.rectangle('fill', zone_x, qte_y, zone_width, 30)
        
        local indicator_x = qte_x + (self.qte_progress * 200) - 3
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle('fill', indicator_x, qte_y - 10, 6, 50)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("ESPACO AGORA!", qte_x + 50, qte_y + 35)
        
        local time_left = 1 - self.qte_progress
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.rectangle('fill', qte_x, qte_y + 60, time_left * 200, 5)
    end
    
    love.graphics.setColor(1, 1, 1)
    
    if self.comboTimer > 0 then
        love.graphics.push() 
        love.graphics.setFont(self.comboFont)
        
        local r, g, b = 1, 1, 0.4
        if self.comboCounter >= 3 then r, g, b = 0, 1, 0 end
        if self.comboCounter >= 5 then r, g, b = 1, 0, 1 end
        
        love.graphics.setColor(r, g, b) 
        love.graphics.print(self.comboMessage, 10, 10)
        love.graphics.pop() 
    end
end

return PlayerCar
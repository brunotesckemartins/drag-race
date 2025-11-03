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
    
    car.gear_power = { 30, 55, 80, 105, 130, 155, 170 }
    
    car.qte_active = false
    car.qte_progress = 0
    car.qte_speed = 1.5
    car.qte_zone_start = 0.3
    car.qte_zone_end = 0.7
    car.qte_size = 80

    car.firstQTEready = false
    car.firstQTEtimer = 0
    
    car.start_qte_start = 3500
    car.start_qte_end = 4500
    
    car.comboCounter = 0
    car.comboMessage = ""
    car.comboTimer = 0
    
    car.comboNames = { "BOM!", "ÓTIMO!", "PERFEITO!", "INCRÍVEL!", "DIVINO!" }
    car.comboFont = love.graphics.newFont(24)
    
    car.engineGlow = 0
    car.wheelRotation = 0
    car.exhaustParticles = {}
    car.exhaustTimer = 0
    car.timeInGear = 0
    
    return car
end


function PlayerCar:update(dt)
    if self.rpm > self.max_rpm then

        self.rpm = self.max_rpm         
    else
        local power = self.gear_power[self.gear] or 15 
        self.speed = self.speed + (power * dt)
        
        self.rpm = self.rpm + (2500 + (self.speed * 4)) * dt
    end
    
    if self.rpm < 1000 then self.rpm = 1000 end

    self.x = self.x + self.speed * dt
    
    self.timeInGear = self.timeInGear + dt 

    if self.gear < #self.gear_power then
        self:updateQTE(dt)
    end
    
    self:updateVisualEffects(dt)
    
    if self.comboTimer > 0 then
        self.comboTimer = self.comboTimer - dt
        if self.comboTimer <= 0 then
            self.comboMessage = ""
        end
    end
end

function PlayerCar:updateVisualEffects(dt)
    self.engineGlow = math.min(1.0, self.rpm / self.max_rpm * 1.5)
    
    self.wheelRotation = self.wheelRotation + (self.speed * 0.1)
    
    self.exhaustTimer = self.exhaustTimer + dt
    if self.exhaustTimer > 0.05 then
        self.exhaustTimer = 0

        local exhaustX = self.x - 5   
        local exhaustY = self.y + 8   
        
        table.insert(self.exhaustParticles, {
            x = exhaustX,
            y = exhaustY,
            life = 1.0,
            size = math.random(3, 8),
            speedX = -math.random(20, 40),
            speedY = math.random(-5, 5)
        })
    end
    
    for i = #self.exhaustParticles, 1, -1 do
        local p = self.exhaustParticles[i]
        p.x = p.x + p.speedX * dt
        p.y = p.y + p.speedY * dt
        p.life = p.life - dt * 2
        
        if p.life <= 0 then
            table.remove(self.exhaustParticles, i)
        end
    end
end

function PlayerCar:updateQTE(dt)
    local minTime = 3.0 
    local rpmThreshold = 7500 
    
    if not self.qte_active and self.rpm > rpmThreshold and self.timeInGear > minTime and math.random() < 0.1 then
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
    
    self.comboCounter = self.comboCounter + 1
    local nameIndex = math.min(self.comboCounter, #self.comboNames)
    local hypeWord = self.comboNames[nameIndex]
    
    self.comboMessage = hypeWord .. " (x" .. self.comboCounter .. ")"
    self.comboTimer = 1.5
    
    local bonus = 1.15 + (self.comboCounter * 0.05)  
    self.speed = self.speed * bonus
    
    self.gear = math.min(self.gear + 1, #self.gear_power)
    self.rpm = 2500
    self.timeInGear = 0
end

function PlayerCar:qteFailed()
    self.qte_active = false
    self.speed = self.speed * 0.98  
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
        self.speed = self.speed * 0.98
        self.comboMessage = "AGUARDE QTE!"
        self.comboTimer = 0.8
        self.comboCounter = 0
        self.timeInGear = 0
    end
end

function PlayerCar:applyStartBoost()
    if self.rpm >= self.start_qte_start and self.rpm <= self.start_qte_end then
        self.speed = 80
        cameraShake = 2
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
    if images and images.playerCar then
        love.graphics.draw(images.playerCar, self.x, self.y, 0, 1, 1, 0, 0)
    else
        love.graphics.setColor(0.2, 0.6, 1.0)
        love.graphics.rectangle('fill', self.x, self.y, 60, 30)
        love.graphics.setColor(1, 1, 1)
    end
    
    for _, p in ipairs(self.exhaustParticles) do
        local alpha = p.life * 0.8
        love.graphics.setColor(0.8, 0.8, 0.2, alpha)
        love.graphics.circle('fill', p.x, p.y, p.size * p.life)
    end
    love.graphics.setColor(1, 1, 1)
end

function PlayerCar:drawUI(raceState)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle('fill', 5, 515, 790, 80, 10)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("MARCHA: " .. self.gear .. "/" .. #self.gear_power, 20, 530)
    love.graphics.print("VELOCIDADE: " .. math.floor(self.speed) .. " km/h", 20, 550)
    love.graphics.print("COMBO: x" .. self.comboCounter, 20, 570)
    
    local rpm_percent = self.rpm / self.max_rpm
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle('fill', 200, 540, 400, 20, 3)
    
    if rpm_percent < 0.7 then
        love.graphics.setColor(0, 0.8, 0)
    elseif rpm_percent < 0.9 then
        love.graphics.setColor(1, 0.8, 0)
    else
        love.graphics.setColor(1, 0, 0)
    end
    love.graphics.rectangle('fill', 200, 540, rpm_percent * 400, 20, 3)
    
    if self.qte_active then
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.rectangle('fill', 200, 150, 400, 100, 10)
        
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.rectangle('fill', 220, 180, 360, 30, 5)
        
        local zone_x = 220 + (self.qte_zone_start * 360)
        local zone_width = (self.qte_zone_end - self.qte_zone_start) * 360
        love.graphics.setColor(0, 1, 0, 0.6)
        love.graphics.rectangle('fill', zone_x, 180, zone_width, 30, 3)
        
        local indicator_x = 220 + (self.qte_progress * 360)
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle('fill', indicator_x - 2, 170, 4, 40)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("PRESSIONE [ESPAÇO] AGORA!", 250, 155)
        
        local time_left = 1 - self.qte_progress
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.rectangle('fill', 220, 215, time_left * 360, 4)
    end
    
    love.graphics.setColor(1, 1, 1)
    
    if self.comboTimer > 0 then
        love.graphics.push() 
        love.graphics.setFont(self.comboFont)
        
        local r, g, b = 1, 1, 0.4
        if self.comboCounter >= 3 then r, g, b = 0, 1, 0 end
        if self.comboCounter >= 5 then r, g, b = 1, 0.5, 1 end
        
        love.graphics.setColor(r, g, b) 
        local textWidth = self.comboFont:getWidth(self.comboMessage)
        love.graphics.print(self.comboMessage, (love.graphics.getWidth() - textWidth) / 2, 50)
        love.graphics.pop() 
    end
end

return PlayerCar
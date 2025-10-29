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
    
    car.gear_power = { 30, 50, 70, 90, 110 } 
    
    car.qte_start = 6500
    car.qte_end = 7500

    car.comboCounter = 0
    car.comboMessage = "" 
    car.comboTimer = 0 

    car.comboNames = { "BOM!", "ÓTIMO!", "PERFEITO!", "INCRÍVEL!", "DIVINO!", "DEUS DA MARCHA!" }

    car.comboFont = love.graphics.newFont(24) 
    
    return car
end

function PlayerCar:update(dt)
    if self.rpm > self.max_rpm then

        if self.gear == #self.gear_power then 
            self.rpm = self.max_rpm 
        else

            self.speed = self.speed * 0.98 
        end
        
    else

        local power = self.gear_power[self.gear] or 15 
        self.speed = self.speed + (power * dt)
        
        self.rpm = self.rpm + (3000 + (self.speed * 5)) * dt
    end
    
    if self.rpm < 1000 then self.rpm = 1000 end

    self.x = self.x + self.speed * dt

    if self.comboTimer > 0 then
        self.comboTimer = self.comboTimer - dt
        if self.comboTimer <= 0 then
            self.comboMessage = ""
        end
    end
end

function PlayerCar:shiftGear()
    if self.gear >= #self.gear_power then
        return 
    end

    local current_rpm = self.rpm

    if current_rpm >= self.qte_start and current_rpm <= self.qte_end then

        self.comboCounter = self.comboCounter + 1
        
        local nameIndex = math.min(self.comboCounter, #self.comboNames)
        local hypeWord = self.comboNames[nameIndex]
        
        self.comboMessage = hypeWord .. " (x" .. self.comboCounter .. ")"
        self.comboTimer = 1.0 
        
        self.speed = self.speed * 1.1 
        print("PERFEITO!")
        
    elseif current_rpm < self.qte_start then

        if self.comboCounter > 0 then 
            self.comboMessage = "COMBO QUEBRADO!"
            self.comboTimer = 0.7 
        end
        self.comboCounter = 0 
        
        self.speed = self.speed * 0.9 
        print("Adiantou!")
        
    elseif current_rpm > self.qte_end then

        if self.comboCounter > 0 then
            self.comboMessage = "COMBO QUEBRADO!"
            self.comboTimer = 0.7
        end
        self.comboCounter = 0
        
        self.speed = self.speed * 0.8 
        print("Atrasou!")
    end

    self.gear = self.gear + 1
    self.rpm = 3500 
end

function PlayerCar:draw()

    love.graphics.setColor(1, 1, 1) 
    love.graphics.rectangle('fill', self.x, self.y, 100, 50)

    love.graphics.print("Marcha: " .. self.gear, 10, 550)
    love.graphics.print("Velocidade: " .. math.floor(self.speed), 10, 570)
    
    love.graphics.setColor(0.5, 0.5, 0.5) 
    love.graphics.rectangle('fill', 150, 550, 500, 30)
    
    local qte_start_x = 150 + (self.qte_start / self.max_rpm) * 500
    local qte_width = ((self.qte_end - self.qte_start) / self.max_rpm) * 500
    love.graphics.setColor(0, 1, 0, 0.7) 
    love.graphics.rectangle('fill', qte_start_x, 550, qte_width, 30)

    local rpm_percent = self.rpm / self.max_rpm
    love.graphics.setColor(1, 0, 0) 
    love.graphics.rectangle('fill', 150 + (rpm_percent * 500), 545, 5, 40)
    
    love.graphics.setColor(1, 1, 1) 
    

    if self.comboTimer > 0 then

        love.graphics.push() 

        love.graphics.setFont(self.comboFont)

        love.graphics.setColor(1, 1, 0.4) 

        love.graphics.print(self.comboMessage, 10, 10)

        love.graphics.pop() 
    end
end

return PlayerCar
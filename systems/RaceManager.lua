local RaceManager = {}
RaceManager.__index = RaceManager

function RaceManager:new()
    local manager = {}
    setmetatable(manager, RaceManager)
    manager.countdown = 3
    manager.raceState = "countdown" 
    manager.timer = 0
    return manager
end

function RaceManager:update(dt, playerCar, opponents)
    if self.raceState == "countdown" then
        self.countdown = self.countdown - dt
        if self.countdown <= 0 then
            self.raceState = "running"
            playerCar:applyStartBoost()
            for i, opponent in ipairs(opponents) do
                opponent:applyStartBoost()
            end
        end
    
    elseif self.raceState == "running" then
        local finishLine = 2000

        if playerCar.x > finishLine then
            self.raceState = "finished_player_wins"
        else
            for i, opponent in ipairs(opponents) do
                if opponent.x > finishLine then
                    self.raceState = "finished_opponent_wins"
                    break
                end
            end
        end
    end
end

function RaceManager:draw()
    love.graphics.setColor(1, 1, 1) 
    
    if self.raceState == "countdown" then
        love.graphics.print(math.ceil(self.countdown), 400, 300)
    elseif self.raceState == "running" then
        love.graphics.print("GO!", 400, 300)
    end
end

return RaceManager
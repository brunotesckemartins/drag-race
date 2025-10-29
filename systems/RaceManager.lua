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

function RaceManager:update(dt, playerCar, opponentCar)
    if self.raceState == "countdown" then
        self.countdown = self.countdown - dt
        if self.countdown <= 0 then
            self.raceState = "running"
        end
    
    elseif self.raceState == "running" then
        local finishLine = 3000 

        if playerCar.x > finishLine then
            self.raceState = "finished_player_wins"
            print("Jogador Venceu!")

        elseif opponentCar.x > finishLine then
            self.raceState = "finished_opponent_wins"
            print("Oponente Venceu!")
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
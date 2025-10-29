local PlayerCar = require('entities.PlayerCar')
local OpponentCar = require('entities.OpponentCar')
local RaceManager = require('systems.RaceManager')

local playerCar, opponentCar, raceManager

local gameState = "menu" 

local bigFont 
local defaultFont 

function love.load()
    playerCar = PlayerCar:new() 
    opponentCar = OpponentCar:new()
    raceManager = RaceManager:new()

    defaultFont = love.graphics.getFont()
    bigFont = love.graphics.newFont(48) 
end

function love.update(dt)
    if gameState == "corrida" then
        
        if raceManager.raceState == "running" then
            playerCar:update(dt)
            opponentCar:update(dt)
        end
        
        raceManager:update(dt, playerCar, opponentCar)

        if raceManager.raceState == "finished_player_wins" or raceManager.raceState == "finished_opponent_wins" then
            gameState = "fim"
        end
    end
end

function love.draw()
    if gameState == "menu" then
        love.graphics.setFont(defaultFont)
        love.graphics.setColor(1, 1, 1) 
        love.graphics.print("DRAG RACE", 380, 250)
        love.graphics.print("Aperte ENTER para começar", 340, 300)
        
    elseif gameState == "corrida" then
        love.graphics.setFont(defaultFont) 
        love.graphics.setColor(1, 1, 1) 
        
        playerCar:draw()
        opponentCar:draw()
        raceManager:draw() 
        
    elseif gameState == "fim" then
        
        love.graphics.push() 
        love.graphics.setFont(bigFont) 
        
        local text = ""
        local textWidth = 0

        if raceManager.raceState == "finished_player_wins" then
            text = "VITÓRIA!"
            love.graphics.setColor(0.1, 0.8, 0.1) 
        elseif raceManager.raceState == "finished_opponent_wins" then
            text = "GAME OVER"
            love.graphics.setColor(0.9, 0.1, 0.1) 
        end

        textWidth = bigFont:getWidth(text)
        love.graphics.print(text, (love.graphics.getWidth() / 2) - (textWidth / 2), 250)
        
        love.graphics.pop() 
        love.graphics.setColor(1, 1, 1)

        love.graphics.print("Aperte ENTER para voltar ao Menu", 320, 350)
    end
end

function love.keypressed(key)
    if gameState == "menu" then
        if key == "return" then 
            gameState = "corrida"
            raceManager = RaceManager:new() 
            playerCar = PlayerCar:new() 
            opponentCar = OpponentCar:new() 
        end
        
    elseif gameState == "corrida" then
        if key == 'space' and raceManager.raceState == "running" then
            playerCar:shiftGear()
        end
        
    elseif gameState == "fim" then
        if key == "return" then
            playerCar = PlayerCar:new()
            opponentCar = OpponentCar:new()
            raceManager = RaceManager:new() 
            gameState = "menu"
        end
    end
end
local PlayerCar = require('entities.PlayerCar')
local OpponentCar = require('entities.OpponentCar')
local RaceManager = require('systems.RaceManager')
local Scenery = require('systems.Scenery')

local playerCar, opponentCar, raceManager, scenery
local gameState = "menu"
local bigFont
local defaultFont

cameraShake = 0
qtePulse = 0
qtePulseDir = 1
cameraX = 0

function love.load()
    playerCar = PlayerCar:new() 
    opponentCar = OpponentCar:new()
    raceManager = RaceManager:new()
    scenery = Scenery:new()

    defaultFont = love.graphics.getFont()
    bigFont = love.graphics.newFont(48)
end

function love.update(dt)
    if cameraShake and cameraShake > 0 then
        cameraShake = cameraShake * 0.9
        if cameraShake < 0.1 then cameraShake = 0 end
    else
        cameraShake = 0
    end
    
    if qtePulse then
        qtePulse = qtePulse + (dt * qtePulseDir * 3)
        if qtePulse > 1 then
            qtePulse = 1
            qtePulseDir = -1
        elseif qtePulse < 0 then
            qtePulse = 0
            qtePulseDir = 1
        end
    else
        qtePulse = 0
        qtePulseDir = 1
    end

    if gameState == "corrida" then
        if raceManager.raceState == "countdown" then
            playerCar:update(dt)
            opponentCar:update(dt, playerCar.x)
            
            if love.keyboard.isDown('space') then
                playerCar.rpm = playerCar.rpm + (4000 * dt)
                if playerCar.rpm > playerCar.max_rpm then
                    playerCar.rpm = playerCar.max_rpm
                end
            end
            
        elseif raceManager.raceState == "running" then
            playerCar:update(dt)
            opponentCar:update(dt, playerCar.x)
        end
        
        raceManager:update(dt, playerCar, opponentCar)
        
        if raceManager.raceState == "finished_player_wins" or raceManager.raceState == "finished_opponent_wins" then
            gameState = "fim"
        end
        
        cameraX = math.max(0, playerCar.x - 150)
    end
end

function love.draw()
    love.graphics.push()
    
    local shakeX = 0
    local shakeY = 0
    if cameraShake and cameraShake > 0 then
        shakeX = math.random(-cameraShake, cameraShake)
        shakeY = math.random(-cameraShake, cameraShake)
    end
    love.graphics.translate(shakeX, shakeY)

    if gameState == "menu" then
        love.graphics.setFont(defaultFont)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("DRAG RACE", 380, 250)
        love.graphics.print("Aperte ENTER para começar", 340, 300)
        
    elseif gameState == "corrida" then
        love.graphics.setFont(defaultFont)
        love.graphics.setColor(1, 1, 1)
        
        scenery:drawBackground(cameraX)
        
        love.graphics.push()
        love.graphics.translate(-cameraX, 0)
        
        scenery:drawMidground()
        playerCar:drawWorld()
        opponentCar:drawWorld()
        raceManager:draw()
        
        love.graphics.pop()
        
        playerCar:drawUI(raceManager.raceState)
        opponentCar:drawUI()
        
    elseif gameState == "fim" then
        scenery:drawBackground(cameraX)
        
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
    
    love.graphics.pop()
end

function love.keypressed(key)
    if gameState == "menu" then
        if key == "return" then
            gameState = "corrida"
            raceManager = RaceManager:new()
            playerCar = PlayerCar:new()
            opponentCar = OpponentCar:new()
            cameraX = 0
            cameraShake = 0
            qtePulse = 0
            qtePulseDir = 1
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
            cameraX = 0
            cameraShake = 0
            qtePulse = 0
            qtePulseDir = 1
        end
    end
end
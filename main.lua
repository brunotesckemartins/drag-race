local PlayerCar = require('entities.PlayerCar')
local OpponentCar = require('entities.OpponentCar')
local RaceManager = require('systems.RaceManager')
local Scenery = require('systems.Scenery')

local playerCar, raceManager, scenery
local opponents = {} 
local gameState = "menu"
local bigFont
local defaultFont
local sounds = {} 

cameraShake = 0
qtePulse = 0
qtePulseDir = 1
cameraX = 0

local crtShader
local mainCanvas
local gameWidth, gameHeight

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    gameWidth = love.graphics.getWidth()
    gameHeight = love.graphics.getHeight()

    local shaderStatus, shaderErr = pcall(function()
        crtShader = love.graphics.newShader("crt.glsl")
    end)
    if not shaderStatus then
        print("Erro no Shader: " .. tostring(shaderErr))
    end
    
    mainCanvas = love.graphics.newCanvas(gameWidth, gameHeight)
    mainCanvas:setFilter("nearest", "nearest")

    images = {}
    pcall(function()
        images.playerCar = love.graphics.newImage("assets/images/player_car.png")
        images.opponentCar = love.graphics.newImage("assets/images/opponent_car.png")
        images.background = love.graphics.newImage("assets/images/background.png")
    end)
    
    sounds = {}
    
    local function loadAudio(path, type)
        if love.filesystem.getInfo(path) then
            local src = love.audio.newSource(path, type or "stream")
            return src
        else
            return nil
        end
    end

    sounds.menu = loadAudio("assets/audio/menu.ogg", "stream")
    sounds.race = loadAudio("assets/audio/race.ogg", "stream")
    
    sounds.engine = loadAudio("assets/audio/engine.mp3", "static")
    sounds.shift = loadAudio("assets/audio/shift.mp3", "static")

    if sounds.menu then sounds.menu:setLooping(true) end
    if sounds.race then sounds.race:setLooping(true) end
    if sounds.engine then sounds.engine:setLooping(true) end 

    playerCar = PlayerCar:new() 
    
    opponents = {
        OpponentCar:new(1),  
        OpponentCar:new(2),  
        OpponentCar:new(3)  
    }
    
    raceManager = RaceManager:new()
    scenery = Scenery:new()

    defaultFont = love.graphics.getFont()
    bigFont = love.graphics.newFont(48)

    if sounds.menu then sounds.menu:play() end
end

function love.update(dt)
    if cameraShake and cameraShake > 0 then
        cameraShake = cameraShake - (dt * 15)
        if cameraShake < 0 then cameraShake = 0 end
    else
        cameraShake = 0
    end

    if qtePulse then
        qtePulse = qtePulse + (dt * qtePulseDir * 3)
        if qtePulse >= 1 then
            qtePulse = 1
            qtePulseDir = -1
        elseif qtePulse <= 0 then
            qtePulse = 0
            qtePulseDir = 1
        end
    else 
        qtePulse = 0
        qtePulseDir = 1
    end

    if gameState == "corrida" then
        if sounds.engine then
            local minPitch = 0.5
            local maxPitch = 2.2
            local rpmPercent = playerCar.rpm / playerCar.max_rpm
            
            local currentPitch = minPitch + (rpmPercent * (maxPitch - minPitch))
            sounds.engine:setPitch(currentPitch)
        end

        if raceManager.raceState == "countdown" then
            playerCar:update(dt)
            for i, opponent in ipairs(opponents) do
                opponent:update(dt, playerCar.x)
            end
            
            if love.keyboard.isDown('space') then
                playerCar.rpm = playerCar.rpm + (4000 * dt)
                if playerCar.rpm > playerCar.max_rpm then
                    playerCar.rpm = playerCar.max_rpm
                end
            end
            
        elseif raceManager.raceState == "running" then
            playerCar:update(dt)
            for i, opponent in ipairs(opponents) do
                opponent:update(dt, playerCar.x)
            end
        end
        
        raceManager:update(dt, playerCar, opponents)
        
        if raceManager.raceState == "finished_player_wins" or raceManager.raceState == "finished_opponent_wins" then
            if sounds.race then sounds.race:stop() end
            if sounds.engine then sounds.engine:stop() end
            
            gameState = "fim"
        end
        
        cameraX = math.max(0, playerCar.x - 150)
    end
end

function love.draw()
    love.graphics.setCanvas(mainCanvas)
    love.graphics.clear() 

    if gameState == "menu" then
        love.graphics.setFont(defaultFont)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("DRAG RACE", 380, 250)
        love.graphics.print("Aperte ENTER para começar", 340, 300)
        
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.print("Music by DavidKBD (itch.io)", 10, gameHeight - 30)
        
    elseif gameState == "corrida" then
        love.graphics.push()
        local shakeX = 0
        local shakeY = 0
        if cameraShake and cameraShake > 0 then
            shakeX = math.random(-cameraShake, cameraShake)
            shakeY = math.random(-cameraShake, cameraShake)
        end
        
        love.graphics.translate(shakeX, shakeY)
        
        scenery:drawBackground(cameraX)
        
        love.graphics.push()
        love.graphics.translate(-cameraX, 0)
        
        scenery:drawMidground(raceManager.finishLine)
        playerCar:drawWorld()
        for i, opponent in ipairs(opponents) do
            opponent:drawWorld()
        end
        raceManager:draw()
        
        love.graphics.pop()
        love.graphics.pop()  
        
        love.graphics.setFont(defaultFont)
        
        playerCar:drawUI(raceManager.raceState)

        love.graphics.setFont(defaultFont)
        
        for i, opponent in ipairs(opponents) do
            opponent:drawUI(i)
        end
        
    elseif gameState == "fim" then
        love.graphics.push()
        love.graphics.translate(0, 0) 
        
        scenery:drawBackground(cameraX)
        
        love.graphics.push()
        love.graphics.translate(-cameraX, 0)
        
        scenery:drawMidground(raceManager.finishLine)
        playerCar:drawWorld()
        for i, opponent in ipairs(opponents) do
            opponent:drawWorld()
        end
        raceManager:draw()
        
        love.graphics.pop()
        love.graphics.pop()
        
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 200, gameWidth, 250)

        love.graphics.setFont(bigFont)
        
        local text = ""
        local textWidth = 0

        if raceManager.raceState == "finished_player_wins" then
            text = "VITÓRIA!"
            love.graphics.setColor(0.1, 0.8, 0.1)
        else
            text = "GAME OVER"
            love.graphics.setColor(0.9, 0.1, 0.1)
        end

        textWidth = bigFont:getWidth(text)
        love.graphics.print(text, (gameWidth / 2) - (textWidth / 2), 250)
        
        love.graphics.setFont(defaultFont)
        love.graphics.setColor(1, 1, 1)
        
        local menuText = "Aperte ENTER para voltar ao Menu"
        local menuWidth = defaultFont:getWidth(menuText)
        
        love.graphics.print(menuText, (gameWidth / 2) - (menuWidth / 2), 350)
    end

    love.graphics.setCanvas()
    if crtShader then love.graphics.setShader(crtShader) end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(mainCanvas, 0, 0)
    
    love.graphics.setShader()
end

function love.keypressed(key)
    if gameState == "menu" then
        if key == "return" then
            if sounds.menu then sounds.menu:stop() end
            if sounds.race then sounds.race:play() end
            if sounds.engine then sounds.engine:play() end
            
            gameState = "corrida"
            raceManager = RaceManager:new()
            playerCar = PlayerCar:new()
            opponents = {
                OpponentCar:new(1),
                OpponentCar:new(2), 
                OpponentCar:new(3)
            }
            cameraX = 0
            cameraShake = 0
            qtePulse = 0
            qtePulseDir = 1
        end
        
    elseif gameState == "corrida" then
        if key == 'space' and raceManager.raceState == "running" then
            playerCar:shiftGear()
            
            if sounds.shift then
                sounds.shift:stop() 
                sounds.shift:play()
            end
        end
        
    elseif gameState == "fim" then
        if key == "return" then
            if sounds.menu then sounds.menu:play() end
            
            playerCar = PlayerCar:new()
            opponents = {
                OpponentCar:new(1),
                OpponentCar:new(2),
                OpponentCar:new(3)
            }
            raceManager = RaceManager:new()
            gameState = "menu"
            cameraX = 0
            cameraShake = 0
            qtePulse = 0
            qtePulseDir = 1
        end
    end
end
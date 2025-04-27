function love.load()
    -- Window setup
    love.window.setMode(0, 0, {fullscreen = true})
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    
    -- Game state
    gameState = "menu" -- "menu", "playing", "settings"
    
    -- Target setup
    target = {}
    target.x = 300
    target.y = 300
    target.radius = 50
    target.color = {0, 1, 1}
    
    -- Game variables
    score = 0
    timer = 0
    gameTime = 30 -- Default game time in seconds
    
    -- Settings variables
    settings = {
        targetSize = "medium", -- "small", "medium", "large"
        targetColor = "cyan", -- "cyan", "red", "green"
        gameDuration = "30s", -- "30s", "60s", "90s"
        difficulty = "normal" -- "easy", "normal", "hard"
    }
    
    -- Visual elements
    colors = {
        background = {78/255, 78/255, 153/255},
        menuBackground = {58/255, 58/255, 133/255, 0.9},
        buttonHover = {100/255, 100/255, 180/255},
        buttonNormal = {78/255, 78/255, 153/255},
        textColor = {1, 1, 1},
        cyan = {0, 1, 1},
        red = {1, 0.4, 0.4},
        green = {0.4, 1, 0.4}
    }
    
    -- Fonts
    titleFont = love.graphics.newFont(60)
    gameFont = love.graphics.newFont(25)
    menuFont = love.graphics.newFont(30)
    
    -- Buttons
    buttons = {}
    initializeButtons()
    
    -- Decorative targets for menu
    decorativeTargets = createDecorativeTargets(10)
    
    love.window.setTitle("Gliber - AimTrainer")
end

function love.update(dt)
    if gameState == "playing" then
        timer = timer + dt
        
        -- End game when time is up
        if timer >= gameTime then
            gameState = "results"
        end
    else
        -- Update decorative targets when not playing
        for i, t in ipairs(decorativeTargets) do
            -- Flickering effect
            t.flickerTimer = t.flickerTimer + dt
            if t.flickerTimer > t.flickerRate then
                t.flickerTimer = 0
                t.alpha = t.alpha == 0.7 and 0.5 or 0.7
            end
            
            -- Subtle movement
            t.x = t.x + math.cos(love.timer.getTime() * t.speedX) * 0.3
            t.y = t.y + math.sin(love.timer.getTime() * t.speedY) * 0.3
        end
    end
    
    -- Update button hover states
    local mx, my = love.mouse.getPosition()
    for _, button in pairs(buttons) do
        if button.state == gameState and pointInRect(mx, my, button.x, button.y, button.width, button.height) then
            button.hover = true
        else
            button.hover = false
        end
    end
end

function love.draw()
    -- Set background color
    love.graphics.setBackgroundColor(colors.background)
    
    if gameState == "menu" then
        drawMenu()
    elseif gameState == "settings" then
        drawSettings()
    elseif gameState == "playing" then
        drawGame()
    elseif gameState == "results" then
        drawResults()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        if gameState == "playing" then
            local mouseToTarget = distanceBetween(x, y, target.x, target.y)
            if mouseToTarget < target.radius then
                score = score + 1
                target.x = math.random(target.radius, screenWidth - target.radius)
                target.y = math.random(target.radius, screenHeight - target.radius)
            else
                score = score - 1
                target.x = math.random(target.radius, screenWidth - target.radius)
                target.y = math.random(target.radius, screenHeight - target.radius)
                if score <= 0 then 
                    score = 0
                end
            end
        else
            -- Check button clicks
            for _, button in pairs(buttons) do
                if button.state == gameState and pointInRect(x, y, button.x, button.y, button.width, button.height) then
                    button.action()
                end
            end
        end
    end
end

function initializeButtons()
    -- Menu buttons
    local buttonWidth = 300
    local buttonHeight = 60
    local centerX = screenWidth / 2 - buttonWidth / 2
    local startY = screenHeight / 2
    
    -- Main menu buttons
    buttons.play = {
        state = "menu",
        x = centerX,
        y = startY,
        width = buttonWidth,
        height = buttonHeight,
        text = "PLAY",
        hover = false,
        action = function()
            resetGame()
            gameState = "playing"
        end
    }
    
    buttons.settings = {
        state = "menu",
        x = centerX,
        y = startY + buttonHeight + 20,
        width = buttonWidth,
        height = buttonHeight,
        text = "SETTINGS",
        hover = false,
        action = function()
            gameState = "settings"
        end
    }
    
    buttons.exit = {
        state = "menu",
        x = centerX,
        y = startY + (buttonHeight + 20) * 2,
        width = buttonWidth,
        height = buttonHeight,
        text = "EXIT",
        hover = false,
        action = function()
            love.event.quit()
        end
    }
    
    -- Settings buttons
    buttons.targetSize = {
        state = "settings",
        x = centerX,
        y = startY - 120,
        width = buttonWidth,
        height = buttonHeight,
        text = "TARGET SIZE: " .. string.upper(settings.targetSize),
        hover = false,
        action = function()
            if settings.targetSize == "small" then
                settings.targetSize = "medium"
                target.radius = 50
            elseif settings.targetSize == "medium" then
                settings.targetSize = "large"
                target.radius = 75
            else
                settings.targetSize = "small"
                target.radius = 25
            end
            buttons.targetSize.text = "TARGET SIZE: " .. string.upper(settings.targetSize)
        end
    }
    
    buttons.targetColor = {
        state = "settings",
        x = centerX,
        y = startY - 40,
        width = buttonWidth,
        height = buttonHeight,
        text = "TARGET COLOR: " .. string.upper(settings.targetColor),
        hover = false,
        action = function()
            if settings.targetColor == "cyan" then
                settings.targetColor = "red"
                target.color = colors.red
            elseif settings.targetColor == "red" then
                settings.targetColor = "green"
                target.color = colors.green
            else
                settings.targetColor = "cyan"
                target.color = colors.cyan
            end
            buttons.targetColor.text = "TARGET COLOR: " .. string.upper(settings.targetColor)
        end
    }
    
    buttons.gameDuration = {
        state = "settings",
        x = centerX,
        y = startY + 40,
        width = buttonWidth,
        height = buttonHeight,
        text = "GAME TIME: " .. settings.gameDuration,
        hover = false,
        action = function()
            if settings.gameDuration == "30s" then
                settings.gameDuration = "60s"
                gameTime = 60
            elseif settings.gameDuration == "60s" then
                settings.gameDuration = "90s"
                gameTime = 90
            else
                settings.gameDuration = "30s"
                gameTime = 30
            end
            buttons.gameDuration.text = "GAME TIME: " .. settings.gameDuration
        end
    }
    
    buttons.difficulty = {
        state = "settings",
        x = centerX,
        y = startY + 120,
        width = buttonWidth,
        height = buttonHeight,
        text = "DIFFICULTY: " .. string.upper(settings.difficulty),
        hover = false,
        action = function()
            if settings.difficulty == "easy" then
                settings.difficulty = "normal"
            elseif settings.difficulty == "normal" then
                settings.difficulty = "hard"
            else
                settings.difficulty = "easy"
            end
            buttons.difficulty.text = "DIFFICULTY: " .. string.upper(settings.difficulty)
        end
    }
    
    buttons.back = {
        state = "settings",
        x = centerX,
        y = startY + 200,
        width = buttonWidth,
        height = buttonHeight,
        text = "BACK",
        hover = false,
        action = function()
            gameState = "menu"
        end
    }
    
    -- Results screen buttons
    buttons.playAgain = {
        state = "results",
        x = centerX,
        y = startY + 100,
        width = buttonWidth,
        height = buttonHeight,
        text = "PLAY AGAIN",
        hover = false,
        action = function()
            resetGame()
            gameState = "playing"
        end
    }
    
    buttons.mainMenu = {
        state = "results",
        x = centerX,
        y = startY + 180,
        width = buttonWidth,
        height = buttonHeight,
        text = "MAIN MENU",
        hover = false,
        action = function()
            gameState = "menu"
        end
    }
end

function drawMenu()
    -- Draw decorative circles first so they appear behind the text
    drawDecorativeTargets()
    
    -- Title
    love.graphics.setColor(colors.textColor)
    love.graphics.setFont(titleFont)
    local title = "AIMTRAINER"
    local subtitle = "GLIBER"
    
    -- Calculate text dimensions
    local titleWidth = titleFont:getWidth(title)
    local subtitleWidth = titleFont:getWidth(subtitle)
    
    -- Center the title text
    love.graphics.print(title, screenWidth/2 - titleWidth/2, screenHeight/4)
    love.graphics.print(subtitle, screenWidth/2 - subtitleWidth/2, screenHeight/4 + titleFont:getHeight())
    
    -- Draw buttons
    for _, button in pairs(buttons) do
        if button.state == "menu" then
            drawButton(button)
        end
    end
end

function drawSettings()
    -- Settings title
    love.graphics.setColor(colors.textColor)
    love.graphics.setFont(titleFont)
    local title = "SETTINGS"
    local titleWidth = titleFont:getWidth(title)
    love.graphics.print(title, screenWidth/2 - titleWidth/2, screenHeight/4)
    
    -- Draw decorative circles
    drawDecorativeTargets()
    
    -- Translucent background for settings panel
    love.graphics.setColor(colors.menuBackground)
    local panelWidth = 400
    local panelHeight = 400
    love.graphics.rectangle("fill", screenWidth/2 - panelWidth/2, screenHeight/2 - 150, panelWidth, panelHeight, 10, 10)
    
    -- Draw buttons
    for _, button in pairs(buttons) do
        if button.state == "settings" then
            drawButton(button)
        end
    end
end

function drawGame()
    -- Draw target
    love.graphics.setColor(target.color)
    love.graphics.circle("fill", target.x, target.y, target.radius)
    
    -- Draw HUD
    love.graphics.setColor(colors.textColor)
    love.graphics.setFont(gameFont)
    
    -- Score
    love.graphics.print("SCORE: " .. score, 20, 20)
    
    -- Timer
    local timeLeft = math.ceil(gameTime - timer)
    love.graphics.print("TIME: " .. timeLeft .. "s", 20, 60)
    
    -- Draw escape instruction
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.print("Press ESC to return to menu", 20, screenHeight - 50)
end

function drawResults()
    -- Results title
    love.graphics.setColor(colors.textColor)
    love.graphics.setFont(titleFont)
    local title = "RESULTS"
    local titleWidth = titleFont:getWidth(title)
    love.graphics.print(title, screenWidth/2 - titleWidth/2, screenHeight/4)
    
    -- Stats
    love.graphics.setFont(menuFont)
    local statsText = "Score: " .. score .. "\nTime: " .. math.floor(timer) .. "s"
    love.graphics.printf(statsText, 0, screenHeight/2 - 50, screenWidth, "center")
    
    -- Draw buttons
    for _, button in pairs(buttons) do
        if button.state == "results" then
            drawButton(button)
        end
    end
    
    -- Draw decorative circles
    drawDecorativeTargets()
end

function drawButton(button)
    -- Button background
    if button.hover then
        love.graphics.setColor(colors.buttonHover)
    else
        love.graphics.setColor(colors.buttonNormal)
    end
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 10, 10)
    
    -- Button border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 10, 10)
    
    -- Button text
    love.graphics.setColor(colors.textColor)
    love.graphics.setFont(menuFont)
    local textWidth = menuFont:getWidth(button.text)
    local textHeight = menuFont:getHeight()
    love.graphics.print(
        button.text,
        button.x + button.width/2 - textWidth/2,
        button.y + button.height/2 - textHeight/2
    )
end

function createDecorativeTargets(count)
    local targets = {}
    for i = 1, count do
        local target = {
            x = math.random(50, screenWidth - 50),
            y = math.random(50, screenHeight - 50),
            radius = math.random(20, 40),
            alpha = 0.7,
            flickerTimer = 0,
            flickerRate = math.random(0.3, 1.5), -- Random flicker speed
            speedX = math.random(20, 50) / 100, -- Random movement speed
            speedY = math.random(20, 50) / 100,
            hasPlus = i == 5 -- The 5th target will have a plus sign
        }
        targets[i] = target
    end
    return targets
end

function drawDecorativeTargets()
    -- Draw animated decorative targets in the background
    for _, t in ipairs(decorativeTargets) do
        -- Draw the target circle
        love.graphics.setColor(colors.red[1], colors.red[2], colors.red[3], t.alpha)
        love.graphics.circle("fill", t.x, t.y, t.radius)
        
        -- Draw plus sign on special target
        if t.hasPlus then
            love.graphics.setColor(1, 1, 1, t.alpha + 0.2)
            local plusSize = t.radius * 0.7
            local thickness = t.radius * 0.2
            
            -- Horizontal line of plus
            love.graphics.rectangle("fill", 
                t.x - plusSize/2, 
                t.y - thickness/2, 
                plusSize, 
                thickness)
            
            -- Vertical line of plus
            love.graphics.rectangle("fill", 
                t.x - thickness/2, 
                t.y - plusSize/2, 
                thickness, 
                plusSize)
        end
    end
end

function resetGame()
    score = 0
    timer = 0
    target.x = math.random(target.radius, screenWidth - target.radius)
    target.y = math.random(target.radius, screenHeight - target.radius)
end

function love.keypressed(key)
    if key == "escape" then
        if gameState == "playing" then
            gameState = "menu"
        elseif gameState == "settings" or gameState == "results" then
            gameState = "menu"
        elseif gameState == "menu" then
            love.event.quit()
        end
    end
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function pointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end
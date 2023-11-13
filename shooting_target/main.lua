eGameStates = {
    eGameStates_Ready = 1,
    eGameStates_Playing = 2,
}

eMouseStates = {
    eLeftButton = 1,
}

-- https://love2d.org/wiki/love.load
-- love.load to do one-time setup of your game
function love.load()
    target = {}
    target.x = 300
    target.y = 300
    target.radius = 50

    score = 0
    timer = 0
    gameState = eGameStates.eGameStates_Ready

    gameFont = love.graphics.newFont(40)

    sprites = {}
    sprites.sky = love.graphics.newImage("sprites/sky.png")
    sprites.crosshairs = love.graphics.newImage("sprites/crosshairs.png")
    sprites.target = love.graphics.newImage("sprites/target.png")

    love.mouse.setVisible(false)
end

-- love.update which is used to manage your game's state frame-to-frame,
-- https://love2d.org/wiki/love.update
function love.update(dt)
    -- 60fps. 1초에 60번 호출
    -- 1번 재호출될 때 0.0166666667 정도가 걸린다느 의미.
    if timer > 0 then
        timer = timer - 1 * dt
    end
    
    if timer < 0  then
        timer = 0
        gameState = eGameStates.eGameStates_Ready
    end
end

-- https://love2d.org/wiki/love.draw
function love.draw()
    love.graphics.draw(sprites.sky, 0, 0)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(gameFont)
    love.graphics.print("score: " .. score, 0, 0)
    love.graphics.print(math.ceil(timer), 300, 0)

    if gameState == eGameStates.eGameStates_Ready then
        love.graphics.printf("Click anywhere to begin!", 0, 250, love.graphics.getWidth(), "center")
    end

    if gameState == eGameStates.eGameStates_Playing then
        love.graphics.draw(sprites.target, target.x - target.radius, target.y - target.radius)
    end

    love.graphics.draw(sprites.crosshairs, love.mouse.getX() - 20, love.mouse.getY() - 20)
end

-- https://love2d.org/wiki/love.mousepressed
function love.mousepressed( x, y, button, istouch, presses )
    if button == eMouseStates.eLeftButton and gameState == eGameStates.eGameStates_Playing then
        local mouseToTarget = distanceBetween(x, y, target.x, target.y)
        if mouseToTarget <= target.radius then
            score = score + 1

            -- 안전 영역내에서 random 생성
            -- 이보다 안 쪽에서 x, y를 생성해야 함
            target.x = math.random(target.radius, love.graphics.getWidth() - target.radius)
            target.y = math.random(target.radius, love.graphics.getHeight() - target.radius)
        end
    elseif button == eMouseStates.eLeftButton and gameState == eGameStates.eGameStates_Ready then
        gameState = eGameStates.eGameStates_Playing
        timer = 10
        score = 0
    end
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
eGameStates = {
    MENU = 1,
    PLAY = 2,
}

function love.load()
    math.randomseed(os.time())

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 175

    myFont = love.graphics.newFont(40)

    zombies = {}

    bullets = {}

    gameState = eGameStates.MENU
    maxTime = 2
    enemyResponeTimer = maxTime

    score = 0
end

-- update는 frame마다 호출됨.
-- fps가 하락하면 update 호출 횟수도 줄어듦.
-- frame이 바뀌어도 동일한 정도로 움직이게 만들어야 함.
-- 핵심 : if frame rate drop, should be compensate for it.
-- case 1. 60fps -> 30fps
-- update 호출이 덜 일어나지만 dt가 늘어났으므로 dt를 곱하여 compensate.
-- case 2. 60fps -> 120fps
-- update 호출이 더 자주 일어나지만 dt가 줄어들었으므로 dt를 곱하면 compensate됨.

function love.update(dt)
    if (gameState == eGameStates.PLAY) then
        -- love.keypressed는 한 번 누를 때마다 한 번씩
        -- keyboard.isDown을 체크하는 방식은 한 번 누르고 있으면 주루루룩 호출됨.
        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            if (player.x > love.graphics.getWidth()) then
                player.x = love.graphics.getWidth()
            else
                player.x = player.x + player.speed * dt
            end
        end
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            if (player.x < 0) then
                player.x = 0
            else
                player.x = player.x - player.speed * dt
            end
        end
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            if (player.y < 0) then
                player.y = 0
            else
                player.y = player.y - player.speed * dt
            end
        end
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            if (player.y > love.graphics.getHeight()) then
                player.y = love.graphics.getHeight()
            else
                player.y = player.y + player.speed * dt
            end
        end
    end

    -- 매 frame마다 플레이어를 향해 이동하도록 함.
    -- unit circle에서 x, y 좌표는 (cos, sin)으로 표현됨.
    for i, z in ipairs(zombies) do
        z.x = z.x + math.cos(zombiePlayerRadAngle(z)) * z.speed * dt
        z.y = z.y + math.sin(zombiePlayerRadAngle(z)) * z.speed * dt

        -- collision detection
        if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
            for i, z in ipairs(zombies) do
                zombies[i] = nil
                gameState = eGameStates.MENU
            end
        end
    end

    for i, b in ipairs(bullets) do
        b.x = b.x + math.cos(b.direction) * b.speed * dt
        b.y = b.y + math.sin(b.direction) * b.speed * dt
    end

    -- remove bullets
    -- #table return count of table
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.y < 0
            or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
            -- 앞에서부터 remove하면 index가 교란됨. 뒤에서부터 지워야 함.
            table.remove(bullets, i)
        end
    end

    for i, z in ipairs(zombies) do
        for j, b in ipairs(bullets) do
            if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
                z.dead = true
                b.dead = true
                score = score + 1
            end
        end
    end

    for i = #zombies, 1, -1 do
        local z = zombies[i]
        if z.dead == true then
            table.remove(zombies, i)
        end
    end

    for j = #bullets, 1, -1 do
        local b = bullets[j]
        if b.dead == true then
            table.remove(bullets, j)
        end
    end

    if gameState == eGameStates.PLAY then
        enemyResponeTimer = enemyResponeTimer - 1 * dt
        if enemyResponeTimer <= 0 then
            spawnZombie()
            -- respone 타임이 점차 줄어들되 0이 되지는 않게.
            maxTime = 0.95 * maxTime
            enemyResponeTimer = maxTime
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

    if gameState == eGameStates.MENU then
        love.graphics.setFont(myFont)
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    end

    love.graphics.printf("score : " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")

    -- https://love2d.org/wiki/love.graphics.draw
    love.graphics.draw(sprites.player, player.x, player.y, playerMouseRadAngle(), nil, nil, sprites.player:getWidth() / 2,
        sprites.player:getHeight() / 2)

    for i, z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie,
            z.x, z.y,
            zombiePlayerRadAngle(z),
            nil, nil,
            sprites.zombie:getWidth() / 2,
            sprites.zombie:getHeight() / 2)
    end

    for i, b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet,
            b.x, b.y,
            nil,
            0.5, 0.5,
            sprites.bullet:getWidth() / 2,
            sprites.bullet:getHeight() / 2)
    end
end

function degToRadian(num)
    return num * math.pi / 180
end

function playerMouseRadAngle()
    -- player(source)의 rot을 mouse(target)를 바라보게 하라.
    -- math.atan2(target.y - source.y, target.x - source.x)
    ---@diagnostic disable-next-line: deprecated
    return math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
end

function zombiePlayerRadAngle(enemy)
    ---@diagnostic disable-next-line: deprecated
    return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function spawnZombie()
    local zombie = {}

    zombie.x = 0
    zombie.y = 0
    zombie.speed = 75
    zombie.dead = false

    local side = math.random(1, 4)
    -- left
    if side == 1 then
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
        -- right
    elseif side == 2 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
        -- top
    elseif side == 3 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
        -- bottom
    elseif side == 4 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end

    table.insert(zombies, zombie)
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.dead = false
    bullet.direction = playerMouseRadAngle()

    table.insert(bullets, bullet)
end

function love.keypressed(key)
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and gameState == eGameStates.PLAY then
        spawnBullet()
    elseif button == 1 and gameState == eGameStates.MENU then
        gameState = eGameStates.PLAY

        player.x = love.graphics.getWidth() / 2
        player.y = love.graphics.getHeight() / 2
        score = 0

        -- reset respone timer
        maxTime = 2
        enemyResponeTimer = maxTime
    end
end

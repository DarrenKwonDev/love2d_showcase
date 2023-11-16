function love.load()
    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 175

    zombies = {}

    bullets = {}
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
    -- love.keypressed는 한 번 누를 때마다 한 번씩
    -- keyboard.isDown을 체크하는 방식은 한 번 누르고 있으면 주루루룩 호출됨.
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        player.y = player.y + player.speed * dt
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
            end
        end
    end

    for i, b in ipairs(bullets) do
        b.x = b.x + math.cos(b.direction) * b.speed * dt
        b.y = b.y + math.sin(b.direction) * b.speed * dt
    end
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

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
    zombie.x = math.random(0, love.graphics.getWidth());
    zombie.y = math.random(0, love.graphics.getHeight());
    zombie.speed = 75;

    table.insert(zombies, zombie)
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.direction = playerMouseRadAngle()

    table.insert(bullets, bullet)
end

function love.keypressed(key)
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        spawnBullet()
    end
end

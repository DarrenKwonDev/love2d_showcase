function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)

    OffsetFromCenterX = 25
    EyeBallRadius = 75
    IrisRadius = 37.5

    EyeCenter = {
        leftEyeX = love.graphics.getWidth() / 2 - OffsetFromCenterX - EyeBallRadius,
        rightEyeX = love.graphics.getWidth() / 2 + OffsetFromCenterX + EyeBallRadius,
        y = love.graphics.getHeight() / 2
    }
end

function love.update(dt)
end

function love.draw()
    -- draw eyeball
    love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
    love.graphics.circle("fill",
        EyeCenter.leftEyeX,
        EyeCenter.y,
        EyeBallRadius)
    love.graphics.circle("fill",
        EyeCenter.rightEyeX,
        EyeCenter.y,
        EyeBallRadius)

    -- draw iris
    love.graphics.setColor(love.math.colorFromBytes(255, 0, 0))

    -- 각도
    -- eye가 mouse를 보게
    leftIrisAngle = math.atan2(love.mouse.getY() - EyeCenter.y, love.mouse.getX() - EyeCenter.leftEyeX)
    rightIrisAngle = math.atan2(love.mouse.getY() - EyeCenter.y, love.mouse.getX() - EyeCenter.rightEyeX)

    -- 특정 각도를 향해 x, y를 움직이되 그 비율은 동공의 반지름에서 아이리스의 반지름을 뺀 값까지만.
    love.graphics.circle("fill",
        EyeCenter.leftEyeX + math.cos(leftIrisAngle) * (EyeBallRadius - IrisRadius),
        EyeCenter.y + math.sin(leftIrisAngle) * (EyeBallRadius - IrisRadius),
        IrisRadius)

    love.graphics.circle("fill",
        EyeCenter.rightEyeX + math.cos(rightIrisAngle) * (EyeBallRadius - IrisRadius),
        EyeCenter.y + math.sin(rightIrisAngle) * (EyeBallRadius - IrisRadius),
        IrisRadius)

    -- dev console
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(table.concat({
        "mouse x : " .. love.mouse.getX(),
        "mouse y : " .. love.mouse.getY(),
        "distance left eyeball center .. cursor" ..
        distance(EyeCenter.leftEyeX, EyeCenter.y, love.mouse.getX(), love.mouse.getY()),
        "rad left eyeball center .. cursor" ..
        math.atan2(love.mouse.getY() - EyeCenter.y, love.mouse.getX() - EyeCenter.leftEyeX),

    }))
end

function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function radSouceToTarget(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

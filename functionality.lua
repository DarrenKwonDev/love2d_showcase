function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function playerMouseRadAngle()
    -- player가 mouse를 바라보게
    ---@diagnostic disable-next-line: deprecated
    return math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
end

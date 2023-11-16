---@diagnostic disable: undefined-global
function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)

    WindowWidth = love.graphics.getWidth()
    WindowHeight = love.graphics.getHeight()

    love.mouse.setVisible(false)
end

function love.update(dt)
    CircleX = love.mouse.getX()
    CircleY = love.mouse.getY()
end

function love.draw()
    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("fill", CircleX, CircleY, 20)

    love.graphics.setColor(255, 255, 255)
    love.graphics.print(table.concat({
        "cursor x : " .. love.mouse.getX(),
        "cursor y : " .. love.mouse.getY(),
    }, '\n'))
end

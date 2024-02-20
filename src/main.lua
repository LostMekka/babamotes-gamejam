require "math"

require("images")
require("worlds")

function love.load()
    setupTestWorld()
end

function love.draw()
    -- bg tiles
    love.graphics.setColor(1, 1, 1)
    for i = math.floor((scroll_x) / 128), math.ceil((scroll_x + 800) / 128) do
        for j = math.floor((scroll_y) / 128), math.ceil((scroll_y + 600) / 128) do
            drawimage("sprites/floor-tile.png", i * 128 - scroll_x, j * 128 - scroll_y)
        end
    end

    for _, obj in pairs(objects) do
        if obj.alive then
            love.graphics.setColor(obj.debugColor)
            local x, y = obj.collider:getPosition()
            local r = obj.radius or 12
            love.graphics.circle("fill", x - scroll_x, y - scroll_y, r, r)
            if obj.draw then obj:draw() end
        end
    end

    love.graphics.print(string.format("player hp: %d", player.hp), 5, 5)
end

function love.update()
    if love.keyboard.isScancodeDown("escape") then
        love.event.quit()
    end

    local dt = love.timer.getDelta()
    for _, obj in pairs(objects) do
        if obj.alive and obj.update then
            obj:update(dt)
        end
    end

    if player.collider:enter("playerTrigger") then
        player.hp = player.hp + 10
    end

    world:update(dt)
    scroll_x = player.collider:getX() - 400
    scroll_y = player.collider:getY() - 300
end

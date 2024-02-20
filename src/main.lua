require "math"

require("images")
require("worlds")
require("viewport")

function love.load()
    createHubWorld()
end

function love.draw()
    -- WORLD
    worldViewport:use(function()
        -- bg tiles
        love.graphics.setColor(1, 1, 1)
        local vpx, vpy, vpw, vph = worldViewport:getWorldViewportRect()
        for i = math.floor(vpx / 128), math.ceil((vpx + vpw) / 128) do
            for j = math.floor(vpy / 128), math.ceil((vpy + vph) / 128) do
                drawimage("sprites/floor-tile.png", i * 128, j * 128)
            end
        end
        -- game entities
        for _, obj in pairs(objects) do
            if obj.alive then
                love.graphics.setColor(obj.debugColor)
                local x, y = obj.collider:getPosition()
                local r = obj.radius or 12
                love.graphics.circle("fill", x, y, r, r)
                if obj.draw then obj:draw() end
            end
        end
    end)

    -- GUI
    screenViewport:use(function()
        love.graphics.print(string.format("player hp: %d", player.hp), 5, 5)
    end)
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
    if customWorldUpdate then
        customWorldUpdate(dt)
    else
        worldViewport:setTargetPosition(player.collider:getPosition())
    end
    worldViewport:update(dt)
    screenViewport:update(dt)
end
